//
//  File.swift
//  
//
//  Created by Stefan Springer on 05.09.21.
//

import Foundation

public func escapeAll(_ text: String) -> String {
    return text
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: ">", with: "&gt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
        .replacingOccurrences(of: "'", with: "&apos;")
}

public func escapeText(_ text: String) -> String {
    return text
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
}

public func escapeDoubleQuotedValue(_ text: String) -> String {
    return text
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: "\"", with: "&quot;")
}

public func escapeSimpleQuotedValue(_ text: String) -> String {
    return text
        .replacingOccurrences(of: "&", with: "&amp;")
        .replacingOccurrences(of: "<", with: "&lt;")
        .replacingOccurrences(of: "'", with: "&apos;")
}

public func sortByName(_ declarations: [String:XDeclarationInInternalSubset]) -> [XDeclarationInInternalSubset] {
    var sorted = [XDeclarationInInternalSubset]()
    declarations.keys.sorted().forEach { name in
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
public final class WeakList<T: AnyObject>: Sequence {
    
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

public func writeSimplePropertiesList(properties: [String:String], path: String, title: String? = nil, lineEnding: String = "\n", errorHandler: ((String) -> ())? = nil) {
    do {
        let fileManager = FileManager.default
        
        // If file exists, remove it
        if fileManager.fileExists(atPath: path)
        {
            try fileManager.removeItem(atPath: path)
        }
        
        // Create file and open it for writing
        fileManager.createFile(atPath: path,  contents:Data(" ".utf8), attributes: nil)
        let fileHandle = FileHandle(forWritingAtPath: path)
        if fileHandle == nil
        {
            throw SimplePropertiesParseError("\(path):E: could not open file for writing")
        }
        else
        {
            if let theTitle = title {
                try fileHandle!._write("# \(theTitle)\(lineEnding)")
            }
            try properties.keys.sorted{
                let caseInsensitive = $0.compare($1, options: .caseInsensitive)
                if caseInsensitive == ComparisonResult.orderedSame {
                    return $0.compare($1) == .orderedAscending
                }
                else {
                 return caseInsensitive == .orderedAscending
                }
            }.forEach { key in
                try fileHandle!._write("\(escapeInSimplePropertiesList(key))=\(escapeInSimplePropertiesList(properties[key]!))\(lineEnding)")
            }
            
            fileHandle!.closeFile()
        }
    }
    catch {
        let errorMessage = "\(path):E: \(error.localizedDescription)"
        if let theErrorHandler = errorHandler {
            theErrorHandler(errorMessage)
        }
        else {
            print(errorMessage)
        }
    }
}

/**
 Comments ("# ...") are only considered when the (whitespace trimmed) line is started by "#" or there is a whitespace before it!
 */
public func readSimplePropertiesList(path: String, errorHandler: ((String) -> ())? = nil) -> [String:String] {
    var result = [String:String]()
    var lineNumber = 0
    do {
        try String(contentsOfFile: path, encoding: .utf8).enumerateLines { (_line, _) in
            lineNumber += 1
            if let line = _line.components(separatedBy: " #").first?.trimmingCharacters(in: .whitespaces),
               !line.isEmpty,
               !line.hasPrefix("#")
            {
                if let firstEqual = line.firstIndex(of: "=") {
                    let key = String(line[..<firstEqual]).trimmingCharacters(in: .whitespaces)
                    if !key.isEmpty {
                        result[unescapeInSimplePropertiesList(key)] =
                            unescapeInSimplePropertiesList(
                                String(line[line.index(firstEqual, offsetBy: 1)...])
                                    .trimmingCharacters(in: .whitespaces)
                            )
                    }
                }
                else {
                    let errorMessage = "\(path):\(lineNumber):E: missing equal sign"
                    if let theErrorHandler = errorHandler {
                        theErrorHandler(errorMessage)
                    }
                    else {
                        print(errorMessage)
                    }
                }
            }
        }
    }
    catch {
        let errorMessage = "\(path):E: \(error.localizedDescription)"
        if let theErrorHandler = errorHandler {
            theErrorHandler(errorMessage)
        }
        else {
            print(errorMessage)
        }
    }
    return result
}

var standardError = FileHandle.standardError

extension FileHandle: TextOutputStream {
  public func write(_ string: String) {
    let data = Data(string.utf8)
    self.write(data)
  }
}

extension Sequence {
    
    func forEachAsync (
        _ operation: (Element) async -> Void
    ) async {
        for element in self {
            await operation(element)
        }
    }
    
    func forEachAsyncThrowing (
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
        self.forEach { s in
            if let s = s {
                nonNils.append(s)
            }
        }
        return nonNils.isEmpty ? nil : nonNils.joined(separator: separator)
    }
    
    func joinedNonEmpties(separator: String) -> String? {
        var nonEmpties = [String]()
        self.forEach { s in
            if let s = s, !s.isEmpty {
                nonEmpties.append(s)
            }
        }
        return nonEmpties.isEmpty ? nil : nonEmpties.joined(separator: separator)
    }
}
