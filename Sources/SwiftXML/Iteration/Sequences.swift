//===--- Sequences.swift --------------------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
// and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

import Foundation

public struct TypedIterator<T> {
    
    private var iterator: any IteratorProtocol
    
    public init(for sequence: any Sequence<T>) {
        self.iterator = sequence.makeIterator() as any IteratorProtocol
    }
    
    public mutating func next() -> T? {
        return iterator.next() as! T?
    }
}

// >>>>>>>>>>>>>>>>
// with conditions:

public final class XContentSequenceWithCondition: XContentSequence {
    
    let sequence: XContentSequence
    let condition: (XContent) -> Bool
    
    public init(sequence: XContentSequence, condition: @escaping (XContent) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    public override func makeIterator() -> XContentIterator {
        return XContentIteratorWithCondition(
            iterator: sequence.makeIterator(),
            condition: condition
        )
    }
}

public final class XContentSequenceWhileCondition: XContentSequence {
    
    let sequence: XContentSequence
    let condition: (XContent) -> Bool
    
    public init(sequence: XContentSequence, while condition: @escaping (XContent) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    public override func makeIterator() -> XContentIterator {
        return XContentIteratorWhileCondition(
            iterator: sequence.makeIterator(),
            while: condition
        )
    }
}

public final class XContentSequenceUntilCondition: XContentSequence {
    
    let sequence: XContentSequence
    let condition: (XContent) -> Bool
    
    public init(sequence: XContentSequence, until condition: @escaping (XContent) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    public override func makeIterator() -> XContentIterator {
        return XContentIteratorUntilCondition(
            iterator: sequence.makeIterator(),
            until: condition
        )
    }
}

public final class XContentSequenceIncludingCondition: XContentSequence {
    
    let sequence: XContentSequence
    let condition: (XContent) -> Bool
    
    public init(sequence: XContentSequence, untilAndIncluding condition: @escaping (XContent) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    public override func makeIterator() -> XContentIterator {
        return XContentIteratorIncludingCondition(
            iterator: sequence.makeIterator(),
            untilAndIncluding: condition
        )
    }
}

public final class XTextSequenceWithCondition: XTextSequence {
    
    let sequence: XTextSequence
    let condition: (XText) -> Bool
    
    public init(sequence: XTextSequence, condition: @escaping (XText) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    public override func makeIterator() -> XTextIterator {
        return XTextIteratorWithCondition(
            iterator: sequence.makeIterator(),
            condition: condition
        )
    }
}

public final class XTextSequenceWhileCondition: XTextSequence {
    
    let sequence: XTextSequence
    let condition: (XText) -> Bool
    
    public init(sequence: XTextSequence, while condition: @escaping (XText) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    public override func makeIterator() -> XTextIterator {
        return XTextIteratorWhileCondition(
            iterator: sequence.makeIterator(),
            while: condition
        )
    }
}

public final class XTextSequenceUntilCondition: XTextSequence {
    
    let sequence: XTextSequence
    let condition: (XText) -> Bool
    
    public init(sequence: XTextSequence, until condition: @escaping (XText) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    public override func makeIterator() -> XTextIterator {
        return XTextIteratorUntilCondition(
            iterator: sequence.makeIterator(),
            until: condition
        )
    }
}

public final class XTextSequenceIncludingCondition: XTextSequence {
    
    let sequence: XTextSequence
    let condition: (XText) -> Bool
    
    public init(sequence: XTextSequence, untilAndIncluding condition: @escaping (XText) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    public override func makeIterator() -> XTextIterator {
        return XTextIteratorIncludingCondition(
            iterator: sequence.makeIterator(),
            untilAndIncluding: condition
        )
    }
}

public final class XElementSequenceWithCondition: XElementSequence {
    
    let sequence: XElementSequence
    let condition: (XElement) -> Bool
    
