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

fileprivate func makePrefix(forName name: String, andURI uri: String) -> String {
    if !name.contains(":"), !name.isEmpty {
        name
    } else if let lastURIComponent = uri.split(separator: "/", omittingEmptySubsequences: true).last?.lowercased(),
              let prefix = lastURIComponent.split(separator: ":").last, !prefix.isEmpty {
        String(prefix)
    } else if let prefix = name.split(separator: ":").last, !prefix.isEmpty {
        String(prefix)
    } else {
        "a"
    }
}

public final class XParseBuilder: XEventHandler {
    
    public func parsingTime(seconds: Double) {
        // -
    }

    let document: XDocument
    let namespaceAware: Bool
    let silentEmptyRootPrefix: Bool
    let keepComments: Bool
    let keepCDATASections: Bool
    let externalWrapperElement: String?
    
    var currentBranch: XBranchInternal
    
    var prefixes = Set<String>()
    var prefixCorrections = [String:String]()
    var resultingNamespaceURIToPrefix = [String:String]()
    var resultingPrefixToNamespaceURI = [String:String]()
    var namespaceURIAndPrefixDuringBuild = [(String,String)]()
    var prefixFreeNSURIsCount = 0
    
    let registeringAttributes: AttributeRegisterMode
    let registeringAttributeValuesFor: AttributeRegisterMode
    let registeringAttributesForNamespaces: AttributeWithNamespaceURIRegisterMode
    let registeringAttributeValuesForForNamespaces: AttributeWithNamespaceURIRegisterMode
    
    public init(
        document: XDocument,
        namespaceAware: Bool = false,
        silentEmptyRootPrefix: Bool = false,
        keepComments: Bool = false,
        keepCDATASections: Bool = false,
        externalWrapperElement: String? = nil,
        registeringAttributes: AttributeRegisterMode = .none,
        registeringAttributeValuesFor: AttributeRegisterMode = .none,
        registeringAttributesForNamespaces: AttributeWithNamespaceURIRegisterMode = .none,
        registeringAttributeValuesForForNamespaces: AttributeWithNamespaceURIRegisterMode = .none
    ) {
        
        self.document = document
        self.namespaceAware = namespaceAware
        self.silentEmptyRootPrefix = silentEmptyRootPrefix
        self.keepComments = keepComments
        self.keepCDATASections = keepCDATASections
        self.externalWrapperElement = externalWrapperElement
        
        self.registeringAttributes = registeringAttributes
        self.registeringAttributeValuesFor = registeringAttributeValuesFor
        self.registeringAttributesForNamespaces = registeringAttributesForNamespaces
        self.registeringAttributeValuesForForNamespaces = registeringAttributeValuesForForNamespaces
        
        self.currentBranch = document
        
        document._attributeRegisterMode = registeringAttributes
        document._attributeValueRegisterMode = registeringAttributeValuesFor
    }
    
    public func documentStart() {}
    
