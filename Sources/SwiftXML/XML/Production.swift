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
    func activeProduction(for writer: Writer, atNode node: XNode) -> XActiveProduction
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
    
    public init(writeEmptyTags: Bool = true, linebreak: String = X_DEFAULT_LINEBREAK) {
        self.writeEmptyTags = writeEmptyTags
        self.linebreak = linebreak
    }
    
    public func activeProduction(for writer: Writer, atNode node: XNode) -> XActiveProduction {
        ActiveDefaultProduction(writer: writer, writeEmptyTags: writeEmptyTags, linebreak: linebreak)
    }
    
}

open class ActiveDefaultProduction: XActiveProduction {
    
    private var writer: Writer
    
    public func write(_ text: String) throws {
        try writer.write(text)
    }
    
    private let writeEmptyTags: Bool
    
    private let _linebreak: String
    
    public var linebreak: String {
        get { _linebreak }
    }
    
    public init(writer: Writer, writeEmptyTags: Bool = true, linebreak: String = X_DEFAULT_LINEBREAK) {
        self.writer = writer
        self.writeEmptyTags = writeEmptyTags
        self._linebreak = linebreak
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
        try write("<\(element.name)")
    }
    
    open func sortAttributeNames(attributeNames: [String], element: XElement) -> [String] {
        return attributeNames
    }
    
    open func writeAttributeValue(name: String, value: String, element: XElement) throws {
        try write(escapeDoubleQuotedValue(value).replacingOccurrences(of: "\n", with: "&#x0A;").replacingOccurrences(of: "\r", with: "&#x0D;"))
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
        if element.isEmpty && writeAsEmptyTagIfEmpty(element: element) {
            try write("/>")
        }
        else {
            try write(">")
        }
    }
    
    open func writeElementEnd(element: XElement) throws {
        if !(element.isEmpty && writeAsEmptyTagIfEmpty(element: element)) {
            try write("</\(element.name)>")
        }
    }
    
    open func writeText(text: XText) throws {
        try write(escapeText(text._value))
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
        try write("\(declarationInInternalSubsetIndentation)<!ENTITY \(internalEntityDeclaration._name) \"\(escapeDoubleQuotedValue(internalEntityDeclaration._value))\">\(linebreak)")
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
        try write("\(declarationInInternalSubsetIndentation)<!ENTITY % \(parameterEntityDeclaration._name) \"\(escapeDoubleQuotedValue(parameterEntityDeclaration._value))\"\(linebreak)>")
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
    
    public init(writeEmptyTags: Bool = true, indentation: String = X_DEFAULT_INDENTATION, linebreak: String = X_DEFAULT_LINEBREAK) {
        self.writeEmptyTags = writeEmptyTags
        self.indentation = indentation
        self.linebreak = linebreak
    }
    
    public func activeProduction(for writer: Writer, atNode node: XNode) -> XActiveProduction {
        ActivePrettyPrintProduction(writer: writer, writeEmptyTags: writeEmptyTags, indentation: indentation, linebreak: linebreak)
    }
    
}

open class ActivePrettyPrintProduction: ActiveDefaultProduction {
    
    private var indentation: String
    
    public init(writer: Writer, writeEmptyTags: Bool = true, indentation: String = X_DEFAULT_INDENTATION, linebreak: String = X_DEFAULT_LINEBREAK) {
        self.indentation = indentation
        super.init(writer: writer, writeEmptyTags: writeEmptyTags, linebreak: linebreak)
    }
    
    private var indentationLevel = 0
    
    private var mixed = [Bool]()
    
    open func mightHaveMixedContent(element: XElement) -> Bool {
        return element.content.contains(where: { $0 is XText || $0 is XInternalEntity || $0 is XInternalEntity })
    }
    
    open override func writeElementStartBeforeAttributes(element: XElement) throws {
        if mixed.last != true {
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
            if mixed.last != true {
                try write(linebreak)
                if indentationLevel > 0 {
                    for _ in 1...indentationLevel {
                        try write(indentation)
                    }
                }
            }
            mixed.removeLast()
        }
        try super.writeElementEnd(element: element)
    }
}

public class HTMLProductionTemplate: XProductionTemplate {
    
