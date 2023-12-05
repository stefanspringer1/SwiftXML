//===--- ChainedIterators.swift -------------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
// and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

import Foundation

public extension XNode {
    
    var ancestors: XElementSequence {
        get { XAncestorsSequence(node: self) }
    }
    
    func ancestors(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequence(node: self), condition: condition)
    }
    
    func ancestors(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequence(node: self), elementName: name)
    }
    
    func ancestors(_ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequence(node: self), condition: { names.isEmpty || names.contains($0.name) })
    }
    
    func ancestors(_ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequence(node: self), condition: { names.isEmpty || names.contains($0.name) })
    }
    
    func ancestors(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XAncestorsSequence(node: self), while: condition)
    }
    
    func ancestors(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XAncestorsSequence(node: self), until: condition)
    }
    
    func ancestors(untilAndIncluding condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceIncludingCondition(sequence: XAncestorsSequence(node: self), untilAndIncluding: condition)
    }
    
    var ancestorsIncludingSelf: XElementSequence {
        get { XAncestorsSequenceIncludingSelf(node: self) }
    }
    
    func ancestorsIncludingSelf(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), condition: condition)
    }
    
    func ancestorsIncludingSelf(_ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), elementName: name)
    }
    
    func ancestorsIncludingSelf(_ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), condition: { names.isEmpty || names.contains($0.name) })
    }
    
    func ancestorsIncludingSelf(_ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), condition: { names.isEmpty || names.contains($0.name) })
    }
    
    func ancestorsIncludingSelf(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), while: condition)
    }
    
    func ancestorsIncludingSelf(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), until: condition)
    }
    
    func ancestorsIncludingSelf(untilAndIncluding condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceIncludingCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), untilAndIncluding: condition)
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
    
    func content(untilAndIncluding condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceIncludingCondition(sequence: XSequenceOfContent(node: self), untilAndIncluding: condition)
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
    
    func contentReversed(untilAndIncluding condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceIncludingCondition(sequence: XReversedSequenceOfContent(node: self), untilAndIncluding: condition)
    }
    
    var immediateTexts: XTextSequence {
        get { XSequenceOfTexts(node: self) }
    }
    
    func immediateTexts(_ condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithCondition(sequence: XSequenceOfTexts(node: self), condition: condition)
    }
    
    func immediateTexts(while condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWhileCondition(sequence: XSequenceOfTexts(node: self), while: condition)
    }
    
    func immediateTexts(until condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceUntilCondition(sequence: XSequenceOfTexts(node: self), until: condition)
    }
    
    func immediateTexts(untilAndIncluding condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceIncludingCondition(sequence: XSequenceOfTexts(node: self), untilAndIncluding: condition)
    }
    
    var immediateTextsReversed: XTextSequence {
        get { XReversedSequenceOfTexts(node: self) }
    }
    
    func immediateTextsReversed(_ condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithCondition(sequence: XReversedSequenceOfTexts(node: self), condition: condition)
    }
    
    func immediateTextsReversed(while condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWhileCondition(sequence: XReversedSequenceOfTexts(node: self), while: condition)
    }
    
    func immediateTextsReversed(until condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceUntilCondition(sequence: XReversedSequenceOfTexts(node: self), until: condition)
    }
    
    func immediateTextsReversed(untilAndIncluding condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceIncludingCondition(sequence: XReversedSequenceOfTexts(node: self), untilAndIncluding: condition)
    }
    
    var allTexts: XTextSequence {
        get { XSequenceOfAllTexts(node: self) }
    }
    
    func allTexts(_ condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithCondition(sequence: XSequenceOfAllTexts(node: self), condition: condition)
    }
    
    func allTexts(while condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWhileCondition(sequence: XSequenceOfAllTexts(node: self), while: condition)
    }
    
    func allTexts(until condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceUntilCondition(sequence: XSequenceOfAllTexts(node: self), until: condition)
    }
    
    func allTexts(untilAndIncluding condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceIncludingCondition(sequence: XSequenceOfAllTexts(node: self), untilAndIncluding: condition)
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
    
    func children(_ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), condition: { names.isEmpty || names.contains($0.name) })
    }
    
    func children(_ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), condition: { names.isEmpty || names.contains($0.name) })
    }
    
    func children(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XChildrenSequence(node: self), while: condition)
    }
    
    func children(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XChildrenSequence(node: self), until: condition)
    }
    
    func children(untilAndIncluding condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceIncludingCondition(sequence: XChildrenSequence(node: self), untilAndIncluding: condition)
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
    
    func childrenReversed(_ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XReversedChildrenSequence(node: self), condition: { names.isEmpty || names.contains($0.name) })
    }
    
    func childrenReversed(_ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XReversedChildrenSequence(node: self), condition: { names.isEmpty || names.contains($0.name) })
    }
    
    func childrenReversed(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XReversedChildrenSequence(node: self), while: condition)
    }
    
    func childrenReversed(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XReversedChildrenSequence(node: self), until: condition)
    }
    
    func childrenReversed(untilAndIncluding condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceIncludingCondition(sequence: XReversedChildrenSequence(node: self), untilAndIncluding: condition)
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
    
    func allContent(untilAndIncluding condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceIncludingCondition(sequence: XAllContentSequence(node: self), untilAndIncluding: condition)
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
    
    func allContentIncludingSelf(untilAndIncluding condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceIncludingCondition(sequence: XAllContentIncludingSelfSequence(node: self), untilAndIncluding: condition)
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
    
    func descendants(_ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), condition: { names.isEmpty || names.contains($0.name) })
    }
    
    func descendants(_ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), condition: { names.isEmpty || names.contains($0.name) })
    }
    
    func descendants(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XDescendantsSequence(node: self), while: condition)
    }
    
    func descendants(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XDescendantsSequence(node: self), until: condition)
    }
    
    func descendants(untilAndIncluding condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceIncludingCondition(sequence: XDescendantsSequence(node: self), untilAndIncluding: condition)
    }
    
}

