//
//  File.swift
//  
//
//  Created by Stefan Springer on 10.03.22.
//

import Foundation


public class XElementIteratorDependingOnElementIterator: XElementIterator {
    
    private let iterator1: XElementIterator
    private var element1: XElement? = nil
    private var started = false
    let nextSequenceGetter: (XElement) -> XElementSequence
    private var iterator2: XElementIterator? = nil
    
    init(sequence: XElementSequence, nextSequenceGetter: @escaping (XElement) -> XElementSequence) {
        iterator1 = sequence.makeIterator()
        self.nextSequenceGetter = nextSequenceGetter
    }
    
    public override func next() -> XElement? {
        if !started {
            element1 = iterator1.next()
            started = true
        }
        while let theElement1 = element1 {
            let theIterator2 = iterator2 ?? {
                let newIterator2 = nextSequenceGetter(theElement1).makeIterator()
                iterator2 = newIterator2
                return newIterator2
            }()
            if let theNext = theIterator2.next() {
                return theNext
            }
            else {
                iterator2 = nil
                element1 = iterator1.next()
            }
        }
        return nil
    }
}

public class XElementIteratorDependingOnContentIterator: XElementIterator {
    
    private let iterator1: XContentIterator
    private var content1: XContent? = nil
    private var started = false
    let nextSequenceGetter: (XContent) -> XElementSequence
    private var iterator2: XElementIterator? = nil
    
    init(sequence: XContentSequence, nextSequenceGetter: @escaping (XContent) -> XElementSequence) {
        iterator1 = sequence.makeIterator()
        self.nextSequenceGetter = nextSequenceGetter
    }
    
    public override func next() -> XElement? {
        if !started {
            content1 = iterator1.next()
            started = true
        }
        while let theContent1 = content1 {
            let theIterator2 = iterator2 ?? {
                let newIterator2 = nextSequenceGetter(theContent1).makeIterator()
                iterator2 = newIterator2
                return newIterator2
            }()
            if let theNext = theIterator2.next() {
                return theNext
            }
            else {
                iterator2 = nil
                content1 = iterator1.next()
            }
        }
        return nil
    }
}

public class XContentIteratorDependingOnElementIterator: XContentIterator {
    
    private let iterator1: XElementIterator
    private var content1: XElement? = nil
    private var started = false
    let nextSequenceGetter: (XElement) -> XContentSequence
    private var iterator2: XContentIterator? = nil
    
    init(sequence: XElementSequence, nextSequenceGetter: @escaping (XElement) -> XContentSequence) {
        iterator1 = sequence.makeIterator()
        self.nextSequenceGetter = nextSequenceGetter
    }
    
    public override func next() -> XContent? {
        if !started {
            content1 = iterator1.next()
            started = true
        }
        while let theContent1 = content1 {
            let theIterator2 = iterator2 ?? {
                let newIterator2 = nextSequenceGetter(theContent1).makeIterator()
                iterator2 = newIterator2
                return newIterator2
            }()
            if let theNext = theIterator2.next() {
                return theNext
            }
            else {
                iterator2 = nil
                content1 = iterator1.next()
            }
        }
        return nil
    }
}

public class XContentIteratorDependingOnContentIterator: XContentIterator {
    
    private let iterator1: XContentIterator
    private var content1: XContent? = nil
    private var started = false
    let nextSequenceGetter: (XContent) -> XContentSequence
    private var iterator2: XContentIterator? = nil
    
    init(sequence: XContentSequence, nextSequenceGetter: @escaping (XContent) -> XContentSequence) {
        iterator1 = sequence.makeIterator()
        self.nextSequenceGetter = nextSequenceGetter
    }
    
    public override func next() -> XContent? {
        if !started {
            content1 = iterator1.next()
            started = true
        }
        while let theContent1 = content1 {
            let theIterator2 = iterator2 ?? {
                let newIterator2 = nextSequenceGetter(theContent1).makeIterator()
                iterator2 = newIterator2
                return newIterator2
            }()
            if let theNext = theIterator2.next() {
                return theNext
            }
            else {
                iterator2 = nil
                content1 = iterator1.next()
            }
        }
        return nil
    }
}

public class XFilteredContentIterator: XContentIterator {
    
    private let iterator: XContentIterator
    private let filter: (XContent) -> Bool
    
