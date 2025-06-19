//===--- Production.swift -------------------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
// and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

import Foundation

public let X_DEFAULT_INDENTATION = "  "
public let X_DEFAULT_LINEBREAK = "\n"

/**
 The formatter has two changes over the XFormatter:
 - It writes to the file directly, no need to build complicated strings.
 - It uses the nodes of the XML tree directly.
 */

public protocol Writer {
    func write(_ text: String) throws
}

extension FileHandle {
    func write(text: String) throws {
        try self.write(contentsOf: text.data(using: .utf8)!)
    }
}

public class FileWriter: Writer {
    
    private var _file: FileHandle = FileHandle.standardOutput

    public init(_ file: FileHandle) {
        self._file = file
    }
    
    open func write(_ text: String) throws {
        try _file.write(text: text)
    }
}

public class CollectingWriter: Writer, CustomStringConvertible {
    
    public init() {}
    
    private var texts = [String]()
    
    public var description: String { get { texts.joined() } }
    
    public func write(_ text: String) {
        texts.append(text)
    }
}

public protocol XProductionTemplate {
    func activeProduction(for writer: Writer, withStartElement startElement: XElement?) -> XActiveProduction
}

public protocol XActiveProduction {
    
    func write(_ text: String) throws
    
    func sortDeclarationsInInternalSubset(document: XDocument) -> [XDeclarationInInternalSubset]
    
    func writeDocumentStart(document: XDocument) throws
    
    func writeXMLDeclaration(version: String, encoding: String?, standalone: String?) throws
    
    func writeDocumentTypeDeclarationBeforeInternalSubset(type: String, publicID: String?, systemID: String?, hasInternalSubset: Bool) throws
    
    func writeDocumentTypeDeclarationInternalSubsetStart() throws
    
    func writeDocumentTypeDeclarationInternalSubsetEnd() throws
    
    func writeDocumentTypeDeclarationAfterInternalSubset(hasInternalSubset: Bool) throws
    
    func writeElementStartBeforeAttributes(element: XElement) throws
    
    func sortAttributeNames(attributeNames: [String], element: XElement) -> [String]
    
    func writeAttributeValue(name: String, value: String, element: XElement) throws
    
    func writeAttribute(name: String, value: String, element: XElement) throws
    
    func writeElementStartAfterAttributes(element: XElement) throws
    
    func writeElementEnd(element: XElement) throws
    
    func writeText(text: XText) throws
    
    func writeLiteral(literal: XLiteral) throws
    
    func writeCDATASection(cdataSection: XCDATASection) throws
    
    func writeProcessingInstruction(processingInstruction: XProcessingInstruction) throws
    
    func writeComment(comment: XComment) throws
    
    func writeInternalEntityDeclaration(internalEntityDeclaration: XInternalEntityDeclaration) throws
    
    func writeExternalEntityDeclaration(externalEntityDeclaration: XExternalEntityDeclaration) throws
    
    func writeUnparsedEntityDeclaration(unparsedEntityDeclaration: XUnparsedEntityDeclaration) throws
    
    func writeNotationDeclaration(notationDeclaration: XNotationDeclaration) throws
    
    func writeParameterEntityDeclaration(parameterEntityDeclaration: XParameterEntityDeclaration) throws
    
    func writeInternalEntity(internalEntity: XInternalEntity) throws
    
    func writeExternalEntity(externalEntity: XExternalEntity) throws
    
    func writeElementDeclaration(elementDeclaration: XElementDeclaration) throws
    
    func writeAttributeListDeclaration(attributeListDeclaration: XAttributeListDeclaration) throws

    func writeDocumentEnd(document: XDocument) throws
}

public class DefaultProductionTemplate: XProductionTemplate {
    
    public let writeEmptyTags: Bool
    public let linebreak: String
    public let escapeGreaterThan: Bool
    public let escapeAllInText: Bool
    public let escapeAll: Bool
    public let prefixTranslations: [String:String]?
    
