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
    
    func ancestors(_ condition: @escaping (XElement) -> Bool, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XAncestorsSequence(node: self), condition: condition, while: whileCondition)
    }
    
    func ancestors(_ condition: @escaping (XElement) -> Bool, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XAncestorsSequence(node: self), condition: condition, until: untilCondition)
    }
    
    func ancestors(prefix: String? = nil, _ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequence(node: self), prefix: prefix, elementName: name)
    }
    
    func ancestors(prefix: String? = nil, _ name: String, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XAncestorsSequence(node: self), prefix: prefix, elementName: name, while: whileCondition)
    }
    
    func ancestors(prefix: String? = nil, _ name: String, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XAncestorsSequence(node: self), prefix: prefix, elementName: name, until: untilCondition)
    }
    
    func ancestors(prefix: String? = nil, _ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequence(node: self), condition: { $0.prefix == prefix && names.contains($0.name) })
    }
    
    func ancestors(prefix: String? = nil, _ names: [String], while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XAncestorsSequence(node: self), condition: { $0.prefix == prefix && names.contains($0.name) }, while: whileCondition)
    }
    
    func ancestors(prefix: String? = nil, _ names: [String], until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XAncestorsSequence(node: self), condition: { $0.prefix == prefix && names.contains($0.name) }, until: untilCondition)
    }
    
    func ancestors(prefix: String? = nil, _ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequence(node: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) })
    }
    
    func ancestors(prefix: String? = nil, _ names: String..., while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XAncestorsSequence(node: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, while: whileCondition)
    }
    
    func ancestors(prefix: String? = nil, _ names: String..., until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XAncestorsSequence(node: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, until: untilCondition)
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
    
    func ancestorsIncludingSelf(_ condition: @escaping (XElement) -> Bool, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), condition: condition, while: whileCondition)
    }
    
    func ancestorsIncludingSelf(_ condition: @escaping (XElement) -> Bool, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), condition: condition, until: untilCondition)
    }
    
    func ancestorsIncludingSelf(prefix: String? = nil, _ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), prefix: prefix, elementName: name)
    }
    
    func ancestorsIncludingSelf(prefix: String? = nil, _ name: String, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), prefix: prefix, elementName: name, while: whileCondition)
    }
    
    func ancestorsIncludingSelf(prefix: String? = nil, _ name: String, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), prefix: prefix, elementName: name, until: untilCondition)
    }
    
    func ancestorsIncludingSelf(prefix: String? = nil, _ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), condition: { $0.prefix == prefix && names.contains($0.name) })
    }
    
    func ancestorsIncludingSelf(prefix: String? = nil, _ names: [String], while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), condition: { $0.prefix == prefix && names.contains($0.name) }, while: whileCondition)
    }
    
    func ancestorsIncludingSelf(prefix: String? = nil, _ names: [String], until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), condition: { $0.prefix == prefix && names.contains($0.name) }, until: untilCondition)
    }
    
    func ancestorsIncludingSelf(prefix: String? = nil, _ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) })
    }
    
    func ancestorsIncludingSelf(prefix: String? = nil, _ names: String..., while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, while: whileCondition)
    }
    
    func ancestorsIncludingSelf(prefix: String? = nil, _ names: String..., until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XAncestorsSequenceIncludingSelf(node: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, until: untilCondition)
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
    
    func content(_ condition: @escaping (XContent) -> Bool, while whileCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndWhileCondition(sequence: XSequenceOfContent(node: self), condition: condition, while: whileCondition)
    }
    
    func content(_ condition: @escaping (XContent) -> Bool, until untilCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndUntilCondition(sequence: XSequenceOfContent(node: self), condition: condition, until: untilCondition)
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
    
    func contentReversed(_ condition: @escaping (XContent) -> Bool, while whileCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndWhileCondition(sequence: XReversedSequenceOfContent(node: self), condition: condition, while: whileCondition)
    }
    
    func contentReversed(_ condition: @escaping (XContent) -> Bool, until untilCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndUntilCondition(sequence: XReversedSequenceOfContent(node: self), condition: condition, until: untilCondition)
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
        get { XSequenceOfImmediateTexts(node: self) }
    }
    
    func immediateTexts(_ condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithCondition(sequence: XSequenceOfImmediateTexts(node: self), condition: condition)
    }
    
    func immediateTexts(_ condition: @escaping (XText) -> Bool, while whileCondition: @escaping (XContent) -> Bool) -> XTextSequence {
        return XTextSequenceWithConditionAndWhileCondition(sequence: XSequenceOfImmediateTexts(node: self), condition: condition, while: whileCondition)
    }
    
    func immediateTexts(_ condition: @escaping (XText) -> Bool, until untilCondition: @escaping (XContent) -> Bool) -> XTextSequence {
        return XTextSequenceWithConditionAndUntilCondition(sequence: XSequenceOfImmediateTexts(node: self), condition: condition, until: untilCondition)
    }
    
    func immediateTexts(while condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWhileCondition(sequence: XSequenceOfImmediateTexts(node: self), while: condition)
    }
    
    func immediateTexts(until condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceUntilCondition(sequence: XSequenceOfImmediateTexts(node: self), until: condition)
    }
    
    func immediateTexts(untilAndIncluding condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceIncludingCondition(sequence: XSequenceOfImmediateTexts(node: self), untilAndIncluding: condition)
    }
    
    var immediateTextsReversed: XTextSequence {
        get { XReversedSequenceOfImmediateTexts(node: self) }
    }
    
    func immediateTextsReversed(_ condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithCondition(sequence: XReversedSequenceOfImmediateTexts(node: self), condition: condition)
    }
    
    func immediateTextsReversed(_ condition: @escaping (XText) -> Bool, while whileCondition: @escaping (XContent) -> Bool) -> XTextSequence {
        return XTextSequenceWithConditionAndWhileCondition(sequence: XReversedSequenceOfImmediateTexts(node: self), condition: condition, while: whileCondition)
    }
    
    func immediateTextsReversed(_ condition: @escaping (XText) -> Bool, until untilCondition: @escaping (XContent) -> Bool) -> XTextSequence {
        return XTextSequenceWithConditionAndUntilCondition(sequence: XReversedSequenceOfImmediateTexts(node: self), condition: condition, until: untilCondition)
    }
    
    func immediateTextsReversed(while condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWhileCondition(sequence: XReversedSequenceOfImmediateTexts(node: self), while: condition)
    }
    
    func immediateTextsReversed(until condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceUntilCondition(sequence: XReversedSequenceOfImmediateTexts(node: self), until: condition)
    }
    
    func immediateTextsReversed(untilAndIncluding condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceIncludingCondition(sequence: XReversedSequenceOfImmediateTexts(node: self), untilAndIncluding: condition)
    }
    
    var allTexts: XTextSequence {
        get { XSequenceOfAllTexts(node: self) }
    }
    
    func allTexts(_ condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithCondition(sequence: XSequenceOfAllTexts(node: self), condition: condition)
    }
    
    func allTexts(_ condition: @escaping (XText) -> Bool, while whileCondition: @escaping (XContent) -> Bool) -> XTextSequence {
        return XTextSequenceWithConditionAndWhileCondition(sequence: XSequenceOfAllTexts(node: self), condition: condition, while: whileCondition)
    }
    
    func allTexts(_ condition: @escaping (XText) -> Bool, until untilCondition: @escaping (XContent) -> Bool) -> XTextSequence {
        return XTextSequenceWithConditionAndUntilCondition(sequence: XSequenceOfAllTexts(node: self), condition: condition, until: untilCondition)
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
    
    var allTextsReversed: XTextSequence {
        get { XReversedSequenceOfAllTexts(node: self) }
    }
    
    func allTextsReversed(_ condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithCondition(sequence: XReversedSequenceOfAllTexts(node: self), condition: condition)
    }
    
    func allTextsReversed(_ condition: @escaping (XText) -> Bool, while whileCondition: @escaping (XContent) -> Bool) -> XTextSequence {
        return XTextSequenceWithConditionAndWhileCondition(sequence: XReversedSequenceOfAllTexts(node: self), condition: condition, while: whileCondition)
    }
    
    func allTextsReversed(_ condition: @escaping (XText) -> Bool, until untilCondition: @escaping (XContent) -> Bool) -> XTextSequence {
        return XTextSequenceWithConditionAndUntilCondition(sequence: XReversedSequenceOfAllTexts(node: self), condition: condition, until: untilCondition)
    }
    
    func allTextsReversed(while condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWhileCondition(sequence: XReversedSequenceOfAllTexts(node: self), while: condition)
    }
    
    func allTextsReversed(until condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceUntilCondition(sequence: XReversedSequenceOfAllTexts(node: self), until: condition)
    }
    
    func allTextsReversed(untilAndIncluding condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceIncludingCondition(sequence: XReversedSequenceOfAllTexts(node: self), untilAndIncluding: condition)
    }
    
    var children: XElementSequence {
        get { XChildrenSequence(node: self) }
    }
    
    func children(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), condition: condition)
    }
    
    func children(_ condition: @escaping (XElement) -> Bool, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XChildrenSequence(node: self), condition: condition, while: whileCondition)
    }
    
    func children(_ condition: @escaping (XElement) -> Bool, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XChildrenSequence(node: self), condition: condition, until: untilCondition)
    }
    
    func children(prefix: String? = nil, _ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), prefix: prefix, elementName: name)
    }
    
    func children(prefix: String? = nil, _ name: String, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XChildrenSequence(node: self), prefix: prefix, elementName: name, while: whileCondition)
    }
    
    func children(prefix: String? = nil, _ name: String, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XChildrenSequence(node: self), prefix: prefix, elementName: name, until: untilCondition)
    }
    
    func children(prefix: String? = nil, _ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), condition: { $0.prefix == prefix && names.contains($0.name) })
    }
    
    func children(prefix: String? = nil, _ names: [String], while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XChildrenSequence(node: self), condition: { $0.prefix == prefix && names.contains($0.name) }, while: whileCondition)
    }
    
    func children(prefix: String? = nil, _ names: [String], until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XChildrenSequence(node: self), condition: { $0.prefix == prefix && names.contains($0.name) }, until: untilCondition)
    }
    
    func children(prefix: String? = nil, _ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XChildrenSequence(node: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) })
    }
    
    func children(prefix: String? = nil, _ names: String..., while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XChildrenSequence(node: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, while: whileCondition)
    }
    
    func children(prefix: String? = nil, _ names: String..., until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XChildrenSequence(node: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, until: untilCondition)
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
    
    func childrenReversed(_ condition: @escaping (XElement) -> Bool, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XReversedChildrenSequence(node: self), condition: condition, while: whileCondition)
    }
    
    func childrenReversed(_ condition: @escaping (XElement) -> Bool, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XReversedChildrenSequence(node: self), condition: condition, until: untilCondition)
    }
    
    func childrenReversed(prefix: String? = nil, _ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XReversedChildrenSequence(node: self), prefix: prefix, elementName: name)
    }
    
    func childrenReversed(prefix: String? = nil, _ name: String, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XReversedChildrenSequence(node: self), prefix: prefix, elementName: name, while: whileCondition)
    }
    
    func childrenReversed(prefix: String? = nil, _ name: String, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XReversedChildrenSequence(node: self), prefix: prefix, elementName: name, until: untilCondition)
    }
    
    func childrenReversed(prefix: String? = nil, _ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XReversedChildrenSequence(node: self), condition: { $0.prefix == prefix && names.contains($0.name) })
    }
    
    func childrenReversed(prefix: String? = nil, _ names: [String], while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XReversedChildrenSequence(node: self), condition: { $0.prefix == prefix && names.contains($0.name) }, while: whileCondition)
    }
    
    func childrenReversed(prefix: String? = nil, _ names: [String], until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XReversedChildrenSequence(node: self), condition: { $0.prefix == prefix && names.contains($0.name) }, until: untilCondition)
    }
    
    func childrenReversed(prefix: String? = nil, _ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XReversedChildrenSequence(node: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) })
    }
    
    func childrenReversed(prefix: String? = nil, _ names: String..., while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XReversedChildrenSequence(node: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, while: whileCondition)
    }
    
    func childrenReversed(prefix: String? = nil, _ names: String..., until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XReversedChildrenSequence(node: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, until: untilCondition)
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
    
    func allContent(_ condition: @escaping (XContent) -> Bool, while whileCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndWhileCondition(sequence: XAllContentSequence(node: self), condition: condition, while: whileCondition)
    }
    
    func allContent(_ condition: @escaping (XContent) -> Bool, until untilCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndUntilCondition(sequence: XAllContentSequence(node: self), condition: condition, until: untilCondition)
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
    
    func allContentIncludingSelf(_ condition: @escaping (XContent) -> Bool, while whileCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndWhileCondition(sequence: XAllContentIncludingSelfSequence(node: self), condition: condition, while: whileCondition)
    }
    
    func allContentIncludingSelf(_ condition: @escaping (XContent) -> Bool, until untilCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndUntilCondition(sequence: XAllContentIncludingSelfSequence(node: self), condition: condition, until: untilCondition)
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
    
    var allContentReversed: XContentSequence {
        get { XReversedSequenceOfAllContent(node: self) }
    }
    
    func allContentReversed(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XReversedSequenceOfAllContent(node: self), condition: condition)
    }
    
    func allContentReversed(_ condition: @escaping (XContent) -> Bool, while whileCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndWhileCondition(sequence: XReversedSequenceOfAllContent(node: self), condition: condition, while: whileCondition)
    }
    
    func allContentReversed(_ condition: @escaping (XContent) -> Bool, until untilCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndUntilCondition(sequence: XReversedSequenceOfAllContent(node: self), condition: condition, until: untilCondition)
    }
    
    func allContentReversed(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XReversedSequenceOfAllContent(node: self), while: condition)
    }
    
    func allContentReversed(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XReversedSequenceOfAllContent(node: self), until: condition)
    }
    
    func allTContentReversed(untilAndIncluding condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceIncludingCondition(sequence: XReversedSequenceOfAllContent(node: self), untilAndIncluding: condition)
    }
    
    var descendants: XElementSequence {
        get { XDescendantsSequence(node: self) }
    }
    
    func descendants(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), condition: condition)
    }
    
    func descendants(_ condition: @escaping (XElement) -> Bool, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XDescendantsSequence(node: self), condition: condition, while: whileCondition)
    }
    
    func descendants(_ condition: @escaping (XElement) -> Bool, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XDescendantsSequence(node: self), condition: condition, until: untilCondition)
    }
    
    func descendants(prefix: String? = nil, _ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), prefix: prefix, elementName: name)
    }
    
    func descendants(prefix: String? = nil, _ name: String, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XDescendantsSequence(node: self), prefix: prefix, elementName: name, while: whileCondition)
    }
    
    func descendants(prefix: String? = nil, _ name: String, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XDescendantsSequence(node: self), prefix: prefix, elementName: name, until: untilCondition)
    }
    
    func descendants(prefix: String? = nil, _ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), condition: { $0.prefix == prefix && names.contains($0.name) })
    }
    
    func descendants(prefix: String? = nil, _ names: [String], while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XDescendantsSequence(node: self), condition: { $0.prefix == prefix && names.contains($0.name) }, while: whileCondition)
    }
    
    func descendants(prefix: String? = nil, _ names: [String], until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XDescendantsSequence(node: self), condition: { $0.prefix == prefix && names.contains($0.name) }, until: untilCondition)
    }
    
    func descendants(prefix: String? = nil, _ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsSequence(node: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) })
    }
    
    func descendants(prefix: String? = nil, _ names: String..., while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XDescendantsSequence(node: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, while: whileCondition)
    }
    
    func descendants(prefix: String? = nil, _ names: String..., until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XDescendantsSequence(node: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, until: untilCondition)
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
    
    func next(_ condition: @escaping (XContent) -> Bool, while whileCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndWhileCondition(sequence: XNextSequence(content: self), condition: condition, while: whileCondition)
    }
    
    func next(_ condition: @escaping (XContent) -> Bool, until untilCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndUntilCondition(sequence: XNextSequence(content: self), condition: condition, until: untilCondition)
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
    
    var nextIncludingSelf: XContentSequence {
        get { XNextSequence(content: self) }
    }
    
    func nextIncludingSelf(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XNextIncludingSelfSequence(content: self), condition: condition)
    }
    
    func nextIncludingSelf(_ condition: @escaping (XContent) -> Bool, while whileCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndWhileCondition(sequence: XNextIncludingSelfSequence(content: self), condition: condition, while: whileCondition)
    }
    
    func nextIncludingSelf(_ condition: @escaping (XContent) -> Bool, until untilCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndUntilCondition(sequence: XNextIncludingSelfSequence(content: self), condition: condition, until: untilCondition)
    }
    
    func nextIncludingSelf(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XNextIncludingSelfSequence(content: self), while: condition)
    }
    
    func nextIncludingSelf(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XNextIncludingSelfSequence(content: self), until: condition)
    }
    
    func nextIncludingSelf(untilAndIncluding condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceIncludingCondition(sequence: XNextIncludingSelfSequence(content: self), untilAndIncluding: condition)
    }
    
    var previous: XContentSequence {
        get { XPreviousSequence(content: self) }
    }
    
    func previous(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XPreviousSequence(content: self), condition: condition)
    }
    
    func previous(_ condition: @escaping (XContent) -> Bool, while whileCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndWhileCondition(sequence: XPreviousSequence(content: self), condition: condition, while: whileCondition)
    }
    
    func previous(_ condition: @escaping (XContent) -> Bool, until untilCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndUntilCondition(sequence: XPreviousSequence(content: self), condition: condition, until: untilCondition)
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
    
    var previousIncludingSelf: XContentSequence {
        get { XPreviousIncludingSelfSequence(content: self) }
    }
    
    func previousIncludingSelf(_ condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithCondition(sequence: XPreviousIncludingSelfSequence(content: self), condition: condition)
    }
    
    func previousIncludingSelf(_ condition: @escaping (XContent) -> Bool, while whileCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndWhileCondition(sequence: XPreviousIncludingSelfSequence(content: self), condition: condition, while: whileCondition)
    }
    
    func previousIncludingSelf(_ condition: @escaping (XContent) -> Bool, until untilCondition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWithConditionAndUntilCondition(sequence: XPreviousIncludingSelfSequence(content: self), condition: condition, until: untilCondition)
    }
    
    func previousIncludingSelf(while condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceWhileCondition(sequence: XPreviousIncludingSelfSequence(content: self), while: condition)
    }
    
    func previousIncludingSelf(until condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceUntilCondition(sequence: XPreviousIncludingSelfSequence(content: self), until: condition)
    }
    
    func previousIncludingSelf(untilAndIncluding condition: @escaping (XContent) -> Bool) -> XContentSequence {
        return XContentSequenceIncludingCondition(sequence: XPreviousIncludingSelfSequence(content: self), untilAndIncluding: condition)
    }
    
    var nextTexts: XTextSequence {
        get { XNextTextsSequence(content: self) }
    }
    
    func nextTexts(_ condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithCondition(sequence: XNextTextsSequence(content: self), condition: condition)
    }
    
    func nextTexts(_ condition: @escaping (XText) -> Bool, while whileCondition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithConditionAndWhileCondition(sequence: XNextTextsSequence(content: self), condition: condition, while: whileCondition)
    }
    
    func nextTexts(_ condition: @escaping (XText) -> Bool, until untilCondition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithConditionAndUntilCondition(sequence: XNextTextsSequence(content: self), condition: condition, until: untilCondition)
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
    
    func previousTexts(_ condition: @escaping (XText) -> Bool, while whileCondition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithConditionAndWhileCondition(sequence: XPreviousTextsSequence(content: self), condition: condition, while: whileCondition)
    }
    
    func previousTexts(_ condition: @escaping (XText) -> Bool, until untilCondition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithConditionAndUntilCondition(sequence: XPreviousTextsSequence(content: self), condition: condition, until: untilCondition)
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
    
    func nextElements(_ condition: @escaping (XElement) -> Bool, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XNextElementsSequence(content: self), condition: condition, while: whileCondition)
    }
    
    func nextElements(_ condition: @escaping (XElement) -> Bool, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XNextElementsSequence(content: self), condition: condition, until: untilCondition)
    }
    
    func nextElements(prefix: String? = nil, _ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextElementsSequence(content: self), prefix: prefix, elementName: name)
    }
    
    func nextElements(prefix: String? = nil, _ name: String, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XNextElementsSequence(content: self), prefix: prefix, elementName: name, while: whileCondition)
    }
    
    func nextElements(prefix: String? = nil, _ name: String, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XNextElementsSequence(content: self), prefix: prefix, elementName: name, until: untilCondition)
    }
    
    func nextElements(prefix: String? = nil, _ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextElementsSequence(content: self), condition: { $0.prefix == prefix && names.contains($0.name) })
    }
    
    func nextElements(prefix: String? = nil, _ names: [String], while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XNextElementsSequence(content: self), condition: { $0.prefix == prefix && names.contains($0.name) }, while: whileCondition)
    }
    
    func nextElements(prefix: String? = nil, _ names: [String], until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XNextElementsSequence(content: self), condition: { $0.prefix == prefix && names.contains($0.name) }, until: untilCondition)
    }
    
    func nextElements(prefix: String? = nil, _ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextElementsSequence(content: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) })
    }
    
    func nextElements(prefix: String? = nil, _ names: String..., while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XNextElementsSequence(content: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, while: whileCondition)
    }
    
    func nextElements(prefix: String? = nil, _ names: String..., until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XNextElementsSequence(content: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, until: untilCondition)
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
    
    func previousElements(_ condition: @escaping (XElement) -> Bool, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XPreviousElementsSequence(content: self), condition: condition, while: whileCondition)
    }
    
    func previousElements(_ condition: @escaping (XElement) -> Bool, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XPreviousElementsSequence(content: self), condition: condition, until: untilCondition)
    }
    
    func previousElements(prefix: String? = nil, _ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousElementsSequence(content: self), prefix: prefix, elementName: name)
    }
    
    func previousElements(prefix: String? = nil, _ name: String, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XPreviousElementsSequence(content: self), prefix: prefix, elementName: name, while: whileCondition)
    }
    
    func previousElements(prefix: String? = nil, _ name: String, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XPreviousElementsSequence(content: self), prefix: prefix, elementName: name, until: untilCondition)
    }
    
    func previousElements(prefix: String? = nil, _ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousElementsSequence(content: self), condition: { $0.prefix == prefix && names.contains($0.name) })
    }
    
    func previousElements(prefix: String? = nil, _ names: [String], while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XPreviousElementsSequence(content: self), condition: { $0.prefix == prefix && names.contains($0.name) }, while: whileCondition)
    }
    
    func previousElements(prefix: String? = nil, _ names: [String], until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XPreviousElementsSequence(content: self), condition: { $0.prefix == prefix && names.contains($0.name) }, until: untilCondition)
    }
    
    func previousElements(prefix: String? = nil, _ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousElementsSequence(content: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) })
    }
    
    func previousElements(prefix: String? = nil, _ names: String..., while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XPreviousElementsSequence(content: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, while: whileCondition)
    }
    
    func previousElements(prefix: String? = nil, _ names: String..., until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XPreviousElementsSequence(content: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, until: untilCondition)
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
    
    var nextCloseElements: XElementSequence {
        get { XNextCloseElementsSequence(content: self) }
    }
    
    func nextCloseElements(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextCloseElementsSequence(content: self), condition: condition)
    }
    
    func nextCloseElements(_ condition: @escaping (XElement) -> Bool, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XNextCloseElementsSequence(content: self), condition: condition, while: whileCondition)
    }
    
    func nextCloseElements(_ condition: @escaping (XElement) -> Bool, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XNextCloseElementsSequence(content: self), condition: condition, until: untilCondition)
    }
    
    func nextCloseElements(prefix: String? = nil, _ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextCloseElementsSequence(content: self), prefix: prefix, elementName: name)
    }
    
    func nextCloseElements(prefix: String? = nil, _ name: String, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XNextCloseElementsSequence(content: self), prefix: prefix, elementName: name, while: whileCondition)
    }
    
    func nextCloseElements(prefix: String? = nil, _ name: String, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XNextCloseElementsSequence(content: self), prefix: prefix, elementName: name, until: untilCondition)
    }
    
    func nextCloseElements(prefix: String? = nil, _ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextCloseElementsSequence(content: self), condition: { $0.prefix == prefix && names.contains($0.name) })
    }
    
    func nextCloseElements(prefix: String? = nil, _ names: [String], while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XNextCloseElementsSequence(content: self), condition: { $0.prefix == prefix && names.contains($0.name) }, while: whileCondition)
    }
    
    func nextCloseElements(prefix: String? = nil, _ names: [String], until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XNextCloseElementsSequence(content: self), condition: { $0.prefix == prefix && names.contains($0.name) }, until: untilCondition)
    }
    
    func nextCloseElements(prefix: String? = nil, _ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextCloseElementsSequence(content: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) })
    }
    
    func nextCloseElements(prefix: String? = nil, _ names: String..., while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XNextCloseElementsSequence(content: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, while: whileCondition)
    }
    
    func nextCloseElements(prefix: String? = nil, _ names: String..., until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XNextCloseElementsSequence(content: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, until: untilCondition)
    }
    
    func nextCloseElements(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XNextCloseElementsSequence(content: self), while: condition)
    }
    
    func nextCloseElements(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XNextCloseElementsSequence(content: self), until: condition)
    }
    
    func nextCloseElements(untilAndIncluding condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceIncludingCondition(sequence: XNextCloseElementsSequence(content: self), untilAndIncluding: condition)
    }
    
    var previousCloseElements: XElementSequence {
        get { XPreviousCloseElementsSequence(content: self) }
    }
    
    func previousCloseElements(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousCloseElementsSequence(content: self), condition: condition)
    }
    
    func previousCloseElements(_ condition: @escaping (XElement) -> Bool, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XPreviousCloseElementsSequence(content: self), condition: condition, while: whileCondition)
    }
    
    func previousCloseElements(_ condition: @escaping (XElement) -> Bool, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XPreviousCloseElementsSequence(content: self), condition: condition, until: untilCondition)
    }
    
    func previousCloseElements(prefix: String? = nil, _ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousCloseElementsSequence(content: self), prefix: prefix, elementName: name)
    }
    
    func previousCloseElements(prefix: String? = nil, _ name: String, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XPreviousCloseElementsSequence(content: self), prefix: prefix, elementName: name, while: whileCondition)
    }
    
    func previousCloseElements(prefix: String? = nil, _ name: String, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XPreviousCloseElementsSequence(content: self), prefix: prefix, elementName: name, until: untilCondition)
    }
    
    func previousCloseElements(prefix: String? = nil, _ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousCloseElementsSequence(content: self), condition: { $0.prefix == prefix && names.contains($0.name) })
    }
    
    func previousCloseElements(prefix: String? = nil, _ names: [String], while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XPreviousCloseElementsSequence(content: self), condition: { $0.prefix == prefix && names.contains($0.name) }, while: whileCondition)
    }
    
    func previousCloseElements(prefix: String? = nil, _ names: [String], until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XPreviousCloseElementsSequence(content: self), condition: { $0.prefix == prefix && names.contains($0.name) }, until: untilCondition)
    }
    
    func previousCloseElements(prefix: String? = nil, _ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousCloseElementsSequence(content: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) })
    }
    
    func previousCloseElements(prefix: String? = nil, _ names: String..., while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XPreviousCloseElementsSequence(content: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, while: whileCondition)
    }
    
    func previousCloseElements(prefix: String? = nil, _ names: String..., until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XPreviousCloseElementsSequence(content: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, until: untilCondition)
    }
    
    func previousCloseElements(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XPreviousCloseElementsSequence(content: self), while: condition)
    }
    
    func previousCloseElements(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XPreviousCloseElementsSequence(content: self), until: condition)
    }
    
    func previousCloseElements(untilAndIncluding condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceIncludingCondition(sequence: XPreviousCloseElementsSequence(content: self), untilAndIncluding: condition)
    }
}

