//
//  File.swift
//  
//
//  Created by Stefan Springer on 27.09.21.
//

import Foundation

extension XBranch {
    
    public var content: XContentSequence {
        get { XSequenceOfContent(node: self) }
    }
    
    public func content(where condition: @escaping (XNode) -> Bool) -> XContentSequence {
        return XNodeSequenceWithCondition(sequence: XSequenceOfContent(node: self), condition: condition)
    }
    
    public var children: XElementSequence {
        get { return XChildrenSequence(node: self) }
    }
    
    public func children(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), condition: condition)
    }
    
    public func children(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), elementName: name)
    }
    
    public var allContent: XContentSequence {
        get { XAllContentSequence(node: self) }
    }
    
    public func allContent(where condition: @escaping (XNode) -> Bool) -> XContentSequence {
        return XNodeSequenceWithCondition(sequence: XAllContentSequence(node: self), condition: condition)
    }
    
    public var descendants: XElementSequence {
        get { XDescendantsSequence(node: self) }
    }
    
    public func descendants(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), condition: condition)
    }
    
    public func descendants(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), elementName: name)
    }
    
}

extension XContent {
    
    public var ancestors: XElementSequence {
        get { XAncestorsSequence(node: self) }
    }
    
    public func ancestors(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequence(node: self), condition: condition)
    }
    
    public func ancestors(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequence(node: self), elementName: name)
    }
    
    public var content: XContentSequence {
        get { XSequenceOfContent(node: self) }
    }
    
    public func content(where condition: @escaping (XNode) -> Bool) -> XContentSequence {
        return XNodeSequenceWithCondition(sequence: XSequenceOfContent(node: self), condition: condition)
    }
    
    public var children: XElementSequence {
        get { return XChildrenSequence(node: self) }
    }
    
    public func children(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), condition: condition)
    }
    
    public func children(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), elementName: name)
    }
    
    public var next: XContentSequence {
        get { XNextSequence(content: self) }
    }
    
    public func next(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XNodeSequenceWithCondition(sequence: XNextSequence(content: self), condition: condition)
    }
    
    public var previous: XContentSequence {
        get { XPreviousSequence(content: self) }
    }
    
    public func previous(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XNodeSequenceWithCondition(sequence: XPreviousSequence(content: self), condition: condition)
    }
    
    public var nextElements: XElementSequence {
        get { XNextElementsSequence(content: self) }
    }
    
    public func nextElements(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextElementsSequence(content: self), condition: condition)
    }
    
    public func nextElements(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextElementsSequence(content: self), elementName: name)
    }
    
    public var previousElements: XElementSequence {
        get { XPreviousElementsSequence(content: self) }
    }
    
    public func previousElements(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousElementsSequence(content: self), condition: condition)
    }
    
    public func previousElements(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousElementsSequence(content: self), elementName: name)
    }
    
    public var allContent: XContentSequence {
        get { XAllContentSequence(node: self) }
    }
    
    public func allContent(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XNodeSequenceWithCondition(sequence: XAllContentSequence(node: self), condition: condition)
    }
    
    public var allContentIncludingSelf: XContentSequence {
        get { XAllContentIncludingSelfSequence(node: self) }
    }
    
    public func allContentIncludingSelf(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XNodeSequenceWithCondition(sequence: XAllContentIncludingSelfSequence(node: self), condition: condition)
    }
    
    public var descendants: XElementSequence {
        get { XDescendantsSequence(node: self) }
    }
    
    public func descendants(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), condition: condition)
    }
    
    public func descendants(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), elementName: name)
    }
    
}

extension XElement {
    
    public var descendantsIncludingSelf: XElementSequence { get { XDescendantsIncludingSelfSequence(element: self) } }
    
    public func descendantsIncludingSelf(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsIncludingSelfSequence(element: self), condition: condition)
    }
    
    public func descendantsIncludingSelf(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsIncludingSelfSequence(element: self), elementName: name)
    }
}

public extension XContentSequence {
    
    func findFirst() -> XNode? {
        return makeIterator().next()
    }
    
    func find(index: Int) -> XNode? {
        let iterator = makeIterator()
        var position = 0
        var node: XNode? = nil
        while position <= index {
            node = iterator.next()
            if node == nil {
                return nil
            }
            position += 1
        }
        return node
    }
    
    var exist: Bool { get { makeIterator().next() != nil } }
    
}

public extension XElementSequence {
    
    func findFirst() -> XElement? {
        return makeIterator().next()
    }
    
    func find(index: Int) -> XElement? {
        let iterator = makeIterator()
        var position = 0
        var node: XElement? = nil
        while position <= index {
            node = iterator.next()
            if node == nil {
                return nil
            }
            position += 1
        }
        return node
    }
    
    var exist: Bool { get { makeIterator().next() != nil } }
    
}
