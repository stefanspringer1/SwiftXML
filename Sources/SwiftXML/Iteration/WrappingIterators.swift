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
public final class XBidirectionalContentIterator: XContentIterator {
    
    var previousIterator: XBidirectionalContentIterator? = nil
    var nextIterator: XBidirectionalContentIterator? = nil
    
    public typealias Element = XContent
    
    var nodeIterator: XContentIteratorProtocol
    
    public init(nodeIterator: XContentIteratorProtocol) {
        self.nodeIterator = nodeIterator    }
    
    weak var current: Element? = nil
    var prefetched = false
    
    public override func next() -> XContent? {
        if prefetched {
            prefetched = false
            return current
        }
        current?.removeContentIterator(self)
        current = nodeIterator.next()
        current?.addContentIterator(self)
        return current
    }
    
    public override func previous() -> XContent? {
        prefetched = false
        current?.removeContentIterator(self)
        current = nodeIterator.previous()
        current?.addContentIterator(self)
        return current
    }
    
    public func prefetch() {
        current?.removeContentIterator(self)
        current = nodeIterator.next()
        current?.addContentIterator(self)
        prefetched = true
    }
}

public final class XBidirectionalElementIterator: XElementIterator {
    
    var previousIterator: XBidirectionalElementIterator? = nil
    var nextIterator: XBidirectionalElementIterator? = nil
    
    public typealias Element = XElement
    
    var elementIterator: XElementIteratorProtocol
    
    public init(elementIterator: XElementIteratorProtocol) {
        self.elementIterator = elementIterator
    }
    
    weak var current: XElement? = nil
    var prefetched = false
    
    public override func next() -> XElement? {
        if prefetched {
            prefetched = false
            return current
        }
        current?._elementIterators.remove(self)
        current = elementIterator.next()
        current?._elementIterators.append(self)
        return current
    }
    
    public override func previous() -> XElement? {
        prefetched = false
        current?._elementIterators.remove(self)
        current = elementIterator.previous()
        current?._elementIterators.append(self)
        return current
    }
    
    public func prefetch() {
        current?._elementIterators.remove(self)
        current = elementIterator.next()
        current?._elementIterators.append(self)
        prefetched = true
    }
}

public final class XElementNameIterator: XElementIterator {
    
    var previousIterator: XElementNameIterator? = nil
    var nextIterator: XElementNameIterator? = nil
    
    public typealias Element = XElement
    
    var elementIterator: XElementIteratorProtocol
    
    var keepLast: Bool
    
    public init(elementIterator: XElementIteratorProtocol, keepLast: Bool = false) {
        self.elementIterator = elementIterator
        self.keepLast = keepLast
    }
    
    weak var current: XElement? = nil
    var prefetched = false
    
    public override func next() -> XElement? {
        if prefetched {
            prefetched = false
            return current
        }
        let next = elementIterator.next()
        if keepLast && next == nil {
            return nil
        }
        else {
            current?._nameIterators.remove(self)
            current = next
            current?._nameIterators.append(self)
            return current
        }
    }
    
    public override func previous() -> XElement? {
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

public typealias XAttributeSpot = (String,XElement)

public final class XBidirectionalAttributeIterator: XAttributeIterator {
    
    var previousIterator: XBidirectionalAttributeIterator? = nil
    var nextIterator: XBidirectionalAttributeIterator? = nil
    
    public typealias Element = XAttributeSpot
    
    var attributeIterator: XAttributeIteratorProtocol
    
    var keepLast: Bool
    
    init(attributeIterator: XAttributeIteratorProtocol, keepLast: Bool = false) {
        self.attributeIterator = attributeIterator
        self.keepLast = keepLast
    }
    
    weak var current: XAttribute? = nil
    var prefetched = false
    
    public override func next() -> XAttributeSpot? {
        if prefetched {
            prefetched = false
        }
        else {
            let next = attributeIterator.next()
            if keepLast && next == nil {
                return nil
            }
            else {
                current?.attributeIterators.remove(self)
                current = next
                current?.attributeIterators.append(self)
            }
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