public extension XText {
    
    var nextTextsIncludingSelf: XTextSequence {
        get { XNextTextsIncludingSelfSequence(text: self) }
    }
    
    func nextTextsIncludingSelf(_ condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithCondition(sequence: XNextTextsIncludingSelfSequence(text: self), condition: condition)
    }
    
    func nextTextsIncludingSelf(_ condition: @escaping (XText) -> Bool, while whileCondition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithConditionAndWhileCondition(sequence: XNextTextsIncludingSelfSequence(text: self), condition: condition, while: whileCondition)
    }
    
    func nextTextsIncludingSelf(_ condition: @escaping (XText) -> Bool, until untilCondition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithConditionAndUntilCondition(sequence: XNextTextsIncludingSelfSequence(text: self), condition: condition, until: untilCondition)
    }
    
    func nextTextsIncludingSelf(while condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWhileCondition(sequence: XNextTextsIncludingSelfSequence(text: self), while: condition)
    }
    
    func nextTextsIncludingSelf(until condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceUntilCondition(sequence: XNextTextsIncludingSelfSequence(text: self), until: condition)
    }
    
    func nextTextsIncludingSelf(untilAndIncluding condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceIncludingCondition(sequence: XNextTextsIncludingSelfSequence(text: self), untilAndIncluding: condition)
    }
    
