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
    let keepComments: Bool
    let keepCDATASections: Bool
    
    var currentBranch: XBranchInternal
    
    public init(document: XDocument, keepComments: Bool = false, keepCDATASections: Bool = false) {
        
        self.document = document
        self.keepComments = keepComments
        self.keepCDATASections = keepCDATASections
        
        self.currentBranch = document
        
    }
    
    public func documentStart() {
        
    }
    
    public func xmlDeclaration(version: String, encoding: String?, standalone: String?, textRange _: XTextRange?, dataRange _: XDataRange?) {
        document.xmlVersion = version
        if let theEncoding = encoding {
            document.encoding = theEncoding
        }
        if let theStandalone = standalone {
            document.standalone = theStandalone
        }
    }
    
    public func documentTypeDeclarationStart(type: String, publicID: String?, systemID: String?, textRange _: XTextRange?, dataRange _: XDataRange?) {
        document.type = type
        document.publicID = publicID
        document.systemID = systemID
    }
    
    public func documentTypeDeclarationEnd(textRange _: XTextRange?, dataRange _: XDataRange?) {
        // -
    }
    
    public func elementStart(name: String, attributes: [String:String]?, textRange _: XTextRange?, dataRange _: XDataRange?) {
        let element = XElement(name)
        currentBranch.add(element)
        element.setAttributes(attributes: attributes)
        currentBranch = element
    }
    
    public func elementEnd(name: String, textRange _: XTextRange?, dataRange _: XDataRange?) {
        if let parent = currentBranch._parent {
            currentBranch = parent
        }
        else {
            currentBranch = document
        }
    }
    
    public func text(text: String, whitespace: WhitespaceIndicator, textRange _: XTextRange?, dataRange _: XDataRange?) {
        currentBranch.add(XText(text, whitespace: whitespace))
    }
    
    public func cdataSection(text: String, textRange _: XTextRange?, dataRange _: XDataRange?) {
        currentBranch.add(keepCDATASections ? XCDATASection(text: text): XText(text))
    }
    
    public func internalEntity(name: String, textRange _: XTextRange?, dataRange _: XDataRange?) {
        currentBranch.add(XInternalEntity(name))
    }
    
    public func externalEntity(name: String, textRange _: XTextRange?, dataRange _: XDataRange?) {
        currentBranch.add(XExternalEntity(name))
    }
    
    public func processingInstruction(target: String, data: String?, textRange _: XTextRange?, dataRange _: XDataRange?) {
        currentBranch.add(XProcessingInstruction(target: target, data: data))
    }
    
    public func comment(text: String, textRange _: XTextRange?, dataRange _: XDataRange?) {
        if keepComments {
            currentBranch.add(XComment(text: text))
        }
    }
    
    public func internalEntityDeclaration(name: String, value: String, textRange _: XTextRange?, dataRange _: XDataRange?) {
        let decl = XInternalEntityDeclaration(name: name, value: value)
        document.internalEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func externalEntityDeclaration(name: String, publicID: String?, systemID: String, textRange _: XTextRange?, dataRange _: XDataRange?) {
        let decl = XExternalEntityDeclaration(name: name, publicID: publicID, systemID: systemID)
        document.externalEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func unparsedEntityDeclaration(name: String, publicID: String?, systemID: String, notation: String, textRange _: XTextRange?, dataRange _: XDataRange?) {
        let decl = XUnparsedEntityDeclaration(name: name, publicID: publicID, systemID: systemID, notationName: notation)
        document.unparsedEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func notationDeclaration(name: String, publicID: String?, systemID: String?, textRange _: XTextRange?, dataRange _: XDataRange?) {
        let decl = XNotationDeclaration(name: name, publicID: publicID, systemID: systemID)
        document.notationDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func elementDeclaration(name: String, literal: String, textRange _: XTextRange?, dataRange _: XDataRange?) {
        let decl = XElementDeclaration(name: name, literal: literal)
        document.elementDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func attributeListDeclaration(name: String, literal: String, textRange _: XTextRange?, dataRange _: XDataRange?) {
        let decl = XAttributeListDeclaration(name: name, literal: literal)
        document.attributeListDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func parameterEntityDeclaration(name: String, value: String, textRange _: XTextRange?, dataRange _: XDataRange?) {
        let decl = XParameterEntityDeclaration(name: name, value: value)
        document.parameterEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func documentEnd() {
    }
}
