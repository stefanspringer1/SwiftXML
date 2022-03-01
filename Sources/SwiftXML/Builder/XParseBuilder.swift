//
//  XParseBuilder.swift
//
//  Created 2021 by Stefan Springer, https://stefanspringer.com
//  License: Apache License 2.0

import Foundation
import SwiftXMLInterfaces

public final class XParseBuilder: XEventHandler {
    
    public func parsingTime(seconds: Double) {
        // -
    }

    let document: XDocument
    var currentBranch: XBranch
    
    public init(
        document: XDocument,
        currentBranch: XBranch? = nil
    ) {
        self.document = document
        self.currentBranch = currentBranch ?? document
    }
    
    public func documentStart() {
        
    }
    
    public func xmlDeclaration(version: String, encoding: String?, standalone: String?, sourceRange _: SourceRange) {
        document.xmlVersion = version
        if let theEncoding = encoding {
            document.encoding = theEncoding
        }
        if let theStandalone = standalone {
            document.standalone = theStandalone
        }
    }
    
    public func documentTypeDeclarationStart(type: String, publicID: String?, systemID: String?, sourceRange _: SourceRange) {
        document.type = type
        document.publicID = publicID
        document.systemID = systemID
    }
    
    public func documentTypeDeclarationEnd(sourceRange _: SourceRange) {
        // -
    }
    
    public func elementStart(name: String, attributes: [String:String]?, sourceRange _: SourceRange) {
        let element = XElement(name)
        currentBranch.add(element)
        element.setAttributes(attributes: attributes)
        currentBranch = element
    }
    
    public func elementEnd(name: String, sourceRange _: SourceRange) {
        if let parent = currentBranch._parent {
            currentBranch = parent
        }
        else {
            currentBranch = document
        }
    }
    
    public func text(text: String, whitespace: WhitespaceIndicator, sourceRange _: SourceRange) {
        currentBranch.add(XText(text, whitespace: whitespace))
    }
    
    public func cdataSection(text: String, sourceRange _: SourceRange) {
        currentBranch.add(XCDATASection(text: text))
    }
    
    public func internalEntity(name: String, sourceRange _: SourceRange) {
        currentBranch.add(XInternalEntity(name))
    }
    
    public func externalEntity(name: String, sourceRange _: SourceRange) {
        currentBranch.add(XExternalEntity(name))
    }
    
    public func processingInstruction(target: String, data: String?, sourceRange _: SourceRange) {
        currentBranch.add(XProcessingInstruction(target: target, data: data))
    }
    
    public func comment(text: String, sourceRange _: SourceRange) {
        currentBranch.add(XComment(text: text))
    }
    
    public func internalEntityDeclaration(name: String, value: String, sourceRange _: SourceRange) {
        let decl = XInternalEntityDeclaration(name: name, value: value)
        document.internalEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func externalEntityDeclaration(name: String, publicID: String?, systemID: String, sourceRange _: SourceRange) {
        let decl = XExternalEntityDeclaration(name: name, publicID: publicID, systemID: systemID)
        document.externalEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func unparsedEntityDeclaration(name: String, publicID: String?, systemID: String, notation: String, sourceRange _: SourceRange) {
        let decl = XUnparsedEntityDeclaration(name: name, publicID: publicID, systemID: systemID, notationName: notation)
        document.unparsedEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func notationDeclaration(name: String, publicID: String?, systemID: String?, sourceRange _: SourceRange) {
        let decl = XNotationDeclaration(name: name, publicID: publicID, systemID: systemID)
        document.notationDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func elementDeclaration(name: String, literal: String, sourceRange _: SourceRange) {
        let decl = XElementDeclaration(name: name, literal: literal)
        document.elementDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func attributeListDeclaration(name: String, literal: String, sourceRange _: SourceRange) {
        let decl = XAttributeListDeclaration(name: name, literal: literal)
        document.attributeListDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func parameterEntityDeclaration(name: String, value: String, sourceRange _: SourceRange) {
        let decl = XParameterEntityDeclaration(name: name, value: value)
        document.parameterEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func documentEnd() {
    }
}
