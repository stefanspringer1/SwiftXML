//
//  BasicIterators.swift
//  
//
//  Created by Stefan Springer on 27.09.21.
//

import Foundation

/**
 Iterates though the elements of a specified name.
 */
public final class XElementsOfSameNameIterator: XElementIteratorProtocol {
    
    private var started = false
    weak var document: XDocument?
    let name: String
    weak var currentElement: XElement? = nil
    
    public init(document: XDocument, name: String) {
        self.document = document
        self.name = name
    }
    
    public func next() -> XElement? {
        if started {
            currentElement = currentElement?.nextWithSameName
        }
        else {
            currentElement = document?._elementsOfName_first[name]
            started = true
        }
        return currentElement
    }
    
    public func previous() -> XElement? {
        if started {
            currentElement = currentElement?.previousWithSameName
            if currentElement == nil {
                started = false
            }
            return currentElement
        }
        return nil
    }
}

/**
 Iterates though the elements with a specified attribute name.
 */
final class XAttributesOfSameNameIterator: XAttributeIteratorProtocol {

    private var started = false
    weak var document: XDocument?
    let attributeName: String
    weak var currentAttribute: XAttribute? = nil
    
    public init(document: XDocument, attributeName: String) {
        self.document = document
        self.attributeName = attributeName
    }
    
    func next() -> XAttribute? {
        if started {
            currentAttribute = currentAttribute?.nextWithSameName
        }
        else {
            currentAttribute = document?._attributesOfName_first[attributeName]
            started = true
        }
        return currentAttribute
    }
    
    func previous() -> XAttribute? {
        if started {
            currentAttribute = currentAttribute?.previousWithSameName
            if currentAttribute == nil {
                started = false
            }
            return currentAttribute
        }
        return nil
    }
}

/**
 Iterates though the content of a branch.
 */
public final class XContentsIterator: XNodeIteratorProtocol {
    
    private var started = false
    let node: XNode
    weak var currentNode: XNode? = nil
    
    public init(
        node: XNode
    ) {
        self.node = node
    }
    
    public func next() -> XNode? {
        if started {
            currentNode = currentNode?._next
        }
        else {
            currentNode = (node as? XBranch)?._firstChild
            started = true
        }
        return currentNode
    }
    
    public func previous() -> XNode? {
        if started {
            currentNode = currentNode?._previous
            if currentNode == nil {
                started = false
            }
            return currentNode
        }
        return nil
    }
}

/**
 Iterates though the nodes right of a node.
 */
public final class XNextIterator: XNodeIteratorProtocol {
    
    let node: XNode
    weak var currentNode: XNode? = nil
    
    public init(
        node: XNode
    ) {
        self.node = node
        currentNode = node
    }
    
    public func next() -> XNode? {
        currentNode = currentNode?._next
        return currentNode
    }
    
    public func previous() -> XNode? {
        if currentNode === node {
            return nil
        }
        else {
            currentNode = currentNode?._previous
            if currentNode === node {
                return nil
            }
        }
        return currentNode
    }
}

/**
 Iterates though the nodes left of a node.
 */
public final class XPreviousIterator: XNodeIteratorProtocol {
    
    weak var node: XNode?
    weak var currentNode: XNode? = nil
    
    public init(
        node: XNode
    ) {
        self.node = node
        currentNode = node
    }
    
    public func next() -> XNode? {
        currentNode = currentNode?._previous
        return currentNode
    }
    
    public func previous() -> XNode? {
        if currentNode === node {
            return nil
        }
        else {
            currentNode = currentNode?._next
            if currentNode === node {
                return nil
            }
        }
        return currentNode
    }
}

/**
 Iterates though the elements right of a node.
 */
public final class XRightIterator: XElementIteratorProtocol {
    
    weak var node: XNode?
    weak var currentNode: XNode? = nil
    
    public init(
        node: XNode
    ) {
        self.node = node
        currentNode = node
    }
    