    public init(
        writeEmptyTags: Bool = true,
        escapeGreaterThan: Bool = false,
        escapeAllInText: Bool = false,
        escapeAll: Bool = false,
        linebreak: String = X_DEFAULT_LINEBREAK,
        prefixTranslations: [String:String]? = nil
    ) {
        self.writeEmptyTags = writeEmptyTags
        self.linebreak = linebreak
        self.escapeGreaterThan = escapeGreaterThan
        self.escapeAllInText = escapeAllInText
        self.escapeAll = escapeAll
        self.prefixTranslations = prefixTranslations
    }
    
    public func activeProduction(for writer: Writer, withStartElement startElement: XElement?) -> XActiveProduction {
        ActiveDefaultProduction(
            withStartElement: startElement,
            writer: writer,
            writeEmptyTags: writeEmptyTags,
            escapeGreaterThan: escapeGreaterThan,
            escapeAllInText: escapeAllInText,
            escapeAll: escapeAll,
            linebreak: linebreak,
            prefixTranslations: prefixTranslations
        )
    }
    
}

open class ActiveDefaultProduction: XActiveProduction {
    
    private var writer: Writer
    
    public func write(_ text: String) throws {
        try writer.write(text)
    }
    
    let escapeGreaterThan: Bool
    let escapeAllInText: Bool
    let escapeAll: Bool
    private let writeEmptyTags: Bool
    
    private let _linebreak: String
    
    public var linebreak: String {
        get { _linebreak }
    }
    
    let startElement: XElement?
    
    public let prefixTranslations: [String:String]?
    
    public init(
        withStartElement startElement: XElement?,
        writer: Writer,
        writeEmptyTags: Bool = true,
        escapeGreaterThan: Bool = false,
        escapeAllInText: Bool = false,
        escapeAll: Bool = false,
        linebreak: String = X_DEFAULT_LINEBREAK,
        prefixTranslations: [String:String]?
    ) {
        self.startElement = startElement
        self.writer = writer
        self.writeEmptyTags = writeEmptyTags
        self.escapeGreaterThan = escapeGreaterThan
        self.escapeAllInText = escapeAllInText
        self.escapeAll = escapeAll
        self._linebreak = linebreak
        self.prefixTranslations = prefixTranslations
    }
    
    private var _declarationInInternalSubsetIndentation = " "
    
    public var declarationInInternalSubsetIndentation: String {
            set {
                _declarationInInternalSubsetIndentation = newValue
            }
            get {
                return _declarationInInternalSubsetIndentation
            }
        }
    
    open func sortDeclarationsInInternalSubset(document: XDocument) -> [XDeclarationInInternalSubset] {
        var sorted = [XDeclarationInInternalSubset]()
        for declarations in [
            sortByName(document.internalEntityDeclarations),
            sortByName(document.externalEntityDeclarations),
            sortByName(document.notationDeclarations),
            sortByName(document.unparsedEntityDeclarations),
            sortByName(document.elementDeclarations),
            sortByName(document.attributeListDeclarations),
            sortByName(document.parameterEntityDeclarations)
        ] {
            for declaration in declarations {
                sorted.append(declaration)
            }
        }
        return sorted
    }
    
    open func writeDocumentStart(document: XDocument) throws {
    }
    