    init(sequence: XContentSequence, filter: @escaping (XContent) -> Bool) {
        iterator = sequence.makeIterator()
        self.filter = filter
    }
    
    public override func next() -> XContent? {
        var content: XContent? = iterator.next()
        while let theContent = content, !filter(theContent) {
            content = iterator.next()
        }
        return content
    }
}

public class XFilteredElementIterator: XElementIterator {
    
    private let iterator: XElementIterator
    private let filter: (XElement) -> Bool
    
    init(sequence: XElementSequence, filter: @escaping (XElement) -> Bool) {
        iterator = sequence.makeIterator()
        self.filter = filter
    }
    
    public override func next() -> XElement? {
        var element: XElement? = iterator.next()
        while let theElement = element, !filter(theElement) {
            element = iterator.next()
        }
        return element
    }
}

public class XContentDependingOnContentIterator: XContentIterator {
    
    private let iterator1: XContentIterator
    private var content1: XContent? = nil
    let contentGetter: (XContent) -> XContent?
    
    init(sequence: XContentSequence, contentGetter: @escaping (XContent) -> XContent?) {
        iterator1 = sequence.makeIterator()
        self.contentGetter = contentGetter
    }
    
    public override func next() -> XContent? {
        var content2: XContent? = nil
        while content2 == nil {
            content1 = iterator1.next()
            if let theContent1 = content1 {
                content2 = contentGetter(theContent1)
            }
            else {
                return nil
            }
        }
        return content2
    }
}

public class XContentDependingOnElementIterator: XContentIterator {
    
    private let iterator1: XElementIterator
    private var element1: XElement? = nil
    let contentGetter: (XElement) -> XContent?
    
    init(sequence: XElementSequence, contentGetter: @escaping (XElement) -> XContent?) {
        iterator1 = sequence.makeIterator()
        self.contentGetter = contentGetter
    }
    
    public override func next() -> XContent? {
        var content2: XContent? = nil
        while content2 == nil {
            element1 = iterator1.next()
            if let theContent1 = element1 {
                content2 = contentGetter(theContent1)
            }
            else {
                return nil
            }
        }
        return content2
    }
}

public class XElementDependingOnContentIterator: XElementIterator {
    
    private let iterator1: XContentIterator
    private var content1: XContent? = nil
    let elementGetter: (XContent) -> XElement?
    
    init(sequence: XContentSequence, elementGetter: @escaping (XContent) -> XElement?) {
        iterator1 = sequence.makeIterator()
        self.elementGetter = elementGetter
    }
    
    public override func next() -> XElement? {
        var element2: XElement? = nil
        while element2 == nil {
            content1 = iterator1.next()
            if let theContent1 = content1 {
                element2 = elementGetter(theContent1)
            }
            else {
                return nil
            }
        }
        return element2
    }
}

public class XNameSequenceDependingOnElementSequence: XStringSequence {
    
    let sequence: XElementSequence
    
    init(sequence: XElementSequence) {
        self.sequence = sequence
    }
    
    override public func makeIterator() -> XNameDependingOnElementIterator {
        return XNameDependingOnElementIterator(sequence: sequence)
    }
}

public class XNameDependingOnElementIterator: XStringIterator {
    
    private let iterator: XElementIterator
    
    init(sequence: XElementSequence) {
        iterator = sequence.makeIterator()
    }
    
    public override func next() -> String? {
        if let element = iterator.next() {
            return element.name
        }
        else {
            return nil
        }
    }
}

public class XElementDependingOnElementIterator: XElementIterator {
    
    private let iterator1: XElementIterator
    private var element1: XElement? = nil
    let elementGetter: (XElement) -> XElement?
    
    init(sequence: XElementSequence, elementGetter: @escaping (XElement) -> XElement?) {
        iterator1 = sequence.makeIterator()
        self.elementGetter = elementGetter
    }
    
    public override func next() -> XElement? {
        var element2: XElement? = nil
        while element2 == nil {
            element1 = iterator1.next()
            if let theContent1 = element1 {
                element2 = elementGetter(theContent1)
            }
            else {
                return nil
            }
        }
        return element2
    }
}

public class XElementSequenceDependingOnElementSequence: XElementSequence {
    
    let sequence: XElementSequence
    let nextSequenceGetter: (XElement) -> XElementSequence
    
