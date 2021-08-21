//
//  XMLBuilder.swift
//
//  Created 2021 by Stefan Springer, https://stefanspringer.com
//  License: Apache License 2.0

import Foundation
import SwiftXMLInterfaces

class XMLBuilder: SwiftXMLInterfaces.DefaultXMLEventHandler {

    let document: XMLDocument
    var currentBranch: XMLBranch
    
    init(
        document: inout XMLDocument,
        currentBranch: XMLBranch? = nil
    ) {
        self.document = document
        self.currentBranch = currentBranch ?? document
    }
    
    public override func documentStart() {
    }
    
    public override func xmlDeclaration(version: String, encoding: String?, standalone: String?) {
        document.xmlVersion = version
        if let theEncoding = encoding {
            document.encoding = theEncoding
        }
        if let theStandalone = standalone {
            document.standalone = theStandalone
        }
    }
    
    public override func documentTypeDeclaration(type: String, publicID: String?, systemID: String?) {
        document.type = type
        document.publicID = publicID
        document.systemID = systemID
    }
    
    public override func elementStart(name: String, attributes: inout [String:String], combineTexts: Bool) {
        let element = XMLElement(name: name);
        currentBranch.add(element)
        element.setAttributes(attributes: attributes)
        currentBranch = element
    }
    
    public override func elementEnd(name: String) {
        if let parent = currentBranch.parent {
            currentBranch = parent
        }
        else {
            currentBranch = document
        }
    }
    
    public override func text(text: String, isWhitespace: Bool) {
        currentBranch.add(XMLText(text))
    }
    
    public override func cdataSection(text: String) {
        currentBranch.add(XMLCDATASection(text: text))
    }
    
    public override func internalEntity(name: String) {
        currentBranch.add(XMLInternalEntity(name))
    }
    
    public override func externalEntity(name: String) {
        currentBranch.add(XMLExternalEntity(name))
    }
    
    public override func processingInstruction(target: String, content: String?) {
        currentBranch.add(XMLProcessingInstruction(target: target, content: content))
    }
    
    public override func comment(text: String) {
        currentBranch.add(XMLComment(text: text))
    }
    
    public override func internalEntityDeclaration(name: String, value: String) {
        let decl = XMLInternalEntityDeclaration(name: name, value: value)
        document.internalEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public override func externalEntityDeclaration(name: String, publicID: String?, systemID: String) {
        let decl = XMLExternalEntityDeclaration(name: name, publicID: publicID, systemID: systemID)
        document.externalEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public override func unparsedEntityDeclaration(name: String, publicID: String?, systemID: String, notation: String) {
        let decl = XMLUnparsedEntityDeclaration(name: name, publicID: publicID, systemID: systemID, notationName: notation)
        document.unparsedEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public override func notationDeclaration(name: String, publicID: String?, systemID: String?) {
        let decl = XMLNotationDeclaration(name: name, publicID: publicID, systemID: systemID)
        document.notationDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public override func elementDeclaration(name: String, text: String) {
        let decl = XMLElementDeclaration(name: name, text: text)
        document.elementDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public override func attributeListDeclaration(name: String, text: String) {
        let decl = XMLAttributeListDeclaration(name: name, text: text)
        document.attributeListDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public override func parameterEntityDeclaration(name: String, value: String) {
        let decl = XMLParameterEntityDeclaration(name: name, value: value)
        document.parameterEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public override func documentEnd() {
    }
}
