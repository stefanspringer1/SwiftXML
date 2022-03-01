//
//  File.swift
//  
//
//  Created by Stefan Springer on 01.03.22.
//

import Foundation

public typealias XRuleAction = (XElement)->()

public struct XRule {
    
    public let elementName: String
    public let action: XRuleAction
    
    public init(_ elementName: String, action: @escaping XRuleAction) {
        self.elementName = elementName
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
        
        var iteratorsWithActions = [(XElementNameIterator,XRuleAction)]()
        
        rules.forEach { rule in
            iteratorsWithActions.append((
                XElementNameIterator(elementIterator: XElementsOfSameNameIterator(document: document, name: rule.elementName, keepLast: true)),
                rule.action
            ))
        }
        
        var working = true
        while working {
            working = false
            iteratorsWithActions.forEach { (iterator,action) in
                while let element = iterator.next() {
                    working = true
                    action(element)
                }
            }
        }
    }
}
