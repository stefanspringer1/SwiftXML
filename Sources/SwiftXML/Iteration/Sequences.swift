//
//  File.swift
//  
//
//  Created by Stefan Springer on 27.09.21.
//

import Foundation

public class XTraversalSequence: Sequence {
    
    let node: XNode
    let directionIndicator: XDirectionIndicator
    
    init(node: XNode, directionIndicator: XDirectionIndicator) {
        self.node = node
        self.directionIndicator = directionIndicator
    }
    
    public func makeIterator() -> XNodeIterator {
        return XNodeIterator(nodeIterator: XTreeIterator(startNode: node, directionIndicator: directionIndicator))
    }
}

public class XNextSequence: Sequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public func makeIterator() -> XNodeIterator {
        return XNodeIterator(nodeIterator: XNextIterator(node: node))
    }
}

public class XPreviousSequence: Sequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public func makeIterator() -> XNodeIterator {
        return XNodeIterator(nodeIterator: XPreviousIterator(node: node))
    }
}

public class XRightSequence: Sequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public func makeIterator() -> XElementTreeIterator {
        return XElementTreeIterator(elementIterator: XRightIterator(node: node))
    }
}

public class XLeftSequence: Sequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public func makeIterator() -> XElementTreeIterator {
        return XElementTreeIterator(elementIterator: XLeftIterator(node: node))
    }
}

public class XContentSequence: Sequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public func makeIterator() -> XNodeIterator {
        return XNodeIterator(nodeIterator: XContentsIterator(node: node))
    }
}

public class XChildrenSequence: Sequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public func makeIterator() -> XElementTreeIterator {
        return XElementTreeIterator(elementIterator: XChildrenIterator(node: node))
    }
}

public class XAncestorsSequence: Sequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public func makeIterator() -> XElementTreeIterator {
        return XElementTreeIterator(elementIterator: XAncestorsIterator(startNode: node))
    }
}

public class XAllContentSequence: Sequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public func makeIterator() -> XNodeIterator {
        return XNodeIterator(nodeIterator: XAllContentsIterator(node: node))
    }
}

public class XDescendantsSequence: Sequence {
    
    let node: XNode
    
    init(node: XNode) {
        self.node = node
    }
    
    public func makeIterator() -> XElementTreeIterator {
        return XElementTreeIterator(elementIterator: XDescendantsIterator(node: node))
    }
}

public class XElementsOfSameNameSequence: Sequence {
    
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

public class XAttributesOfSameNameSequence: Sequence {
    
    let document: XDocument
    let attributeName: String
    
    init(document: XDocument, attributeName: String) {
        self.document = document
        self.attributeName = attributeName
    }
    
    public func makeIterator() -> XAttributeIterator {
        return XAttributeIterator(
            attributeIterator: XAttributesOfSameNameIterator(
                document: document,
                attributeName: attributeName
            )
        )
    }
}
