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

        var iteratorsWithActions = [(Any,Any)]()

        for rule in rules {
            if let elementAction = rule.action as? XElementAction {
                for name in rule.names {
                    iteratorsWithActions.append((
                        XXBidirectionalElementNameIterator(elementIterator: XElementsOfSameNameIterator(document: document, name: name, keepLast: true), keepLast: true),
                        elementAction
                    ))
                }
            }

        }

        var working = true; stopped = false
        while !stopped && working {
            working = false
            for (_iterator,_action) in iteratorsWithActions {
                if !stopped, let iterator = _iterator as? XXBidirectionalElementNameIterator, let action = _action as? XElementAction {
                    while !stopped, let next = iterator.next() {
                        working = true
                        action(next)
                    }
                }
            }
        }
    }
}