    public static func defaultXMLDeclaration(version: String, encoding: String?, standalone: String?, linebreak: String) -> String? {
        if version != "1.0" || encoding != nil || standalone != nil {
            "<?xml version=\"\(version)\"\(encoding != nil ? " encoding=\"\(encoding ?? "?")\"" : "")\(standalone != nil ? " standalone=\"\(standalone ?? "?")\"" : "")?>\(linebreak)"
        } else {
            nil
        }
    }
    
    open func writeXMLDeclaration(version: String, encoding: String?, standalone: String?) throws {
        if let defaultXMLDeclaration = Self.defaultXMLDeclaration(version: version, encoding: encoding, standalone: standalone, linebreak: linebreak) {
            try write(defaultXMLDeclaration)
        }
    }
    
    open func writeDocumentTypeDeclarationBeforeInternalSubset(type: String, publicID: String?, systemID: String?, hasInternalSubset: Bool) throws {
        if publicID != nil || systemID != nil || hasInternalSubset {
            try write("<!DOCTYPE \(type)\(publicID != nil ? " PUBLIC \"\(publicID ?? "")\"" : "")\(systemID != nil ? "\(publicID == nil ? " SYSTEM" : "") \"\(systemID ?? "")\"" : "")")
            if !hasInternalSubset {
                try write(">\(linebreak)")
            }
        }
    }
    
    open func writeDocumentTypeDeclarationInternalSubsetStart() throws {
        try write("\(linebreak)[\(linebreak)")
    }
    
    open func writeDocumentTypeDeclarationInternalSubsetEnd() throws {
        try write("]")
    }
    
    open func writeDocumentTypeDeclarationAfterInternalSubset(hasInternalSubset: Bool) throws {
        if hasInternalSubset {
            try write(">\(linebreak)")
        }
    }
    
    open func writeElementStartBeforeAttributes(element: XElement) throws {
        if let prefix = element.prefix {
            if let prefixTranslations, let translatedPrefix = prefixTranslations[prefix] {
                if translatedPrefix.isEmpty {
                    try write("<\(element.name)")
                } else {
                    try write("<\(translatedPrefix):\(element.name)")
                }
            } else {
                try write("<\(prefix):\(element.name)")
            }
        } else {
            try write("<\(element.name)")
        }
    }
    
    open func sortAttributeNames(attributeNames: [String], element: XElement) -> [String] {
        return attributeNames
    }
    
    open func writeAttributeValue(name: String, value: String, element: XElement) throws {
        try write(
            (
                escapeAll ? value.escapingAllForXML :
                (escapeGreaterThan ? value.escapingDoubleQuotedValueForXML.replacingOccurrences(of: ">", with: "&gt;") : value.escapingDoubleQuotedValueForXML)
            )
                .replacingOccurrences(of: "\n", with: "&#x0A;").replacingOccurrences(of: "\r", with: "&#x0D;")
        )
    }
    
    open func writeAttribute(name: String, value: String, element: XElement) throws {
        try write(" \(name)=\"")
        try writeAttributeValue(name: name, value: value, element: element)
        try write("\"")
    }
    
    open func writeAsEmptyTagIfEmpty(element: XElement) -> Bool {
        return writeEmptyTags
    }
    
    open func writeElementStartAfterAttributes(element: XElement) throws {
        if element === startElement, let document = element.document, !document._prefixToNamespaceURI.isEmpty {
            for (prefix, uri) in document._prefixToNamespaceURI.sorted(by: < ) {
                let attributeName: String
                if let prefixTranslations, let translatedPrefix = prefixTranslations[prefix] {
                    if translatedPrefix.isEmpty {
                        attributeName = "xmlns"
                    } else {
                        attributeName = "xmlns:\(translatedPrefix)"
                    }
                } else {
                    attributeName = "xmlns:\(prefix)"
                }
                try write(" \(attributeName)=\"")
                try writeAttributeValue(name: attributeName, value: uri, element: element)
                try write("\"")
            }
        }
        if element.isEmpty && writeAsEmptyTagIfEmpty(element: element) {
            try write("/>")
        }
        else {
            try write(">")
        }
    }
    
    open func writeElementEnd(element: XElement) throws {
        if !(element.isEmpty && writeAsEmptyTagIfEmpty(element: element)) {
            if let prefix = element.prefix {
                if let prefixTranslations, let translatedPrefix = prefixTranslations[prefix] {
                    if translatedPrefix.isEmpty {
                        try write("</\(element.name)>")
                    } else {
                        try write("</\(translatedPrefix):\(element.name)>")
                    }
                } else {
                    try write("</\(prefix):\(element.name)>")
                }
            } else {
                try write("</\(element.name)>")
            }
        }
    }
    
    open func writeText(text: XText) throws {
        try write(
            escapeAll || escapeAllInText ? text.value.escapingAllForXML :
                (escapeGreaterThan ? text.value.escapingForXML.replacingOccurrences(of: ">", with: "&gt;") : text.value.escapingForXML)
        )
    }
    
    open func writeLiteral(literal: XLiteral) throws {
        try write(literal._value)
    }
    
    open func writeCDATASection(cdataSection: XCDATASection) throws {
        try write("<![CDATA[\(cdataSection._value)]]>")
    }
    
    open func writeProcessingInstruction(processingInstruction: XProcessingInstruction) throws {
        try write("<?\(processingInstruction._target)\(processingInstruction._data != nil ? " \(processingInstruction._data ?? "")" : "")?>")
    }
    
    open func writeComment(comment: XComment) throws {
        try write("<!--\(comment._value.avoidingDoubleHyphens)-->")
    }
    
    open func writeInternalEntityDeclaration(internalEntityDeclaration: XInternalEntityDeclaration) throws {
        try write("\(declarationInInternalSubsetIndentation)<!ENTITY \(internalEntityDeclaration._name) \"\(internalEntityDeclaration._value.escapingDoubleQuotedValueForXML)\">\(linebreak)")
    }
    
    open func writeExternalEntityDeclaration(externalEntityDeclaration: XExternalEntityDeclaration) throws {
        try write("\(declarationInInternalSubsetIndentation)<!ENTITY \(externalEntityDeclaration._name)\(externalEntityDeclaration._publicID != nil ? " PUBLIC \"\(externalEntityDeclaration._publicID ?? "")\"" : " SYSTEM") \"\(externalEntityDeclaration._systemID)\">\(linebreak)")
    }
    
    open func writeUnparsedEntityDeclaration(unparsedEntityDeclaration: XUnparsedEntityDeclaration) throws {
        try write("\(declarationInInternalSubsetIndentation)<!ENTITY \(unparsedEntityDeclaration._name)\(unparsedEntityDeclaration._publicID != nil ? " PUBLIC \"\(unparsedEntityDeclaration._publicID ?? "")\"" : " SYSTEM") \"\(unparsedEntityDeclaration._systemID)\" NDATA \(unparsedEntityDeclaration._notationName)>\(linebreak)")
    }
    
    open func writeNotationDeclaration(notationDeclaration: XNotationDeclaration) throws {
        try write("\(declarationInInternalSubsetIndentation)<!NOTATION \(notationDeclaration._name)\(notationDeclaration._publicID != nil ? " PUBLIC \"\(notationDeclaration._publicID ?? "")\"" : "")\(notationDeclaration._systemID != nil ? "\(notationDeclaration._publicID == nil ? " SYSTEM" : "") \"\(notationDeclaration._systemID ?? "")\"" : "")\(linebreak)>")
    }
    
    open func writeParameterEntityDeclaration(parameterEntityDeclaration: XParameterEntityDeclaration) throws {
        try write("\(declarationInInternalSubsetIndentation)<!ENTITY % \(parameterEntityDeclaration._name) \"\(parameterEntityDeclaration._value.escapingDoubleQuotedValueForXML)\"\(linebreak)>")
    }
    
    open func writeInternalEntity(internalEntity: XInternalEntity) throws {
        try write("&\(internalEntity._name);")
    }
    
    open func writeExternalEntity(externalEntity: XExternalEntity) throws {
        try write("&\(externalEntity._name);")
    }
    
    open func writeElementDeclaration(elementDeclaration: XElementDeclaration) throws {
        try write("\(declarationInInternalSubsetIndentation)\(elementDeclaration._literal)\(linebreak)")
    }
    
    open func writeAttributeListDeclaration(attributeListDeclaration: XAttributeListDeclaration) throws {
        try write("\(declarationInInternalSubsetIndentation)\(attributeListDeclaration._literal)\(linebreak)")
    }
    
    open func writeDocumentEnd(document: XDocument) throws {
        
    }
}

