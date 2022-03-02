//
//  Transformation.swift
//
//  Created 2022 by Stefan Springer, https://stefanspringer.com
//  License: Apache License 2.0

import Foundation

public typealias XElementAction = (XElement)->()

public typealias XAttributeAction = (String,XElement)->()

public struct XRule {
    
    public let name: String
    public let action: Any
    
    public init(forElement name: String, action: @escaping XElementAction) {
        self.name = name
        self.action = action
    }
    
    public init(forAttribute name: String, action: @escaping XAttributeAction) {
        self.name = name
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
                iteratorsWithActions.append((
                    XElementNameIterator(elementIterator: XElementsOfSameNameIterator(document: document, name: rule.name, keepLast: true), keepLast: true),
                    elementAction
                ))
            }
            else if let attributeAction = rule.action as? XAttributeAction {
                iteratorsWithActions.append((
                    XAttributeIterator(attributeIterator: XAttributesOfSameNameIterator(document: document, attributeName: rule.name, keepLast: true), keepLast: true),
                    attributeAction
                ))
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
                else if let iterator = _iterator as? XAttributeIterator, let action = _action as? XAttributeAction {
                    while let (value,element) = iterator.next() {
                        working = true
                        action(value,element)
                    }
                }
            }
        }
    }
}
