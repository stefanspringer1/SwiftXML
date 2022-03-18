//
//  BasicIterators.swift
//
//  Created 2022 by Stefan Springer, https://stefanspringer.com
//  License: Apache License 2.0

import Foundation

public class XContentIterator: IteratorProtocol {
    public typealias Element = XContent
    public func next() -> XContent? {
        return nil
    }
}

public class XContentIteratorWithCondition: XContentIterator {
    
    let iterator: XContentIterator
    let condition: (XContent) -> Bool
    
    init(iterator: XContentIterator, condition: @escaping (XContent) -> Bool) {
        self.iterator = iterator
        self.condition = condition
    }
    
    public override func next() -> XContent? {
        var _next: XContent? = nil
        repeat {
            _next = iterator.next()
            if let node = _next, condition(node) {
                return node
            }
        } while _next != nil
        return nil
    }
}

public class XContentSequence: LazySequenceProtocol {
    public func makeIterator() -> XContentIterator {
        return XContentIterator()
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

public class XContentLikeIterator: IteratorProtocol {
    public typealias Element = XContentLike
    public func next() -> XContentLike? {
        return nil
    }
}

public class XContentLikeSequence: LazySequenceProtocol {
    public func makeIterator() -> XContentLikeIterator {
        return XContentLikeIterator()
    }
}

public class XContentLikeSequenceFromArray: XContentLikeSequence {
    let array: Array<XContentLike?>
    
    public init(formArray array: Array<XContentLike?>) {
        self.array = array
    }
    
    public override func makeIterator() -> XContentLikeIterator {
        return XContentLikeIteratorFromArray(formArray: array)
    }
}
    
    
public class XContentLikeIteratorFromArray: XContentLikeIterator {
    let array: Array<XContentLike?>
    var nextIndex = -1
    
    public init(formArray array: Array<XContentLike?>) {
        self.array = array
    }
    
    public override func next() -> XContentLike? {
        var result: XContentLike? = nil
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
public final class XContentsIterator: XContentIteratorProtocol {
    
    private var started = false
    let node: XNode
    weak var currentNode: XContent? = nil
    
    public init(
        node: XNode
    ) {
        self.node = node
    }
    
    public func next() -> XContent? {
        if started {
            currentNode = currentNode?._next
        }
        else {
            currentNode = (node as? XBranchInternal)?._firstContent
            started = true
        }
        return currentNode
    }
    
    public func previous() -> XContent? {
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
 Iterates though the content after a content.
 */
public final class XNextIterator: XContentIteratorProtocol {
    
    let content: XContent
    weak var currentContent: XContent? = nil
    
    public init(
        content: XContent
    ) {
        self.content = content
        currentContent = content
    }
    
    public func next() -> XContent? {
        currentContent = currentContent?._next
        return currentContent
    }
    
    public func previous() -> XContent? {
        if currentContent === content {
            return nil
        }
        else {
            currentContent = currentContent?._previous
            if currentContent === content {
                return nil
            }
        }
        return currentContent
    }
}

/**
 Iterates though the content before a content.
 */
public final class XPreviousIterator: XContentIteratorProtocol {
    
    weak var content: XContent?
    weak var currentContent: XContent? = nil
    
    public init(
        node: XContent
    ) {
        self.content = node
        currentContent = node
    }
    
    public func next() -> XContent? {
        currentContent = currentContent?._previous
        return currentContent
    }
    
    public func previous() -> XContent? {
        if currentContent === content {
            return nil
        }
        else {
            currentContent = currentContent?._next
            if currentContent === content {
                return nil
            }
        }
        return currentContent
    }
}

/**
 Iterates though the elements before a node.
 */
public final class XPreviousElementsIterator: XElementIteratorProtocol {
    
    weak var content: XContent?
    weak var currentContent: XContent? = nil
    
    public init(
        content: XContent
    ) {
        self.content = content
        currentContent = content
    }
    
    public func next() -> XElement? {
        repeat {
            currentContent = currentContent?._previous
        } while currentContent != nil && !(currentContent! is XElement)
        return currentContent as? XElement
    }
    
    public func previous() -> XElement? {
        repeat {
            if currentContent === content {
                return nil
            }
            else {
                currentContent = currentContent?._next
                if currentContent === content {
                    return nil
                }
            }
        } while currentContent != nil && !(currentContent! is XElement)
        return currentContent as? XElement
    }
}

/**
 Iterates though the elements after a content.
 */
public final class XNextElementsIterator: XElementIteratorProtocol {
    
    weak var content: XContent?
    weak var currentContent: XContent? = nil
    
    public init(
        content: XContent
    ) {
        self.content = content
        currentContent = content
    }
    
    public func next() -> XElement? {
        repeat {
            currentContent = currentContent?._next
        } while currentContent != nil && !(currentContent! is XElement)
        return currentContent as? XElement
    }
    
    public func previous() -> XElement? {
        repeat {
            if currentContent === content {
                return nil
            }
            else {
                currentContent = currentContent?._previous
                if currentContent === content {
                    return nil
                }
            }
        } while currentContent != nil && !(currentContent! is XElement)
        return currentContent as? XElement
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
                currentNode = (node as? XBranchInternal)?._firstContent
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
public final class XAllContentsIterator: XContentIteratorProtocol {
    
    weak var startNode: XNode?
    weak var currentNode: XNode? = nil
    
    public init(
        node: XNode
    ) {
        self.startNode = node
        self.currentNode = node
    }
    
    public func next() -> XContent? {
        if startNode?.getLastInTree() === currentNode {
            currentNode = nil
        }
        else {
            currentNode = currentNode?._nextInTree
        }
        return currentNode as? XContent
    }
    
    public func previous() -> XContent? {
        if currentNode === startNode {
            currentNode = nil
        }
        else {
            currentNode = currentNode?._previousInTree as? XContent
        }
        return currentNode as? XContent
    }
}

/**
 Iterates though all content (tree traversal) of a branch.
 */
public final class XAllContentsIncludingSelfIterator: XContentIteratorProtocol {
    
    weak var startNode: XNode?
    weak var currentNode: XNode? = nil
    var started = false
    
    public init(
        node: XNode
    ) {
        self.startNode = node
    }
    
    public func next() -> XContent? {
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
        return currentNode as? XContent
    }
    
    public func previous() -> XContent? {
        if currentNode === startNode {
            currentNode = nil
            started = false
            return nil
        }
        else {
            currentNode = currentNode?._previousInTree
            return currentNode as? XContent
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
public final class XTreeIterator: XContentIteratorProtocol {
    
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
    
    public func next() -> XContent? {
        if started {
            while true {
                if downDirection,
                   let branch = currentNode as? XBranchInternal {
                    if let firstChild = branch._firstContent {
                        currentNode = firstChild
                        directionIndicator.up = false
                        return currentNode as? XContent
                    }
                    else {
                        downDirection = false
                        directionIndicator.up = true
                        return branch as? XContent
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
                    if let theCurrentNode = currentNode as? XBranchInternal {
                        directionIndicator.up = true
                        return theCurrentNode as? XContent
                    }
                    else {
                        return nil
                    }
                }
            }
        }
        else {
            currentNode = startNode
            if let document = currentNode as? XDocument {
                currentNode = document._firstContent
            }
            started = true
            return currentNode as? XContent
        }
    }
    
    public func previous() -> XContent? {
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
            return currentNode as? XContent
        }
        return nil
    }
    
}

/**
Iterator that iterates over exactly one node. This ist mainly for testing.
 */
public final class XContentSelfIterator: XContentIteratorProtocol {
    
    weak var theContent: XContent?
    private var done: Bool = false
    
    public init(content: XContent) {
        self.theContent = content
    }
    
    public func next() -> XContent? {
        if done {
            return nil
        }
        else {
            done = true
            return theContent
        }
    }
    
    public func previous() -> XContent? {
        return nil // do nothing
    }
}

/**
Iterator that iterates over exactly one element. This ist mainly for testing.
 */
public final class XElementSelfIterator: XElementIteratorProtocol {
    
    weak var element: XElement?
    private var done: Bool = false
    
    public init(element: XElement) {
        self.element = element
    }
    
    public func next() -> XElement? {
        if done {
            return nil
        }
        else {
            done = true
            return element
        }
    }
    
    public func previous() -> XElement? {
        return nil // do nothing
    }
}