    init(sequence: XElementSequence, nextSequenceGetter: @escaping (XElement) -> XElementSequence) {
        self.sequence = sequence
        self.nextSequenceGetter = nextSequenceGetter
    }
    
    override public func makeIterator() -> XElementIterator {
        return XElementIteratorDependingOnElementIterator(sequence: sequence, nextSequenceGetter: nextSequenceGetter)
    }
}

public class XElementSequenceDependingOnContentSequence: XElementSequence {
    
    let sequence: XContentSequence
    let nextSequenceGetter: (XContent) -> XElementSequence
    
    init(sequence: XContentSequence, nextSequenceGetter: @escaping (XContent) -> XElementSequence) {
        self.sequence = sequence
        self.nextSequenceGetter = nextSequenceGetter
    }
    
    override public func makeIterator() -> XElementIterator {
        return XElementIteratorDependingOnContentIterator(sequence: sequence, nextSequenceGetter: nextSequenceGetter)
    }
}

public class XContentSequenceDependingOnElementSequence: XContentSequence {
    
    let sequence: XElementSequence
    let nextSequenceGetter: (XElement) -> XContentSequence
    
    init(sequence: XElementSequence, nextSequenceGetter: @escaping (XElement) -> XContentSequence) {
        self.sequence = sequence
        self.nextSequenceGetter = nextSequenceGetter
    }
    
    override public func makeIterator() -> XContentIterator {
        return XContentIteratorDependingOnElementIterator(sequence: sequence, nextSequenceGetter: nextSequenceGetter)
    }
}

public class XContentSequenceDependingOnContentSequence: XContentSequence {
    
    let sequence: XContentSequence
    let nextSequenceGetter: (XContent) -> XContentSequence
    
    init(sequence: XContentSequence, nextSequenceGetter: @escaping (XContent) -> XContentSequence) {
        self.sequence = sequence
        self.nextSequenceGetter = nextSequenceGetter
    }
    
    override public func makeIterator() -> XContentIterator {
        return XContentIteratorDependingOnContentIterator(sequence: sequence, nextSequenceGetter: nextSequenceGetter)
    }
}

public class XFilteredContentSequence: XContentSequence {
    
    let sequence: XContentSequence
    let filter: (XContent) -> Bool
    
    init(sequence: XContentSequence, filter: @escaping (XContent) -> Bool) {
        self.sequence = sequence
        self.filter = filter
    }
    
    override public func makeIterator() -> XContentIterator {
        return XFilteredContentIterator(sequence: sequence, filter: filter)
    }
}

public class XFilteredElementSequence: XElementSequence {
    
    let sequence: XElementSequence
    let filter: (XElement) -> Bool
    
    init(sequence: XElementSequence, filter: @escaping (XElement) -> Bool) {
        self.sequence = sequence
        self.filter = filter
    }
    
    override public func makeIterator() -> XElementIterator {
        return XFilteredElementIterator(sequence: sequence, filter: filter)
    }
}

public class XContentDependingOnContentSequence: XContentSequence {
    
    let sequence: XContentSequence
    let contentGetter: (XContent) -> XContent?
    
    init(sequence: XContentSequence, contentGetter: @escaping (XContent) -> XContent?) {
        self.sequence = sequence
        self.contentGetter = contentGetter
    }
    
    override public func makeIterator() -> XContentIterator {
        return XContentDependingOnContentIterator(sequence: sequence, contentGetter: contentGetter)
    }
}

public class XElementDependingOnContentSequence: XElementSequence {
    
    let sequence: XContentSequence
    let elementGetter: (XContent) -> XElement?
    
    init(sequence: XContentSequence, elementGetter: @escaping (XContent) -> XElement?) {
        self.sequence = sequence
        self.elementGetter = elementGetter
    }
    
    override public func makeIterator() -> XElementIterator {
        return XElementDependingOnContentIterator(sequence: sequence, elementGetter: elementGetter)
    }
}

public class XContentDependingOnElementSequence: XContentSequence {
    
    let sequence: XElementSequence
    let contentGetter: (XElement) -> XContent?
    
    init(sequence: XElementSequence, contentGetter: @escaping (XElement) -> XContent?) {
        self.sequence = sequence
        self.contentGetter = contentGetter
    }
    