public class PrettyPrintProductionTemplate: XProductionTemplate {
    
    public let writeEmptyTags: Bool
    public let indentation: String
    public let linebreak: String
    public let prefixTranslations: [String:String]?
    
    public init(
        writeEmptyTags: Bool = true,
        indentation: String = X_DEFAULT_INDENTATION,
        linebreak: String = X_DEFAULT_LINEBREAK,
        prefixTranslations: [String:String]? = nil
    ) {
        self.writeEmptyTags = writeEmptyTags
        self.indentation = indentation
        self.linebreak = linebreak
        self.prefixTranslations = prefixTranslations
    }
    
    public func activeProduction(for writer: Writer, withStartElement startElement: XElement?) -> XActiveProduction {
        ActivePrettyPrintProduction(
            withStartElement: startElement,
            writer: writer,
            writeEmptyTags: writeEmptyTags,
            indentation: indentation,
            linebreak: linebreak,
            prefixTranslations: prefixTranslations
        )
    }
    
}

open class ActivePrettyPrintProduction: ActiveDefaultProduction {
    
    private var indentation: String
    
    public init(
        withStartElement startElement: XElement?,
        writer: Writer,
        writeEmptyTags: Bool = true,
        indentation: String = X_DEFAULT_INDENTATION,
        escapeGreaterThan: Bool = false,
        escapeAllInText: Bool = false,
        escapeAll: Bool = false,
        linebreak: String = X_DEFAULT_LINEBREAK,
        prefixTranslations: [String:String]?
    ) {
        self.indentation = indentation
        super.init(
            withStartElement: startElement,
            writer: writer,
            writeEmptyTags: writeEmptyTags,
            escapeGreaterThan: escapeGreaterThan,
            escapeAllInText: escapeAllInText,
            escapeAll: escapeAll,
            linebreak: linebreak,
            prefixTranslations: prefixTranslations
        )
    }
    
