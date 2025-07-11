//===--- Util.swift -------------------------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
// and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

import Foundation
import AutoreleasepoolShim

public struct SwiftXMLError: LocalizedError, CustomStringConvertible {

    private let message: String

    public init(_ message: String) {
        self.message = message
    }
    
    public var description: String { message }
    
    public var errorDescription: String? { message }
}

public extension String {
    
    var escapingAllForXML: String {
        self
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
    
    var escapingForXML: String {
        self
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
    }
    
    var escapingDoubleQuotedValueForXML: String {
        self
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
    
    var escapingSimpleQuotedValueForXML: String {
        self
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
    
}

public func sortByName(_ declarations: [String:XDeclarationInInternalSubset]) -> [XDeclarationInInternalSubset] {
    var sorted = [XDeclarationInInternalSubset]()
    for name in declarations.keys.sorted() {
        if let theDeclaration = declarations[name] {
            sorted.append(theDeclaration)
        }
    }
    return sorted
}

struct Stack<Element> {
    var elements = [Element]()
    mutating func push(_ item: Element) {
        elements.append(item)
    }
    mutating func change(_ item: Element) {
        _ = pop()
        elements.append(item)
    }
    mutating func pop() -> Element? {
        if elements.isEmpty {
            return nil
        }
        else {
            return elements.removeLast()
        }
    }
    func peek() -> Element? {
        return elements.last
    }
    func peekAll() -> [Element] {
        return elements
    }
}

public final class WeaklyListed<T: AnyObject> {
    var next: WeaklyListed<T>? = nil
    
    weak var element: T?
    
    init(_ element: T) {
        self.element = element
    }
    
    // prevent stack overflow when destroying the list,
    // to be applied on the first element in that list,
    // cf. https://forums.swift.org/t/deep-recursion-in-deinit-should-not-happen/54987
    // !!! This should not be necessary anymore with Swift 5.7 or on masOS 13. !!!
    func removeFollowing() {
        var node = self
        while isKnownUniquelyReferenced(&node.next) {
            (node, node.next) = (node.next!, nil)
        }
    }
}

/**
 A list that stores its elements weakly. It looks for zombies whenever operating
 on it; therefore it is only suitable for a small number of elements.
 */
public final class WeakList<T: AnyObject>: LazySequenceProtocol {
    
    var first: WeaklyListed<T>? = nil
    
    public func remove(_ o: T) {
        var previous: WeaklyListed<T>? = nil
        var iterated = first
        while let item = iterated {
            if item.element == nil || item.element === o {
                previous?.next = item.next
                item.next = nil
                if item === first {
                    first = nil
                }
            }
            previous = iterated
            iterated = item.next
        }
    }
    
    public func append(_ o: T) {
        if first == nil {
            first = WeaklyListed(o)
        }
        else {
            var previous: WeaklyListed<T>? = nil
            var iterated = first
            while let item = iterated {
                if item.element == nil || item.element === o {
                    previous?.next = item.next
                    item.next = nil
                }
                previous = iterated
                iterated = item.next
                if iterated == nil {
                    previous?.next = WeaklyListed(o)
                }
            }
        }
    }
    
    public func makeIterator() -> WeakListIterator<T> {
        return WeakListIterator(start: first)
    }
    
    deinit {
        first?.removeFollowing()
    }
}

public final class WeakListIterator<T: AnyObject>: IteratorProtocol {
    
    var started = false
    var current: WeaklyListed<T>?
    
    public init(start: WeaklyListed<T>?) {
        current = start
    }
    
    public func next() -> T? {
        var previous: WeaklyListed<T>? = nil
        if started {
            previous = current
            current = current?.next
        }
        else {
            started = true
        }
        while let item = current, item.element == nil {
            previous?.next = item.next
            current = item.next
            item.next = nil
        }
        return current?.element
    }
}

public struct SimplePropertiesParseError: LocalizedError {
    
    private let message: String

    init(_ message: String) {
        self.message = message
    }
    
    public var errorDescription: String? {
        return message
    }
}

func escapeInSimplePropertiesList(_ text: String) -> String {
    return text
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "=", with: "\\=")
        .replacingOccurrences(of: ":", with: "\\:")
        .replacingOccurrences(of: "\n", with: "\\n")
        .replacingOccurrences(of: "#", with: "\\#")
}
func unescapeInSimplePropertiesList(_ text: String) -> String {
    return text.components(separatedBy: "\\\\").map { $0
        .replacingOccurrences(of: "\\#", with: "#")
        .replacingOccurrences(of: "\\n", with: "\n")
        .replacingOccurrences(of: "\\:", with: ":")
        .replacingOccurrences(of: "\\=", with: "=")
        .replacingOccurrences(of: "\\\\", with: "\\")
    }.joined(separator: "\\")
}

extension Sequence {
    
    func forEachAsync (
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}

extension Array where Element == String? {
    
    func joined(separator: String) -> String? {
        var nonNils = [String]()
        for s in self {
            if let s = s {
                nonNils.append(s)
            }
        }
        return nonNils.isEmpty ? nil : nonNils.joined(separator: separator)
    }
    
    func joinedNonEmpties(separator: String) -> String? {
        var nonEmpties = [String]()
        for s in self {
            if let s = s, !s.isEmpty {
                nonEmpties.append(s)
            }
        }
        return nonEmpties.isEmpty ? nil : nonEmpties.joined(separator: separator)
    }
}

extension StringProtocol {
    
    /// Test if a text contains a part matching a certain regular expression.
    ///
    /// Use a regular expression of the form "^...$" to test if the whole text matches the expression.
    func contains(regex: String) -> Bool {
        var match: Range<String.Index>?
        autoreleasepool {
            match = self.range(of: regex, options: .regularExpression)
        }
        return match != nil
    }
    
}

extension String {
    
    var nonEmpty: String? { self.isEmpty ? nil : self }
    
    var avoidingDoubleHyphens: String {
        
        var result  = if self.contains("--") {
            self.replacingOccurrences(of: "--", with: "(HYPHEN)(HYPHEN)")
        } else {
            self
        }
        
        if result.hasPrefix("-") {
            result = "(HYPHEN)\(result.dropFirst())"
        }
        
        if result.hasSuffix("-") {
            result = "\(result.dropLast())(HYPHEN)"
        }
        
        return result
    }
    
}

/// A wrapper around Set that can passed around by reference.
class Referenced<T> {
    
    public var referenced: T
    
    public init(_ referenced: T) {
        self.referenced = referenced
    }
    
}

class TieredDictionary<K1: Hashable,K2: Hashable,V> {
    
    private var dictionary = [K1:Referenced<[K2:V]>]()
    
    public init() {}
    
    public var isEmpty: Bool { dictionary.isEmpty }
    
    public func put(key1: K1, key2: K2, value: V?) {
        let indexForKey1 = dictionary[key1] ?? {
            let newIndex = Referenced([K2:V]())
            dictionary[key1] = newIndex
            return newIndex
        }()
        indexForKey1.referenced[key2] = value
        if indexForKey1.referenced.isEmpty {
            dictionary[key1] = nil
        }
    }
    
    public func removeValue(forKey1 key1: K1, andKey2 key2: K2) -> V? {
        guard let indexForKey1 = dictionary[key1] else { return nil }
        guard let value = indexForKey1.referenced[key2] else { return nil }
        indexForKey1.referenced[key2] = nil
        if indexForKey1.referenced.isEmpty {
            dictionary[key1] = nil
        }
        return value
    }
    
    public subscript(key1: K1, key2: K2) -> V? {
        
        set {
            put(key1: key1, key2: key2, value: newValue)
        }
        
        get {
            return dictionary[key1]?.referenced[key2]
        }
        
    }
    
    public subscript(key1: K1) -> [K2:V]? {
        
        get {
            return dictionary[key1]?.referenced
        }
        
    }
    
    public var leftKeys: Dictionary<K1, Referenced<Dictionary<K2, V>>>.Keys { dictionary.keys }
    
    public func rightKeys(forLeftKey leftKey: K1) -> Dictionary<K2, V>.Keys? {
        return dictionary[leftKey]?.referenced.keys
    }
    
    public var rightKeys: Set<K2> {
        var keys = Set<K2>()
        leftKeys.forEach { leftKey in
            rightKeys(forLeftKey: leftKey)?.forEach { rightKey in
                keys.insert(rightKey)
            }
        }
        return keys
    }
    
    public var all: [V] {
        leftKeys.compactMap { dictionary[$0]?.referenced.values }.flatMap{ $0 }
    }
    
    public func all(forFirstKey key1: K1) -> Dictionary<K2, V>.Values? {
        dictionary[key1]?.referenced.values
    }
    
    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        dictionary.removeAll(keepingCapacity: keepCapacity)
    }
}