    override public func makeIterator() -> XContentIterator {
        return XContentDependingOnElementIterator(sequence: sequence, contentGetter: contentGetter)
    }
}

public class XElementDependingOnElementSequence: XElementSequence {
    
    let sequence: XElementSequence
    let elementGetter: (XElement) -> XElement?
    
    init(sequence: XElementSequence, elementGetter: @escaping (XElement) -> XElement?) {
        self.sequence = sequence
        self.elementGetter = elementGetter
    }
    
    override public func makeIterator() -> XElementIterator {
        return XElementDependingOnElementIterator(sequence: sequence, elementGetter: elementGetter)
    }
}

public func collect(@XContentBuilder builder: @escaping () -> [XContent]) -> (() -> [XContent]) {
    return builder
}

extension XContentSequence {
    
    public func filter(_ isIncluded: @escaping (XContent) -> Bool) -> XContentSequence {
        return XFilteredContentSequence(sequence: self, filter: isIncluded)
    }
    
    public func clone() -> XContentSequence {
        return XContentDependingOnContentSequence(sequence: self, contentGetter: { content in content.clone() })
    }
    
    public func shallowClone() -> XContentSequence {
        return XContentDependingOnContentSequence(sequence: self, contentGetter: { content in content.shallowClone() })
    }
    
