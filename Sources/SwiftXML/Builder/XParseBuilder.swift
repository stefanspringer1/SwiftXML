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
    
    public func xmlDeclaration(version: String, encoding: String?, standalone: String?) {
        document.xmlVersion = version
        if let theEncoding = encoding {
            document.encoding = theEncoding
        }
        if let theStandalone = standalone {
            document.standalone = theStandalone
        }
    }
    
    public func documentTypeDeclaration(type: String, publicID: String?, systemID: String?) {
        document.type = type
        document.publicID = publicID
        document.systemID = systemID
    }
    
    public func elementStart(name: String, attributes: [String:String]?) {
        let element = XElement(name)
        currentBranch.add(element)
        element.setAttributes(attributes: attributes)
        currentBranch = element
    }
    
    public func elementEnd(name: String) {
        if let parent = currentBranch._parent {
            currentBranch = parent
        }
        else {
            currentBranch = document
        }
    }
    
    public func text(text: String, whitespace: WhitespaceIndicator) {
        currentBranch.add(XText(text, whitespace: whitespace))
    }
    
    public func cdataSection(text: String) {
        currentBranch.add(XCDATASection(text: text))
    }
    
    public func internalEntity(name: String) {
        currentBranch.add(XInternalEntity(name))
    }
    
    public func externalEntity(name: String) {
        currentBranch.add(XExternalEntity(name))
    }
    
    public func processingInstruction(target: String, data: String?) {
        currentBranch.add(XProcessingInstruction(target: target, data: data))
    }
    
    public func comment(text: String) {
        currentBranch.add(XComment(text: text))
    }
    
    public func internalEntityDeclaration(name: String, value: String) {
        let decl = XInternalEntityDeclaration(name: name, value: value)
        document.internalEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func externalEntityDeclaration(name: String, publicID: String?, systemID: String) {
        let decl = XExternalEntityDeclaration(name: name, publicID: publicID, systemID: systemID)
        document.externalEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func unparsedEntityDeclaration(name: String, publicID: String?, systemID: String, notation: String) {
        let decl = XUnparsedEntityDeclaration(name: name, publicID: publicID, systemID: systemID, notationName: notation)
        document.unparsedEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func notationDeclaration(name: String, publicID: String?, systemID: String?) {
        let decl = XNotationDeclaration(name: name, publicID: publicID, systemID: systemID)
        document.notationDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func elementDeclaration(name: String, literal: String) {
        let decl = XElementDeclaration(name: name, literal: literal)
        document.elementDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func attributeListDeclaration(name: String, literal: String) {
        let decl = XAttributeListDeclaration(name: name, literal: literal)
        document.attributeListDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func parameterEntityDeclaration(name: String, value: String) {
        let decl = XParameterEntityDeclaration(name: name, value: value)
        document.parameterEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func documentEnd() {
    }
}
