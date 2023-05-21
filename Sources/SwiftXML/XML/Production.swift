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
        if #available(macOS 10.15.4, *) {
            try self.write(contentsOf: text.data(using: .utf8)!)
        } else {
            self.write(text.data(using: .utf8)!)
        }
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
    
    private var texts = [String]()
    
    public var description: String { get { texts.joined() } }
    
    public func write(_ text: String) {
        texts.append(text)
    }
}

public protocol XProduction {
    
    func setWriter(_ writer: Writer?)
    
    func getWriter() -> Writer?
    
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

open class XDefaultProduction: XProduction {
    
    private var _writer: Writer? = nil
    
    public func setWriter(_ writer: Writer?) {
        self._writer = writer
    }
    
    public func getWriter() -> Writer? {
        return _writer
    }
    
    public func write(_ text: String) throws {
        try _writer?.write(text)
    }
    
    private let writeEmptyTags: Bool
    
    private let _linebreak: String
    
    public var linebreak: String {
        get { _linebreak }
    }
    
    public init(writeEmptyTags: Bool = true, linebreak: String = "\n") {
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
        ([
            sortByName(document.internalEntityDeclarations),
            sortByName(document.externalEntityDeclarations),
            sortByName(document.notationDeclarations),
            sortByName(document.unparsedEntityDeclarations),
            sortByName(document.elementDeclarations),
            sortByName(document.attributeListDeclarations),
            sortByName(document.parameterEntityDeclarations)
        ]).forEach { declarations in
            declarations.forEach { declaration in
                sorted.append(declaration)
            }
        }
        return sorted
    }
    
    open func writeDocumentStart(document: XDocument) throws {
    }
    
    open func writeXMLDeclaration(version: String, encoding: String?, standalone: String?) throws {
        if version != "1.0" || encoding != nil || standalone != nil {
            try write("<?xml version=\"\(version)\"\(encoding != nil ? " encoding=\"\(encoding ?? "?")\"" : "")\(standalone != nil ? " standalone=\"\(standalone ?? "?")\"" : "")?>\(linebreak)")
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
        try write(escapeDoubleQuotedValue(value))
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
        try write("<!--\(comment._value)-->")
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

open class XPrettyPrintProduction: XDefaultProduction {

    private var _indentation: String
    
    public init(writeEmptyTags: Bool = true, indentation: String = "  ", linebreak: String = "\n") {
        self._indentation = indentation
        super.init(writeEmptyTags: writeEmptyTags, linebreak: linebreak)
    }
    
    private var indentationLevel = 0
    
    private var mixed = [Bool]()
    
    open func hasMixedContent(element: XElement) -> Bool {
        return element.content.contains(where: { $0 is XText })
    }
    
    open override func writeElementStartBeforeAttributes(element: XElement) throws {
        if mixed.last != true {
            if indentationLevel > 0 {
                try write(linebreak)
                for _ in 1...indentationLevel {
                    try write(_indentation)
                }
            }
        }
        try super.writeElementStartBeforeAttributes(element: element)
    }
    
    open override func writeElementStartAfterAttributes(element: XElement) throws {
        try super.writeElementStartAfterAttributes(element: element)
        if !element.isEmpty {
            mixed.append(mixed.last == true || hasMixedContent(element: element))
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
                        try write(_indentation)
                    }
                }
            }
            mixed.removeLast()
        }
        try super.writeElementEnd(element: element)
    }
}

open class XHTMLProduction: XPrettyPrintProduction {

    public init(indentation: String = "  ", linebreak: String = "\n") {
        super.init(writeEmptyTags: false, indentation: indentation, linebreak: linebreak)
    }
    
    open override func writeXMLDeclaration(version: String, encoding: String?, standalone: String?) {
        // do not write the XML declaration for HTML
    }
    
    open override func writeDocumentTypeDeclarationBeforeInternalSubset(type: String, publicID: String?, systemID: String?, hasInternalSubset: Bool) throws {
        try write("<!DOCTYPE html")
    }
    
    override open func writeDocumentTypeDeclarationAfterInternalSubset(hasInternalSubset: Bool) throws {
        try write(">\(linebreak)")
    }

    public var htmlEmptyTags = [
        "area", "base", "br", "col", "embed", "hr", "img", "input",
        "link", "meta", "param", "source", "track", "wbr"
    ]
    
    open override func writeAsEmptyTagIfEmpty(element: XElement) -> Bool {
        return htmlEmptyTags.contains(element.name)
    }
    
    public var htmlStrictInlines = [
        "a", "abbr", "acronym", "b", "bdo", "big", "br", "cite", "code", "dfn", "em", "i",
        "kbd", "output", "q", "samp", "small", "span", "strong", "sub",
        "sup", "time", "var"
    ]
    
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
    
    open override func hasMixedContent(element: XElement) -> Bool {
        return element.content.contains(where: { isInline($0) })
    }
    
    public func sort(texts: [String], preferring preferred: String) -> [String] {
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
}
