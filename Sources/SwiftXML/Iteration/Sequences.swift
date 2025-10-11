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
    
    public init(sequence: XElementSequence, prefix: String?, elementName: String) {
        self.sequence = sequence
        self.condition = { $0.prefix == prefix && $0.name == elementName }
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
    
    public init(sequence: XElementSequence, prefix: String?, elementName: String) {
        self.sequence = sequence
        self.condition = { $0.prefix == prefix && $0.name == elementName }
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
    
    public init(sequence: XElementSequence, prefix: String?, elementName: String) {
        self.sequence = sequence
        self.condition = { $0.prefix == prefix && $0.name == elementName }
    }
    
    public override func makeIterator() -> XElementIterator {
        return XElementIteratorUntilCondition(
            iterator: sequence.makeIterator(),
            until: condition
        )
    }
}

public final class XElementSequenceWithConditionAndUntilCondition: XElementSequence {
    
    let sequence: XElementSequence
    let condition: (XElement) -> Bool
    let untilCondition: (XElement) -> Bool
    
    public init(sequence: XElementSequence, condition: @escaping (XElement) -> Bool, until untilCondition: @escaping (XElement) -> Bool) {
        self.sequence = sequence
        self.condition = condition
        self.untilCondition = untilCondition
    }
    
    public init(sequence: XElementSequence, prefix: String?, elementName: String, until untilCondition: @escaping (XElement) -> Bool) {
        self.sequence = sequence
        self.condition = { $0.prefix == prefix && $0.name == elementName }
        self.untilCondition = untilCondition
    }
    
    public override func makeIterator() -> XElementIterator {
        return XElementIteratorWithConditionAndUntilCondition(
            iterator: sequence.makeIterator(),
            condition: condition,
            until: untilCondition
        )
    }
}

public final class XElementSequenceWithConditionAndWhileCondition: XElementSequence {
    
    let sequence: XElementSequence
    let condition: (XElement) -> Bool
    let whileCondition: (XElement) -> Bool
    
    public init(sequence: XElementSequence, condition: @escaping (XElement) -> Bool, while whileCondition: @escaping (XElement) -> Bool) {
        self.sequence = sequence
        self.condition = condition
        self.whileCondition = whileCondition
    }
    
    public init(sequence: XElementSequence, prefix: String?, elementName: String, while whileCondition: @escaping (XElement) -> Bool) {
        self.sequence = sequence
        self.condition = { $0.prefix == prefix && $0.name == elementName }
        self.whileCondition = whileCondition
    }
    
    public override func makeIterator() -> XElementIterator {
        return XElementIteratorWithConditionAndWhileCondition(
            iterator: sequence.makeIterator(),
            condition: condition,
            while: whileCondition
        )
    }
}

public final class XContentSequenceWithConditionAndUntilCondition: XContentSequence {
    
    let sequence: XContentSequence
    let condition: (XContent) -> Bool
    let untilCondition: (XContent) -> Bool
    
    public init(sequence: XContentSequence, condition: @escaping (XContent) -> Bool, until untilCondition: @escaping (XContent) -> Bool) {
        self.sequence = sequence
        self.condition = condition
        self.untilCondition = untilCondition
    }
    
    public override func makeIterator() -> XContentIterator {
        return XContentIteratorWithConditionAndUntilCondition(
            iterator: sequence.makeIterator(),
            condition: condition,
            until: untilCondition
        )
    }
}

public final class XContentSequenceWithConditionAndWhileCondition: XContentSequence {
    
    let sequence: XContentSequence
    let condition: (XContent) -> Bool
    let whileCondition: (XContent) -> Bool
    
    public init(sequence: XContentSequence, condition: @escaping (XContent) -> Bool, while whileCondition: @escaping (XContent) -> Bool) {
        self.sequence = sequence
        self.condition = condition
        self.whileCondition = whileCondition
    }
    
    public override func makeIterator() -> XContentIterator {
        return XContentIteratorWithConditionAndWhileCondition(
            iterator: sequence.makeIterator(),
            condition: condition,
            while: whileCondition
        )
    }
}

public final class XTextSequenceWithConditionAndUntilCondition: XTextSequence {
    
    let sequence: XTextSequence
    let condition: (XText) -> Bool
    let untilCondition: (XText) -> Bool
    
    public init(sequence: XTextSequence, condition: @escaping (XText) -> Bool, until untilCondition: @escaping (XText) -> Bool) {
        self.sequence = sequence
        self.condition = condition
        self.untilCondition = untilCondition
    }
    
    public override func makeIterator() -> XTextIterator {
        return XTextIteratorWithConditionAndUntilCondition(
            iterator: sequence.makeIterator(),
            condition: condition,
            until: untilCondition
        )
    }
}

public final class XTextSequenceWithConditionAndWhileCondition: XTextSequence {
    
    let sequence: XTextSequence
    let condition: (XText) -> Bool
    let whileCondition: (XText) -> Bool
    
    public init(sequence: XTextSequence, condition: @escaping (XText) -> Bool, while whileCondition: @escaping (XText) -> Bool) {
        self.sequence = sequence
        self.condition = condition
        self.whileCondition = whileCondition
    }
    
    public override func makeIterator() -> XTextIterator {
        return XTextIteratorWithConditionAndWhileCondition(
            iterator: sequence.makeIterator(),
            condition: condition,
            while: whileCondition
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
    
    public init(sequence: XElementSequence, prefix: String?, elementName: String) {
        self.sequence = sequence
        self.condition = { $0.prefix == prefix && $0.name == elementName }
    }
    
    public override func makeIterator() -> XElementIterator {
        return XElementIteratorIncludingCondition(
            iterator: sequence.makeIterator(),
            untilAndIncluding: condition
        )
    }
}

public final class XAttributeSequenceWithCondition: XAttributeSequence {
    
    let sequence: XAttributeSequence
    let condition: (XAttributeSpot) -> Bool
    
    public init(sequence: XAttributeSequence, condition: @escaping (XAttributeSpot) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    public override func makeIterator() -> XAttributeIterator {
        return XAttributeIteratorWithCondition(
            iterator: sequence.makeIterator(),
            condition: condition
        )
    }
}

public final class XAttributeSequenceWhileCondition: XAttributeSequence {
    
    let sequence: XAttributeSequence
    let condition: (XAttributeSpot) -> Bool
    
    public init(sequence: XAttributeSequence, while condition: @escaping (XAttributeSpot) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    public override func makeIterator() -> XAttributeIterator {
        return XAttributeIteratorWhileCondition(
            iterator: sequence.makeIterator(),
            while: condition
        )
    }
}

public final class XAttributeSequenceUntilCondition: XAttributeSequence {
    
    let sequence: XAttributeSequence
    let condition: (XAttributeSpot) -> Bool
    
    public init(sequence: XAttributeSequence, until condition: @escaping (XAttributeSpot) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    public override func makeIterator() -> XAttributeIterator {
        return XAttributeIteratorUntilCondition(
            iterator: sequence.makeIterator(),
            until: condition
        )
    }
}

public final class XAttributeSequenceIncludingCondition: XAttributeSequence {
    
    let sequence: XAttributeSequence
    let condition: (XAttributeSpot) -> Bool
    
    public init(sequence: XAttributeSequence, untilAndIncluding condition: @escaping (XAttributeSpot) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    public override func makeIterator() -> XAttributeIterator {
        return XAttributeIteratorIncludingCondition(
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
        return XBidirectionalContentIterator(contentIterator: XTreeIterator(startNode: node, directionIndicator: directionIndicator))
    }
}

public final class XNextSequence: XContentSequence {
    
    let content: XContent
    
    public init(content: XContent) {
        self.content = content
    }
    
    public override func makeIterator() -> XContentIterator {
        return XBidirectionalContentIterator(contentIterator: XNextIterator(content: content))
    }
}

public final class XNextIncludingSelfSequence: XContentSequence {
    
    let content: XContent
    
    public init(content: XContent) {
        self.content = content
    }
    
    public override func makeIterator() -> XContentIterator {
        return XBidirectionalContentIterator(contentIterator: XNextIncludingSelfIterator(content: content))
    }
}

public final class XPreviousSequence: XContentSequence {
    
    let content: XContent
    
    public init(content: XContent) {
        self.content = content
    }
    
    public override func makeIterator() -> XBidirectionalContentIterator {
        return XBidirectionalContentIterator(contentIterator: XPreviousIterator(content: content))
    }
}

public final class XPreviousIncludingSelfSequence: XContentSequence {
    
    let content: XContent
    
    public init(content: XContent) {
        self.content = content
    }
    
    public override func makeIterator() -> XBidirectionalContentIterator {
        return XBidirectionalContentIterator(contentIterator: XPreviousIncludingSelfIterator(content: content))
    }
}

public final class XNextTextsSequence: XTextSequence {
    
    let content: XContent
    
    public init(content: XContent) {
        self.content = content
    }
    
    public override func makeIterator() -> XBidirectionalTextIterator {
        return XBidirectionalTextIterator(textIterator: XNextTextsIterator(node: content))
    }
}

public final class XNextTextsIncludingSelfSequence: XTextSequence {
    
    let text: XText
    
    public init(text: XText) {
        self.text = text
    }
    
    public override func makeIterator() -> XBidirectionalTextIterator {
        return XBidirectionalTextIterator(textIterator: XNextTextsIncludingSelfIterator(text: text))
    }
}

public final class XPreviousTextsSequence: XTextSequence {
    
    let content: XContent
    
    public init(content: XContent) {
        self.content = content
    }
    
    public override func makeIterator() -> XBidirectionalTextIterator {
        return XBidirectionalTextIterator(textIterator: XPreviousTextsIterator(content: content))
    }
}

public final class XPreviousTextsIncludingSelfSequence: XTextSequence {
    
    let text: XText
    
    public init(text: XText) {
        self.text = text
    }
    
    public override func makeIterator() -> XBidirectionalTextIterator {
        return XBidirectionalTextIterator(textIterator: XPreviousTextsIncludingSelfIterator(text: text))
    }
}

public final class XNextElementsSequence: XElementSequence {
    
    let content: XContent
    
    public init(content: XContent) {
        self.content = content
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(elementIterator: XNextElementsIterator(content: content))
    }
}

public final class XNextCloseElementsSequence: XElementSequence {
    
    let content: XContent
    
    public init(content: XContent) {
        self.content = content
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(elementIterator: XNextCloseElementsIterator(content: content))
    }
}

public final class XNextElementsIncludingSelfSequence: XElementSequence {
    
    let element: XElement
    
    public init(element: XElement) {
        self.element = element
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(elementIterator: XNextElementsIncludingSelfIterator(element: element))
    }
}

public final class XNextCloseElementsIncludingSelfSequence: XElementSequence {
    
    let element: XElement
    
    public init(element: XElement) {
        self.element = element
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(elementIterator: XNextCloseElementsIncludingSelfIterator(element: element))
    }
}

public final class XPreviousElementsSequence: XElementSequence {
    
    let content: XContent
    
    public init(content: XContent) {
        self.content = content
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(elementIterator: XPreviousElementsIterator(content: content))
    }
}

public final class XPreviousCloseElementsSequence: XElementSequence {
    
    let content: XContent
    
    public init(content: XContent) {
        self.content = content
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(elementIterator: XPreviousCloseElementsIterator(content: content))
    }
}

public final class XPreviousElementsIncludingSelfSequence: XElementSequence {
    
    let element: XElement
    
    public init(element: XElement) {
        self.element = element
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(elementIterator: XPreviousElementsIncludingSelfIterator(element: element))
    }
}

public final class XPreviousCloseElementsIncludingSelfSequence: XElementSequence {
    
    let element: XElement
    
    public init(element: XElement) {
        self.element = element
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(elementIterator: XPreviousCloseElementsIncludingSelfIterator(element: element))
    }
}

public final class XSequenceOfContent: XContentSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XContentIterator {
        return XBidirectionalContentIterator(contentIterator: XContentsIterator(node: node))
    }
}

public final class XReversedSequenceOfContent: XContentSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XContentIterator {
        return XBidirectionalContentIterator(contentIterator: XReversedContentsIterator(node: node))
    }
}

public final class XSequenceOfImmediateTexts: XTextSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XTextIterator {
        return XBidirectionalTextIterator(textIterator: XNextTextsIterator(node: node))
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

public final class XReversedSequenceOfAllContent: XContentSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XContentIterator {
        return XBidirectionalContentIterator(contentIterator: XReversedAllContentIterator(node: node))
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
        return XBidirectionalContentIterator(contentIterator: XAllContentsIterator(node: node))
    }
}

public final class XAllContentIncludingSelfSequence: XContentSequence {
    
    let node: XNode
    
    public init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XBidirectionalContentIterator {
        return XBidirectionalContentIterator(contentIterator: XAllContentsIncludingSelfIterator(node: node))
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
    let prefix: String?
    let elementName: String
    
    public init(document: XDocument, prefix: String?, name: String) {
        self.document = document
        self.prefix = prefix
        self.elementName = name
    }
    
    public override func makeIterator() -> XElementIterator {
        return XXBidirectionalElementNameIterator(
            elementIterator: XElementsOfSameNameIterator(
                document: document,
                prefix: prefix,
                name: elementName
            )
        )
    }
}

public final class XAttributesOfSameNameSequence: XAttributeSequence {
    
    let document: XDocument
    let attributePrefix: String?
    let attributeName: String
    
    public init(document: XDocument, attributePrefix: String?, attributeName: String) {
        self.document = document
        self.attributePrefix = attributePrefix
        self.attributeName = attributeName
    }
    
    public override func makeIterator() -> XAttributeIterator {
        return XBidirectionalAttributeIterator(
            forAttributeName: attributeName, attributeIterator: XAttributesOfSameNameIterator(
                document: document,
                attributePrefix: attributePrefix,
                attributeName: attributeName
            )
        )
    }
}

public final class XProcessingInstructionsOfSameTargetSequence: XProcessingInstructionSequence {
    
    let document: XDocument
    let target: String
    
    public init(document: XDocument, target: String) {
        self.document = document
        self.target = target
    }
    
    public override func makeIterator() -> XProcessingInstructionIterator {
        return XBidirectionalProcessingInstructionIterator(
            processingInstructionIterator: XProcessingInstructionOfSameTargetIterator(
                document: document,
                target: target
            )
        )
    }
}


public final class XAttributesOfSameValueSequence: XAttributeSequence {
    
    let document: XDocument
    let attributePrefix: String?
    let attributeName: String
    let attributeValue: String
    
    public init(document: XDocument, attributePrefix: String?, attributeName: String, attributeValue: String) {
        self.document = document
        self.attributePrefix = attributePrefix
        self.attributeName = attributeName
        self.attributeValue = attributeValue
    }
    
    public override func makeIterator() -> XAttributeIterator {
        return XBidirectionalAttributeIterator(
            forAttributeName: attributeName, attributeIterator: XAttributesOfSameValueIterator(
                document: document,
                attributePrefix: attributePrefix,
                attributeName: attributeName,
                attributeValue: attributeValue
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
    
    let content: XContent
    
    public init(content: XContent) {
        self.content = content
    }
    
    public override func makeIterator() -> XBidirectionalContentIterator {
        return XBidirectionalContentIterator(
            contentIterator: XContentSelfIterator(
                content: content
            )
        )
    }
}
