//
//  File.swift
//  
//
//  Created by Stefan Springer on 27.09.21.
//

import Foundation

extension XNode {
    
    public var ancestors: XElementSequence {
        get { XAncestorsSequence(node: self) }
    }
    
    public func ancestors(with condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequence(node: self), condition: condition)
    }
    
    public func ancestors(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequence(node: self), elementName: name)
    }
    
    public var content: XNodeSequence {
        get { XContentSequence(node: self) }
    }
    
    public func content(with condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceWithCondition(sequence: XContentSequence(node: self), condition: condition)
    }
    
    public var children: XElementSequence {
        get { return XChildrenSequence(node: self) }
    }
    
    public func children(with condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), condition: condition)
    }
    
    public func children(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), elementName: name)
    }
    
    public var next: XNodeSequence {
        get { XNextSequence(node: self) }
    }
    
    public func next(with condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceWithCondition(sequence: XNextSequence(node: self), condition: condition)
    }
    
    public var previous: XNodeSequence {
        get { XPreviousSequence(node: self) }
    }
    
    public func previous(with condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceWithCondition(sequence: XPreviousSequence(node: self), condition: condition)
    }
    
    public var nextElements: XElementSequence {
        get { XNextElementsSequence(node: self) }
    }
    
    public func nextElements(with condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextElementsSequence(node: self), condition: condition)
    }
    
    public func nextElements(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextElementsSequence(node: self), elementName: name)
    }
    
    public var previousElements: XElementSequence {
        get { XPreviousElementsSequence(node: self) }
    }
    
    public func previousElements(with condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousElementsSequence(node: self), condition: condition)
    }
    
    public func previousElements(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousElementsSequence(node: self), elementName: name)
    }
    
    public var allContent: XNodeSequence {
        get { XAllContentSequence(node: self) }
    }
    
    public func allContent(with condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceWithCondition(sequence: XAllContentSequence(node: self), condition: condition)
    }
    
    public var allContentIncludingSelf: XNodeSequence {
        get { XAllContentIncludingSelfSequence(node: self) }
    }
    
    public func allContentIncludingSelf(with condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceWithCondition(sequence: XAllContentIncludingSelfSequence(node: self), condition: condition)
    }
    
    public var descendants: XElementSequence {
        get { XDescendantsSequence(node: self) }
    }
    
    public func descendants(with condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), condition: condition)
    }
    
    public func descendants(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), elementName: name)
    }
    
}

extension XElement {
    
    public var descendantsIncludingSelf: XElementSequence { get { XDescendantsIncludingSelfSequence(element: self) } }
    
    public func descendantsIncludingSelf(with condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsIncludingSelfSequence(element: self), condition: condition)
    }
    
    public func descendantsIncludingSelf(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsIncludingSelfSequence(element: self), elementName: name)
    }
}

public extension XNodeSequence {
    
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
