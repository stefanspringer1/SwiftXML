//
//  WrappingIterators.swift
//  
//
//  Created by Stefan Springer on 27.09.21.
//

import Foundation

/**
 The XNodeIterator does the work of making sure that an XML tree can be manipulated
 during iteration. It is ignorant about what precise iteration takes place. The
 precise iteration is implemented in "iteratorImplementation" which implements
 the XIteratorProtocol.
 */
public class XNodeIterator: IteratorProtocol {
    
    var previousIterator: XNodeIterator? = nil
    var nextIterator: XNodeIterator? = nil
    
    public typealias Element = XNode
    
    var nodeIterator: XNodeIteratorProtocol
    
    public init(nodeIterator: XNodeIteratorProtocol) {
        self.nodeIterator = nodeIterator
    }
    
    weak var current: Element? = nil
    var prefetched = false
    
    public func next() -> XNode? {
        if prefetched {
            prefetched = false
            return current
        }
        current?.removeNodeIterator(self)
        current = nodeIterator.next()
        current?.addNodeIterator(self)
        return current
    }
    
    public func previous() -> XNode? {
        prefetched = false
        current?.removeNodeIterator(self)
        current = nodeIterator.previous()
        current?.addNodeIterator(self)
        return current
    }
    
    public func prefetch() {
        current?.removeNodeIterator(self)
        current = nodeIterator.next()
        current?.addNodeIterator(self)
        prefetched = true
    }
}

public class XElementTreeIterator: IteratorProtocol {
    
    var previousIterator: XElementTreeIterator? = nil
    var nextIterator: XElementTreeIterator? = nil
    
    public typealias Element = XElement
    
    var elementIterator: XElementIteratorProtocol
    
    public init(elementIterator: XElementIteratorProtocol) {
        self.elementIterator = elementIterator
    }
    
    weak var current: XElement? = nil
    var prefetched = false
    
    public func next() -> XElement? {
        if prefetched {
            prefetched = false
            return current
        }
        current?._treeIterators.remove(self)
        current = elementIterator.next()
        current?._treeIterators.append(self)
        return current
    }
    
    public func previous() -> XElement? {
        prefetched = false
        current?._treeIterators.remove(self)
        current = elementIterator.previous()
        current?._treeIterators.append(self)
        return current
    }
    
    public func prefetch() {
        current?._treeIterators.remove(self)
        current = elementIterator.next()
        current?._treeIterators.append(self)
        prefetched = true
    }
}

public class XElementNameIterator: IteratorProtocol {
    
    var previousIterator: XElementNameIterator? = nil
    var nextIterator: XElementNameIterator? = nil
    
    public typealias Element = XElement
    
    var elementIterator: XElementIteratorProtocol
    
    public init(elementIterator: XElementIteratorProtocol) {
        self.elementIterator = elementIterator
    }
    
    weak var current: XElement? = nil
    var prefetched = false
    
    public func next() -> XElement? {
        if prefetched {
            prefetched = false
            return current
        }
        current?._nameIterators.remove(self)
        current = elementIterator.next()
        current?._nameIterators.append(self)
        return current
    }
    
    public func previous() -> XElement? {
        prefetched = false
        current?._nameIterators.remove(self)
        current = elementIterator.previous()
        current?._nameIterators.append(self)
        return current
    }
    
    public func prefetch() {
        current?._nameIterators.remove(self)
        current = elementIterator.next()
        current?._nameIterators.append(self)
        prefetched = true
    }
}

public struct XAttributeSpot {
    public let value: String
    public let element: XElement
}

public class XAttributeIterator: IteratorProtocol {
    
    var previousIterator: XAttributeIterator? = nil
    var nextIterator: XAttributeIterator? = nil
    
    public typealias Element = XAttributeSpot
    
    var attributeIterator: XAttributeIteratorProtocol
    
    init(attributeIterator: XAttributeIteratorProtocol) {
        self.attributeIterator = attributeIterator
    }
    
    weak var current: XAttribute? = nil
    var prefetched = false
    
    public func next() -> XAttributeSpot? {
        if prefetched {
            prefetched = false
        }
        else {
            current?.attributeIterators.remove(self)
            current = attributeIterator.next()
            current?.attributeIterators.append(self)
        }
        if let theValue = current?.value, let theElement = current?.element {
            return XAttributeSpot(value: theValue,element: theElement)
        }
        else {
            current?.attributeIterators.remove(self)
            return nil
        }
    }
    
    public func previous() -> XAttributeSpot? {
        prefetched = false
        current?.attributeIterators.remove(self)
        current = attributeIterator.previous()
        if let theValue = current?.value, let theElement = current?.element {
            current?.attributeIterators.append(self)
            return XAttributeSpot(value: theValue,element: theElement)
        }
        else {
            return nil
        }
    }
    
    public func prefetch() {
        current?.attributeIterators.remove(self)
        current = attributeIterator.next()
        current?.attributeIterators.append(self)
        prefetched = true
    }
}