    public init(sequence: XElementSequence, condition: @escaping (XElement) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    public init(sequence: XElementSequence, elementName: String) {
        self.sequence = sequence
        self.condition = { $0.name == elementName }
    }
    
    public override func makeIterator() -> XElementIterator {
        return XElementIteratorWithCondition(
            iterator: sequence.makeIterator(),
            condition: condition
        )
    }
}

public final class XElementSequenceWhileCondition: XElementSequence {
    
    let sequence: XElementSequence
    let condition: (XElement) -> Bool
    
    public init(sequence: XElementSequence, while condition: @escaping (XElement) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    public init(sequence: XElementSequence, elementName: String) {
        self.sequence = sequence
        self.condition = { $0.name == elementName }
    }
    
    public override func makeIterator() -> XElementIterator {
        return XElementIteratorWhileCondition(
            iterator: sequence.makeIterator(),
            while: condition
        )
    }
}

public final class XElementSequenceUntilCondition: XElementSequence {
    
    let sequence: XElementSequence
    let condition: (XElement) -> Bool
    
    public init(sequence: XElementSequence, until condition: @escaping (XElement) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    public init(sequence: XElementSequence, elementName: String) {
        self.sequence = sequence
        self.condition = { $0.name == elementName }
    }
    
    public override func makeIterator() -> XElementIterator {
        return XElementIteratorUntilCondition(
            iterator: sequence.makeIterator(),
            until: condition
        )
    }
}

public final class XElementSequenceIncludingCondition: XElementSequence {
    
    let sequence: XElementSequence
    let condition: (XElement) -> Bool
    
    public init(sequence: XElementSequence, untilAndIncluding condition: @escaping (XElement) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    public init(sequence: XElementSequence, elementName: String) {
        self.sequence = sequence
        self.condition = { $0.name == elementName }
    }
    
    public override func makeIterator() -> XElementIterator {
        return XElementIteratorIncludingCondition(
            iterator: sequence.makeIterator(),
            untilAndIncluding: condition
        )
    }
}

// <<<<<<<<<<<<<<<<

public final class XTraversalSequence: XContentSequence {
    
    let node: XNode
    let directionIndicator: XDirectionIndicator
    
    public init(node: XNode, directionIndicator: XDirectionIndicator) {
        self.node = node
        self.directionIndicator = directionIndicator
    }
    
    public override func makeIterator() -> XContentIterator {
        return XBidirectionalContentIterator(nodeIterator: XTreeIterator(startNode: node, directionIndicator: directionIndicator))
    }
}

public final class XNextSequence: XContentSequence {
    
    let theContent: XContent
    
    public init(content: XContent) {
        self.theContent = content
    }
    
    public override func makeIterator() -> XContentIterator {
        return XBidirectionalContentIterator(nodeIterator: XNextIterator(content: theContent))
    }
}

public final class XPreviousSequence: XContentSequence {
    
    let theContent: XContent
    
    public init(content: XContent) {
        self.theContent = content
    }
    
    public override func makeIterator() -> XBidirectionalContentIterator {
        return XBidirectionalContentIterator(nodeIterator: XPreviousIterator(content: theContent))
    }
}

public final class XNextTextsSequence: XTextSequence {
    
    let theContent: XContent
    
    public init(content: XContent) {
        self.theContent = content
    }
    
    public override func makeIterator() -> XBidirectionalTextIterator {
        return XBidirectionalTextIterator(textIterator: XNextTextsIterator(content: theContent))
    }
}

public final class XPreviousTextsSequence: XTextSequence {
    
    let theContent: XContent
    
    public init(content: XContent) {
        self.theContent = content
    }
    
    public override func makeIterator() -> XBidirectionalTextIterator {
        return XBidirectionalTextIterator(textIterator: XPreviousTextsIterator(content: theContent))
    }
}

public final class XNextElementsSequence: XElementSequence {
    
    let theContent: XContent
    
    public init(content: XContent) {
        self.theContent = content
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(elementIterator: XNextElementsIterator(content: theContent))
    }
}

public final class XPreviousElementsSequence: XElementSequence {
    
    let theContent: XContent
    
