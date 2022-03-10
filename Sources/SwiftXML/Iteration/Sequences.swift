//
//  File.swift
//  
//
//  Created by Stefan Springer on 27.09.21.
//

import Foundation

public final class XTraversalSequence: XNodeSequence {
    
    let node: XNode
    let directionIndicator: XDirectionIndicator
    
    init(node: XNode, directionIndicator: XDirectionIndicator) {
        self.node = node
        self.directionIndicator = directionIndicator
    }
    
    public override func makeIterator() -> XBidirectionalNodeIterator {
        return XBidirectionalNodeIterator(nodeIterator: XTreeIterator(startNode: node, directionIndicator: directionIndicator))
    }
}

public final class XNextSequence: XNodeSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XBidirectionalNodeIterator {
        return XBidirectionalNodeIterator(nodeIterator: XNextIterator(node: node))
    }
}

public final class XPreviousSequence: XNodeSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XBidirectionalNodeIterator {
        return XBidirectionalNodeIterator(nodeIterator: XPreviousIterator(node: node))
    }
}

public final class XNextElementsSequence: XElementSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public func makeIterator() -> XElementTreeIterator {
        return XElementTreeIterator(elementIterator: XNextElementsIterator(node: node))
    }
}

public final class XPreviousElementsSequence: XElementSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public func makeIterator() -> XElementTreeIterator {
        return XElementTreeIterator(elementIterator: XPreviousElementsIterator(node: node))
    }
}

public final class XContentSequence: XNodeSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XBidirectionalNodeIterator {
        return XBidirectionalNodeIterator(nodeIterator: XContentsIterator(node: node))
    }
}

public final class XChildrenSequence: XElementSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public func makeIterator() -> XElementTreeIterator {
        return XElementTreeIterator(elementIterator: XChildrenIterator(node: node))
    }
}

public final class XAncestorsSequence: XElementSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public func makeIterator() -> XElementTreeIterator {
        return XElementTreeIterator(elementIterator: XAncestorsIterator(startNode: node))
    }
}

public final class XAllContentSequence: XNodeSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XBidirectionalNodeIterator {
        return XBidirectionalNodeIterator(nodeIterator: XAllContentsIterator(node: node))
    }
}

public final class XAllContentIncludingSelfSequence: XNodeSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public override func makeIterator() -> XBidirectionalNodeIterator {
        return XBidirectionalNodeIterator(nodeIterator: XAllContentsIterator(node: node))
    }
}

public final class XDescendantsSequence: XElementSequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public func makeIterator() -> XElementTreeIterator {
        return XElementTreeIterator(elementIterator: XDescendantsIterator(node: node))
    }
}

public final class XDescendantsIncludingSelfSequence: XElementSequence {
    
    let element: XElement
    
    init(element: XElement) {
        self.element = element
    }
    
    public func makeIterator() -> XElementTreeIterator {
        return XElementTreeIterator(elementIterator: XDescendantsIncludingSelfIterator(element: element))
    }
}

public final class XElementsOfSameNameSequence: XElementSequence {
    
    let document: XDocument
    let name: String
    
    init(document: XDocument, name: String) {
        self.document = document
        self.name = name
    }
    
    public func makeIterator() -> XElementNameIterator {
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