public extension XContent {
    
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
    
    func next(untilAndIncluding condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceIncludingCondition(sequence: XNextSequence(content: self), untilAndIncluding: condition)
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
    
    func previous(untilAndIncluding condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceIncludingCondition(sequence: XPreviousSequence(content: self), untilAndIncluding: condition)
    }
    
    var nextTexts: XTextSequence {
        get { XNextTextsSequence(content: self) }
    }
    
    func nextTexts(_ condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithCondition(sequence: XNextTextsSequence(content: self), condition: condition)
    }
    
    func nextTexts(while condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWhileCondition(sequence: XNextTextsSequence(content: self), while: condition)
    }
    
    func nextTexts(until condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceUntilCondition(sequence: XNextTextsSequence(content: self), until: condition)
    }
    
    func nextTexts(untilAndIncluding condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceIncludingCondition(sequence: XNextTextsSequence(content: self), untilAndIncluding: condition)
    }
    
    var previousTexts: XTextSequence {
        get { XPreviousTextsSequence(content: self) }
    }
    
    func previousTexts(_ condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithCondition(sequence: XPreviousTextsSequence(content: self), condition: condition)
    }
    
    func previousTexts(while condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWhileCondition(sequence: XPreviousTextsSequence(content: self), while: condition)
    }
    
    func previousTexts(until condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceUntilCondition(sequence: XPreviousTextsSequence(content: self), until: condition)
    }
    
    func previousTexts(untilAndIncluding condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceIncludingCondition(sequence: XPreviousTextsSequence(content: self), untilAndIncluding: condition)
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
        return XElementSequenceWithCondition(sequence: XNextElementsSequence(content: self), condition: { names.isEmpty || names.contains($0.name) })
    }
    
    func nextElements(_ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextElementsSequence(content: self), condition: { names.isEmpty || names.contains($0.name) })
    }
    
    func nextElements(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XNextElementsSequence(content: self), while: condition)
    }
    
    func nextElements(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XNextElementsSequence(content: self), until: condition)
    }
    
    func nextElements(untilAndIncluding condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceIncludingCondition(sequence: XNextElementsSequence(content: self), untilAndIncluding: condition)
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
        return XElementSequenceWithCondition(sequence: XPreviousElementsSequence(content: self), condition: { names.isEmpty || names.contains($0.name) })
    }
    
    func previousElements(_ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousElementsSequence(content: self), condition: { names.isEmpty || names.contains($0.name) })
    }
    
    func previousElements(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XPreviousElementsSequence(content: self), while: condition)
    }
    
    func previousElements(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XPreviousElementsSequence(content: self), until: condition)
    }
    
    func previousElements(untilAndIncluding condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceIncludingCondition(sequence: XPreviousElementsSequence(content: self), untilAndIncluding: condition)
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
        return XElementSequenceWithCondition(sequence: XDescendantsIncludingSelfSequence(element: self), condition: { names.isEmpty || names.contains($0.name) })
    }
    
    func descendantsIncludingSelf(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XDescendantsIncludingSelfSequence(element: self), while: condition)
    }
    
    func descendantsIncludingSelf(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XDescendantsIncludingSelfSequence(element: self), until: condition)
    }
    
    func descendantsIncludingSelf(untilAndIncluding condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceIncludingCondition(sequence: XDescendantsIncludingSelfSequence(element: self), untilAndIncluding: condition)
    }
}

public extension Sequence where Element: Any {
    
    var first: Element? {
        var iterator = makeIterator()
        return iterator.next()
    }
    
    var exist: Bool {
        var iterator = makeIterator()
        return iterator.next() != nil
    }
    
    var absent: Bool { !exist }
    
    var existing: Self? { exist ? self : nil }
    
}