    private var indentationLevel = 0
    
    private var mixed = [Bool]()
    
    open func mightHaveMixedContent(element: XElement) -> Bool {
        return element.content.contains(where: { $0 is XText || $0 is XInternalEntity || $0 is XInternalEntity })
    }
    
    /// This can be used to suppress the "pretty print" before an element.
    public var suppressPrettyPrintBeforeElement = false
    public var forcePrettyPrintAtElement = false
    
    open override func writeElementStartBeforeAttributes(element: XElement) throws {
        if forcePrettyPrintAtElement { mixed.append(false) }
        if forcePrettyPrintAtElement || (suppressPrettyPrintBeforeElement == false && mixed.last != true) {
            if indentationLevel > 0 {
                try write(linebreak)
                for _ in 1...indentationLevel {
                    try write(indentation)
                }
            }
        }
        try super.writeElementStartBeforeAttributes(element: element)
    }
    
    open override func writeElementStartAfterAttributes(element: XElement) throws {
        try super.writeElementStartAfterAttributes(element: element)
        if !element.isEmpty {
            mixed.append(mixed.last == true || mightHaveMixedContent(element: element))
            indentationLevel += 1
        }
    }
    
    open override func writeElementEnd(element: XElement) throws {
        if !element.isEmpty {
            indentationLevel -= 1
            if forcePrettyPrintAtElement || mixed.last != true {
                try write(linebreak)
                if indentationLevel > 0 {
                    for _ in 1...indentationLevel {
                        try write(indentation)
                    }
                }
            }
            mixed.removeLast()
        }
        if forcePrettyPrintAtElement { mixed.removeLast() }
        try super.writeElementEnd(element: element)
    }
}