    var previousTextsIncludingSelf: XTextSequence {
        get { XPreviousTextsIncludingSelfSequence(text: self) }
    }
    
    func previousTextsIncludingSelf(_ condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithCondition(sequence: XPreviousTextsIncludingSelfSequence(text: self), condition: condition)
    }
    
    func previousTextsIncludingSelf(_ condition: @escaping (XText) -> Bool, while whileCondition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithConditionAndWhileCondition(sequence: XPreviousTextsIncludingSelfSequence(text: self), condition: condition, while: whileCondition)
    }
    
    func previousTextsIncludingSelf(_ condition: @escaping (XText) -> Bool, until untilCondition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWithConditionAndUntilCondition(sequence: XPreviousTextsIncludingSelfSequence(text: self), condition: condition, until: untilCondition)
    }
    
    func previousTextsIncludingSelf(while condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceWhileCondition(sequence: XPreviousTextsIncludingSelfSequence(text: self), while: condition)
    }
    
    func previousTextsIncludingSelf(until condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceUntilCondition(sequence: XPreviousTextsIncludingSelfSequence(text: self), until: condition)
    }
    
    func previousTextsIncludingSelf(untilAndIncluding condition: @escaping (XText) -> Bool) -> XTextSequence {
        return XTextSequenceIncludingCondition(sequence: XPreviousTextsIncludingSelfSequence(text: self), untilAndIncluding: condition)
    }
    
}

