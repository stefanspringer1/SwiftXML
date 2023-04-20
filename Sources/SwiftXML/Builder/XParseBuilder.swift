//===--- XParseBuilder.swift ----------------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
// and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

import Foundation
import SwiftXMLInterfaces

public final class XParseBuilder: XEventHandler {
    
    public func parsingTime(seconds: Double) {
        // -
    }

    let document: XDocument
    let keepComments: Bool
    let keepCDATASections: Bool
    let externalWrapperElement: String?
    
    var currentBranch: XBranchInternal
    
    public init(
        document: XDocument,
        keepComments: Bool = false,
        keepCDATASections: Bool = false,
        externalWrapperElement: String? = nil
    ) {
        
        self.document = document
        self.keepComments = keepComments
        self.keepCDATASections = keepCDATASections
        self.externalWrapperElement = externalWrapperElement
        
        self.currentBranch = document
        
    }
    
    public func documentStart() {}
    
    public func enterExternalDataSource(data: Data, entityName: String?, systemID: String, url: URL?, textRange _: XTextRange?, dataRange _: XDataRange?) {
        if let elementName = externalWrapperElement {
            elementStart(
                name: elementName,
                attributes: ["name": entityName, "sytemID":  systemID, "path": url?.path],
                textRange: nil,
                dataRange: nil
            )
        }
    }
    
    public func leaveExternalDataSource() {
        if let elementName = externalWrapperElement {
            elementEnd(name: elementName, textRange: nil, dataRange: nil)
        }
    }
    
    public func enterInternalDataSource(data: Data, entityName: String, textRange: XTextRange?, dataRange: XDataRange?) {
        // -
    }
    
    public func leaveInternalDataSource() {
        // -
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
    
    public func elementStart(name: String, attributes: [String:String?]?, textRange: XTextRange?, dataRange _: XDataRange?) {
        let element = XElement(name)
        currentBranch._add(element)
        element.setAttributes(attributes: attributes)
        currentBranch = element
        element._sourceRange = textRange
    }
    
    public func elementEnd(name: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        if let endTagTextRange = textRange, let element = currentBranch as? XElement, let startTagTextRange = element._sourceRange {
            element._sourceRange = XTextRange(
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
        node._sourceRange = textRange
        currentBranch._add(node)
    }
    
    public func cdataSection(text: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let node = keepCDATASections ? XCDATASection(text): XText(text)
        node._sourceRange = textRange
        currentBranch._add(node)
    }
    
    public func internalEntity(name: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let node = XInternalEntity(name)
        node._sourceRange = textRange
        currentBranch._add(node)
    }
    
    public func externalEntity(name: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let node = XExternalEntity(name)
        node._sourceRange = textRange
        currentBranch._add(node)
    }
    
    public func processingInstruction(target: String, data: String?, textRange: XTextRange?, dataRange _: XDataRange?) {
        let node = XProcessingInstruction(target: target, data: data)
        node._sourceRange = textRange
        currentBranch._add(node)
    }
    
    public func comment(text: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        if keepComments {
            let node = XComment(text)
            node._sourceRange = textRange
            currentBranch._add(node)
        }
    }
    
    public func internalEntityDeclaration(name: String, value: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let decl = XInternalEntityDeclaration(name: name, value: value)
        decl._sourceRange = textRange
        document.internalEntityDeclarations[name] = decl
    }
    
    public func externalEntityDeclaration(name: String, publicID: String?, systemID: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let decl = XExternalEntityDeclaration(name: name, publicID: publicID, systemID: systemID)
        decl._sourceRange = textRange
        document.externalEntityDeclarations[name] = decl
    }
    
    public func unparsedEntityDeclaration(name: String, publicID: String?, systemID: String, notation: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let decl = XUnparsedEntityDeclaration(name: name, publicID: publicID, systemID: systemID, notationName: notation)
        decl._sourceRange = textRange
        document.unparsedEntityDeclarations[name] = decl
    }
    
    public func notationDeclaration(name: String, publicID: String?, systemID: String?, textRange: XTextRange?, dataRange _: XDataRange?) {
        let decl = XNotationDeclaration(name: name, publicID: publicID, systemID: systemID)
        decl._sourceRange = textRange
        document.notationDeclarations[name] = decl
    }
    
    public func elementDeclaration(name: String, literal: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let decl = XElementDeclaration(name: name, literal: literal)
        decl._sourceRange = textRange
        document.elementDeclarations[name] = decl
    }
    
    public func attributeListDeclaration(name: String, literal: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let decl = XAttributeListDeclaration(name: name, literal: literal)
        decl._sourceRange = textRange
        document.attributeListDeclarations[name] = decl
    }
    
    public func parameterEntityDeclaration(name: String, value: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        let decl = XParameterEntityDeclaration(name: name, value: value)
        decl._sourceRange = textRange
        document.parameterEntityDeclarations[name] = decl
    }
    
    public func documentEnd() {}
    
}
