//===--- SequenceConcatenation.swift --------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
// and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

import Foundation

// elements of names:

public final class XElementsOfNamesSequence: XElementSequence {
    
    private let names: [String]
    private let document: XDocument
    
    init(forNames names: [String], forDocument document: XDocument) {
        self.names = names
        self.document = document
    }
    
    public override func makeIterator() -> XElementIterator {
        return XElementsOfNamesIterator(forNames: names, forDocument: document)
    }
    
}

public final class XElementsOfNamesIterator: XElementIterator {
    
    private let iterators: [XXBidirectionalElementNameIterator]
    private var foundElement = false
    private var iteratorIndex = 0
    
    init(forNames names: [String], forDocument document: XDocument) {
        iterators = names.map{ XXBidirectionalElementNameIterator(
            elementIterator: XElementsOfSameNameIterator(
                document: document,
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