public extension XElement {
    
    var nextElementsIncludingSelf: XElementSequence {
        get { XNextElementsIncludingSelfSequence(element: self) }
    }
    
    func nextElementsIncludingSelf(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextElementsIncludingSelfSequence(element: self), condition: condition)
    }
    
    func nextElementsIncludingSelf(_ condition: @escaping (XElement) -> Bool, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XNextElementsIncludingSelfSequence(element: self), condition: condition, while: whileCondition)
    }
    
    func nextElementsIncludingSelf(_ condition: @escaping (XElement) -> Bool, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XNextElementsIncludingSelfSequence(element: self), condition: condition, until: untilCondition)
    }
    
    func nextElementsIncludingSelf(prefix: String? = nil, _ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextElementsIncludingSelfSequence(element: self), prefix: prefix, elementName: name)
    }
    
    func nextElementsIncludingSelf(prefix: String? = nil, _ name: String, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XNextElementsIncludingSelfSequence(element: self), prefix: prefix, elementName: name, while: whileCondition)
    }
    
    func nextElementsIncludingSelf(prefix: String? = nil, _ name: String, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XNextElementsIncludingSelfSequence(element: self), prefix: prefix, elementName: name, until: untilCondition)
    }
    
    func nextElementsIncludingSelf(prefix: String? = nil, _ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && names.contains($0.name) })
    }
    
    func nextElementsIncludingSelf(prefix: String? = nil, _ names: [String], while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XNextElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && names.contains($0.name) }, while: whileCondition)
    }
    
    func nextElementsIncludingSelf(prefix: String? = nil, _ names: [String], until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XNextElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && names.contains($0.name) }, until: untilCondition)
    }
    
    func nextElementsIncludingSelf(prefix: String? = nil, _ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) })
    }
    
    func nextElementsIncludingSelf(prefix: String? = nil, _ names: String..., while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XNextElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, while: whileCondition)
    }
    
    func nextElementsIncludingSelf(prefix: String? = nil, _ names: String..., until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XNextElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, until: untilCondition)
    }
    
    func nextElementsIncludingSelf(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XNextElementsIncludingSelfSequence(element: self), while: condition)
    }
    
    func nextElementsIncludingSelf(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XNextElementsIncludingSelfSequence(element: self), until: condition)
    }
    
    func nextElementsIncludingSelf(untilAndIncluding condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceIncludingCondition(sequence: XNextElementsIncludingSelfSequence(element: self), untilAndIncluding: condition)
    }
    
    var previousElementsIncludingSelf: XElementSequence {
        get { XPreviousElementsIncludingSelfSequence(element: self) }
    }
    
    func previousElementsIncludingSelf(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousElementsIncludingSelfSequence(element: self), condition: condition)
    }
    
    func previousElementsIncludingSelf(_ condition: @escaping (XElement) -> Bool, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XPreviousElementsIncludingSelfSequence(element: self), condition: condition, while: whileCondition)
    }
    
    func previousElementsIncludingSelf(_ condition: @escaping (XElement) -> Bool, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XPreviousElementsIncludingSelfSequence(element: self), condition: condition, until: untilCondition)
    }
    
    func previousElementsIncludingSelf(prefix: String? = nil, _ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousElementsIncludingSelfSequence(element: self), prefix: prefix, elementName: name)
    }
    
    func previousElementsIncludingSelf(prefix: String? = nil, _ name: String, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XPreviousElementsIncludingSelfSequence(element: self), prefix: prefix, elementName: name, while: whileCondition)
    }
    
    func previousElementsIncludingSelf(prefix: String? = nil, _ name: String, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XPreviousElementsIncludingSelfSequence(element: self), prefix: prefix, elementName: name, until: untilCondition)
    }
    
    func previousElementsIncludingSelf(prefix: String? = nil, _ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && names.contains($0.name) })
    }
    
    func previousElementsIncludingSelf(prefix: String? = nil, _ names: [String], while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XPreviousElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && names.contains($0.name) }, while: whileCondition)
    }
    
    func previousElementsIncludingSelf(prefix: String? = nil, _ names: [String], until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XPreviousElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && names.contains($0.name) }, until: untilCondition)
    }
    
    func previousElementsIncludingSelf(prefix: String? = nil, _ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) })
    }
    
    func previousElementsIncludingSelf(prefix: String? = nil, _ names: String..., while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XPreviousElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, while: whileCondition)
    }
    
    func previousElementsIncludingSelf(prefix: String? = nil, _ names: String..., until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XPreviousElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, until: untilCondition)
    }
    
    func previousElementsIncludingSelf(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XPreviousElementsIncludingSelfSequence(element: self), while: condition)
    }
    
    func previousElementsIncludingSelf(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XPreviousElementsIncludingSelfSequence(element: self), until: condition)
    }
    
    func previousElementsIncludingSelf(untilAndIncluding condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceIncludingCondition(sequence: XPreviousElementsIncludingSelfSequence(element: self), untilAndIncluding: condition)
    }
    
    var nextCloseElementsIncludingSelf: XElementSequence {
        get { XNextCloseElementsIncludingSelfSequence(element: self) }
    }
    
    func nextCloseElementsIncludingSelf(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextCloseElementsIncludingSelfSequence(element: self), condition: condition)
    }
    
    func nextCloseElementsIncludingSelf(prefix: String? = nil, _ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextCloseElementsIncludingSelfSequence(element: self), prefix: prefix, elementName: name)
    }
    
    func nextCloseElementsIncludingSelf(prefix: String? = nil, _ name: String, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XNextCloseElementsIncludingSelfSequence(element: self), prefix: prefix, elementName: name, while: whileCondition)
    }
    
    func nextCloseElementsIncludingSelf(prefix: String? = nil, _ name: String, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XNextCloseElementsIncludingSelfSequence(element: self), prefix: prefix, elementName: name, until: untilCondition)
    }
    
    func nextCloseElementsIncludingSelf(prefix: String? = nil, _ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextCloseElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && names.contains($0.name) })
    }
    
    func nextCloseElementsIncludingSelf(prefix: String? = nil, _ names: [String], while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XNextCloseElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && names.contains($0.name) }, while: whileCondition)
    }
    
    func nextCloseElementsIncludingSelf(prefix: String? = nil, _ names: [String], until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XNextCloseElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && names.contains($0.name) }, until: untilCondition)
    }
    
    func nextCloseElementsIncludingSelf(prefix: String? = nil, _ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XNextCloseElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) })
    }
    
    func nextCloseElementsIncludingSelf(prefix: String? = nil, _ names: String..., while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XNextCloseElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, while: whileCondition)
    }
    
    func nextCloseElementsIncludingSelf(prefix: String? = nil, _ names: String..., until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XNextCloseElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, until: untilCondition)
    }
    
    func nextCloseElementsIncludingSelf(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XNextCloseElementsIncludingSelfSequence(element: self), while: condition)
    }
    
    func nextCloseElementsIncludingSelf(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XNextCloseElementsIncludingSelfSequence(element: self), until: condition)
    }
    
    func nextCloseElementsIncludingSelf(untilAndIncluding condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceIncludingCondition(sequence: XNextCloseElementsIncludingSelfSequence(element: self), untilAndIncluding: condition)
    }
    
    var previousCloseElementsIncludingSelf: XElementSequence {
        get { XPreviousCloseElementsIncludingSelfSequence(element: self) }
    }
    
    func previousCloseElementsIncludingSelf(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousCloseElementsIncludingSelfSequence(element: self), condition: condition)
    }
    
    func previousCloseElementsIncludingSelf(_ condition: @escaping (XElement) -> Bool, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XPreviousCloseElementsIncludingSelfSequence(element: self), condition: condition, while: whileCondition)
    }
    
    func previousCloseElementsIncludingSelf(_ condition: @escaping (XElement) -> Bool, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XPreviousCloseElementsIncludingSelfSequence(element: self), condition: condition, until: untilCondition)
    }
    
    func previousCloseElementsIncludingSelf(prefix: String? = nil, _ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousCloseElementsIncludingSelfSequence(element: self), prefix: prefix, elementName: name)
    }
    
    func previousCloseElementsIncludingSelf(prefix: String? = nil, _ name: String, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XPreviousCloseElementsIncludingSelfSequence(element: self), prefix: prefix, elementName: name, while: whileCondition)
    }
    
    func previousCloseElementsIncludingSelf(prefix: String? = nil, _ name: String, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XPreviousCloseElementsIncludingSelfSequence(element: self), prefix: prefix, elementName: name, until: untilCondition)
    }
    
    func previousCloseElementsIncludingSelf(prefix: String? = nil, _ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousCloseElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && names.contains($0.name) })
    }
    
    func previousCloseElementsIncludingSelf(prefix: String? = nil, _ names: [String], while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XPreviousCloseElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && names.contains($0.name) }, while: whileCondition)
    }
    
    func previousCloseElementsIncludingSelf(prefix: String? = nil, _ names: [String], until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XPreviousCloseElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && names.contains($0.name) }, until: untilCondition)
    }
    
    func previousCloseElementsIncludingSelf(prefix: String? = nil, _ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XPreviousCloseElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) })
    }
    
    func previousCloseElementsIncludingSelf(prefix: String? = nil, _ names: String..., while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XPreviousCloseElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, while: whileCondition)
    }
    
    func previousCloseElementsIncludingSelf(prefix: String? = nil, _ names: String..., until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XPreviousCloseElementsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, until: untilCondition)
    }
    
    func previousCloseElementsIncludingSelf(while condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWhileCondition(sequence: XPreviousCloseElementsIncludingSelfSequence(element: self), while: condition)
    }
    
    func previousCloseElementsIncludingSelf(until condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceUntilCondition(sequence: XPreviousCloseElementsIncludingSelfSequence(element: self), until: condition)
    }
    
    func previousCloseElementsIncludingSelf(untilAndIncluding condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceIncludingCondition(sequence: XPreviousCloseElementsIncludingSelfSequence(element: self), untilAndIncluding: condition)
    }
    
    var descendantsIncludingSelf: XElementSequence { get { XDescendantsIncludingSelfSequence(element: self) } }
    
    func descendantsIncludingSelf(_ condition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsIncludingSelfSequence(element: self), condition: condition)
    }
    
    func descendantsIncludingSelf(_ condition: @escaping (XElement) -> Bool, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XDescendantsIncludingSelfSequence(element: self), condition: condition, while: whileCondition)
    }
    
    func descendantsIncludingSelf(_ condition: @escaping (XElement) -> Bool, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XDescendantsIncludingSelfSequence(element: self), condition: condition, until: untilCondition)
    }
    
    func descendantsIncludingSelf(prefix: String? = nil, _ name: String) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsIncludingSelfSequence(element: self), prefix: prefix, elementName: name)
    }
    
    func descendantsIncludingSelf(prefix: String? = nil, _ name: String, while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XDescendantsIncludingSelfSequence(element: self), prefix: prefix, elementName: name, while: whileCondition)
    }
    
    func descendantsIncludingSelf(prefix: String? = nil, _ name: String, until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XDescendantsIncludingSelfSequence(element: self), prefix: prefix, elementName: name, until: untilCondition)
    }
    
    func descendantsIncludingSelf(prefix: String? = nil, _ names: [String]) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && names.contains($0.name) })
    }
    
    func descendantsIncludingSelf(prefix: String? = nil, _ names: [String], while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XDescendantsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && names.contains($0.name) }, while: whileCondition)
    }
    
    func descendantsIncludingSelf(prefix: String? = nil, _ names: [String], until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XDescendantsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && names.contains($0.name) }, until: untilCondition)
    }
    
    func descendantsIncludingSelf(prefix: String? = nil, _ names: String...) -> XElementSequence {
        return XElementSequenceWithCondition(sequence: XDescendantsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) })
    }
    
    func descendantsIncludingSelf(prefix: String? = nil, _ names: String..., while whileCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndWhileCondition(sequence: XDescendantsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, while: whileCondition)
    }
    
    func descendantsIncludingSelf(prefix: String? = nil, _ names: String..., until untilCondition: @escaping (XElement) -> Bool) -> XElementSequence {
        return XElementSequenceWithConditionAndUntilCondition(sequence: XDescendantsIncludingSelfSequence(element: self), condition: { $0.prefix == prefix && (names.isEmpty || names.contains($0.name)) }, until: untilCondition)
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
    
    var last: Element? {
        var iterator = makeIterator()
        var last: Element? = nil
        while let next = iterator.next() {
            last = next
        }
        return last
    }
    
    var exist: Bool {
        var iterator = makeIterator()
        return iterator.next() != nil
    }
    
    var absent: Bool { !exist }
    
    var existing: Self? { exist ? self : nil }
    
}