public class HTMLProductionTemplate: XProductionTemplate {
    
    public let indentation: String
    public let linebreak: String
    public let htmlNamespaceReference: NamespaceReference?
    public let suppressDocumentTypeDeclaration: Bool
    public let writeAsASCII: Bool
    public let escapeGreaterThan: Bool
    public let escapeAllInText: Bool
    public let escapeAll: Bool
    public let suppressUncessaryPrettyPrintAtAnchors: Bool
    public let prefixTranslations: [String:String]?
    
    public init(
        indentation: String = X_DEFAULT_INDENTATION,
        linebreak: String = X_DEFAULT_LINEBREAK,
        withHTMLNamespaceReference htmlNamespaceReference: NamespaceReference? = nil,
        suppressDocumentTypeDeclaration: Bool = false,
        writeAsASCII: Bool = false,
        escapeGreaterThan: Bool = false,
        escapeAllInText: Bool = false,
        escapeAll: Bool = false,
        suppressUncessaryPrettyPrintAtAnchors: Bool = false,
        prefixTranslations: [String:String]? = nil
    ) {
        self.indentation = indentation
        self.linebreak = linebreak
        self.htmlNamespaceReference = htmlNamespaceReference
        self.suppressDocumentTypeDeclaration = suppressDocumentTypeDeclaration
        self.writeAsASCII = writeAsASCII
        self.escapeGreaterThan = escapeGreaterThan
        self.escapeAllInText = escapeAllInText
        self.escapeAll = escapeAll
        self.suppressUncessaryPrettyPrintAtAnchors = suppressUncessaryPrettyPrintAtAnchors
        self.prefixTranslations = prefixTranslations
    }
    
    open func activeProduction(for writer: Writer, withStartElement startElement: XElement?) -> XActiveProduction {
        ActiveHTMLProduction(
            withStartElement: startElement,
            writer: writer,
            indentation: indentation,
            linebreak: linebreak,
            withHTMLNamespaceReference: htmlNamespaceReference,
            suppressDocumentTypeDeclaration: suppressDocumentTypeDeclaration,
            writeAsASCII: writeAsASCII,
            escapeGreaterThan: escapeGreaterThan,
            escapeAllInText: escapeAllInText,
            escapeAll: escapeAll,
            suppressUncessaryPrettyPrintAtAnchors: suppressUncessaryPrettyPrintAtAnchors,
            prefixTranslations: prefixTranslations
        )
    }
    
}

open class ActiveHTMLProduction: ActivePrettyPrintProduction {

    public var htmlEmptyTags: [String]
    public var htmlStrictBlocks: [String]
    public var htmlStrictInlines: [String]
    public var blockOrInline: [String]
    public var suppressDocumentTypeDeclaration: Bool
    public let fullHTMLPrefix: String
    public let writeAsASCII: Bool
    public let suppressUncessaryPrettyPrintAtAnchors: Bool
    