    public func next() -> XElement? {
        repeat {
            currentNode = currentNode?._next
        } while currentNode != nil && !(currentNode! is XElement)
        return currentNode as? XElement
    }
    
    public func previous() -> XElement? {
        repeat {
            if currentNode === node {
                return nil
            }
            else {
                currentNode = currentNode?._previous
                if currentNode === node {
                    return nil
                }
            }
        } while currentNode != nil && !(currentNode! is XElement)
        return currentNode as? XElement
    }
}

/**
 Iterates though the elements left of a node.
 */
public final class XLeftIterator: XElementIteratorProtocol {
    
    weak var node: XNode?
    weak var currentNode: XNode? = nil
    
    public init(
        node: XNode
    ) {
        self.node = node
        currentNode = node
    }
    
    public func next() -> XElement? {
        repeat {
            currentNode = currentNode?._previous
        } while currentNode != nil && !(currentNode! is XElement)
        return currentNode as? XElement
    }
    
    public func previous() -> XElement? {
        repeat {
            if currentNode === node {
                return nil
            }
            else {
                currentNode = currentNode?._next
                if currentNode === node {
                    return nil
                }
            }
        } while currentNode != nil && !(currentNode! is XElement)
        return currentNode as? XElement
    }
}

/**
 Iterates though the children of a branch.
 */
public final class XChildrenIterator: XElementIteratorProtocol {
    
    private var started = false
    weak var node: XNode?
    weak var currentNode: XNode? = nil
    
    public init(
        node: XNode
    ) {
        self.node = node
    }
    
    public func next() -> XElement? {
        repeat {
            if started {
                currentNode = currentNode?._next
            }
            else {
                currentNode = (node as? XBranch)?._firstChild
                started = true
            }
        } while currentNode != nil && !(currentNode! is XElement)
        return currentNode as? XElement
    }
    
    public func previous() -> XElement? {
        repeat {
            if started {
                currentNode = currentNode?._previous
                if currentNode == nil {
                    started = false
                }
            }
        } while currentNode != nil && !(currentNode! is XElement)
        return currentNode as? XElement
    }
}

/**
 Iterates though the ancestors.
 */
public final class XAncestorsIterator: XElementIteratorProtocol {
    
    private var started = false
    weak var startNode: XNode?
    weak var currentNode: XElement? = nil
    var ancestorCount = 0
    
    public init(
        startNode: XNode
    ) {
        self.startNode = startNode
    }
    
    public func next() -> XElement? {
        if started {
            currentNode = currentNode?.parent
        }
        else {
            currentNode = startNode?.parent
            started = true
        }
        if currentNode != nil {
            ancestorCount += 1
        }
        return currentNode
    }
    
    public func previous() -> XElement? {
        if started {
            ancestorCount -= 1
            if ancestorCount == 0 {
                currentNode = nil
                started = false
            }
            else {
                currentNode = currentNode?.parent
                for _ in 2...ancestorCount {
                    currentNode = currentNode?.parent
                }
            }
        }
        return currentNode
    }
}

/**
 Iterates though all content (tree traversal) of a branch.
 */
public final class XAllContentsIterator: XNodeIteratorProtocol {
    
    weak var startNode: XNode?
    weak var currentNode: XNode? = nil
    
    public init(
        node: XNode
    ) {
        self.startNode = node
        self.currentNode = node
    }
    
    public func next() -> XNode? {
        if startNode?.getLastInTree() === currentNode {
            currentNode = nil
        }
        else {
            currentNode = currentNode?._nextInTree
        }
        return currentNode
    }
    
    public func previous() -> XNode? {
        if currentNode === startNode {
            currentNode = nil
        }
        else {
            currentNode = currentNode?._previousInTree
        }
        return currentNode
    }
}

/**
 Iterates though all elements (tree traversal) of a branch.
 */
