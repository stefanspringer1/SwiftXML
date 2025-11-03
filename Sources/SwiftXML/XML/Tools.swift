//===--- Tools.swift ------------------------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
// and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

import Foundation
import SwiftXMLInterfaces
import SwiftXMLParser

/// Info that a correction in the call to `copyXStructure` has to use.
public struct StructureCopyInfo {
    public let structure: XContent
    public let start: XContent
    public let cloneForStart: XContent
    public let end: XContent
    public let cloneForEnd: XContent
}

/// Copies the structure from `start` to `end`, optionally up to the `upTo` value.
/// `start` and `end` must have a common ancestor.
/// Returns `nil` if there is no common ancestor.
/// The returned element is a clone of the `upTo` value if a) it is not `nil`
/// and b) `upTo` is an ancestor of the common ancestor or the ancestor itself.
/// Else it is the clone of the common ancestor (but generally with a different
/// content in both cases). The `correction` can do some corrections.
public func copyXStructure(from start: XContent, to end: XContent, upTo: XElement? = nil, correction: ((StructureCopyInfo) -> XContent)? = nil) -> XContent? {
    
    func addUpTo(fromCopy copy: XContent) -> XContent {
        guard let upTo else { return copy }
        var result = copy
        while let backlink = result.backlink, backlink !== upTo, let parent = backlink.parent {
            let parentClone = parent.shallowClone
            parentClone.add { result }
            result = parentClone
        }
        return result
    }
    
    if start === end {
        let startClone = start.clone
        let result = addUpTo(fromCopy: startClone)
        if let correction {
            return correction(StructureCopyInfo(structure: result, start: start, cloneForStart: startClone, end: start, cloneForEnd: startClone))
        } else {
            return result
        }
    }
    
    let allAncestorsForStart = Array(start.ancestorsIncludingSelf(untilAndIncluding: { $0 === upTo }))
    
    guard let commonAncestor = end.ancestorsIncludingSelf(untilAndIncluding: { $0 === upTo }).filter({ ancestor in allAncestorsForStart.contains(where: { $0 === ancestor }) }).first else {
        return nil
    }
    
    var ancestorsForStart = start.ancestorsIncludingSelf(until: { $0 === commonAncestor }).reversed()
    if ancestorsForStart.last === start {
        ancestorsForStart.removeLast()
    }
    
    var ancestorsForEnd = end.ancestorsIncludingSelf(until: { $0 === commonAncestor }).reversed()
    if ancestorsForEnd.last === end {
        ancestorsForEnd.removeLast()
    }
    
    let startClone = start.clone
    
    func processAncestorsForStart() -> XContent {
        var content: XContent = startClone
        var orginalContent = start
        while let ancestor = ancestorsForStart.popLast() {
            let cloneOfAncestor = ancestor.shallowClone
            cloneOfAncestor.add {
                content
                orginalContent.next.map { $0.clone }
            }
            content = cloneOfAncestor
            orginalContent = ancestor
        }
        return content
    }
    
    let endClone = end.clone
    
    func processAncestorsForEnd() -> XContent {
        var content: XContent = endClone
        var orginalContent = end
        while let ancestor = ancestorsForEnd.popLast() {
            let cloneOfAncestor = ancestor.shallowClone
            cloneOfAncestor.add {
                ancestor.content(until: { $0 === orginalContent }).map { $0.clone }
                content
            }
            content = cloneOfAncestor
            orginalContent = ancestor
        }
        return content
    }
    
    let combined = commonAncestor.shallowClone
    let structureForStart = processAncestorsForStart()
    let structureForEnd = processAncestorsForEnd()
    combined.add {
        structureForStart
    }
    let stopForMiddle = structureForEnd.backlink!
    for middle in structureForStart.backlink!.next(until: { $0 === stopForMiddle }) {
        combined.add { middle.clone }
    }
    combined.add {
        structureForEnd
    }
    
    let result = addUpTo(fromCopy: combined)
    
    if let correction {
        return correction(StructureCopyInfo(structure: result, start: start, cloneForStart: startClone, end: end, cloneForEnd: endClone))
    } else {
        return result
    }
}

public struct XDocumentProperties {
    
    // -----------------------------
    // from the XML declaration:
    // -----------------------------
    
    /// The XML version text.
    public let xmlVersion: String?
    
    /// The XML version text.
    public let encoding: String?
    public let standalone: String?
    
    // -----------------------------
    // from the doctype declaration:
    // -----------------------------
    
    /// The document name.
    public let name: String?
    public var publicID: String?
    public var systemID: String?
    
    // -----------------------------
    // the root element:
    // -----------------------------
    
    /// The root element.
    public let root: XElement?
    
}

public extension XDocumentSource {
    
    /// Get the document properties from the document source with parsing it any further.
    /// The root property will be an empty representation of root element.
    /// Note that no namespace is being resolved.
    func readDocumentProperties() throws -> XDocumentProperties {
        
        class PublicIDAndRootReader: XDefaultEventHandler {
            
            var xmlVersion: String? = nil
            var encoding: String? = nil
            var standalone: String? = nil
            var name: String? = nil
            var publicID: String? = nil
            var systemID: String? = nil
            var root: XElement? = nil
            
            override func xmlDeclaration(version: String, encoding: String?, standalone: String?, textRange: XTextRange?, dataRange: XDataRange?) -> Bool {
                self.xmlVersion = version
                self.encoding = encoding
                self.standalone = standalone
                return true
            }
            
            override func documentTypeDeclarationStart(name: String, publicID: String?, systemID: String?, textRange: XTextRange?, dataRange: XDataRange?) -> Bool {
                self.name = name
                self.publicID = publicID
                self.systemID = systemID
                return true
            }
            
            override func elementStart(name: String, attributes: inout [String : String], textRange: XTextRange?, dataRange: XDataRange?) -> Bool {
                root = XElement(name, attributes)
                return false
            }
            
        }
        
        let eventHandler = PublicIDAndRootReader()
        
        try XParser().parse(fromData: self.getData(), eventHandlers: [eventHandler])
        
        return XDocumentProperties(
            xmlVersion: eventHandler.xmlVersion,
            encoding: eventHandler.encoding,
            standalone: eventHandler.standalone,
            name: eventHandler.name,
            publicID: eventHandler.publicID,
            systemID: eventHandler.systemID,
            root: eventHandler.root
        )
    }
}
