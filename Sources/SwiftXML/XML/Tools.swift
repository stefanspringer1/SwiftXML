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
        while let backLink = result.backLink, backLink !== upTo, let parent = backLink.parent {
            let parentClone = parent.shallowClone()
            parentClone.add { result }
            result = parentClone
        }
        return result
    }
    
    if start === end {
        let startClone = start.clone()
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
    
    var ancestorsForStart = start.ancestors(until: { $0 === commonAncestor }).reversed()
    var ancestorsForEnd = end.ancestors(until: { $0 === commonAncestor }).reversed()
    
    let startClone = start.clone()
    
    func processAncestorsForStart() -> XContent {
        var content: XContent = startClone
        var orginalContent = start
        while let ancestor = ancestorsForStart.popLast() {
            let cloneOfAncestor = ancestor.shallowClone()
            cloneOfAncestor.add {
                content
                orginalContent.next.map { $0.clone() }
            }
            content = cloneOfAncestor
            orginalContent = ancestor
        }
        return content
    }
    
    let endClone = end.clone()
    
    func processAncestorsForEnd() -> XContent {
        var content: XContent = endClone
        var orginalContent = end
        while let ancestor = ancestorsForEnd.popLast() {
            let cloneOfAncestor = ancestor.shallowClone()
            cloneOfAncestor.add {
                ancestor.content(until: { $0 === orginalContent }).map { $0.clone() }
                content
            }
            content = cloneOfAncestor
            orginalContent = ancestor
        }
        return content
    }
    
    let combined = commonAncestor.shallowClone()
    let structureForStart = processAncestorsForStart()
    let structureForEnd = processAncestorsForEnd()
    combined.add {
        structureForStart
    }
    let stopForMiddle = structureForEnd.backLink!
    for middle in structureForStart.backLink!.next(until: { $0 === stopForMiddle }) {
        combined.add { middle.clone() }
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
