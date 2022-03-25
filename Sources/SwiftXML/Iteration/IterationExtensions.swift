//
//  File.swift
//  
//
//  Created by Stefan Springer on 27.09.21.
//

import Foundation

public extension XBranch {
    
    var content: XContentSequence {
        get { XSequenceOfContent(node: self) }
    }
    
    func content(_ condition: @escaping (XNode) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XSequenceOfContent(node: self), condition: condition)
    }
    
    func content(while condition: @escaping (XNode) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XSequenceOfContent(node: self), while: condition)
    }
    
    func content(until condition: @escaping (XNode) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XSequenceOfContent(node: self), until: condition)
    }
    
    var contentReversed: XContentSequence {
        get { XReversedSequenceOfContent(node: self) }
    }
    
    func contentReversed(_ condition: @escaping (XNode) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XReversedSequenceOfContent(node: self), condition: condition)
    }
    
    func contentReversed(while condition: @escaping (XNode) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XReversedSequenceOfContent(node: self), while: condition)
    }
    
    func contentReversed(until condition: @escaping (XNode) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XReversedSequenceOfContent(node: self), until: condition)
    }
    
    var children: XElementSequence {
        get { return XChildrenSequence(node: self) }
    }
    
    func children(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), condition: condition)
    }
    
    func children(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), elementName: name)
    }
    
    func children(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XChildrenSequence(node: self), while: condition)
    }
    
    func children(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XChildrenSequence(node: self), until: condition)
    }
    
    var childrenReversed: XElementSequence {
        get { return XReversedChildrenSequence(node: self) }
    }
    
    func childrenReversed(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XReversedChildrenSequence(node: self), condition: condition)
    }
    
    func childrenReversed(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XReversedChildrenSequence(node: self), elementName: name)
    }
    
    func childrenReversed(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XReversedChildrenSequence(node: self), while: condition)
    }
    
    func childrenReversed(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XReversedChildrenSequence(node: self), until: condition)
    }
    
    var allContent: XContentSequence {
        get { XAllContentSequence(node: self) }
    }
    
    func allContent(_ condition: @escaping (XNode) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XAllContentSequence(node: self), condition: condition)
    }
    
    func allContent(while condition: @escaping (XNode) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XAllContentSequence(node: self), while: condition)
    }
    
    func allContent(until condition: @escaping (XNode) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XAllContentSequence(node: self), until: condition)
    }
    
    var descendants: XElementSequence {
        get { XDescendantsSequence(node: self) }
    }
    
    func descendants(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), condition: condition)
    }
    
    func descendants(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), elementName: name)
    }
    
    func descendants(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XDescendantsSequence(node: self), while: condition)
    }
    
    func descendants(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XDescendantsSequence(node: self), until: condition)
    }
    
}

extension XContent {
    
    public var ancestors: XElementSequence {
        get { XAncestorsSequence(node: self) }
    }
    
