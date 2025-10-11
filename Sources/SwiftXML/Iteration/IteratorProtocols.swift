//===--- IteratorProtocols.swift ------------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
// and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

import Foundation

/**
 The XNodeIteratorProtocol implements one more features over the IteratorProtocol,
 it can go backwards via the function "previous".
 */
public protocol XContentIteratorProtocol {
    mutating func next() -> XContent?
    mutating func previous() -> XContent?
}

/**
 The XTextIteratorProtocol implements one more features over the IteratorProtocol,
 it can go backwards via the function "previous".
 */
public protocol XTextIteratorProtocol {
    mutating func next() -> XText?
    mutating func previous() -> XText?
}

/**
 The XElementIteratorProtocol implements one more features over the IteratorProtocol,
 it can go backwards via the function "previous".
 */
public protocol XElementIteratorProtocol {
    mutating func next() -> XElement?
    mutating func previous() -> XElement?
}

/**
 XAttributeIteratorProtocol is the version of XNodeIteratorProtocol for
 attributes.
 */
protocol XAttributeIteratorProtocol {
    mutating func next() -> AttributeProperties?
    mutating func previous() -> AttributeProperties?
}

/**
 XProcessingInstructionrotocol is the version of XNodeIteratorProtocol for
 processing instructions.
 */
public protocol XProcessingInstructionIteratorProtocol {
    mutating func next() -> XProcessingInstruction?
    mutating func previous() -> XProcessingInstruction?
}