    public init(
        withStartElement startElement: XElement?,
        writer: Writer,
        indentation: String = X_DEFAULT_INDENTATION,
        linebreak: String = X_DEFAULT_LINEBREAK,
        withHTMLNamespaceReference htmlNamespaceReference: NamespaceReference?,
        suppressDocumentTypeDeclaration: Bool = false,
        writeAsASCII: Bool = false,
        escapeGreaterThan: Bool = false,
        escapeAllInText: Bool = false,
        escapeAll: Bool = false,
        suppressUncessaryPrettyPrintAtAnchors: Bool = false,
        prefixTranslations: [String:String]?
    ) {
        if let htmlNamespaceReference {
            switch htmlNamespaceReference {
            case .uri(let uri):
                fullHTMLPrefix = startElement?.document?.prefix(forNamespaceURI: uri)?.appending(":") ?? ""
            case .prefix(let prefix):
                fullHTMLPrefix = prefix.appending(":")
            }
        } else {
            fullHTMLPrefix = ""
        }
        htmlEmptyTags = [
            "\(fullHTMLPrefix)area",
            "\(fullHTMLPrefix)base",
            "\(fullHTMLPrefix)br",
            "\(fullHTMLPrefix)col",
            "\(fullHTMLPrefix)embed",
            "\(fullHTMLPrefix)hr",
            "\(fullHTMLPrefix)img",
            "\(fullHTMLPrefix)input",
            "\(fullHTMLPrefix)link",
            "\(fullHTMLPrefix)meta",
            "\(fullHTMLPrefix)param",
            "\(fullHTMLPrefix)source",
            "\(fullHTMLPrefix)track",
            "\(fullHTMLPrefix)wbr",
        ]
        htmlStrictBlocks = [
            "\(fullHTMLPrefix)div",
            "\(fullHTMLPrefix)p",
            "\(fullHTMLPrefix)table",
            "\(fullHTMLPrefix)thead",
            "\(fullHTMLPrefix)tbody",
            "\(fullHTMLPrefix)tfoot",
            "\(fullHTMLPrefix)tr",
            "\(fullHTMLPrefix)th",
            "\(fullHTMLPrefix)td",
        ]
        htmlStrictInlines = [
            "\(fullHTMLPrefix)abbr",
            "\(fullHTMLPrefix)acronym",
            "\(fullHTMLPrefix)b",
            "\(fullHTMLPrefix)bdo",
            "\(fullHTMLPrefix)big",
            "\(fullHTMLPrefix)br",
            "\(fullHTMLPrefix)cite",
            "\(fullHTMLPrefix)code",
            "\(fullHTMLPrefix)dfn",
            "\(fullHTMLPrefix)em",
            "\(fullHTMLPrefix)i",
            "\(fullHTMLPrefix)input",
            "\(fullHTMLPrefix)kbd",
            "\(fullHTMLPrefix)output",
            "\(fullHTMLPrefix)q",
            "\(fullHTMLPrefix)samp",
            "\(fullHTMLPrefix)small",
            "\(fullHTMLPrefix)span",
            "\(fullHTMLPrefix)strong",
            "\(fullHTMLPrefix)sub",
            "\(fullHTMLPrefix)sup",
            "\(fullHTMLPrefix)time",
            "\(fullHTMLPrefix)var",
        ]
        blockOrInline = [
            "\(fullHTMLPrefix)a",
            "\(fullHTMLPrefix)img",
        ]
        self.suppressDocumentTypeDeclaration = suppressDocumentTypeDeclaration
        self.writeAsASCII = writeAsASCII
        self.suppressUncessaryPrettyPrintAtAnchors = suppressUncessaryPrettyPrintAtAnchors
        super.init(
            withStartElement: startElement,
            writer: writer,
            writeEmptyTags: false,
            indentation: indentation,
            escapeGreaterThan: escapeGreaterThan,
            escapeAllInText: escapeAllInText,
            escapeAll: escapeAll,
            linebreak: linebreak,
            prefixTranslations: prefixTranslations
        )
    }
    
    open override func writeXMLDeclaration(version: String, encoding: String?, standalone: String?) throws {
        // do not write the XML declaration for HTML
    }
    
    open override func writeDocumentTypeDeclarationBeforeInternalSubset(type: String, publicID: String?, systemID: String?, hasInternalSubset: Bool) throws {
        if !suppressDocumentTypeDeclaration {
            try write("<!DOCTYPE html")
        }
    }
    
    override open func writeDocumentTypeDeclarationAfterInternalSubset(hasInternalSubset: Bool) throws {
        if !suppressDocumentTypeDeclaration {
            try write(">\(linebreak)")
        }
    }
    
    open override func writeAsEmptyTagIfEmpty(element: XElement) -> Bool {
        return htmlEmptyTags.contains(element.name)
    }
    
