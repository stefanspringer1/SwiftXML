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
    
#if DEBUG
    
    public let actionFile: String
    public let actionLine: Int

    public init(forElements names: [String], file: String = #file, line: Int = #line, action: @escaping XElementAction) {
        self.names = names
        self.action = action
        self.actionFile = file
        self.actionLine = line
    }

    public init(forElements names: String..., file: String = #file, line: Int = #line, action: @escaping XElementAction) {
        self.names = names
        self.action = action
        self.actionFile = file
        self.actionLine = line
    }
    
    public init(forAttributes names: [String], file: String = #file, line: Int = #line, action: @escaping XAttributeAction) {
        self.names = names
        self.action = action
        self.actionFile = file
        self.actionLine = line
    }
    
    public init(forAttributes names: String..., file: String = #file, line: Int = #line, action: @escaping XAttributeAction) {
        self.names = names
        self.action = action
        self.actionFile = file
        self.actionLine = line
    }
    
#else
    
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
    
#endif
}

public protocol XRulesConvertible {
    func asXRules() -> [XRule]
}

extension XRule: XRulesConvertible {
    public func asXRules() -> [XRule] {
        return [self]
    }
}

extension Optional: XRulesConvertible where Wrapped == XRule {
    public func asXRules() -> [XRule] {
        switch self {
            case .some(let wrapped): return [wrapped]
            case .none: return []
        }
    }
}

extension Array: XRulesConvertible where Element == XRule {
    public func asXRules() -> [XRule] {
        return self
    }
}


@resultBuilder
public struct XRulesBuilder {
    public static func buildBlock(_ components: XRulesConvertible...) -> [XRule] {
        return components.flatMap({ $0.asXRules() })
    }

    public static func buildEither(first component: XRulesConvertible) -> [XRule] {
        return component.asXRules()
    }

    public static func buildEither(second component: XRulesConvertible) -> [XRule] {
        return component.asXRules()
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

        #if DEBUG
        struct AppliedAction { let iterator: any IteratorProtocol; let action: Any; let actionFile: String; let actionLine: Int }
        #else
        struct AppliedAction { let iterator: any IteratorProtocol; let action: Any }
        #endif
        
        var iteratorsWithAppliedActions = [AppliedAction]()

        for rule in rules {
            if let elementAction = rule.action as? XElementAction {
                for name in rule.names {
                    #if DEBUG
                    iteratorsWithAppliedActions.append(AppliedAction(
                        iterator: XXBidirectionalElementNameIterator(elementIterator: XElementsOfSameNameIterator(document: document, name: name, keepLast: true), keepLast: true),
                        action: elementAction,
                        actionFile: rule.actionFile,
                        actionLine: rule.actionLine
                    ))
                    #else
                    iteratorsWithAppliedActions.append(AppliedAction(
                        iterator: XXBidirectionalElementNameIterator(elementIterator: XElementsOfSameNameIterator(document: document, name: name, keepLast: true), keepLast: true),
                        action: elementAction
                    ))
                    #endif
                }
            } else if let attributeAction = rule.action as? XAttributeAction {
                rule.names.forEach { name in
                    #if DEBUG
                    iteratorsWithAppliedActions.append(AppliedAction(
                        iterator: XBidirectionalAttributeIterator(forAttributeName: name, attributeIterator: XAttributesOfSameNameIterator(document: document, attributeName: name, keepLast: true), keepLast: true),
                        action: attributeAction,
                        actionFile: rule.actionFile,
                        actionLine: rule.actionLine
                    ))
                    #else
                    iteratorsWithAppliedActions.append(AppliedAction(
                        iterator: XBidirectionalAttributeIterator(forAttributeName: name, attributeIterator: XAttributesOfSameNameIterator(document: document, attributeName: name, keepLast: true), keepLast: true),
                        action: attributeAction
                    ))
                    #endif
                }
            }
        }
        
        var working = true; stopped = false
        while !stopped && working {
            working = false
            actions: for appliedAction in iteratorsWithAppliedActions {
                if stopped { break actions }
                if let iterator = appliedAction.iterator as? XXBidirectionalElementNameIterator, let action = appliedAction.action as? XElementAction {
                    action: while let next = iterator.next() {
                        if stopped { break action }
                        working = true
                        action(next)
                    }
                } else if let iterator = appliedAction.iterator as? XBidirectionalAttributeIterator, let action = appliedAction.action as? XAttributeAction {
                    action: while let attribute = iterator.next() {
                        if stopped { break action }
                        working = true
                        action(attribute)
                    }
                }
            }
        }
    }
}
