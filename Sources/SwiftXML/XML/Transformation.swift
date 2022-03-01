//
//  File.swift
//  
//
//  Created by Stefan Springer on 01.03.22.
//

import Foundation

public typealias RuleAction = (XElement)->()

public struct Rule {
    
    public let elementName: String
    public let action: RuleAction
    
    public init(_ elementName: String, action: @escaping RuleAction) {
        self.elementName = elementName
        self.action = action
    }
}

public class Transformation {
    
    let document: XDocument
    let rules: [Rule]
    
    public init(forDocument document: XDocument, withRules rules: [Rule]) {
        self.document = document
        self.rules = rules
    }
    
    public func execute() {
        
        var iteratorsWithActions = [(XElementNameIterator,RuleAction)]()
        
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
