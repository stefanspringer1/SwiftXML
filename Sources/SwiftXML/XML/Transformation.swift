//
//  Transformation.swift
//
//  Created 2022 by Stefan Springer, https://stefanspringer.com
//  License: Apache License 2.0

import Foundation

public typealias XElementAction = (XElement)->()

public typealias XAttributeAction = (XAttributeSpot)->()

public struct XRule {
    
    public let names: [String]
    public let action: Any
    
    public init(forElement names: [String], action: @escaping XElementAction) {
        self.names = names
        self.action = action
    }
    
    public init(forAttribute names: [String], action: @escaping XAttributeAction) {
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
                        XBidirectionalAttributeIterator(attributeIterator: XAttributesOfSameNameIterator(document: document, attributeName: name, keepLast: true), keepLast: true),
                        attributeAction
                    ))
                }
            }
            
        }
        
        var working = true
        while working {
            working = false
            iteratorsWithActions.forEach { (_iterator,_action) in
                if let iterator = _iterator as? XElementNameIterator, let action = _action as? XElementAction {
                    while let next = iterator.next() {
                        working = true
                        action(next)
                    }
                }
                else if let iterator = _iterator as? XBidirectionalAttributeIterator, let action = _action as? XAttributeAction {
                    while let attribute = iterator.next() {
                        working = true
                        action(attribute)
                    }
                }
            }
        }
    }
}