    private func isStrictlyInline(_ node: XNode?) -> Bool {
        guard let node else { return false }
        return node is XText || {
            if let element = node as? XElement {
                return htmlStrictInlines.contains(element.name)
            }
            else {
                return false
            }
        }()
    }
    
    private func isStrictlyBlock(_ node: XNode?) -> Bool {
        guard let node else { return false }
        if let element = node as? XElement {
            return htmlStrictBlocks.contains(element.name)
        }
        else {
            return false
        }
    }
    
    open override func mightHaveMixedContent(element: XElement) -> Bool {
        return element.children({ !self.blockOrInline.contains($0.name) }).absent || element.content.contains(where: { isStrictlyInline($0) })
    }
    
    open func sort(texts: [String], preferring preferred: String) -> [String] {
        return texts.sorted { name1, name2 in
            if name2 == preferred {
                return false
            }
            else {
                return name1 == preferred || name1 < name2
            }
        }
    }
    
    open override func writeElementStartBeforeAttributes(element: XElement) throws {
        let oldSuppressPrettyPrintBeforeElement = suppressPrettyPrintBeforeElement
        let oldForcePrettyPrintAtElement = forcePrettyPrintAtElement
        suppressPrettyPrintBeforeElement = isStrictlyInline(element) || (
            suppressUncessaryPrettyPrintAtAnchors && element.name == "a"
            && !isStrictlyBlock(element.previousTouching)
        )
        forcePrettyPrintAtElement = htmlStrictBlocks.contains(element.name)
        try super.writeElementStartBeforeAttributes(element: element)
        suppressPrettyPrintBeforeElement = oldSuppressPrettyPrintBeforeElement
        forcePrettyPrintAtElement = oldForcePrettyPrintAtElement
    }
    
    open override func writeElementEnd(element: XElement) throws {
        let oldForcePrettyPrintAtElement = forcePrettyPrintAtElement
        forcePrettyPrintAtElement = (element.lastContent as? XElement)?.fullfills{ htmlStrictBlocks.contains($0.name) } == true
        try super.writeElementEnd(element: element)
        forcePrettyPrintAtElement = oldForcePrettyPrintAtElement
    }
    
    open override func sortAttributeNames(attributeNames: [String], element: XElement) -> [String] {
        if element.name == "meta" {
            return sort(texts: attributeNames, preferring: "name")
        }
        else if element.name == "script" {
            return sort(texts: attributeNames, preferring: "src")
        }
        else {
            return super.sortAttributeNames(attributeNames: attributeNames, element: element)
        }
    }
    
    open override func writeText(text: XText) throws {
        var result = (escapeAll || escapeAllInText) ? text._value.escapingAllForXML : text._value.escapingForXML
        if escapeGreaterThan {
            result = result.replacingOccurrences(of: ">", with: "&gt;")
        }
        if writeAsASCII {
            result = result.asciiWithXMLCharacterReferences
        }
        try write(result)
    }
    
    open override func writeAttributeValue(name: String, value: String, element: XElement) throws {
        var result = (
                escapeAll ? value.escapingAllForXML :
                (escapeGreaterThan ? value.escapingDoubleQuotedValueForXML.replacingOccurrences(of: ">", with: "&gt;") : value.escapingDoubleQuotedValueForXML)
            )
                .replacingOccurrences(of: "\n", with: "&#x0A;").replacingOccurrences(of: "\r", with: "&#x0D;")
        if writeAsASCII {
            result = result.asciiWithXMLCharacterReferences
        }
        try write(result)
    }
    
}

fileprivate extension String {
    
    var asciiWithXMLCharacterReferences: String {
        var texts = [String]()
        for scalar in self.unicodeScalars {
            if scalar.value < 127 {
                texts.append(String(scalar))
            } else {
                texts.append("&#x\(String(format: "%04x", scalar.value));")
            }
        }
        return texts.joined()
    }
    
}
