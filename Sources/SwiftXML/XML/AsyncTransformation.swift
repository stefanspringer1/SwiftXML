//
//  Transformation.swift
//
//  Created 2022 by Stefan Springer, https://stefanspringer.com
//  License: Apache License 2.0

import Foundation

public typealias XAsyncElementAction = (XElement) async -> ()

public typealias XAsyncAttributeAction = (XAttributeSpot) async -> ()

public struct XAsyncRule {
    
    public let names: [String]
    public let action: Any
    
    public init(forElements names: [String], action: @escaping XAsyncElementAction) {
        self.names = names
        self.action = action
    }
    
    public init(forAttributes names: [String], action: @escaping XAsyncAttributeAction) {
        self.names = names
        self.action = action
    }
}

@resultBuilder
public struct XAsyncRulesBuilder {
    public static func buildBlock(_ components: XAsyncRule...) -> [XAsyncRule] {
        return components
    }
}

public class XAsyncTransformation {
    
    let rules: [XAsyncRule]
    
    public init(@XAsyncRulesBuilder builder: () -> [XAsyncRule]) {
        self.rules = builder()
    }
    
    var stopped = false
    
    public func stop() {
        stopped = true
    }
    
    public func execute(inDocument document: XDocument) async {
        
        var iteratorsWithActions = [(Any,Any)]()
        
        rules.forEach { rule in
            if let elementAction = rule.action as? XAsyncElementAction {
                rule.names.forEach { name in
                    iteratorsWithActions.append((
                        XElementNameIterator(elementIterator: XElementsOfSameNameIterator(document: document, name: name, keepLast: true), keepLast: true),
                        elementAction
                    ))
                }
            }
            else if let attributeAction = rule.action as? XAsyncAttributeAction {
                rule.names.forEach { name in
                    iteratorsWithActions.append((
                        XBidirectionalAttributeIterator(attributeIterator: XAttributesOfSameNameIterator(document: document, attributeName: name, keepLast: true), keepLast: true),
                        attributeAction
                    ))
                }
            }
            
        }
        
        var working = true; stopped = false
        while !stopped && working {
            working = false
            await iteratorsWithActions.forEachAsync { (_iterator,_action) in
                if !stopped, let iterator = _iterator as? XElementNameIterator, let action = _action as? XAsyncElementAction {
                    while !stopped, let next = iterator.next() {
                        working = true
                        await action(next)
                    }
                }
                else if !stopped, let iterator = _iterator as? XBidirectionalAttributeIterator, let action = _action as? XAsyncAttributeAction {
                    while !stopped, let attribute = iterator.next() {
                        working = true
                        await action(attribute)
                    }
                }
            }
        }
    }
}
