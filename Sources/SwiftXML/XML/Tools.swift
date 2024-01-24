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

/// Copies the structure from `start` to `end`, optionally up to the `upTo` value.
/// `start` and `end` must have a common ancestor.
/// Returns `nil` if there is no common ancestor.
/// The returned element is a clone of the `upTo` value if a) it is not `nil`
/// and b) `upTo` is an ancestor of the common ancestor or the ancestor itself.
/// Else it is the clone of the common ancestor (but generally with a different
/// content in both cases).
public func copyStructure(from start: XContent, to end: XContent, upTo: XElement? = nil) -> XContent? {
    
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
        return addUpTo(fromCopy: start.clone())
    }
    
    let allAncestorsForStart = Array(start.ancestorsIncludingSelf(untilAndIncluding: { $0 === upTo }))
    
    guard let commonAncestor = end.ancestorsIncludingSelf(untilAndIncluding: { $0 === upTo }).filter({ ancestor in allAncestorsForStart.contains(where: { $0 === ancestor }) }).first else {
        return nil
    }
    
    var ancestorsForStart = start.ancestors(until: { $0 === commonAncestor }).reversed()
    var ancestorsForEnd = end.ancestors(until: { $0 === commonAncestor }).reversed()
    
    func processAncestorsForStart() -> XContent {
        var content: XContent = start.clone()
        while let ancestor = ancestorsForStart.popLast() {
            let cloneOfAncestor = ancestor.shallowClone()
            cloneOfAncestor.add {
                content
                content.backLink!.next.map { $0.clone() }
            }
            content = cloneOfAncestor
        }
        return content
    }
    
    func processAncestorsForEnd() -> XContent {
        var content: XContent = end.clone()
        while let ancestor = ancestorsForEnd.popLast() {
            let cloneOfAncestor = ancestor.shallowClone()
            cloneOfAncestor.add {
                content.backLink!.previous.map { $0.clone() }
                content
            }
            content = cloneOfAncestor
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
        combined.add { middle }
    }
    combined.add {
        structureForEnd
    }
    
    return addUpTo(fromCopy: combined)
}
