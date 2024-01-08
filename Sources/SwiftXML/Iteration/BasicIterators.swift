//===--- BasicIterators.swift ---------------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
// and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

import Foundation

public class XContentIterator: IteratorProtocol, XContentIteratorProtocol {
    public typealias Element = XContent
    public func next() -> XContent? {
        return nil
    }
    public func previous() -> XContent? {
        return nil
    }
}

public class XTextIterator: IteratorProtocol, XTextIteratorProtocol {
    public typealias Element = XText
    public func next() -> XText? {
        return nil
    }
    public func previous() -> XText? {
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

public class XContentIteratorWhileCondition: XContentIterator {
    
    let iterator: XContentIterator
    let condition: (XContent) -> Bool
    
    init(iterator: XContentIterator, while condition: @escaping (XContent) -> Bool) {
        self.iterator = iterator
        self.condition = condition
    }
    
    public override func next() -> XContent? {
        if let node = iterator.next(), condition(node) {
            return node
        }
        else {
            return nil
        }
    }
}

public class XContentIteratorUntilCondition: XContentIterator {
    
    let iterator: XContentIterator
    let condition: (XContent) -> Bool
    
    init(iterator: XContentIterator, until condition: @escaping (XContent) -> Bool) {
        self.iterator = iterator
        self.condition = condition
    }
    
    public override func next() -> XContent? {
        if let node = iterator.next(), !condition(node) {
            return node
        }
        else {
            return nil
        }
    }
}

public class XContentIteratorIncludingCondition: XContentIterator {
    
    let iterator: XContentIterator
    let condition: (XContent) -> Bool
    var found = false
    
    init(iterator: XContentIterator, untilAndIncluding condition: @escaping (XContent) -> Bool) {
        self.iterator = iterator
        self.condition = condition
    }
    
    public override func next() -> XContent? {
        if found {
            return nil
        } else if let node = iterator.next() {
            found = condition(node)
            return node
        } else {
            return nil
        }
    }
}

public class XTextIteratorWithCondition: XTextIterator {
    
    let iterator: XTextIterator
    let condition: (XText) -> Bool
    
    init(iterator: XTextIterator, condition: @escaping (XText) -> Bool) {
        self.iterator = iterator
        self.condition = condition
    }
    
    public override func next() -> XText? {
        var _next: XText? = nil
        repeat {
            _next = iterator.next()
            if let node = _next, condition(node) {
                return node
            }
        } while _next != nil
        return nil
    }
}

public class XTextIteratorWhileCondition: XTextIterator {
    
    let iterator: XTextIterator
    let condition: (XText) -> Bool
    
    init(iterator: XTextIterator, while condition: @escaping (XText) -> Bool) {
        self.iterator = iterator
        self.condition = condition
    }
    
    public override func next() -> XText? {
        if let node = iterator.next(), condition(node) {
            return node
        }
        else {
            return nil
        }
    }
}

public class XTextIteratorUntilCondition: XTextIterator {
    
    let iterator: XTextIterator
    let condition: (XText) -> Bool
    
    init(iterator: XTextIterator, until condition: @escaping (XText) -> Bool) {
        self.iterator = iterator
        self.condition = condition
    }
    
    public override func next() -> XText? {
        if let text = iterator.next(), !condition(text) {
            return text
        }
        else {
            return nil
        }
    }
}

public class XTextIteratorIncludingCondition: XTextIterator {
    
    let iterator: XTextIterator
    let condition: (XText) -> Bool
    var found = false
    
    init(iterator: XTextIterator, untilAndIncluding condition: @escaping (XText) -> Bool) {
        self.iterator = iterator
        self.condition = condition
    }
    
    public override func next() -> XText? {
        if found {
            return nil
        } else if let text = iterator.next() {
            found = condition(text)
            return text
        } else {
            return nil
        }
    }
}

public class XContentSequence: LazySequenceProtocol {
    public func makeIterator() -> XContentIterator {
        return XContentIterator()
    }
}

public class XTextSequence: LazySequenceProtocol {
    public func makeIterator() -> XTextIterator {
        return XTextIterator()
    }
}

public class XElementIterator: IteratorProtocol, XElementIteratorProtocol {
    public typealias Element = XElement
    public func next() -> XElement? {
        return nil
    }
    public func previous() -> XElement? {
        return nil
    }
}

public class XStringIterator: IteratorProtocol {
    public typealias Element = String
    public func next() -> String? {
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

public class XElementIteratorWhileCondition: XElementIterator {
    
    let iterator: XElementIterator
    let condition: (XElement) -> Bool
    
    init(iterator: XElementIterator, while condition: @escaping (XElement) -> Bool) {
        self.iterator = iterator
        self.condition = condition
    }
    
    init(iterator: XElementIterator, elementName: String) {
        self.iterator = iterator
        self.condition = { $0.name == elementName }
    }
    
    public override func next() -> XElement? {
        if let element = iterator.next(), condition(element) {
            return element
        }
        else {
            return nil
        }
    }
}

public class XElementIteratorUntilCondition: XElementIterator {
    
    let iterator: XElementIterator
    let condition: (XElement) -> Bool
    
    init(iterator: XElementIterator, until condition: @escaping (XElement) -> Bool) {
        self.iterator = iterator
        self.condition = condition
    }
    
    init(iterator: XElementIterator, elementName: String) {
        self.iterator = iterator
        self.condition = { $0.name == elementName }
    }
    
    public override func next() -> XElement? {
        if let element = iterator.next(), !condition(element) {
            return element
        }
        else {
            return nil
        }
    }
}

public class XElementIteratorIncludingCondition: XElementIterator {
    
    let iterator: XElementIterator
    let condition: (XElement) -> Bool
    var found = false
    
    init(iterator: XElementIterator, untilAndIncluding condition: @escaping (XElement) -> Bool) {
        self.iterator = iterator
        self.condition = condition
    }
    
    init(iterator: XElementIterator, elementName: String) {
        self.iterator = iterator
        self.condition = { $0.name == elementName }
    }
    
    public override func next() -> XElement? {
        if found {
            return nil
        } else if let element = iterator.next() {
            found = condition(element)
            return element
        } else {
            return nil
        }
    }
}

public class XElementSequence: LazySequenceProtocol, Sequence {
    public typealias Element = XElement
    public func makeIterator() -> XElementIterator {
        return XElementIterator()
    }
}

public class XStringSequence: LazySequenceProtocol, Sequence {
    public typealias Element = String
    public func makeIterator() -> XStringIterator {
        return XStringIterator()
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
    
    public init(fromArray array: Array<XContentLike?>) {
        self.array = array
    }
    
    public override func makeIterator() -> XContentLikeIterator {
        return XContentLikeIteratorFromArray(fromArray: array)
    }
}

public class XContentLikeIteratorFromArray: XContentLikeIterator {
    let array: Array<XContentLike?>
    var nextIndex = -1
    
    public init(fromArray array: Array<XContentLike?>) {
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

public class XContentLikeSequenceFromLazyElementFilterSequence: XContentLikeSequence {
    let sequence: LazyFilterSequence<XElementSequence>
    
    public init(fromSequence sequence: LazyFilterSequence<XElementSequence>) {
        self.sequence = sequence
    }
    
    public override func makeIterator() -> XContentLikeIterator {
        return XContentLikeIteratorFromLazyElementFilterSequence(fromSequence: sequence)
    }
}

public class XContentLikeIteratorFromLazyElementFilterSequence: XContentLikeIterator {
    var iterator: LazyFilterSequence<XElementSequence>.Iterator
    
    public init(fromSequence sequence: LazyFilterSequence<XElementSequence>) {
        iterator = sequence.makeIterator()
    }
    
    public override func next() -> XContentLike? {
        return iterator.next()
    }
}

public class XContentLikeSequenceFromLazyContentFilterSequence: XContentLikeSequence {
    let sequence: LazyFilterSequence<XContentSequence>
    
    public init(fromSequence sequence: LazyFilterSequence<XContentSequence>) {
        self.sequence = sequence
    }
    
    public override func makeIterator() -> XContentLikeIterator {
        return XContentLikeIteratorFromLazyContentFilterSequence(fromSequence: sequence)
    }
}

public class XContentLikeIteratorFromLazyContentFilterSequence: XContentLikeIterator {
    var iterator: LazyFilterSequence<XContentSequence>.Iterator
    
    public init(fromSequence sequence: LazyFilterSequence<XContentSequence>) {
        iterator = sequence.makeIterator()
    }
    
    public override func next() -> XContentLike? {
        return iterator.next()
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
 Iterates though the content of a branch.
 */
public final class XContentsIterator: XContentIteratorProtocol {
    
    private var started = false
    weak var node: XNode?
    weak var currentContent: XContent? = nil
    
    public init(
        node: XNode
    ) {
        self.node = node
    }
    
    public func next() -> XContent? {
        repeat {
            if started {
                currentContent = currentContent?._next
            }
            else {
                currentContent = (node as? XBranchInternal)?.__firstContent
                started = true
            }
        } while currentContent != nil && currentContent! is _Isolator_
        return currentContent
    }
    
    public func previous() -> XContent? {
        repeat {
            if started {
                currentContent = currentContent?._previous
                if currentContent == nil {
                    started = false
                }
            }
        } while currentContent != nil && currentContent! is _Isolator_
        return currentContent
    }
}

/**
 Iterates though the content of a branch.
 */
public final class XReversedContentsIterator: XContentIteratorProtocol {
    
    private var started = false
    weak var node: XNode?
    weak var currentContent: XContent? = nil
    
    public init(
        node: XNode
    ) {
        self.node = node
    }
    
    public func next() -> XContent? {
        repeat {
            if started {
                currentContent = currentContent?._previous
            }
            else {
                currentContent = (node as? XBranchInternal)?.__lastContent
                started = true
            }
        } while currentContent != nil && currentContent! is _Isolator_
        return currentContent
    }
    
    public func previous() -> XContent? {
        repeat {
            if started {
                currentContent = currentContent?._next
                if currentContent == nil {
                    started = false
                }
            }
        } while currentContent != nil && currentContent! is _Isolator_
        return currentContent
    }
}

/**
 Iterates though the content after a content.
 */
public final class XNextIterator: XContentIteratorProtocol {
    
    weak var content: XContent?
    weak var currentContent: XContent? = nil
    
    public init(
        content: XContent
    ) {
        self.content = content
        currentContent = content
    }
    
    public func next() -> XContent? {
        repeat {
            currentContent = currentContent?._next
        } while currentContent != nil && currentContent! is _Isolator_
        return currentContent
    }
    
    public func previous() -> XContent? {
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
        } while currentContent != nil && currentContent! is _Isolator_
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
        content: XContent
    ) {
        self.content = content
        currentContent = content
    }
    
    public func next() -> XContent? {
        repeat {
            currentContent = currentContent?._previous
        } while currentContent != nil && currentContent! is _Isolator_
        return currentContent
    }
    
    public func previous() -> XContent? {
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
        } while currentContent != nil && currentContent! is _Isolator_
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
 Iterates though the texts of a branch.
 */
public final class XTextsIterator: XTextIterator {
    
    private var started = false
    weak var node: XNode?
    weak var currentNode: XNode? = nil
    
    public init(
        node: XNode
    ) {
        self.node = node
    }
    
    public override func next() -> XText? {
        repeat {
            if started {
                currentNode = currentNode?._next
            }
            else {
                currentNode = (node as? XBranchInternal)?.__firstContent
                started = true
            }
        } while currentNode != nil && !(currentNode! is XText)
        return currentNode as? XText
    }
    
    public override func previous() -> XText? {
        repeat {
            if started {
                currentNode = currentNode?._previous
                if currentNode == nil {
                    started = false
                }
            }
        } while currentNode != nil && !(currentNode! is XText)
        return currentNode as? XText
    }
}

/**
 Iterates though the texts of a branch, reversely.
 */
public final class XReversedAllTextsIterator: XTextIteratorProtocol {
    
    private var started = false
    weak var node: XNode?
    weak var currentNode: XNode? = nil
    
    public init(
        node: XNode
    ) {
        self.node = node
    }
    
    public func next() -> XText? {
        repeat {
            if started {
                currentNode = currentNode?._previous
            }
            else {
                currentNode = (node as? XBranchInternal)?.__lastContent
                started = true
            }
        } while currentNode != nil && !(currentNode! is XText)
        return currentNode as? XText
    }
    
    public func previous() -> XText? {
        repeat {
            if started {
                currentNode = currentNode?._next
                if currentNode == nil {
                    started = false
                }
            }
        } while currentNode != nil && !(currentNode! is XText)
        return currentNode as? XText
    }
}

/**
 Iterates though the texts before a node.
 */
public final class XPreviousTextsIterator: XTextIteratorProtocol {
    
    weak var content: XContent?
    weak var currentContent: XContent? = nil
    
    public init(
        content: XContent
    ) {
        self.content = content
        currentContent = content
    }
    
    public func next() -> XText? {
        repeat {
            currentContent = currentContent?._previous
        } while currentContent != nil && !(currentContent! is XText)
        return currentContent as? XText
    }
    
    public func previous() -> XText? {
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
        } while currentContent != nil && !(currentContent! is XText)
        return currentContent as? XText
    }
}

/**
 Iterates though the texts after a content.
 */
public final class XNextTextsIterator: XTextIteratorProtocol {
    
    weak var content: XContent?
    weak var currentContent: XContent? = nil
    
    public init(
        content: XContent
    ) {
        self.content = content
        currentContent = content
    }
    
    public func next() -> XText? {
        repeat {
            currentContent = currentContent?._next
        } while currentContent != nil && !(currentContent! is XText)
        return currentContent as? XText
    }
    
    public func previous() -> XText? {
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
        } while currentContent != nil && !(currentContent! is XText)
        return currentContent as? XText
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
                currentNode = (node as? XBranchInternal)?.__firstContent
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
 Iterates though the children of a branch, reversely.
 */
public final class XReversedChildrenIterator: XElementIteratorProtocol {
    
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
                currentNode = currentNode?._previous
            }
            else {
                currentNode = (node as? XBranchInternal)?.__lastContent
                started = true
            }
        } while currentNode != nil && !(currentNode! is XElement)
        return currentNode as? XElement
    }
    
    public func previous() -> XElement? {
        repeat {
            if started {
                currentNode = currentNode?._next
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
                currentNode = startNode?.parent
                if ancestorCount >= 2 {
                    for _ in 2...ancestorCount {
                        currentNode = currentNode?.parent
                    }
                }
            }
        }
        return currentNode
    }
}

/**
 Iterates though the ancestors, including self if self is an element.
 */
public final class XAncestorsIteratorIncludingSelf: XElementIteratorProtocol {
    
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
            currentNode = (startNode as? XElement) ??  startNode?.parent
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
                currentNode = (startNode as? XElement) ??  startNode?.parent
                if ancestorCount >= 2 {
                    for _ in 2...ancestorCount {
                        currentNode = currentNode?.parent
                    }
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
        repeat {
            if startNode?.getLastInTree() === currentNode {
                currentNode = nil
            }
            else {
                currentNode = currentNode?._nextInTree
            }
        } while currentNode != nil && currentNode! is _Isolator_
        return currentNode as? XContent
    }
    
    public func previous() -> XContent? {
        repeat {
            if currentNode === startNode {
                currentNode = startNode
                return nil
            }
            else {
                currentNode = currentNode?._previousInTree
            }
        } while currentNode != nil && currentNode! is _Isolator_
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
            if !(currentNode is _Isolator_ || currentNode is XDocument) {
                return currentNode as? XContent
            }
        } while currentNode != nil
        return nil
    }
    
    public func previous() -> XContent? {
        repeat {
            if currentNode === startNode {
                currentNode = nil
                started = false
            }
            else {
                currentNode = currentNode?._previousInTree
                if !(currentNode is _Isolator_) {
                    return currentNode as? XContent
                }
            }
        } while currentNode != nil
        return nil
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
 Iterates though all texts (tree traversal) of a branch.
 */
public final class XAllTextsIterator: XTextIteratorProtocol {
    
    weak var startNode: XNode?
    weak var currentNode: XNode? = nil
    
    public init(
        node: XNode
    ) {
        self.startNode = node
        self.currentNode = node
    }
    
    public func next() -> XText? {
        repeat {
            if startNode?.getLastInTree() === currentNode {
                currentNode = nil
            }
            else {
                currentNode = currentNode?._nextInTree
                if let element = currentNode as? XText {
                    return element
                }
            }
        } while currentNode != nil
        return nil
    }
    
    public func previous() -> XText? {
        repeat {
            if currentNode === startNode {
                currentNode = startNode
                return nil
            }
            else {
                currentNode = currentNode?._previousInTree
                if let element = currentNode as? XText {
                    return element
                }
            }
        } while currentNode != nil
        return nil
    }
}

/**
 Iterates though all elements (tree traversal) of a branch, including teh start node itself if it is an element.
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

public enum XDirection { case down, up }

public final class XDirectionIndicator {
    
    var _direction: XDirection = .down
    
    public var direction: XDirection { _direction }
    
    public init() {}
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
    
    private func _next() -> XContent? {
        if started {
            while true {
                if downDirection,
                   let branch = currentNode as? XBranchInternal {
                    if let firstChild = branch.__firstContent {
                        currentNode = firstChild
                        directionIndicator._direction = .down
                        return currentNode as? XContent
                    }
                    else {
                        downDirection = false
                        directionIndicator._direction = .up
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
                    directionIndicator._direction = .down
                    return next
                }
                else {
                    if downDirection {
                        downDirection = false
                    }
                    currentNode = currentNode?._parent
                    if let theCurrentNode = currentNode as? XBranchInternal {
                        directionIndicator._direction = .up
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
                currentNode = document.__firstContent
            }
            started = true
            return currentNode as? XContent
        }
    }
    
    public func next() -> XContent? {
        while true {
            let node = _next()
            if !(node is _Isolator_) {
                return node
            }
        }
    }
    
    private func _previous() -> XContent? {
        if started {
            if currentNode === startNode {
                currentNode = nil
                started = false
            }
            else if let thePrevious = currentNode?._previous {
                currentNode = thePrevious
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
    
    public func previous() -> XContent? {
        while true {
            let node = _previous()
            if !(node is _Isolator_) {
                return node
            }
        }
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