    public let indentation: String
    public let linebreak: String
    public let htmlNamespaceReference: NamespaceReference
    public let suppressDocumentTypeDeclaration: Bool
    public let writeAsASCII: Bool
    public let escapeGreaterThan: Bool
    
    public init(
        indentation: String = X_DEFAULT_INDENTATION,
        linebreak: String = X_DEFAULT_LINEBREAK,
        withHTMLNamespaceReference htmlNamespaceReference: NamespaceReference = .fullPrefix(""),
        suppressDocumentTypeDeclaration: Bool = false,
        writeAsASCII: Bool = false,
        escapeGreaterThan: Bool = false
    ) {
        self.indentation = indentation
        self.linebreak = linebreak
        self.htmlNamespaceReference = htmlNamespaceReference
        self.suppressDocumentTypeDeclaration = suppressDocumentTypeDeclaration
        self.writeAsASCII = writeAsASCII
        self.escapeGreaterThan = escapeGreaterThan
    }
    
    open func activeProduction(for writer: Writer, atNode node: XNode) -> XActiveProduction {
        ActiveHTMLProduction(
            writer: writer,
            linebreak: linebreak,
            atNode: node,
            withHTMLNamespaceReference: htmlNamespaceReference,
            suppressDocumentTypeDeclaration: suppressDocumentTypeDeclaration,
            writeAsASCII: writeAsASCII,
            escapeGreaterThan: escapeGreaterThan
        )
    }
    
}

open class ActiveHTMLProduction: ActivePrettyPrintProduction {

    public var htmlEmptyTags: [String]
    public var htmlStrictInlines: [String]
    public var suppressDocumentTypeDeclaration: Bool
    public let fullHTMLPrefix: String
    public let writeAsASCII: Bool
    public let escapeGreaterThan: Bool
    
    public init(
        writer: Writer,
        indentation: String = X_DEFAULT_INDENTATION,
        linebreak: String = X_DEFAULT_LINEBREAK,
        atNode node: XNode,
        withHTMLNamespaceReference htmlNamespaceReference: NamespaceReference,
        suppressDocumentTypeDeclaration: Bool,
        writeAsASCII: Bool,
        escapeGreaterThan: Bool
    ) {
        fullHTMLPrefix = ((node as? XDocument ?? node.top) as XBranch?)?.fullPrefix(forNamespaceReference: htmlNamespaceReference) ?? ""
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
            "\(fullHTMLPrefix)wbr"
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
            "\(fullHTMLPrefix)var"
        ]
        self.suppressDocumentTypeDeclaration = suppressDocumentTypeDeclaration
        self.writeAsASCII = writeAsASCII
        self.escapeGreaterThan = escapeGreaterThan
        super.init(writer: writer, writeEmptyTags: false, indentation: indentation, linebreak: linebreak)
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
    
    private func isInline(_ node: XNode) -> Bool {
        return node is XText || {
            if let element = node as? XElement {
                return htmlStrictInlines.contains(element.name)
            }
            else {
                return false
            }
        }()
    }
    
    open override func mightHaveMixedContent(element: XElement) -> Bool {
        return element.content.contains(where: { isInline($0) })
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
        var result = escapeText(text._value).replacingOccurrences(of: "\n", with: "&#x0A;").replacingOccurrences(of: "\r", with: "&#x0D;")
        if escapeGreaterThan {
            result = result.replacingOccurrences(of: ">", with: "&gt;")
        }
        if writeAsASCII {
            result = result.asciiWithXMLCharacterReferences
        }
        try write(result)
    }
    
    open override func writeAttributeValue(name: String, value: String, element: XElement) throws {
        var result = escapeDoubleQuotedValue(value).replacingOccurrences(of: "\n", with: "&#x0A;").replacingOccurrences(of: "\r", with: "&#x0D;")
        if escapeGreaterThan {
            result = result.replacingOccurrences(of: ">", with: "&gt;")
        }
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
