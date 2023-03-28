//
//  File.swift
//  
//
//  Created by Stefan Springer on 27.09.21.
//

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
    mutating func next() -> XAttribute?
    mutating func previous() -> XAttribute?
}
