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

public class XNodeDependingOnNodeIterator: XNodeIterator {
    
    private let iterator1: XNodeIterator
    private var node1: XNode? = nil
    let nodeGetter: (XNode) -> XNode?
    
    init(sequence: XNodeSequence, nodeGetter: @escaping (XNode) -> XNode?) {
        iterator1 = sequence.makeIterator()
        self.nodeGetter = nodeGetter
    }
    
    public override func next() -> XNode? {
        var node2: XNode? = nil
        while node2 == nil {
            node1 = iterator1.next()
            if let theNode1 = node1 {
                node2 = nodeGetter(theNode1)
            }
            else {
                return nil
            }
        }
        return node2
    }
}

public class XNodeDependingOnElementIterator: XNodeIterator {
    
    private let iterator1: XElementIterator
    private var element1: XElement? = nil
    let nodeGetter: (XElement) -> XNode?
    
    init(sequence: XElementSequence, nodeGetter: @escaping (XElement) -> XNode?) {
        iterator1 = sequence.makeIterator()
        self.nodeGetter = nodeGetter
    }
    
    public override func next() -> XNode? {
        var node2: XNode? = nil
        while node2 == nil {
            element1 = iterator1.next()
            if let theNode1 = element1 {
                node2 = nodeGetter(theNode1)
            }
            else {
                return nil
            }
        }
        return node2
    }
}


public class XElementDependingOnNodeIterator: XElementIterator {
    
    private let iterator1: XNodeIterator
    private var node1: XNode? = nil
    let elementGetter: (XNode) -> XElement?
    
    init(sequence: XNodeSequence, elementGetter: @escaping (XNode) -> XElement?) {
        iterator1 = sequence.makeIterator()
        self.elementGetter = elementGetter
    }
    
    public override func next() -> XElement? {
        var element2: XElement? = nil
        while element2 == nil {
            node1 = iterator1.next()
            if let theNode1 = node1 {
                element2 = elementGetter(theNode1)
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
            if let theNode1 = element1 {
                element2 = elementGetter(theNode1)
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

public class XNodeDependingOnNodeSequence: XNodeSequence {
    
    let sequence: XNodeSequence
    let nodeGetter: (XNode) -> XNode?
    
    init(sequence: XNodeSequence, nodeGetter: @escaping (XNode) -> XNode?) {
        self.sequence = sequence
        self.nodeGetter = nodeGetter
    }
    
    override public func makeIterator() -> XNodeIterator {
        return XNodeDependingOnNodeIterator(sequence: sequence, nodeGetter: nodeGetter)
    }
}

public class XElementDependingOnNodeSequence: XElementSequence {
    
    let sequence: XNodeSequence
    let elementGetter: (XNode) -> XElement?
    
    init(sequence: XNodeSequence, elementGetter: @escaping (XNode) -> XElement?) {
        self.sequence = sequence
        self.elementGetter = elementGetter
    }
    
    override public func makeIterator() -> XElementIterator {
        return XElementDependingOnNodeIterator(sequence: sequence, elementGetter: elementGetter)
    }
}

public class XNodeDependingOnElementSequence: XNodeSequence {
    
    let sequence: XElementSequence
    let nodeGetter: (XElement) -> XNode?
    
    init(sequence: XElementSequence, nodeGetter: @escaping (XElement) -> XNode?) {
        self.sequence = sequence
        self.nodeGetter = nodeGetter
    }
    
    override public func makeIterator() -> XNodeIterator {
        return XNodeDependingOnElementIterator(sequence: sequence, nodeGetter: nodeGetter)
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

extension XNodeSequence {
    
    public var ancestors: XElementSequence {
        get { XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.ancestors }) }
    }
    
    public func ancestors(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.ancestors(where: condition) })
    }
    
    public func ancestors(withName name: String) -> XElementSequence {
        return XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.ancestors(name) })
    }
    
    public var content: XNodeSequence {
        get { XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.content }) }
    }
    
    public func content(where condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.content(where: condition) })
    }
    
    public var children: XElementSequence {
        get { XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.children }) }
    }
    
    public func children(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.children(where: condition) })
    }
    
    public func children(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.children(name) })
    }
    
    public var next: XNodeSequence {
        get { XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.next }) }
    }
    
    public func next(where condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.next(where: condition) })
    }
    
    public var previous: XNodeSequence {
        get { XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.previous }) }
    }
    
    public func previous(where condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.previous(where: condition) })
    }
    
    public var nextElements: XElementSequence {
        get { XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.nextElements }) }
    }
    
    public func nextElements(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.nextElements(where: condition) })
    }
    
    public func nextElements(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.nextElements(name) })
    }
    
    public var previousElements: XElementSequence {
        get { XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.previousElements }) }
    }
    
    public func previousElements(where condition: @escaping (XNode) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.previousElements(where: condition) })
    }
    
    public func previousElements(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.previousElements(name) })
    }
    
    public var allContent: XNodeSequence {
        get { XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.allContent }) }
    }
    
    public func allContent(where condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.allContent(where: condition) })
    }
    
    public var allContentIncludingSelf: XNodeSequence {
        get { XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.allContentIncludingSelf }) }
    }
    
    public func allContentIncludingSelf(where condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.allContentIncludingSelf(where: condition) })
    }
    
    public var descendants: XElementSequence {
        get { XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.descendants }) }
    }
    
    public func descendants(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.descendants(where: condition) })
    }
    
    public func descendants(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnNodeSequence(sequence: self, nextSequenceGetter: { node in node.descendants(name) })
    }
    
    public var previousNodeInTree: XNodeSequence {
        get { XNodeDependingOnNodeSequence(sequence: self, nodeGetter: { node in node.previousNodeInTree }) }
    }
    
    public func previousNodeInTree(where condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeDependingOnNodeSequence(sequence: self, nodeGetter: { node in node.previousNodeInTree(where: condition) })
    }
    
    public var nextNodeInTree: XNodeSequence {
        get { XNodeDependingOnNodeSequence(sequence: self, nodeGetter: { node in node.nextNodeInTree }) }
    }
    
    public func nextNodeInTree(where condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeDependingOnNodeSequence(sequence: self, nodeGetter: { node in node.nextNodeInTree(where: condition) })
    }
    
    public var parent: XElementSequence {
        get { XElementDependingOnNodeSequence(sequence: self, elementGetter: { node in node.parent }) }
    }
    
    public func parent(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementDependingOnNodeSequence(sequence: self, elementGetter: { node in node.parent(where: condition) })
    }
    
    public func parent(_ name: String) -> XElementSequence {
        return XElementDependingOnNodeSequence(sequence: self, elementGetter: { node in node.parent(name) })
    }
    
}

