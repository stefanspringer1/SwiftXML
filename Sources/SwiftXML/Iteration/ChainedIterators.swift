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

extension XContentSequence {
    
    public var ancestors: XElementSequence {
        get { XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.ancestors }) }
    }
    
    public func ancestors(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.ancestors(where: condition) })
    }
    
    public func ancestors(withName name: String) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.ancestors(name) })
    }
    
    public var content: XContentSequence {
        get { XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.content }) }
    }
    
    public func content(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.content(where: condition) })
    }
    
    public var children: XElementSequence {
        get { XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.children }) }
    }
    
    public func children(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.children(where: condition) })
    }
    
    public func children(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.children(name) })
    }
    
    public var next: XContentSequence {
        get { XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.next }) }
    }
    
    public func next(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.next(where: condition) })
    }
    
    public var previous: XContentSequence {
        get { XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.previous }) }
    }
    
    public func previous(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.previous(where: condition) })
    }
    
    public var nextElements: XElementSequence {
        get { XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.nextElements }) }
    }
    
    public func nextElements(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.nextElements(where: condition) })
    }
    
    public func nextElements(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.nextElements(name) })
    }
    
    public var previousElements: XElementSequence {
        get { XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.previousElements }) }
    }
    
    public func previousElements(where condition: @escaping (XContent) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.previousElements(where: condition) })
    }
    
    public func previousElements(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.previousElements(name) })
    }
    
    public var allContent: XContentSequence {
        get { XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.allContent }) }
    }
    
    public func allContent(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.allContent(where: condition) })
    }
    
    public var allContentIncludingSelf: XContentSequence {
        get { XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.allContentIncludingSelf }) }
    }
    
    public func allContentIncludingSelf(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.allContentIncludingSelf(where: condition) })
    }
    
    public var descendants: XElementSequence {
        get { XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.descendants }) }
    }
    
    public func descendants(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.descendants(where: condition) })
    }
    
    public func descendants(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnContentSequence(sequence: self, nextSequenceGetter: { content in content.descendants(name) })
    }
    
    public var previousInTreeTouching: XContentSequence {
        get { XContentDependingOnContentSequence(sequence: self, contentGetter: { content in content.previousInTreeTouching }) }
    }
    
    public func previousInTreeTouching(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentDependingOnContentSequence(sequence: self, contentGetter: { content in content.previousInTreeTouching(where: condition) })
    }
    
    public var nextInTreeTouching: XContentSequence {
        get { XContentDependingOnContentSequence(sequence: self, contentGetter: { content in content.nextInTreeTouching }) }
    }
    
    public func nextInTreeTouching(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentDependingOnContentSequence(sequence: self, contentGetter: { content in content.nextInTreeTouching(where: condition) })
    }
    
    public var parent: XElementSequence {
        get { XElementDependingOnContentSequence(sequence: self, elementGetter: { content in content.parent }) }
    }
    
    public func parent(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementDependingOnContentSequence(sequence: self, elementGetter: { content in content.parent(where: condition) })
    }
    
    public func parent(_ name: String) -> XElementSequence {
        return XElementDependingOnContentSequence(sequence: self, elementGetter: { content in content.parent(name) })
    }
    
    public func applied(_ f: @escaping (XContent) -> ()) -> XContentSequence {
        return XContentDependingOnContentSequence(sequence: self, contentGetter: { content in f(content); return content })
    }
    
}

extension XElementSequence {
    
    public var ancestors: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.ancestors }) }
    }
    
    public func ancestors(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.ancestors(where: condition) })
    }
    
    public func ancestors(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.ancestors(name) })
    }
    
    public var content: XContentSequence {
        get { XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.content }) }
    }
    
    public func content(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.content(where: condition) })
    }
    
    public var children: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.children }) }
    }
    
    public func children(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.children(where: condition) })
    }
    
    public func children(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.children(name) })
    }
    
    public var next: XContentSequence {
        get { XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.next }) }
    }
    
    public func next(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.next(where: condition) })
    }
    
    public var previous: XContentSequence {
        get { XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.previous }) }
    }
    
    public func previous(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.previous(where: condition) })
    }
    
    public var nextElements: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.nextElements }) }
    }
    
    public func nextElements(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.nextElements(where: condition) })
    }
    
    public func nextElements(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.nextElements(name) })
    }
    
    public var previousElements: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.previousElements }) }
    }
    
    public func previousElements(where condition: @escaping (XContent) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.previousElements(where: condition) })
    }
    
    public func previousElements(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.previousElements(name) })
    }
    
    public var allContent: XContentSequence {
        get { XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.allContent }) }
    }
    
    public func allContent(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.allContent(where: condition) })
    }
    
    public var allContentIncludingSelf: XContentSequence {
        get { XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.allContentIncludingSelf }) }
    }
    
    public func allContentIncludingSelf(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.allContentIncludingSelf(where: condition) })
    }
    
    public var descendants: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.descendants }) }
    }
    
    public func descendants(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.descendants(where: condition) })
    }
    
    public func descendants(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { content in content.descendants(name) })
    }
    
    public var descendantsIncludingSelf: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { element in element.descendantsIncludingSelf }) }
    }
    
    public func descendantsIncludingSelf(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { element in element.descendantsIncludingSelf(where: condition) })
    }
    
    public func descendantsIncludingSelf(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { element in element.descendantsIncludingSelf(name) })
    }
    
    public var previousInTreeTouching: XContentSequence {
        get { XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.previousInTreeTouching }) }
    }
    
    public func previousInTreeTouching(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.previousInTreeTouching(where: condition) })
    }
    
    public var nextInTreeTouching: XContentSequence {
        get { XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.nextInTreeTouching }) }
    }
    
    public func nextInTreeTouching(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.nextInTreeTouching(where: condition) })
    }
    
    public var parent: XElementSequence {
        get { XElementDependingOnElementSequence(sequence: self, elementGetter: { content in content.parent }) }
    }
    
    public func parent(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementDependingOnElementSequence(sequence: self, elementGetter: { content in content.parent(where: condition) })
    }
    
    public func parent(_ name: String) -> XElementSequence {
        return XElementDependingOnElementSequence(sequence: self, elementGetter: { content in content.parent(name) })
    }
    
    public var firstContent: XContentSequence {
        get { XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.firstContent }) }
    }
    
    public func firstContent(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.firstContent(where: condition) })
    }
    
    public var lastContent: XContentSequence {
        get { XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.lastContent }) }
    }
    
    public func lastContent(where condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentDependingOnElementSequence(sequence: self, contentGetter: { content in content.lastContent(where: condition) })
    }
    
    public func applied(_ f: @escaping (XElement) -> ()) -> XElementSequence {
        return XElementDependingOnElementSequence(sequence: self, elementGetter: { element in f(element); return element })
    }
    
}
