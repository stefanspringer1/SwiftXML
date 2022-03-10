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

public class XElementIteratorDependingOnNodeIterator: XElementIterator {
    
    private let iterator1: XNodeIterator
    private var node1: XNode? = nil
    private var started = false
    let nextSequenceGetter: (XNode) -> XElementSequence
    private var iterator2: XElementIterator? = nil
    
    init(sequence: XNodeSequence, nextSequenceGetter: @escaping (XNode) -> XElementSequence) {
        iterator1 = sequence.makeIterator()
        self.nextSequenceGetter = nextSequenceGetter
    }
    
    public override func next() -> XElement? {
        if !started {
            node1 = iterator1.next()
            started = true
        }
        while let theNode1 = node1 {
            let theIterator2 = iterator2 ?? {
                let newIterator2 = nextSequenceGetter(theNode1).makeIterator()
                iterator2 = newIterator2
                return newIterator2
            }()
            if let theNext = theIterator2.next() {
                return theNext
            }
            else {
                iterator2 = nil
                node1 = iterator1.next()
            }
        }
        return nil
    }
}

public class XNodeIteratorDependingOnElementIterator: XNodeIterator {
    
    private let iterator1: XElementIterator
    private var node1: XElement? = nil
    private var started = false
    let nextSequenceGetter: (XElement) -> XNodeSequence
    private var iterator2: XNodeIterator? = nil
    
    init(sequence: XElementSequence, nextSequenceGetter: @escaping (XElement) -> XNodeSequence) {
        iterator1 = sequence.makeIterator()
        self.nextSequenceGetter = nextSequenceGetter
    }
    
    public override func next() -> XNode? {
        if !started {
            node1 = iterator1.next()
            started = true
        }
        while let theNode1 = node1 {
            let theIterator2 = iterator2 ?? {
                let newIterator2 = nextSequenceGetter(theNode1).makeIterator()
                iterator2 = newIterator2
                return newIterator2
            }()
            if let theNext = theIterator2.next() {
                return theNext
            }
            else {
                iterator2 = nil
                node1 = iterator1.next()
            }
        }
        return nil
    }
}

public class XNodeIteratorDependingOnNodeIterator: XNodeIterator {
    
    private let iterator1: XNodeIterator
    private var node1: XNode? = nil
    private var started = false
    let nextSequenceGetter: (XNode) -> XNodeSequence
    private var iterator2: XNodeIterator? = nil
    
    init(sequence: XNodeSequence, nextSequenceGetter: @escaping (XNode) -> XNodeSequence) {
        iterator1 = sequence.makeIterator()
        self.nextSequenceGetter = nextSequenceGetter
    }
    
    public override func next() -> XNode? {
        if !started {
            node1 = iterator1.next()
            started = true
        }
        while let theNode1 = node1 {
            let theIterator2 = iterator2 ?? {
                let newIterator2 = nextSequenceGetter(theNode1).makeIterator()
                iterator2 = newIterator2
                return newIterator2
            }()
            if let theNext = theIterator2.next() {
                return theNext
            }
            else {
                iterator2 = nil
                node1 = iterator1.next()
            }
        }
        return nil
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

public class XElementSequenceDependingOnNodeSequence: XElementSequence {
    
    let sequence: XNodeSequence
    let nextSequenceGetter: (XNode) -> XElementSequence
    
    init(sequence: XNodeSequence, nextSequenceGetter: @escaping (XNode) -> XElementSequence) {
        self.sequence = sequence
        self.nextSequenceGetter = nextSequenceGetter
    }
    
    override public func makeIterator() -> XElementIterator {
        return XElementIteratorDependingOnNodeIterator(sequence: sequence, nextSequenceGetter: nextSequenceGetter)
    }
}

public class XNodeSequenceDependingOnElementSequence: XNodeSequence {
    
    let sequence: XElementSequence
    let nextSequenceGetter: (XElement) -> XNodeSequence
    
    init(sequence: XElementSequence, nextSequenceGetter: @escaping (XElement) -> XNodeSequence) {
        self.sequence = sequence
        self.nextSequenceGetter = nextSequenceGetter
    }
    
    override public func makeIterator() -> XNodeIterator {
        return XNodeIteratorDependingOnElementIterator(sequence: sequence, nextSequenceGetter: nextSequenceGetter)
    }
}

public class XNodeSequenceDependingOnNodeSequence: XNodeSequence {
    
    let sequence: XNodeSequence
    let nextSequenceGetter: (XNode) -> XNodeSequence
    
    init(sequence: XNodeSequence, nextSequenceGetter: @escaping (XNode) -> XNodeSequence) {
        self.sequence = sequence
        self.nextSequenceGetter = nextSequenceGetter
    }
    
    override public func makeIterator() -> XNodeIterator {
        return XNodeIteratorDependingOnNodeIterator(sequence: sequence, nextSequenceGetter: nextSequenceGetter)
    }
}


extension XNodeSequence {
    
    public var ancestors: XElementSequence {
        get { XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.ancestors }) }
    }
    
