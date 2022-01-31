//
//  File.swift
//
//
//  Created by Stefan Springer on 26.09.21.
//

import Foundation

/**
 The formatter has two changes over the XFormatter:
 - It writes to the file directly, no need to build complicated strings.
 - It uses the nodes of the XML tree directly.
 */

public protocol XProduction {
    
    func setFile(_ file: FileHandle)
    
    func getFile() -> FileHandle
    
    func write(_ text: String)
    
    func sortDeclarationsInInternalSubset(document: XDocument) -> [XDeclarationInInternalSubset]
    
    func writeDocumentStart(document: XDocument)
    
    func writeXMLDeclaration(version: String, encoding: String?, standalone: String?)
    
    func writeDocumentTypeDeclarationBeforeInternalSubset(type: String, publicID: String?, systemID: String?, hasInternalSubset: Bool)
    
    func writeDocumentTypeDeclarationInternalSubsetStart()
    
    func writeDocumentTypeDeclarationInternalSubsetEnd()
    
    func writeDocumentTypeDeclarationAfterInternalSubset(hasInternalSubset: Bool)
    
    func writeElementStartBeforeAttributes(element: XElement)
    
    func sortAttributeNames(attributeNames: [String], element: XElement) -> [String]
    
    func writeAttributeValue(name: String, value: String, element: XElement)
    
    func writeAttribute(name: String, value: String, element: XElement)
    
    func writeElementStartAfterAttributes(element: XElement)
    
    func writeElementEnd(element: XElement)
    
    func writeText(text: XText)
    
    func writeCDATASection(cdataSection: XCDATASection)
    
    func writeProcessingInstruction(processingInstruction: XProcessingInstruction)
    
    func writeComment(comment: XComment)
    
    func writeInternalEntityDeclaration(internalEntityDeclaration: XInternalEntityDeclaration)
    
    func writeExternalEntityDeclaration(externalEntityDeclaration: XExternalEntityDeclaration)
    
    func writeUnparsedEntityDeclaration(unparsedEntityDeclaration: XUnparsedEntityDeclaration)
    
    func writeNotationDeclaration(notationDeclaration: XNotationDeclaration)
    
    func writeParameterEntityDeclaration(parameterEntityDeclaration: XParameterEntityDeclaration)
    
    func writeInternalEntity(internalEntity: XInternalEntity)
    
    func writeExternalEntity(externalEntity: XExternalEntity)
    
    func writeElementDeclaration(elementDeclaration: XElementDeclaration)
    
    func writeAttributeListDeclaration(attributeListDeclaration: XAttributeListDeclaration)

    func writeDocumentEnd(document: XDocument)
}

open class XDefaultProduction: XProduction {
    
    public init() {
        
    }
    
    private var _file: FileHandle = FileHandle.standardOutput

    open func setFile(_ file: FileHandle) {
        self._file = file
    }
    
    open func getFile() -> FileHandle {
        return _file
    }
    
    open func write(_ text: String) {
        _file.write(text.data(using: .utf8)!)
    }
    
    private var _linebreak = "\n"
    