    public func enterExternalDataSource(data: Data, entityName: String?, systemID: String, url: URL?, textRange _: XTextRange?, dataRange _: XDataRange?) {
        if let elementName = externalWrapperElement {
            var attributes = [String:String]()
            attributes["name"] = entityName
            attributes["systemID"] = systemID
            attributes["path"] = url?.path
            elementStart(
                name: elementName,
                attributes: &attributes,
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
    
    public func elementStart(name: String, attributes: inout [String:String], textRange: XTextRange?, dataRange _: XDataRange?) {
        
        let element = XElement(name)
        
        if namespaceAware {
            var namespaceDefinitionCount = 0
            
            for attributeName in attributes.keys {
                
                var uri: String? = nil
                var originalPrefix: String? = nil
                var proposedPrefix: String? = nil
                var existingPrefix: String? = nil
                
                if attributeName.hasPrefix("xmlns:") {
                    uri = attributes[attributeName]
                    existingPrefix = resultingNamespaceURIToPrefix[uri!]
                    originalPrefix = String(attributeName.dropFirst(6))
                    proposedPrefix = existingPrefix ?? originalPrefix
                } else if attributeName == "xmlns" {
                    uri = attributes[attributeName]
                    if silentEmptyRootPrefix && currentBranch is XDocument {
                        resultingNamespaceURIToPrefix[uri!] = ""
                        attributes[attributeName] = nil
                    } else {
                        existingPrefix = resultingNamespaceURIToPrefix[uri!]
                        originalPrefix = ""
                        proposedPrefix = existingPrefix ?? makePrefix(forName: name, andURI: uri!)
                        element.attached["prefixFreeNS"] = true
                        prefixFreeNSURIsCount += 1
                    }
                }
                
                if let uri, let originalPrefix, let proposedPrefix {
                    namespaceDefinitionCount += 1
                    if existingPrefix == nil {
                        var resultingPrefix = proposedPrefix
                        var avoidPrefixClashCount = 1
                        while prefixes.contains(resultingPrefix) {
                            avoidPrefixClashCount += 1
                            resultingPrefix = "\(proposedPrefix)\(avoidPrefixClashCount)"
                        }
                        resultingNamespaceURIToPrefix[uri] = resultingPrefix
                        resultingPrefixToNamespaceURI[resultingPrefix] = uri
                        prefixes.insert(resultingPrefix)
                    }
                    namespaceURIAndPrefixDuringBuild.append((uri,originalPrefix))
                    attributes[attributeName] = nil
                }
            }
            if namespaceDefinitionCount > 0 {
                element.attached["nsCount"] = namespaceDefinitionCount
            }
            
            var prefixOfElement: String? = nil
            let colon = name.firstIndex(of: ":")
            if let colon {
                prefixOfElement = String(name[..<colon])
            } else if prefixFreeNSURIsCount > 0 {
                prefixOfElement = ""
            }
            
            if let prefixOfElement {
                var i = namespaceURIAndPrefixDuringBuild.count - 1
                while i >= 0 {
                    let (uri,prefix) = namespaceURIAndPrefixDuringBuild[i]
                    if prefix == prefixOfElement {
                        element.prefix = resultingNamespaceURIToPrefix[uri]!
                        if let colon {
                            element.name = String(name[colon...].dropFirst())
                        }
                        break
                    }
                    i -= 1
                }
                if i < 0 { // no namespace found:
                    // this prefix cannot be used for namespaces ("dead prefix")!
                    if prefixes.contains(prefixOfElement) {
                        // too late, we have to correct later:
                        if prefixCorrections[prefixOfElement] == nil {
                            var avoidPrefixClashCount = 2
                            var corrected = "\(prefixOfElement)\(avoidPrefixClashCount)"
                            while prefixes.contains(corrected) {
                                avoidPrefixClashCount += 1
                                corrected = "\(prefixOfElement)\(avoidPrefixClashCount)"
                            }
                            prefixCorrections[prefixOfElement] = corrected
                            prefixes.insert(corrected)
                        }
                    } else {
                        // we just avoid this prefix:
                        prefixes.insert(prefixOfElement)
                    }
                }
            }
        }
        
        currentBranch._add(element)
        
        if namespaceAware {
            for (attributeName,attributeValue) in attributes {
                var prefixOfAttribute: String? = nil
                var attributeNameIfPrefix: String? = nil
                
                var literalPrefixOfAttribute: String? = nil
                let colon = attributeName.firstIndex(of: ":")
                if let colon {
                    literalPrefixOfAttribute = String(attributeName[..<colon])
                }
                if let literalPrefixOfAttribute {
                    var i = namespaceURIAndPrefixDuringBuild.count - 1
                    while i >= 0 {
                        let (uri,prefix) = namespaceURIAndPrefixDuringBuild[i]
                        if prefix == literalPrefixOfAttribute {
                            prefixOfAttribute = resultingNamespaceURIToPrefix[uri]!
                            attributeNameIfPrefix = String(attributeName[colon!...].dropFirst())
                            break
                        }
                        i -= 1
                    }
                    if i < 0 { // no namespace found:
                        // this prefix cannot be used for namespaces ("dead prefix")!
                        if prefixes.contains(literalPrefixOfAttribute) {
                            // too late, we have to correct later:
                            if prefixCorrections[literalPrefixOfAttribute] == nil {
                                var avoidPrefixClashCount = 2
                                var corrected = "\(literalPrefixOfAttribute)\(avoidPrefixClashCount)"
                                while prefixes.contains(corrected) {
                                    avoidPrefixClashCount += 1
                                    corrected = "\(literalPrefixOfAttribute)\(avoidPrefixClashCount)"
                                }
                                prefixCorrections[literalPrefixOfAttribute] = corrected
                                prefixes.insert(corrected)
                            }
                        } else {
                            // we just avoid this prefix:
                            prefixes.insert(literalPrefixOfAttribute)
                        }
                    }
                }
                
                if let prefixOfAttribute {
                    let attributeNameIfPrefix = attributeNameIfPrefix!
                    element[prefixOfAttribute,attributeNameIfPrefix] = attributeValue
                    
                    do {
                        let registerUsingNamespaceURIsAndName = switch registeringAttributesForNamespaces {
                        case .none:
                            false
                        case .selected(let selection):
                            selection.contains(where: { $0.namespaceURI == resultingPrefixToNamespaceURI[prefixOfAttribute] && $0.name == attributeNameIfPrefix})
                        case .all:
                            true
                        }
                        if registerUsingNamespaceURIsAndName {
                            let attributeProperties = AttributeProperties(value: attributeValue, element: element)
                            element._registeredAttributesWithPrefix[prefixOfAttribute,attributeNameIfPrefix] = attributeProperties
                            document.registerAttributeWithPrefix(attributeProperties: attributeProperties, withPrefix: prefixOfAttribute, withName: attributeNameIfPrefix)
                        }
                    }
                    
                    do {
                        let registerForValue = switch registeringAttributeValuesForForNamespaces {
                        case .none:
                            false
                        case .selected(let selection):
                            selection.contains(where: { $0.namespaceURI == resultingPrefixToNamespaceURI[prefixOfAttribute] && $0.name == attributeNameIfPrefix})
                        case .all:
                            true
                        }
                        if registerForValue {
                            let attributeProperties = AttributeProperties(value: attributeValue, element: element)
                            element._registeredAttributeWithPrefixValues[prefixOfAttribute,attributeNameIfPrefix] = attributeProperties
                            document.registerAttributeWithPrefixValue(attributeProperties: attributeProperties, withPrefix: prefixOfAttribute, withName: attributeNameIfPrefix)
                        }
                    }
                    
                } else {
                    element[attributeName] = attributeValue
                }
            }
        } else {
            element.setAttributes(attributes: attributes)
        }
        
        currentBranch = element
        element._sourceRange = textRange
    }
    
    public func elementEnd(name: String, textRange: XTextRange?, dataRange _: XDataRange?) {
        
        if namespaceAware, let element = currentBranch as? XElement, let namespaceDefinitionCount = element.attached["nsCount"] as? Int {
            namespaceURIAndPrefixDuringBuild.removeLast(namespaceDefinitionCount)
            element.attached["nsCount"] = nil
            if element.attached["prefixFreeNS"] as? Bool == true {
                prefixFreeNSURIsCount -= 1
                element.attached["prefixFreeNS"] = nil
            }
        }
        
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
            let node = XComment(text, withAdditionalSpace: false)
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
    
    public func documentEnd() {
        
        document._attributeWithPrefixRegisterMode =
            switch registeringAttributesForNamespaces {
            case .none:
                .none
            case .selected(let selection):
                .selected(selection.map{ PrefixedName.make(fromPrefix: resultingNamespaceURIToPrefix[$0.namespaceURI], andName: $0.name) }.compactMap{ $0 })
            case .all:
                .all
            }
        
        document._attributeWithPrefixValueRegisterMode =
            switch registeringAttributeValuesForForNamespaces {
            case .none:
                .none
            case .selected(let selection):
                    .selected(selection.map{ PrefixedName.make(fromPrefix: resultingNamespaceURIToPrefix[$0.namespaceURI], andName: $0.name) }.compactMap{ $0 })
            case .all:
                .all
            }
        
        if namespaceAware {
            if prefixCorrections.isEmpty {
                for (uri,prefix) in resultingNamespaceURIToPrefix {
                    document._namespaceURIToPrefix[uri] = prefix
                    document._prefixToNamespaceURI[prefix] = uri
                    document._prefixes.insert(prefix)
                }
            } else {
                for (uri,prefix) in resultingNamespaceURIToPrefix {
                    let correctedPrefix = prefixCorrections[prefix] ?? prefix
                    document._namespaceURIToPrefix[uri] = correctedPrefix
                    document._prefixToNamespaceURI[correctedPrefix] = uri
                    document._prefixes.insert(correctedPrefix)
                }
                for element in document.descendants {
                    if let prefix = element.prefix, let correctedPrefix = prefixCorrections[prefix] {
                        element.prefix = correctedPrefix
                        if let attributesForThisPrefix = element._attributesForPrefix.secondKeys(forLeftKey: prefix) {
                            for attributeName in attributesForThisPrefix {
                                element[correctedPrefix,attributeName] = element[prefix,attributeName]
                                element[prefix,attributeName] = nil
                            }
                        }
                    }
                }
            }
        }
    }
    
}