    public var ancestors: XElementSequence {
        get { XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.ancestors }) }
    }
    
    public func ancestors(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.ancestors(condition) })
    }
    
    public func ancestors(withName name: String) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.ancestors(name) })
    }
    
    public var content: XContentSequence {
        get { XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.content }) }
    }
    
    public func content(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.content(condition) })
    }
    
    public func content(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.content(while: condition) })
    }
    
    public func content(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.content(until: condition) })
    }
    
    public var contentReversed: XContentSequence {
        get { XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.contentReversed }) }
    }
    
    public func contentReversed(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.contentReversed(condition) })
    }
    
    public func contentReversed(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.contentReversed(while: condition) })
    }
    
    public func contentReversed(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.contentReversed(until: condition) })
    }
    
    public var children: XElementSequence {
        get { XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.children }) }
    }
    
    public func children(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.children(condition) })
    }
    
    public func children(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.children(name) })
    }
    
    public func children(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.children(while: condition) })
    }
    
    public func children(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.children(until: condition) })
    }
    
    public var childrenReversed: XElementSequence {
        get { XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.childrenReversed }) }
    }
    
    public func childrenReversed(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.childrenReversed(condition) })
    }
    
    public func childrenReversed(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.childrenReversed(name) })
    }
    
    public func childrenReversed(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.childrenReversed(while: condition) })
    }
    
    public func childrenReversed(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.childrenReversed(until: condition) })
    }
    
    public var next: XContentSequence {
        get { XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.next }) }
    }
    
    public func next(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.next(condition) })
    }
    
    public func next(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.next(while: condition) })
    }
    
    public func next(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.next(until: condition) })
    }
    
    public var previous: XContentSequence {
        get { XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.previous }) }
    }
    
    public func previous(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.previous(condition) })
    }
    
    public func previous(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.previous(while: condition) })
    }
    
    public func previous(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.previous(until: condition) })
    }
    
    public var nextElements: XElementSequence {
        get { XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.nextElements }) }
    }
    
    public func nextElements(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.nextElements(condition) })
    }
    
    public func nextElements(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.nextElements(name) })
    }
    
    public func nextElements(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.nextElements(while: condition) })
    }
    
    public func nextElements(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.nextElements(until: condition) })
    }
    
    public var previousElements: XElementSequence {
        get { XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.previousElements }) }
    }
    
    public func previousElements(_ condition: @escaping (XContent) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.previousElements(condition) })
    }
    
    public func previousElements(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.previousElements(name) })
    }
    
    public func previousElements(while condition: @escaping (XContent) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.previousElements(while: condition) })
    }
    
    public var allContent: XContentSequence {
        get { XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.allContent }) }
    }
    
    public func allContent(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.allContent(condition) })
    }
    
    public func allContent(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.allContent(while: condition) })
    }
    
    public func allContent(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.allContent(until: condition) })
    }
    
    public var allContentIncludingSelf: XContentSequence {
        get { XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.allContentIncludingSelf }) }
    }
    
    public func allContentIncludingSelf(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.allContentIncludingSelf(condition) })
    }
    
    public func allContentIncludingSelf(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.allContentIncludingSelf(while: condition) })
    }
    
    public func allContentIncludingSelf(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.allContentIncludingSelf(until: condition) })
    }
    
    public var descendants: XElementSequence {
        get { XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.descendants }) }
    }
    
    public func descendants(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.descendants(condition) })
    }
    
    public func descendants(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.descendants(name) })
    }
    
    public func descendants(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.descendants(while: condition) })
    }
    
    public func descendants(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.descendants(until: condition) })
    }
    
    public var previousTouching: XContentSequence {
        get { XContentDependingOnContentSequence(sequence: self, contentGetter: { content in content.previousTouching }) }
    }
    
    public func previousTouching(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentDependingOnContentSequence(sequence: self, contentGetter: { content in content.previousTouching(condition) })
    }
    
    public var previousInTreeTouching: XContentSequence {
        get { XContentDependingOnContentSequence(sequence: self, contentGetter: { content in content.previousInTreeTouching }) }
    }
    
    public func previousInTreeTouching(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentDependingOnContentSequence(sequence: self, contentGetter: { content in content.previousInTreeTouching(condition) })
    }
    
    public var nextTouching: XContentSequence {
        get { XContentDependingOnContentSequence(sequence: self, contentGetter: { content in content.nextTouching }) }
    }
    
    public func nextTouching(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentDependingOnContentSequence(sequence: self, contentGetter: { content in content.nextTouching(condition) })
    }
    
    public var nextInTreeTouching: XContentSequence {
        get { XContentDependingOnContentSequence(sequence: self, contentGetter: { content in content.nextInTreeTouching }) }
    }
    
    public func nextInTreeTouching(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentDependingOnContentSequence(sequence: self, contentGetter: { content in content.nextInTreeTouching(condition) })
    }
    
    public var parent: XElementSequence {
        get { XElementDependingOnContentSequence(sequence: self, elementGetter: { content in content.parent }) }
    }
    
    public func parent(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementDependingOnContentSequence(sequence: self, elementGetter: { content in content.parent(condition) })
    }
    
    public func parent(_ name: String) -> XElementSequence {
        return XElementDependingOnContentSequence(sequence: self, elementGetter: { content in content.parent(name) })
    }
    
    public func applying(_ f: @escaping (XContent) -> ()) -> XContentSequence {
        return XContentDependingOnContentSequence(sequence: self, contentGetter: { content in f(content); return content })
    }
    
    public func insertPrevious(keepPosition: Bool = false, @XContentBuilder builder: () -> [XContent]) {
        self.forEach { content in
            content._insertPrevious(keepPosition: keepPosition, builder())
        }
    }
    
    public func insertPrevious(keepPosition: Bool = false, _ contentGetter: @escaping (XContent) -> [XContent]) {
        self.forEach { content in
            content._insertPrevious(keepPosition: keepPosition, contentGetter(content))
        }
    }
    
    public func insertNext(keepPosition: Bool = false, @XContentBuilder builder: () -> [XContent]) {
        self.forEach { content in
            content._insertNext(keepPosition: keepPosition, builder())
        }
    }
    
    public func insertNext(keepPosition: Bool = false, _ contentGetter: @escaping (XContent) -> [XContent]) {
        self.forEach { content in content._insertNext(keepPosition: keepPosition, contentGetter(content)) }
    }
    
    public func replace(follow: Bool = false, @XContentBuilder builder: () -> [XContent]) {
        self.forEach { content in content.replace(follow: follow, builder: builder) }
    }
    
    public func replace(follow: Bool = false, _ contentGetter: (XContent) -> (() -> [XContent])) {
        self.forEach { content in content.replace(follow: follow, builder: contentGetter(content) ) }
    }
    
    public func remove() {
        self.forEach { content in content.remove() }
    }
    
    public func echo(pretty: Bool = false, terminator: String = "\n") {
        self.forEach { content in content.echo(pretty: pretty, terminator: terminator) }
    }
}

extension XElementSequence {
    
    public func filter(_ isIncluded: @escaping (XElement) -> Bool) -> XElementSequence {
        return XFilteredElementSequence(sequence: self, filter: isIncluded)
    }
    