    public var linebreak: String {
            set {
                _linebreak = newValue
            }
            get {
                return _linebreak
            }
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
    
    open func writeDocumentStart(document: XDocument) {
    }
    
    open func writeXMLDeclaration(version: String, encoding: String?, standalone: String?) {
        write("<?xml version=\"\(version)\"\(encoding != nil ? " encoding=\"\(encoding ?? "?")\"" : "")\(standalone != nil ? " standalone=\"\(standalone ?? "?")\"" : "")?>\(linebreak)")
    }
    
    open func writeDocumentTypeDeclarationBeforeInternalSubset(type: String, publicID: String?, systemID: String?, hasInternalSubset: Bool) {
        write("<!DOCTYPE \(type)\(publicID != nil ? " PUBLIC \"\(publicID ?? "")\"" : "")\(systemID != nil ? "\(publicID == nil ? " SYSTEM" : "") \"\(systemID ?? "")\"" : "")")
    }
    
    open func writeDocumentTypeDeclarationInternalSubsetStart() {
        write("\(linebreak)[\(linebreak)")
    }
    
    open func writeDocumentTypeDeclarationInternalSubsetEnd() {
        write("]")
    }
    
    open func writeDocumentTypeDeclarationAfterInternalSubset(hasInternalSubset: Bool) {
        write(">\(linebreak)")
    }
    
    open func writeElementStartBeforeAttributes(element: XElement) {
        write("<\(element.name)")
    }
    
    open func sortAttributeNames(attributeNames: [String], element: XElement) -> [String] {
        return attributeNames.sorted{ $0.caseInsensitiveCompare($1) == .orderedAscending }
    }
    
    open func writeAttributeValue(name: String, value: String, element: XElement) {
        write(escapeDoubleQuotedValue(value))
    }
    
    open func writeAttribute(name: String, value: String, element: XElement) {
        write(" \(name)=\"")
        writeAttributeValue(name: name, value: value, element: element)
        write("\"")
    }
    
    open func writeElementStartAfterAttributes(element: XElement) {
        if element.isEmpty {
            write("/>")
        }
        else {
            write(">")
        }
    }
    
    open func writeElementEnd(element: XElement) {
        if !element.isEmpty {
            write("</\(element.name)>")
        }
    }
    
    open func writeText(text: XText) {
        write(escapeText(text._text))
    }
    
    open func writeCDATASection(cdataSection: XCDATASection) {
        write("<![CDATA[\(cdataSection.text)]]>")
    }
    
    open func writeProcessingInstruction(processingInstruction: XProcessingInstruction) {
        write("<?\(processingInstruction._target)\(processingInstruction._data != nil ? " \(processingInstruction._data ?? "")" : "")?>")
    }
    
    open func writeComment(comment: XComment) {
        write("<!--\(comment.text)-->")
    }
    
    open func writeInternalEntityDeclaration(internalEntityDeclaration: XInternalEntityDeclaration) {
        write("\(declarationInInternalSubsetIndentation)<!ENTITY \(internalEntityDeclaration.name) \"\(escapeDoubleQuotedValue(internalEntityDeclaration.value))\">\(linebreak)")
    }
    
    open func writeExternalEntityDeclaration(externalEntityDeclaration: XExternalEntityDeclaration) {
        write("\(declarationInInternalSubsetIndentation)<!ENTITY \(externalEntityDeclaration.name)\(externalEntityDeclaration.publicID != nil ? " PUBLIC \"\(externalEntityDeclaration.publicID ?? "")\"" : " SYSTEM") \"\(externalEntityDeclaration.systemID)\">\(linebreak)")
    }
    
    open func writeUnparsedEntityDeclaration(unparsedEntityDeclaration: XUnparsedEntityDeclaration) {
        write("\(declarationInInternalSubsetIndentation)<!ENTITY \(unparsedEntityDeclaration.name)\(unparsedEntityDeclaration.publicID != nil ? " PUBLIC \"\(unparsedEntityDeclaration.publicID ?? "")\"" : " SYSTEM") \"\(unparsedEntityDeclaration.systemID)\" NDATA \(unparsedEntityDeclaration.notationName)>\(linebreak)")
    }
    
    open func writeNotationDeclaration(notationDeclaration: XNotationDeclaration) {
        write("\(declarationInInternalSubsetIndentation)<!NOTATION \(notationDeclaration.name)\(notationDeclaration.publicID != nil ? " PUBLIC \"\(notationDeclaration.publicID ?? "")\"" : "")\(notationDeclaration.systemID != nil ? "\(notationDeclaration.publicID == nil ? " SYSTEM" : "") \"\(notationDeclaration.systemID ?? "")\"" : "")\(linebreak)>")
    }
    
    open func writeParameterEntityDeclaration(parameterEntityDeclaration: XParameterEntityDeclaration) {
        write("\(declarationInInternalSubsetIndentation)<!ENTITY % \(parameterEntityDeclaration.name) \"\(escapeDoubleQuotedValue(parameterEntityDeclaration.value))\"\(linebreak)>")
    }
    
    open func writeInternalEntity(internalEntity: XInternalEntity) {
        write("&\(internalEntity.name);")
    }
    
    open func writeExternalEntity(externalEntity: XExternalEntity) {
        write("&\(externalEntity.name);")
    }
    
    open func writeElementDeclaration(elementDeclaration: XElementDeclaration) {
        write("\(declarationInInternalSubsetIndentation)\(elementDeclaration.literal)\(linebreak)")
    }
    
    open func writeAttributeListDeclaration(attributeListDeclaration: XAttributeListDeclaration) {
        write("\(declarationInInternalSubsetIndentation)\(attributeListDeclaration.literal)\(linebreak)")
    }

    open func writeDocumentEnd(document: XDocument) {
        
    }
}
