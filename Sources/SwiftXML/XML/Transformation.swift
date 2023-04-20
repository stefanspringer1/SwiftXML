//===--- Transformation.swift ---------------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
// and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

import Foundation

public typealias XElementAction = (XElement)->()

public typealias XAttributeAction = (XAttributeSpot)->()

public struct XRule {
    
    public let names: [String]
    public let action: Any
    
    public init(forElements names: [String], action: @escaping XElementAction) {
        self.names = names
        self.action = action
    }
    
    public init(forElements names: String..., action: @escaping XElementAction) {
        self.names = names
        self.action = action
    }
    
    public init(forAttributes names: [String], action: @escaping XAttributeAction) {
        self.names = names
        self.action = action
    }
    
    public init(forAttributes names: String..., action: @escaping XAttributeAction) {
        self.names = names
        self.action = action
    }
}

@resultBuilder
public struct XRulesBuilder {
    public static func buildBlock(_ components: XRule...) -> [XRule] {
        return components
    }
}

public class XTransformation {
    
    let rules: [XRule]
    
    public init(@XRulesBuilder builder: () -> [XRule]) {
        self.rules = builder()
    }
    
    var stopped = false
    
    public func stop() {
        stopped = true
    }
    
    public func execute(inDocument document: XDocument) {
        
        var iteratorsWithActions = [(Any,Any)]()
        
        rules.forEach { rule in
            if let elementAction = rule.action as? XElementAction {
                rule.names.forEach { name in
                    iteratorsWithActions.append((
                        XElementNameIterator(elementIterator: XElementsOfSameNameIterator(document: document, name: name, keepLast: true), keepLast: true),
                        elementAction
                    ))
                }
            }
            else if let attributeAction = rule.action as? XAttributeAction {
                rule.names.forEach { name in
                    iteratorsWithActions.append((
                        XBidirectionalAttributeIterator(forAttributeName: name, attributeIterator: XAttributesOfSameNameIterator(document: document, attributeName: name, keepLast: true), keepLast: true),
                        attributeAction
                    ))
                }
            }
            
        }
        
        var working = true; stopped = false
        while !stopped && working {
            working = false
            iteratorsWithActions.forEach { (_iterator,_action) in
                if !stopped, let iterator = _iterator as? XElementNameIterator, let action = _action as? XElementAction {
                    while !stopped, let next = iterator.next() {
                        working = true
                        action(next)
                    }
                }
                else if !stopped, let iterator = _iterator as? XBidirectionalAttributeIterator, let action = _action as? XAttributeAction {
                    while !stopped, let attribute = iterator.next() {
                        working = true
                        action(attribute)
                    }
                }
            }
        }
    }
}