    public var name: XStringSequence {
        get { XNameSequenceDependingOnElementSequence(sequence: self) }
    }
    
    public func clone() -> XElementSequence {
        return XElementDependingOnElementSequence(sequence: self, elementGetter: { element in element.clone() })
    }
    
    public func shallowClone() -> XElementSequence {
        return XElementDependingOnElementSequence(sequence: self, elementGetter: { element in element.shallowClone() })
    }
    
    public var ancestors: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.ancestors }) }
    }
    
    public func ancestors(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.ancestors(condition) })
    }
    
    public func ancestors(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.ancestors(name) })
    }
    
    public func ancestors(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.ancestors(while: condition) })
    }
    
    public func ancestors(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.ancestors(until: condition) })
    }
    
    public var content: XContentSequence {
        get { XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.content }) }
    }
    
    public func content(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.content(condition) })
    }
    
    public func content(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.content(while: condition) })
    }
    
    public func content(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.content(until: condition) })
    }
    
    public var contentReversed: XContentSequence {
        get { XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.contentReversed }) }
    }
    
    public func contentReversed(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.contentReversed(condition) })
    }
    
    public func contentReversed(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.contentReversed(while: condition) })
    }
    
    public func contentReversed(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.contentReversed(until: condition) })
    }
    
    public var children: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.children }) }
    }
    
    public func children(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.children(condition) })
    }
    
    public func children(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.children(name) })
    }
    
    public func children(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.children(while: condition) })
    }
    
    public func children(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.children(until: condition) })
    }
    
    public var childrenReversed: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.childrenReversed }) }
    }
    
    public func childrenReversed(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.childrenReversed(condition) })
    }
    
    public func childrenReversed(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.childrenReversed(name) })
    }
    
    public func childrenReversed(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.childrenReversed(while: condition) })
    }
    
    public func childrenReversed(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.childrenReversed(until: condition) })
    }
    
    public var next: XContentSequence {
        get { XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.next }) }
    }
    
    public func next(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.next(condition) })
    }
    
    public func next(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.next(while: condition) })
    }
    
    public func next(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.next(until: condition) })
    }
    
    public var previous: XContentSequence {
        get { XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.previous }) }
    }
    
    public func previous(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.previous(condition) })
    }
    
    public func previous(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.previous(while: condition) })
    }
    
    public func previous(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.previous(until: condition) })
    }
    
    public var nextElements: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.nextElements }) }
    }
    
    public func nextElements(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.nextElements(condition) })
    }
    
    public func nextElements(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.nextElements(name) })
    }
    
    public func nextElements(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.nextElements(while: condition) })
    }
    
    public func nextElements(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.nextElements(until: condition) })
    }
    
    public var previousElements: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.previousElements }) }
    }
    
    public func previousElements(_ condition: @escaping (XContent) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.previousElements(condition) })
    }
    
    public func previousElements(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.previousElements(name) })
    }
    
    public func previousElements(while condition: @escaping (XContent) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.previousElements(while: condition) })
    }
    
    public func previousElements(until condition: @escaping (XContent) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.previousElements(until: condition) })
    }
    
    public var allContent: XContentSequence {
        get { XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.allContent }) }
    }
    
    public func allContent(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.allContent(condition) })
    }
    
    public func allContent(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.allContent(while: condition) })
    }
    
    public func allContent(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.allContent(until: condition) })
    }
    
    public var allContentIncludingSelf: XContentSequence {
        get { XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.allContentIncludingSelf }) }
    }
    
    public func allContentIncludingSelf(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.allContentIncludingSelf(condition) })
    }
    
    public func allContentIncludingSelf(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.allContentIncludingSelf(while: condition) })
    }
    
    public func allContentIncludingSelf(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.allContentIncludingSelf(until: condition) })
    }
    
    public var descendants: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.descendants }) }
    }
    
    public func descendants(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.descendants(condition) })
    }
    
    public func descendants(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.descendants(name) })
    }
    
    public func descendants(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.descendants(while: condition) })
    }
    
    public func descendants(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.descendants(until: condition) })
    }
    
    public var descendantsIncludingSelf: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { element in element.descendantsIncludingSelf }) }
    }
    
    public func descendantsIncludingSelf(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { element in element.descendantsIncludingSelf(condition) })
    }
    
    public func descendantsIncludingSelf(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { element in element.descendantsIncludingSelf(name) })
    }
    
    public func descendantsIncludingSelf(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { element in element.descendantsIncludingSelf(while: condition) })
    }
    
    public func descendantsIncludingSelf(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { element in element.descendantsIncludingSelf(until: condition) })
    }
    
    public var previousTouching: XContentSequence {
        get { XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.previousTouching }) }
    }
    
    public func previousTouching(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.previousTouching(condition) })
    }
    
    public var previousInTreeTouching: XContentSequence {
        get { XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.previousInTreeTouching }) }
    }
    
    public func previousInTreeTouching(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.previousInTreeTouching(condition) })
    }
    
    public var nextTouching: XContentSequence {
        get { XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.nextTouching }) }
    }
    
    public func nextTouching(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.nextTouching(condition) })
    }
    
    public var nextInTreeTouching: XContentSequence {
        get { XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.nextInTreeTouching }) }
    }
    
    public func nextInTreeTouching(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.nextInTreeTouching(condition) })
    }
    
    public var parent: XElementSequence {
        get { XElementDependingOnElementSequence(sequence: self, elementGetter: { content in content.parent }) }
    }
    
    public func parent(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementDependingOnElementSequence(sequence: self, elementGetter: { content in content.parent(condition) })
    }
    
    public func parent(_ name: String) -> XElementSequence {
        return XElementDependingOnElementSequence(sequence: self, elementGetter: { content in content.parent(name) })
    }
    
    public var firstContent: XContentSequence {
        get { XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.firstContent }) }
    }
    
    public func firstContent(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.firstContent(condition) })
    }
    
    public var lastContent: XContentSequence {
        get { XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.lastContent }) }
    }
    
    public func lastContent(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.lastContent(condition) })
    }
    
    public func applying(_ f: @escaping (XElement) -> ()) -> XElementSequence {
        return XElementDependingOnElementSequence(sequence: self, elementGetter: { element in f(element); return element })
    }
    
    public func add(@XContentBuilder builder: () -> [XContent]) {
        self.forEach { element in element._add(builder()) }
    }
    
    public func add(_ contentGetter: @escaping (XElement) -> [XContent]) {
        self.forEach { element in element._add(contentGetter(element)) }
    }
    
    public func addFirst(@XContentBuilder builder: () -> [XContent]) {
        self.forEach { element in element._addFirst(builder()) }
    }
    
    public func addFirst(_ contentGetter: @escaping (XElement) -> [XContent]) {
        self.forEach { element in element._addFirst(contentGetter(element)) }
    }
    
    public func setContent(_ contentGetter: @escaping (XElement) -> [XContent]) {
        self.forEach { element in element._setContent(contentGetter(element)) }
    }
    
    public func insertPrevious(keepPosition: Bool = false, @XContentBuilder builder: () -> [XContent]) {
        self.forEach { element in element._insertPrevious(keepPosition: keepPosition, builder()) }
    }
    
    public func insertPrevious(keepPosition: Bool = false, _ contentGetter: @escaping (XElement) -> [XContent]) {
        self.forEach { element in element._insertPrevious(keepPosition: keepPosition, contentGetter(element)) }
    }
    
    public func insertNext(keepPosition: Bool = false, @XContentBuilder builder: () -> [XContent]) {
        self.forEach { element in element._insertNext(keepPosition: keepPosition, builder()) }
    }
    
    public func insertNext(keepPosition: Bool = false, _ contentGetter: @escaping (XElement) -> [XContent]) {
        self.forEach { element in element._insertNext(keepPosition: keepPosition, contentGetter(element)) }
    }
    
    public func replace(follow: Bool = false, @XContentBuilder builder: () -> [XContent]) {
        self.forEach { element in element.replace(follow: follow, builder: builder) }
    }
    
    public func replace(follow: Bool = false, _ contentGetter: (XElement) -> (() -> [XContent])) {
        self.forEach { element in element.replace(follow: follow, builder: contentGetter(element) ) }
    }
    
    public func clear() {
        self.forEach { element in element.clear() }
    }
    
    public func remove() {
        self.forEach { element in element.remove() }
    }
    
    public func echo(pretty: Bool = false, terminator: String = "\n") {
        self.forEach { element in element.echo(pretty: pretty, terminator: terminator) }
    }
    
}