    public func ancestors(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequence(node: self), condition: condition)
    }
    
    public func ancestors(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequence(node: self), elementName: name)
    }
    
    public func ancestors(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XAncestorsSequence(node: self), while: condition)
    }
    
    public func ancestors(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XAncestorsSequence(node: self), until: condition)
    }
    
    public var content: XContentSequence {
        get { XSequenceOfContent(node: self) }
    }
    
    public func content(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XSequenceOfContent(node: self), condition: condition)
    }
    
    public func content(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XSequenceOfContent(node: self), while: condition)
    }
    
    public func content(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XSequenceOfContent(node: self), until: condition)
    }
    
    public var contentReversed: XContentSequence {
        get { XReversedSequenceOfContent(node: self) }
    }
    
    public func contentReversed(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XReversedSequenceOfContent(node: self), condition: condition)
    }
    
    public func contentReversed(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XReversedSequenceOfContent(node: self), while: condition)
    }
    
    public func contentReversed(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XReversedSequenceOfContent(node: self), until: condition)
    }
    
    public var children: XElementSequence {
        get { return XChildrenSequence(node: self) }
    }
    
    public func children(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), condition: condition)
    }
    
    public func children(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), elementName: name)
    }
    
    public func children(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XChildrenSequence(node: self), while: condition)
    }
    
    public func children(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XChildrenSequence(node: self), until: condition)
    }
    
    public var childrenReversed: XElementSequence {
        get { return XReversedChildrenSequence(node: self) }
    }
    
    public func childrenReversed(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XReversedChildrenSequence(node: self), condition: condition)
    }
    
    public func childrenReversed(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XReversedChildrenSequence(node: self), elementName: name)
    }
    
    public func childrenReversed(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XReversedChildrenSequence(node: self), while: condition)
    }
    
    public func childrenReversed(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XReversedChildrenSequence(node: self), until: condition)
    }
    
    public var next: XContentSequence {
        get { XNextSequence(content: self) }
    }
    
    public func next(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XNextSequence(content: self), condition: condition)
    }
    
    public func next(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XNextSequence(content: self), while: condition)
    }
    
    public func next(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XNextSequence(content: self), until: condition)
    }
    
    public var previous: XContentSequence {
        get { XPreviousSequence(content: self) }
    }
    
    public func previous(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XPreviousSequence(content: self), condition: condition)
    }
    
    public func previous(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XPreviousSequence(content: self), while: condition)
    }
    
    public func previous(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XPreviousSequence(content: self), until: condition)
    }
    
    public var nextElements: XElementSequence {
        get { XNextElementsSequence(content: self) }
    }
    
    public func nextElements(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextElementsSequence(content: self), condition: condition)
    }
    
    public func nextElements(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextElementsSequence(content: self), elementName: name)
    }
    
    public func nextElements(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XNextElementsSequence(content: self), while: condition)
    }
    
    public func nextElements(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XNextElementsSequence(content: self), until: condition)
    }
    
    public var previousElements: XElementSequence {
        get { XPreviousElementsSequence(content: self) }
    }
    
    public func previousElements(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousElementsSequence(content: self), condition: condition)
    }
    
    public func previousElements(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousElementsSequence(content: self), elementName: name)
    }
    
    public func previousElements(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XPreviousElementsSequence(content: self), while: condition)
    }
    
    public func previousElements(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XPreviousElementsSequence(content: self), until: condition)
    }
    
    public var allContent: XContentSequence {
        get { XAllContentSequence(node: self) }
    }
    
    public func allContent(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XAllContentSequence(node: self), condition: condition)
    }
    
    public func allContent(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XAllContentSequence(node: self), while: condition)
    }
    
    public func allContent(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XAllContentSequence(node: self), until: condition)
    }
    
    public var allContentIncludingSelf: XContentSequence {
        get { XAllContentIncludingSelfSequence(node: self) }
    }
    
    public func allContentIncludingSelf(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XAllContentIncludingSelfSequence(node: self), condition: condition)
    }
    
    public func allContentIncludingSelf(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XAllContentIncludingSelfSequence(node: self), while: condition)
    }
    
    public func allContentIncludingSelf(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XAllContentIncludingSelfSequence(node: self), until: condition)
    }
    
    public var descendants: XElementSequence {
        get { XDescendantsSequence(node: self) }
    }
    
    public func descendants(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), condition: condition)
    }
    
    public func descendants(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), elementName: name)
    }
    
    public func descendants(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XDescendantsSequence(node: self), while: condition)
    }
    
    public func descendants(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XDescendantsSequence(node: self), until: condition)
    }
    
}

extension XElement {
    
    public var descendantsIncludingSelf: XElementSequence { get { XDescendantsIncludingSelfSequence(element: self) } }
    
    public func descendantsIncludingSelf(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsIncludingSelfSequence(element: self), condition: condition)
    }
    
    public func descendantsIncludingSelf(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsIncludingSelfSequence(element: self), elementName: name)
    }
    
    public func descendantsIncludingSelf(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XDescendantsIncludingSelfSequence(element: self), while: condition)
    }
    
    public func descendantsIncludingSelf(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XDescendantsIncludingSelfSequence(element: self), until: condition)
    }
}

public extension XContentSequence {
    
    func findFirst() -> XContent? {
        return makeIterator().next()
    }
    
    func findLast() -> XContent? {
        let iterator = makeIterator()
        var content: XContent? = nil
        var next: XContent? = nil
        repeat {
            content = next
            next = iterator.next()
        } while next != nil
        return content
    }
    
    func find(index: Int) -> XContent? {
        let iterator = makeIterator()
        var position = 0
        var content: XContent? = nil
        while position <= index {
            content = iterator.next()
            if content == nil {
                return nil
            }
            position += 1
        }
        return content
    }
    
    var exist: Bool { get { makeIterator().next() != nil } }
    
}

public extension XElementSequence {
    
    func findFirst() -> XElement? {
        return makeIterator().next()
    }
    
    func findLast() -> XElement? {
        let iterator = makeIterator()
        var element: XElement? = nil
        var next: XElement? = nil
        repeat {
            element = next
            next = iterator.next()
        } while next != nil
        return element
    }
    
    func find(index: Int) -> XElement? {
        let iterator = makeIterator()
        var position = 0
        var element: XElement? = nil
        while position <= index {
            element = iterator.next()
            if element == nil {
                return nil
            }
            position += 1
        }
        return element
    }
    
    var exist: Bool { get { makeIterator().next() != nil } }
    
}