    public init(content: XContent) {
        self.theContent = content
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(elementIterator: XPreviousElementsIterator(content: theContent))
    }
}

public final class XSequenceOfContent: XContentSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XContentIterator {
        return XBidirectionalContentIterator(nodeIterator: XContentsIterator(node: node))
    }
}

public final class XReversedSequenceOfContent: XContentSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XContentIterator {
        return XBidirectionalContentIterator(nodeIterator: XReversedContentsIterator(node: node))
    }
}

public final class XSequenceOfImmediateTexts: XTextSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XTextIterator {
        return XBidirectionalTextIterator(textIterator: XTextsIterator(node: node))
    }
}

public final class XSequenceOfAllTexts: XTextSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XTextIterator {
        return XBidirectionalTextIterator(textIterator: XAllTextsIterator(node: node))
    }
}

public final class XReversedSequenceOfAllTexts: XTextSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XTextIterator {
        return XBidirectionalTextIterator(textIterator: XReversedAllTextsIterator(node: node))
    }
}

public final class XReversedSequenceOfImmediateTexts: XTextSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XTextIterator {
        return XBidirectionalTextIterator(textIterator: XReversedAllTextsIterator(node: node))
    }
}

public final class XChildrenSequence: XElementSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XElementIterator {
        return XBidirectionalElementIterator(elementIterator: XChildrenIterator(node: node))
    }
}

public final class XReversedChildrenSequence: XElementSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XElementIterator {
        return XBidirectionalElementIterator(elementIterator: XReversedChildrenIterator(node: node))
    }
}

public final class XAncestorsSequence: XElementSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(elementIterator: XAncestorsIterator(startNode: node))
    }
}

public final class XAncestorsSequenceIncludingSelf: XElementSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(elementIterator: XAncestorsIteratorIncludingSelf(startNode: node))
    }
}

public final class XAllContentSequence: XContentSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XBidirectionalContentIterator {
        return XBidirectionalContentIterator(nodeIterator: XAllContentsIterator(node: node))
    }
}

public final class XAllContentIncludingSelfSequence: XContentSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XBidirectionalContentIterator {
        return XBidirectionalContentIterator(nodeIterator: XAllContentsIncludingSelfIterator(node: node))
    }
}

public final class XAllTextsSequence: XTextSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XTextIterator {
        return XBidirectionalTextIterator(textIterator: XAllTextsIterator(node: node))
    }
}

public final class XDescendantsSequence: XElementSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XElementIterator {
        return XBidirectionalElementIterator(elementIterator: XDescendantsIterator(node: node))
    }
}

public final class XDescendantsIncludingSelfSequence: XElementSequence {
    
    let element: XElement
    
    public init(element: XElement) {
        self.element = element
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(elementIterator: XDescendantsIncludingSelfIterator(element: element))
    }
}

public final class XElementsOfSameNameSequence: XElementSequence {
    
    let document: XDocument
    let elementName: String
    
    public init(document: XDocument, name: String) {
        self.document = document
        self.elementName = name
    }
    
    public override func makeIterator() -> XElementIterator {
        return XXBidirectionalElementNameIterator(
            elementIterator: XElementsOfSameNameIterator(
                document: document,
                name: elementName
            )
        )
    }
}

/**
 A sequence iterating only over one element. This ist mainly for testing.
 */
public final class XElementSelfSequence: XElementSequence {
    
    let element: XElement
    
    public init(element: XElement) {
        self.element = element
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(
            elementIterator: XElementSelfIterator(
                element: element
            )
        )
    }
}

/**
 A sequence iterating only over one node. This ist mainly for testing.
 */
public final class XContentSelfSequence: XContentSequence {
    
    let theContent: XContent
    
    public init(content: XContent) {
        self.theContent = content
    }
    
    public override func makeIterator() -> XBidirectionalContentIterator {
        return XBidirectionalContentIterator(
            nodeIterator: XContentSelfIterator(
                content: theContent
            )
        )
    }
}