public final class XDescendantsIterator: XElementIteratorProtocol {
    
    weak var startNode: XNode?
    weak var currentNode: XNode? = nil
    
    public init(
        node: XNode
    ) {
        self.startNode = node
        self.currentNode = node
    }
    
    public func next() -> XElement? {
        repeat {
            if startNode?.getLastInTree() === currentNode {
                currentNode = nil
            }
            else {
                currentNode = currentNode?._nextInTree
                if let element = currentNode as? XElement {
                    return element
                }
            }
        } while currentNode != nil
        return nil
    }
    
    public func previous() -> XElement? {
        repeat {
            if currentNode === startNode {
                currentNode = nil
            }
            else {
                currentNode = currentNode?._previousInTree
                if let element = currentNode as? XElement {
                    return element
                }
            }
        } while currentNode != nil
        return nil
    }
}

/**
 Iterates though all elements (tree traversal) of a branch, inlcuding teh start node itself if it is an element.
 */
public final class XDescendantsIncludingSelfIterator: XElementIteratorProtocol {
    
    weak var startNode: XNode?
    weak var currentNode: XNode? = nil
    var started = false
    
    public init(
        node: XNode
    ) {
        self.startNode = node
    }
    
    public func next() -> XElement? {
        repeat {
            if startNode?.getLastInTree() === currentNode {
                currentNode = nil
            }
            else if started == false {
                currentNode = startNode
                started = true
            }
            else {
                currentNode = currentNode?._nextInTree
            }
            if let element = currentNode as? XElement {
                return element
            }
        } while currentNode != nil
        return nil
    }
    
    public func previous() -> XElement? {
        repeat {
            if currentNode === startNode {
                currentNode = nil
                started = false
            }
            else {
                currentNode = currentNode?._previousInTree
                if let element = currentNode as? XElement {
                    return element
                }
            }
        } while currentNode != nil
        return nil
    }
}

public final class XDirectionIndicator {
    var up = false
}

/**
 Iterates though a tree.
 
 When progressing via next(), down and up events can be captured by the closures
 "down" amd "up".
 */
public final class XTreeIterator: XNodeIteratorProtocol {
    
    var started = false
    weak var startNode: XNode?
    weak var currentNode: XNode? = nil
    var directionIndicator: XDirectionIndicator
    
    public init(
        startNode: XNode,
        directionIndicator: XDirectionIndicator
    ) {
        self.startNode = startNode
        self.directionIndicator = directionIndicator
    }
    
    private var downDirection = true
    
    public func next() -> XNode? {
        if started {
            while true {
                if downDirection,
                   let branch = currentNode as? XBranch {
                    if let firstChild = branch._firstChild {
                        currentNode = firstChild
                        directionIndicator.up = false
                        return currentNode
                    }
                    else {
                        downDirection = false
                        directionIndicator.up = true
                        return branch
                    }
                }
                if currentNode === startNode {
                    currentNode = nil
                    return nil
                }
                if let next = currentNode?._next {
                    currentNode = next
                    downDirection = true
                    directionIndicator.up = false
                    return next
                }
                else {
                    if downDirection {
                        downDirection = false
                    }
                    currentNode = currentNode?._parent
                    if let theCurrentNode = currentNode as? XBranch {
                        directionIndicator.up = true
                        return theCurrentNode
                    }
                    else {
                        return nil
                    }
                }
            }
        }
        else {
            currentNode = startNode
            started = true
            return currentNode
        }
    }
    
    public func previous() -> XNode? {
        if started {
            if currentNode === startNode {
                currentNode = nil
                started = false
            }
            else if let thePrevious = currentNode?._previous {
                currentNode = thePrevious.getLastInTree()
                downDirection = false
            }
            else if let theParent = currentNode?.parent {
                currentNode = theParent
                downDirection = true
            }
            else {
                started = false
                currentNode = nil
            }
            return currentNode
        }
        return nil
    }
    
}
