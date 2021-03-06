//
//  IterationExtensions.swift
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
        get { XChildrenSequence(node: self) }
    }
    
    func children(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), condition: condition)
    }
    
    func children(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), elementName: name)
    }
    
    func children(_ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), condition: { names.contains($0.name) })
    }
    
    func children(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XChildrenSequence(node: self), while: condition)
    }
    
    func children(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XChildrenSequence(node: self), until: condition)
    }
    
    var childrenReversed: XElementSequence {
        get { XReversedChildrenSequence(node: self) }
    }
    
    func childrenReversed(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XReversedChildrenSequence(node: self), condition: condition)
    }
    
    func childrenReversed(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XReversedChildrenSequence(node: self), elementName: name)
    }
    
    func childrenReversed(_ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XReversedChildrenSequence(node: self), condition: { names.contains($0.name) })
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
    
    func descendants(_ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), condition: { names.contains($0.name) })
    }
    
    func descendants(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XDescendantsSequence(node: self), while: condition)
    }
    
    func descendants(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XDescendantsSequence(node: self), until: condition)
    }
    
}

public extension XContent {
    
    var ancestors: XElementSequence {
        get { XAncestorsSequence(node: self) }
    }
    
    func ancestors(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequence(node: self), condition: condition)
    }
    
    func ancestors(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequence(node: self), elementName: name)
    }
    
    func ancestors(_ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequence(node: self), condition: { names.contains($0.name) })
    }
    
    func ancestors(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XAncestorsSequence(node: self), while: condition)
    }
    
    func ancestors(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XAncestorsSequence(node: self), until: condition)
    }
    
    var content: XContentSequence {
        get { XSequenceOfContent(node: self) }
    }
    
    func content(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XSequenceOfContent(node: self), condition: condition)
    }
    
    func content(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XSequenceOfContent(node: self), while: condition)
    }
    
    func content(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XSequenceOfContent(node: self), until: condition)
    }
    
    var contentReversed: XContentSequence {
        get { XReversedSequenceOfContent(node: self) }
    }
    
    func contentReversed(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XReversedSequenceOfContent(node: self), condition: condition)
    }
    
    func contentReversed(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XReversedSequenceOfContent(node: self), while: condition)
    }
    
    func contentReversed(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XReversedSequenceOfContent(node: self), until: condition)
    }
    
    var children: XElementSequence {
        get { XChildrenSequence(node: self) }
    }
    
    func children(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), condition: condition)
    }
    
    func children(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), elementName: name)
    }
    
    func children(_ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), condition: { names.contains($0.name) })
    }
    
    func children(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XChildrenSequence(node: self), while: condition)
    }
    
    func children(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XChildrenSequence(node: self), until: condition)
    }
    
    var childrenReversed: XElementSequence {
        get { XReversedChildrenSequence(node: self) }
    }
    
    func childrenReversed(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XReversedChildrenSequence(node: self), condition: condition)
    }
    
    func childrenReversed(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XReversedChildrenSequence(node: self), elementName: name)
    }
    
    func childrenReversed(_ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XReversedChildrenSequence(node: self), condition: { names.contains($0.name) })
    }
    
    func childrenReversed(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XReversedChildrenSequence(node: self), while: condition)
    }
    
    func childrenReversed(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XReversedChildrenSequence(node: self), until: condition)
    }
    
    var next: XContentSequence {
        get { XNextSequence(content: self) }
    }
    
    func next(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XNextSequence(content: self), condition: condition)
    }
    
    func next(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XNextSequence(content: self), while: condition)
    }
    
    func next(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XNextSequence(content: self), until: condition)
    }
    
    var previous: XContentSequence {
        get { XPreviousSequence(content: self) }
    }
    
    func previous(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XPreviousSequence(content: self), condition: condition)
    }
    
    func previous(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XPreviousSequence(content: self), while: condition)
    }
    
    func previous(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XPreviousSequence(content: self), until: condition)
    }
    
    var nextElements: XElementSequence {
        get { XNextElementsSequence(content: self) }
    }
    
    func nextElements(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextElementsSequence(content: self), condition: condition)
    }
    
    func nextElements(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextElementsSequence(content: self), elementName: name)
    }
    
    func nextElements(_ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextElementsSequence(content: self), condition: { names.contains($0.name) })
    }
    
    func nextElements(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XNextElementsSequence(content: self), while: condition)
    }
    
    func nextElements(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XNextElementsSequence(content: self), until: condition)
    }
    
    var previousElements: XElementSequence {
        get { XPreviousElementsSequence(content: self) }
    }
    
    func previousElements(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousElementsSequence(content: self), condition: condition)
    }
    
    func previousElements(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousElementsSequence(content: self), elementName: name)
    }
    
    func previousElements(_ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousElementsSequence(content: self), condition: { names.contains($0.name) })
    }
    
    func previousElements(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XPreviousElementsSequence(content: self), while: condition)
    }
    
    func previousElements(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XPreviousElementsSequence(content: self), until: condition)
    }
    
    var allContent: XContentSequence {
        get { XAllContentSequence(node: self) }
    }
    
    func allContent(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XAllContentSequence(node: self), condition: condition)
    }
    
    func allContent(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XAllContentSequence(node: self), while: condition)
    }
    
    func allContent(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XAllContentSequence(node: self), until: condition)
    }
    
    var allContentIncludingSelf: XContentSequence {
        get { XAllContentIncludingSelfSequence(node: self) }
    }
    
    func allContentIncludingSelf(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XAllContentIncludingSelfSequence(node: self), condition: condition)
    }
    
    func allContentIncludingSelf(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XAllContentIncludingSelfSequence(node: self), while: condition)
    }
    
    func allContentIncludingSelf(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XAllContentIncludingSelfSequence(node: self), until: condition)
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
    
    func descendants(_ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), condition: { names.contains($0.name) })
    }
    
    func descendants(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XDescendantsSequence(node: self), while: condition)
    }
    
    func descendants(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XDescendantsSequence(node: self), until: condition)
    }
    
}

public extension XElement {
    
    var descendantsIncludingSelf: XElementSequence { get { XDescendantsIncludingSelfSequence(element: self) } }
    
    func descendantsIncludingSelf(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsIncludingSelfSequence(element: self), condition: condition)
    }
    
    func descendantsIncludingSelf(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsIncludingSelfSequence(element: self), elementName: name)
    }
    
    func descendantsIncludingSelf(_ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsIncludingSelfSequence(element: self), condition: { names.contains($0.name) })
    }
    
    func descendantsIncludingSelf(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XDescendantsIncludingSelfSequence(element: self), while: condition)
    }
    
    func descendantsIncludingSelf(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XDescendantsIncludingSelfSequence(element: self), until: condition)
    }
}

public extension XContentSequence {
    
    var first: XContent? {
        return makeIterator().next()
    }
    
    var last: XContent? {
        let iterator = makeIterator()
        var content: XContent? = nil
        var next: XContent? = nil
        repeat {
            content = next
            next = iterator.next()
        } while next != nil
        return content
    }
    
    func at(index: Int) -> XContent? {
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
    
    var existing: XContentSequence? { exist ? self : nil }
    
}

public extension XElementSequence {
    
    var first: XElement? {
        return makeIterator().next()
    }
    
    var last: XElement? {
        let iterator = makeIterator()
        var element: XElement? = nil
        var next: XElement? = nil
        repeat {
            element = next
            next = iterator.next()
        } while next != nil
        return element
    }
    
    func at(index: Int) -> XElement? {
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
    
    var existing: XElementSequence? { exist ? self : nil }
    
}