    public func ancestors(with condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.ancestors(with: condition) })
    }
    
    public var content: XNodeSequence {
        get { XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.content }) }
    }
    
    public func content(with condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.content(with: condition) })
    }
    
    public var children: XElementSequence {
        get { XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.children }) }
    }
    
    public func children(with condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.children(with: condition) })
    }
    
    public var next: XNodeSequence {
        get { XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.next }) }
    }
    
    public func next(with condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.next(with: condition) })
    }
    
    public var previous: XNodeSequence {
        get { XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.previous }) }
    }
    
    public func previous(with condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.previous(with: condition) })
    }
    
    public var nextElements: XElementSequence {
        get { XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.nextElements }) }
    }
    
    public func nextElements(with condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.nextElements(with: condition) })
    }
    
    public var previousElements: XElementSequence {
        get { XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.previousElements }) }
    }
    
    public func previousElements(with condition: @escaping (XNode) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.previousElements(with: condition) })
    }
    
    public var allContent: XNodeSequence {
        get { XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.allContent }) }
    }
    
    public func allContent(with condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.allContent(with: condition) })
    }
    
    public var allContentIncludingSelf: XNodeSequence {
        get { XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.allContentIncludingSelf }) }
    }
    
    public func allContentIncludingSelf(with condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.allContentIncludingSelf(with: condition) })
    }
    
    public var descendants: XElementSequence {
        get { XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.descendants }) }
    }
    
    public func descendants(with condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.descendants(with: condition) })
    }
}

extension XElementSequence {
    
    public var ancestors: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.ancestors }) }
    }
    
    public func ancestors(with condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.ancestors(with: condition) })
    }
    
    public var content: XNodeSequence {
        get { XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.content }) }
    }
    
    public func content(with condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.content(with: condition) })
    }
    
    public var children: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.children }) }
    }
    
    public func children(with condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.children(with: condition) })
    }
    
    public var next: XNodeSequence {
        get { XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.next }) }
    }
    
    public func next(with condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.next(with: condition) })
    }
    
    public var previous: XNodeSequence {
        get { XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.previous }) }
    }
    
    public func previous(with condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.previous(with: condition) })
    }
    
    public var nextElements: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.nextElements }) }
    }
    
    public func nextElements(with condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.nextElements(with: condition) })
    }
    
    public var previousElements: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.previousElements }) }
    }
    
    public func previousElements(with condition: @escaping (XNode) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.previousElements(with: condition) })
    }
    
    public var allContent: XNodeSequence {
        get { XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.allContent }) }
    }
    
    public func allContent(with condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.allContent(with: condition) })
    }
    
    public var allContentIncludingSelf: XNodeSequence {
        get { XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.allContentIncludingSelf }) }
    }
    
    public func allContentIncludingSelf(with condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.allContentIncludingSelf(with: condition) })
    }
    
    public var descendants: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.descendants }) }
    }
    
    public func descendants(with condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.descendants(with: condition) })
    }
    
    public var descendantsIncludingSelf: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { element in element.descendantsIncludingSelf }) }
    }
    
    public func descendantsIncludingSelf(with condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { element in element.descendantsIncludingSelf(with: condition) })
    }
    
}