extension XElementSequence {
    
    public var ancestors: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.ancestors }) }
    }
    
    public func ancestors(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.ancestors(where: condition) })
    }
    
    public func ancestors(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.ancestors(name) })
    }
    
    public var content: XNodeSequence {
        get { XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.content }) }
    }
    
    public func content(where condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.content(where: condition) })
    }
    
    public var children: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.children }) }
    }
    
    public func children(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.children(where: condition) })
    }
    
    public func children(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.children(name) })
    }
    
    public var next: XNodeSequence {
        get { XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.next }) }
    }
    
    public func next(where condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.next(where: condition) })
    }
    
    public var previous: XNodeSequence {
        get { XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.previous }) }
    }
    
    public func previous(where condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.previous(where: condition) })
    }
    
    public var nextElements: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.nextElements }) }
    }
    
    public func nextElements(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.nextElements(where: condition) })
    }
    
    public func nextElements(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.nextElements(name) })
    }
    
    public var previousElements: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.previousElements }) }
    }
    
    public func previousElements(where condition: @escaping (XNode) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.previousElements(where: condition) })
    }
    
    public func previousElements(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.previousElements(name) })
    }
    
    public var allContent: XNodeSequence {
        get { XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.allContent }) }
    }
    
    public func allContent(where condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.allContent(where: condition) })
    }
    
    public var allContentIncludingSelf: XNodeSequence {
        get { XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.allContentIncludingSelf }) }
    }
    
    public func allContentIncludingSelf(where condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.allContentIncludingSelf(where: condition) })
    }
    
    public var descendants: XElementSequence {
        get { XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.descendants }) }
    }
    
    public func descendants(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.descendants(where: condition) })
    }
    
    public func descendants(_ name: String) -> XElementSequence {
        return XElementSequenceDependingOnElementSequence(sequence: self, nextSequenceGetter: { node in node.descendants(name) })
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
    
    public var previousNodeInTree: XNodeSequence {
        get { XNodeDependingOnElementSequence(sequence: self, nodeGetter: { node in node.previousNodeInTree }) }
    }
    
    public func previousNodeInTree(where condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeDependingOnElementSequence(sequence: self, nodeGetter: { node in node.previousNodeInTree(where: condition) })
    }
    
    public var nextNodeInTree: XNodeSequence {
        get { XNodeDependingOnElementSequence(sequence: self, nodeGetter: { node in node.nextNodeInTree }) }
    }
    
    public func nextNodeInTree(where condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeDependingOnElementSequence(sequence: self, nodeGetter: { node in node.nextNodeInTree(where: condition) })
    }
    
    public var parent: XElementSequence {
        get { XElementDependingOnElementSequence(sequence: self, elementGetter: { node in node.parent }) }
    }
    
    public func parent(where condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementDependingOnElementSequence(sequence: self, elementGetter: { node in node.parent(where: condition) })
    }
    
    public func parent(_ name: String) -> XElementSequence {
        return XElementDependingOnElementSequence(sequence: self, elementGetter: { node in node.parent(name) })
    }
    
    public var firstContent: XNodeSequence {
        get { XNodeDependingOnElementSequence(sequence: self, nodeGetter: { node in node.firstContent }) }
    }
    
    public func firstContent(where condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeDependingOnElementSequence(sequence: self, nodeGetter: { node in node.firstContent(where: condition) })
    }
    
    public var lastContent: XNodeSequence {
        get { XNodeDependingOnElementSequence(sequence: self, nodeGetter: { node in node.lastContent }) }
    }
    
    public func lastContent(where condition: @escaping (XNode) -> Bool) -> XNodeSequence {
        return XNodeDependingOnElementSequence(sequence: self, nodeGetter: { node in node.lastContent(where: condition) })
    }
    
}
