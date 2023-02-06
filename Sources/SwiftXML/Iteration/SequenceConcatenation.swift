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
    
    private let iterators: [XElementsOfSameNameIterator]
    private var foundElement = false
    private var iteratorIndex = 0
    
    init(forNames names: [String], forDocument document: XDocument) {
        iterators = names.map{ XElementsOfSameNameIterator(document: document, name: $0, keepLast: true) }
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
    
    private let names: [String]
    private let document: XDocument
    
    init(forNames names: [String], forDocument document: XDocument) {
        self.names = names
        self.document = document
    }
    
    public override func makeIterator() -> XAttributeIterator {
        return XAttributesOfNamesIterator(forNames: names, forDocument: document)
    }
    
}

public final class XAttributesOfNamesIterator: XAttributeIterator {
    
    private let iterators: [XAttributesOfSameNameIterator]
    private var foundElement = false
    private var iteratorIndex = 0
    
    init(forNames names: [String], forDocument document: XDocument) {
        iterators = names.map{ XAttributesOfSameNameIterator(document: document, attributeName: $0, keepLast: true) }
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
            if let next = iterator.next(), let element = next.element {
                foundElement = true
                return XAttributeSpot(name: next.name, value: next.value, element: element)
            }
            else {
                iteratorIndex += 1
            }
        }
    }
    
}
