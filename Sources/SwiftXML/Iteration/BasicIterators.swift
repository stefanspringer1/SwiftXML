//
//  BasicIterators.swift
//
//  Created 2022 by Stefan Springer, https://stefanspringer.com
//  License: Apache License 2.0

import Foundation

public class XNodeIterator: IteratorProtocol {
    public typealias Element = XNode
    public func next() -> XNode? {
        return nil
    }
}

public class XNodeIteratorWithCondition: XNodeIterator {
    
    let iterator: XNodeIterator
    let condition: (XNode) -> Bool
    
    init(iterator: XNodeIterator, condition: @escaping (XNode) -> Bool) {
        self.iterator = iterator
        self.condition = condition
    }
    
    public override func next() -> XNode? {
        var _next: XNode? = nil
        repeat {
            _next = iterator.next()
            if let node = _next, condition(node) {
                return node
            }
        } while _next != nil
        return nil
    }
}

public class XNodeSequence: LazySequenceProtocol {
    public func makeIterator() -> XNodeIterator {
        return XNodeIterator()
    }
}

public class XElementIterator: IteratorProtocol {
    public typealias Element = XElement
    public func next() -> XElement? {
        return nil
    }
}

public class XElementIteratorWithCondition: XElementIterator {
    
    let iterator: XElementIterator
    let condition: (XElement) -> Bool
    
    init(iterator: XElementIterator, condition: @escaping (XElement) -> Bool) {
        self.iterator = iterator
        self.condition = condition
    }
    
    init(iterator: XElementIterator, elementName: String) {
        self.iterator = iterator
        self.condition = { $0.name == elementName }
    }
    
    public override func next() -> XElement? {
        var _next: XElement? = nil
        repeat {
            _next = iterator.next()
            if let element = _next, condition(element) {
                return element
            }
        } while _next != nil
        return nil
    }
}

public class XElementSequence: LazySequenceProtocol {
    public func makeIterator() -> XElementIterator {
        return XElementIterator()
    }
}

public class XAttributeIterator: IteratorProtocol {
    public typealias Element = XAttributeSpot
    public func next() -> XAttributeSpot? {
        return nil
    }
}

public class XAttributeIteratorWithCondition: XAttributeIterator {
    
    let iterator: XAttributeIterator
    let condition: (XAttributeSpot) -> Bool
    
    init(iterator: XAttributeIterator, condition: @escaping (XAttributeSpot) -> Bool) {
        self.iterator = iterator
        self.condition = condition
    }
    
    public override func next() -> XAttributeSpot? {
        var _next: XAttributeSpot? = nil
        repeat {
            _next = iterator.next()
            if let attributeSpot = _next, condition(attributeSpot) {
                return attributeSpot
            }
        } while _next != nil
        return nil
    }
}

public class XAttributeSequence: LazySequenceProtocol {
    public func makeIterator() -> XAttributeIterator {
        return XAttributeIterator()
    }
}

public class XNodeLikeIterator: IteratorProtocol {
    public typealias Element = XNodeLike
    public func next() -> XNodeLike? {
        return nil
    }
}

public class XNodeLikeSequence: LazySequenceProtocol {
    public func makeIterator() -> XNodeLikeIterator {
        return XNodeLikeIterator()
    }
}

public class XNodeLikeSequenceFromArray: XNodeLikeSequence {
    let array: Array<XNodeLike?>
    
    public init(formArray array: Array<XNodeLike?>) {
        self.array = array
    }
    
    public override func makeIterator() -> XNodeLikeIterator {
        return XNodesLikeIteratorFromArray(formArray: array)
    }
}
    
    
public class XNodesLikeIteratorFromArray: XNodeLikeIterator {
    let array: Array<XNodeLike?>
    var nextIndex = -1
    
    public init(formArray array: Array<XNodeLike?>) {
        self.array = array
    }
    
    public override func next() -> XNodeLike? {
        var result: XNodeLike? = nil
        repeat {
            nextIndex += 1
            if nextIndex < array.count {
                result = array[nextIndex]
            }
            else {
                return nil
            }
        } while result == nil
        return result
    }
}

/**
 Iterates though the elements of a specified name.
 */
public final class XElementsOfSameNameIterator: XElementIteratorProtocol {
    
    private var started = false
    weak var document: XDocument?
    let name: String
    weak var currentElement: XElement? = nil
    let keepLast: Bool
    
    public init(document: XDocument, name: String, keepLast: Bool = false) {
        self.document = document
        self.name = name
        self.keepLast = keepLast
    }
    
    public func next() -> XElement? {
        let oldStarted = started
        let oldCurrent = currentElement
        if started {
            currentElement = currentElement?.nextWithSameName
        }
        else {
            currentElement = document?._elementsOfName_first[name]
            started = true
        }
        if currentElement == nil && keepLast {
            started = oldStarted
            currentElement = oldCurrent
            return nil
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
    let keepLast: Bool
    
    public init(document: XDocument, attributeName: String, keepLast: Bool = false) {
        self.document = document
        self.attributeName = attributeName
        self.keepLast = keepLast
    }
    
    func next() -> XAttribute? {
        let oldStarted = started
        let oldCurrent = currentAttribute
        if started {
            currentAttribute = currentAttribute?.nextWithSameName
        }
        else {
            currentAttribute = document?._attributesOfName_first[attributeName]
            started = true
        }
        if currentAttribute == nil && keepLast {
            started = oldStarted
            currentAttribute = oldCurrent
            return nil
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
 Iterates though the nodes after a node.
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
 Iterates though the nodes before a node.
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
 Iterates though the elements after a node.
 */
public final class XNextElementsIterator: XElementIteratorProtocol {
    
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
 Iterates though the elements before a node.
 */
public final class XPreviousElementsIterator: XElementIteratorProtocol {
    
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
 Iterates though all content (tree traversal) of a branch.
 */
public final class XAllContentsIncludingSelfIterator: XNodeIteratorProtocol {
    
    weak var startNode: XNode?
    weak var currentNode: XNode? = nil
    var started = false
    
    public init(
        node: XNode
    ) {
        self.startNode = node
    }
    
    public func next() -> XNode? {
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
        return currentNode
    }
    
    public func previous() -> XNode? {
        if currentNode === startNode {
            currentNode = nil
            started = false
            return nil
        }
        else {
            currentNode = currentNode?._previousInTree
            return currentNode
        }
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
                currentNode = startNode
                return nil
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
        element: XElement
    ) {
        self.startNode = element
    }
    
    public func next() -> XElement? {
        repeat {
            if startNode?.getLastInTree() === currentNode {
                currentNode = startNode
                return nil
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
