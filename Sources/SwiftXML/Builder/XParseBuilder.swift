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
    
    public func elementStart(name: String, attributes: [String:String]?, textRange: XTextRange?, dataRange _: XDataRange?) {
        let element = XElement(name)
        currentBranch._add(element)
        element.setAttributes(attributes: attributes)
        currentBranch = element
        element._textRange = textRange
    }
    
    public func elementEnd(name: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        if let endTagTextRange = textRange, let element = currentBranch as? XElement, let startTagTextRange = element._textRange {
            element._textRange = XTextRange(
                startLine: startTagTextRange.startLine,
                startColumn: startTagTextRange.startColumn,
                endLine: endTagTextRange.endLine,
                endColumn: endTagTextRange.endColumn
            )
        }
        if let parent = currentBranch._parent {
            currentBranch = parent
        }
        else {
            currentBranch = document
        }
    }
    
    public func text(text: String, whitespace: WhitespaceIndicator, textRange: XTextRange?, dataRange _: XDataRange?) {
        let node = XText(text, whitespace: whitespace)
        node._textRange = textRange
        currentBranch._add(node)
    }
    
    public func cdataSection(text: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let node = keepCDATASections ? XCDATASection(text): XText(text)
        node._textRange = textRange
        currentBranch._add(node)
    }
    
    public func internalEntity(name: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let node = XInternalEntity(name)
        node._textRange = textRange
        currentBranch._add(node)
    }
    
    public func externalEntity(name: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let node = XExternalEntity(name)
        node._textRange = textRange
        currentBranch._add(node)
    }
    
    public func processingInstruction(target: String, data: String?, textRange: XTextRange?, dataRange _: XDataRange?) {
        let node = XProcessingInstruction(target: target, data: data)
        node._textRange = textRange
        currentBranch._add(node)
    }
    
    public func comment(text: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        if keepComments {
            let node = XComment(text)
            node._textRange = textRange
            currentBranch._add(node)
        }
    }
    
    public func internalEntityDeclaration(name: String, value: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let decl = XInternalEntityDeclaration(name: name, value: value)
        decl._textRange = textRange
        document.internalEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func externalEntityDeclaration(name: String, publicID: String?, systemID: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let decl = XExternalEntityDeclaration(name: name, publicID: publicID, systemID: systemID)
        decl._textRange = textRange
        document.externalEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func unparsedEntityDeclaration(name: String, publicID: String?, systemID: String, notation: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let decl = XUnparsedEntityDeclaration(name: name, publicID: publicID, systemID: systemID, notationName: notation)
        decl._textRange = textRange
        document.unparsedEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func notationDeclaration(name: String, publicID: String?, systemID: String?, textRange: XTextRange?, dataRange _: XDataRange?) {
        let decl = XNotationDeclaration(name: name, publicID: publicID, systemID: systemID)
        decl._textRange = textRange
        document.notationDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func elementDeclaration(name: String, literal: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let decl = XElementDeclaration(name: name, literal: literal)
        decl._textRange = textRange
        document.elementDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func attributeListDeclaration(name: String, literal: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let decl = XAttributeListDeclaration(name: name, literal: literal)
        decl._textRange = textRange
        document.attributeListDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func parameterEntityDeclaration(name: String, value: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let decl = XParameterEntityDeclaration(name: name, value: value)
        decl._textRange = textRange
        document.parameterEntityDeclarations[name] = decl
        document.declarationsInInternalSubset.append(decl)
    }
    
    public func documentEnd() {
    }
}
