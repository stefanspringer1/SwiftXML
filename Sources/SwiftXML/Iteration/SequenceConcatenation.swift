//===--- SequenceConcatenation.swift --------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
// and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

// elements of names:

public final class XElementsOfNamesSequence: XElementSequence {
    
    private let prefix: String?
    private let names: [String]
    private let document: XDocument
    
    init(forPrefix prefix: String?, forNames names: [String], forDocument document: XDocument) {
        self.prefix = prefix
        self.names = names
        self.document = document
    }
    
    public override func makeIterator() -> XElementIterator {
        return XElementsOfNamesIterator(forPrefix: prefix, forNames: names, forDocument: document)
    }
    
}

public final class XElementsOfNamesIterator: XElementIterator {
    
    private let iterators: [XXBidirectionalElementNameIterator]
    private var foundElement = false
    private var iteratorIndex = 0
    
    init(forPrefix prefix: String?, forNames names: [String], forDocument document: XDocument) {
        iterators = names.map{ XXBidirectionalElementNameIterator(
            elementIterator: XElementsOfSameNameIterator(
                document: document,
                prefix: prefix,
                name: $0,
                keepLast: true
            )
        ) }
    }
    
    public override func next() -> XElement? {
        guard iterators.count > 0 else { return nil }
        while true {
            if iteratorIndex == iterators.count {
                if foundElement {
                    iteratorIndex = 0
                    foundElement = false
                }
                else {
                    return nil
                }
            }
            let iterator = iterators[iteratorIndex]
            if let next = iterator.next() {
                foundElement = true
                return next
            }
            else {
                iteratorIndex += 1
            }
        }
    }
    
}

// attributes of names:

public final class XAttributesOfNamesSequence: XAttributeSequence {
    
    private let attributePrefix: String?
    private let names: [String]
    private let document: XDocument
    
    init(withAttributePrefix attributePrefix: String?, forNames names: [String], forDocument document: XDocument) {
        self.attributePrefix = attributePrefix
        self.names = names
        self.document = document
    }
    
    public override func makeIterator() -> XAttributeIterator {
        return XAttributesOfNamesIterator(forPrefix: attributePrefix, forNames: names, forDocument: document)
    }
    
}

public final class XAttributesOfNamesIterator: XAttributeIterator {
    
    private let iterators: [XBidirectionalAttributeIterator]
    private var foundElement = false
    private var iteratorIndex = 0
    
    init(forPrefix attributePrefix: String?, forNames names: [String], forDocument document: XDocument) {
        iterators = names.map {
            XBidirectionalAttributeIterator(
                forAttributeName: $0, attributeIterator: XAttributesOfSameNameIterator(
                    document: document,
                    attributePrefix: attributePrefix,
                    attributeName: $0,
                    keepLast: true
                )
            )
        }
    }
    
    public override func next() -> XAttributeSpot? {
        guard iterators.count > 0 else { return nil }
        while true {
            if iteratorIndex == iterators.count {
                if foundElement {
                    iteratorIndex = 0
                    foundElement = false
                }
                else {
                    return nil
                }
            }
            let iterator = iterators[iteratorIndex]
            if let next = iterator.next() {
                foundElement = true
                return XAttributeSpot(name: next.name, value: next.value, element: next.element)
            }
            else {
                iteratorIndex += 1
            }
        }
    }
    
}

public final class XProcessingInstructionOfTargetsIterator: XProcessingInstructionIterator {
    
    private let iterators: [XBidirectionalProcessingInstructionIterator]
    private var foundProcessingInstruction = false
    private var iteratorIndex = 0
    
    init(forTargets targets: [String], forDocument document: XDocument) {
        iterators = targets.map {
            XBidirectionalProcessingInstructionIterator(processingInstructionIterator: XProcessingInstructionOfSameTargetIterator(
                    document: document,
                    target: $0,
                    keepLast: true
                )
            )
        }
    }
    
    public override func next() -> XProcessingInstruction? {
        guard iterators.count > 0 else { return nil }
        while true {
            if iteratorIndex == iterators.count {
                if foundProcessingInstruction {
                    iteratorIndex = 0
                    foundProcessingInstruction = false
                }
                else {
                    return nil
                }
            }
            let iterator = iterators[iteratorIndex]
            if let next = iterator.next() {
                foundProcessingInstruction = true
                return next
            }
            else {
                iteratorIndex += 1
            }
        }
    }
    
}
