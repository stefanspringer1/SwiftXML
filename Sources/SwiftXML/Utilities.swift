//===--- Utilities.swift --------------------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
// and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

import Foundation

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

extension String {
    
    func appending(_ string: String?) -> String {
        if let string { self + string } else { self }
    }
    
    func prepending(_ string: String?) -> String {
        if let string { string + self } else { self }
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
    
    var referenced: T
    
    init(_ referenced: T) {
        self.referenced = referenced
    }
    
}

class TwoTieredDictionaryWithStringKeys<V> {
    
    var dictionary = [String:Referenced<[String:V]>]()
    
    init() {}
    
    var isEmpty: Bool { dictionary.isEmpty }
    
    func put(key1: String, key2: String, value: V?) {
        let indexForKey2 = dictionary[key1] ?? {
            let newIndex = Referenced([String:V]())
            dictionary[key1] = newIndex
            return newIndex
        }()
        indexForKey2.referenced[key2] = value
        if indexForKey2.referenced.isEmpty {
            dictionary[key1] = nil
        }
    }
    
    func removeValue(forKey1 key1: String, andKey2 key2: String) -> V? {
        guard let indexForKey2 = dictionary[key1] else { return nil }
        guard let value = indexForKey2.referenced[key2] else { return nil }
        indexForKey2.referenced[key2] = nil
        if indexForKey2.referenced.isEmpty {
            dictionary[key1] = nil
        }
        return value
    }
    
    subscript(key1: String, key2: String) -> V? {
        
        set {
            put(key1: key1, key2: key2, value: newValue)
        }
        
        get {
            return dictionary[key1]?.referenced[key2]
        }
        
    }
    
    subscript(key1: String) -> [String:V]? {
        
        get {
            return dictionary[key1]?.referenced
        }
        
    }
    
    var firstKeys: Dictionary<String, Referenced<Dictionary<String, V>>>.Keys { dictionary.keys }
    
    func secondKeys(forLeftKey leftKey: String) -> Dictionary<String, V>.Keys? {
        return dictionary[leftKey]?.referenced.keys
    }
    
    var secondKeys: Set<String> {
        var keys = Set<String>()
        firstKeys.forEach { leftKey in
            secondKeys(forLeftKey: leftKey)?.forEach { rightKey in
                keys.insert(rightKey)
            }
        }
        return keys
    }
    
    var values: [V] {
        firstKeys.compactMap { dictionary[$0]?.referenced.values }.flatMap{ $0 }
    }
    
    func values(forFirstKey key1: String) -> Dictionary<String, V>.Values? {
        dictionary[key1]?.referenced.values
    }
    
    func removeAll(keepingCapacity keepCapacity: Bool = false) {
        dictionary.removeAll(keepingCapacity: keepCapacity)
    }
    
    var keys: [(String,String)] {
        firstKeys.flatMap{ key1 in
            dictionary[key1]!.referenced.keys.map{ (key1, $0) }
        }
    }
    
    var all: [(String,String,V)] {
        firstKeys.flatMap{ key1 in
            dictionary[key1]!.referenced.map{ (key1, $0.key, $0.value) }
        }
    }
    
    var sorted: [(String,String,V)] {
        firstKeys.sorted().flatMap{ key1 in
            dictionary[key1]!.referenced.sorted(by: { $0.key < $1.key }).map{ (key1, $0.key, $0.value) }
        }
    }
    
}

class ThreeTieredDictionaryWithStringKeys<V> {

    var dictionary = [String:Referenced<[String:Referenced<[String:V]>]>]()
    
    init() {}
    
    var isEmpty: Bool { dictionary.isEmpty }
    
    func put(key1: String, key2: String, key3: String, value: V?) {
        let indexForKey2 = dictionary[key1] ?? {
            let newIndexForKey2 = Referenced([String:Referenced<[String:V]>]())
            dictionary[key1] = newIndexForKey2
            return newIndexForKey2
        }()
        let indexForKey3 = indexForKey2.referenced[key2] ?? {
            let newIndexForKey3 = Referenced([String:V]())
            indexForKey2.referenced[key2] = newIndexForKey3
            return newIndexForKey3
        }()
        indexForKey3.referenced[key3] = value
        if indexForKey3.referenced.isEmpty {
            dictionary[key1]?.referenced[key2] = nil
            if dictionary[key1]?.referenced.isEmpty == true {
                dictionary[key1] = nil
            }
        }
    }
    
    func removeValue(forKey1 key1: String, andKey2 key2: String, andKey3 key3: String) -> V? {
        guard let indexForKey2 = dictionary[key1] else { return nil }
        guard let indexForKey3 = indexForKey2.referenced[key2] else { return nil }
        guard let value = indexForKey3.referenced[key2] else { return nil }
        indexForKey3.referenced[key3] = nil
        if indexForKey3.referenced.isEmpty {
            indexForKey2.referenced[key2] = nil
            if indexForKey2.referenced.isEmpty {
                dictionary[key1] = nil
            }
        }
        return value
    }
    
    subscript(key1: String, key2: String, key3: String) -> V? {
        
        set {
            put(key1: key1, key2: key2, key3: key3, value: newValue)
        }
        
        get {
            return dictionary[key1]?.referenced[key2]?.referenced[key3]
        }
        
    }
    
    subscript(key1: String, key2: String) -> [String:V]? {
        
        get {
            return dictionary[key1]?.referenced[key2]?.referenced
        }
        
    }
    
    var firstKeys: Dictionary<String, Referenced<[String : Referenced<[String : V]>]>>.Keys { dictionary.keys }
    
    func removeAll(keepingCapacity keepCapacity: Bool = false) {
        dictionary.removeAll(keepingCapacity: keepCapacity)
    }
    
    var keys: [(String,String,String)] {
        firstKeys.flatMap{ key1 in
            dictionary[key1]!.referenced.flatMap{ (key2,indexForKey3) in
                indexForKey3.referenced.keys.map{ (key3) in
                    (key1, key2, key3)
                }
            }
        }
    }
    
    var all: [(String,String,String,V)] {
        firstKeys.flatMap{ key1 in
            dictionary[key1]!.referenced.flatMap{ (key2,indexForKey3) in
                indexForKey3.referenced.map{ (key3,value) in
                    (key1, key2, key3, value)
                }
            }
        }
    }
    
    var sorted: [(String,String,String,V)] {
        firstKeys.sorted().flatMap{ key1 in
            dictionary[key1]!.referenced.sorted(by: { $0.key < $1.key }).flatMap{ (key2,indexForKey3) in
                indexForKey3.referenced.sorted(by: { $0.key < $1.key }).map{ (key3,value) in
                    (key1, key2, key3, value)
                }
            }
        }
    }
    
}
