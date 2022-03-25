//
//  File.swift
//  
//
//  Created by Stefan Springer on 27.09.21.
//

import Foundation

// >>>>>>>>>>>>>>>>
// with conditions:

public final class XContentSequenceWithCondition: XContentSequence {
    
    let sequence: XContentSequence
    let condition: (XContent) -> Bool
    
    init(sequence: XContentSequence, condition: @escaping (XContent) -> Bool) {
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
    
    init(sequence: XContentSequence, while condition: @escaping (XContent) -> Bool) {
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
    
    init(sequence: XContentSequence, until condition: @escaping (XContent) -> Bool) {
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

public final class XElementSequenceWithCondition: XElementSequence {
    
    let sequence: XElementSequence
    let condition: (XElement) -> Bool
    
    init(sequence: XElementSequence, condition: @escaping (XElement) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    init(sequence: XElementSequence, elementName: String) {
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
    
    init(sequence: XElementSequence, while condition: @escaping (XElement) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    init(sequence: XElementSequence, elementName: String) {
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
    
    init(sequence: XElementSequence, until condition: @escaping (XElement) -> Bool) {
        self.sequence = sequence
        self.condition = condition
    }
    
    init(sequence: XElementSequence, elementName: String) {
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

public final class XAttributeSequenceWithCondition: XAttributeSequence {
    
    let sequence: XAttributeSequence
    let condition: (XAttributeSpot) -> Bool
    
    init(sequence: XAttributeSequence, condition: @escaping (XAttributeSpot) -> Bool) {
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
    
    init(sequence: XAttributeSequence, while condition: @escaping (XAttributeSpot) -> Bool) {
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
    
    init(sequence: XAttributeSequence, until condition: @escaping (XAttributeSpot) -> Bool) {
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

// <<<<<<<<<<<<<<<<

public final class XTraversalSequence: XContentSequence {
    
    let node: XNode
    let directionIndicator: XDirectionIndicator
    
    init(node: XNode, directionIndicator: XDirectionIndicator) {
        self.node = node
        self.directionIndicator = directionIndicator
    }
    
    public override func makeIterator() -> XContentIterator {
        return XBidirectionalContentIterator(nodeIterator: XTreeIterator(startNode: node, directionIndicator: directionIndicator))
    }
}

public final class XNextSequence: XContentSequence {
    
    let theContent: XContent
    
    init(content: XContent) {
        self.theContent = content
    }
    
    public override func makeIterator() -> XContentIterator {
        return XBidirectionalContentIterator(nodeIterator: XNextIterator(content: theContent))
    }
}

public final class XPreviousSequence: XContentSequence {
    
    let theContent: XContent
    
    init(content: XContent) {
        self.theContent = content
    }
    
    public override func makeIterator() -> XBidirectionalContentIterator {
        return XBidirectionalContentIterator(nodeIterator: XPreviousIterator(node: theContent))
    }
}

public final class XNextElementsSequence: XElementSequence {
    
    let theContent: XContent
    
    init(content: XContent) {
        self.theContent = content
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(elementIterator: XNextElementsIterator(content: theContent))
    }
}

public final class XPreviousElementsSequence: XElementSequence {
    
    let theContent: XContent
    
    init(content: XContent) {
        self.theContent = content
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(elementIterator: XPreviousElementsIterator(content: theContent))
    }
}

public final class XSequenceOfContent: XContentSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XContentIterator {
        return XBidirectionalContentIterator(nodeIterator: XContentsIterator(node: node))
    }
}

public final class XReversedSequenceOfContent: XContentSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XContentIterator {
        return XBidirectionalContentIterator(nodeIterator: XReversedContentsIterator(node: node))
    }
}

public final class XChildrenSequence: XElementSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XElementIterator {
        return XBidirectionalElementIterator(elementIterator: XChildrenIterator(node: node))
    }
}

public final class XReversedChildrenSequence: XElementSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XElementIterator {
        return XBidirectionalElementIterator(elementIterator: XReversedChildrenIterator(node: node))
    }
}

public final class XAncestorsSequence: XElementSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(elementIterator: XAncestorsIterator(startNode: node))
    }
}

public final class XAllContentSequence: XContentSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XBidirectionalContentIterator {
        return XBidirectionalContentIterator(nodeIterator: XAllContentsIterator(node: node))
    }
}

public final class XAllContentIncludingSelfSequence: XContentSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XBidirectionalContentIterator {
        return XBidirectionalContentIterator(nodeIterator: XAllContentsIncludingSelfIterator(node: node))
    }
}

public final class XDescendantsSequence: XElementSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XElementIterator {
        return XBidirectionalElementIterator(elementIterator: XDescendantsIterator(node: node))
    }
}

public final class XDescendantsIncludingSelfSequence: XElementSequence {
    
    let element: XElement
    
    init(element: XElement) {
        self.element = element
    }
    
    public override func makeIterator() -> XBidirectionalElementIterator {
        return XBidirectionalElementIterator(elementIterator: XDescendantsIncludingSelfIterator(element: element))
    }
}

public final class XElementsOfSameNameSequence: XElementSequence {
    
    let document: XDocument
    let name: String
    
    init(document: XDocument, name: String) {
        self.document = document
        self.name = name
    }
    
    public override func makeIterator() -> XElementIterator {
        return XElementNameIterator(
            elementIterator: XElementsOfSameNameIterator(
                document: document,
                name: name
            )
        )
    }
}

public final class XAttributesOfSameNameSequence: XAttributeSequence {
    
    let document: XDocument
    let attributeName: String
    
    init(document: XDocument, attributeName: String) {
        self.document = document
        self.attributeName = attributeName
    }
    
    public func makeIterator() -> XBidirectionalAttributeIterator {
        return XBidirectionalAttributeIterator(
            attributeIterator: XAttributesOfSameNameIterator(
                document: document,
                attributeName: attributeName
            )
        )
    }
}

/**
 A sequence iterating only over one element. This ist mainly for testing.
 */
public final class XElementSelfSequence: XElementSequence {
    
    let element: XElement
    
    init(element: XElement) {
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
    
    init(content: XContent) {
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
