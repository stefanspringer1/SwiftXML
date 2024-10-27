//===--- FromReadme.swift ----------------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
// and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

import XCTest
import class Foundation.Bundle
@testable import SwiftXML


final class SequenceTypesTestTests: XCTestCase {
    
    func testWithoutNames() throws {
        
        let document = try parseXML(fromText: """
            <test><a/>text<b/><c/><d/><e/><f/>text<g/></test>
            """)
        
        let d = document.children.children("d").first
        XCTAssertNotNil(d)
        
        // previous:
        XCTAssertEqual(d?.previousElements.map{ $0.name }.joined(separator: ", "), "c, b, a")
        XCTAssertEqual(d?.previousElementsIncludingSelf.map{ $0.name }.joined(separator: ", "), "d, c, b, a")
        XCTAssertEqual(d?.previousCloseElements.map{ $0.name }.joined(separator: ", "), "c, b")
        XCTAssertEqual(d?.previousCloseElementsIncludingSelf.map{ $0.name }.joined(separator: ", "), "d, c, b")
        
        // next:
        XCTAssertEqual(d?.nextElements.map{ $0.name }.joined(separator: ", "), "e, f, g")
        XCTAssertEqual(d?.nextElementsIncludingSelf.map{ $0.name }.joined(separator: ", "), "d, e, f, g")
        XCTAssertEqual(d?.nextCloseElements.map{ $0.name }.joined(separator: ", "), "e, f")
        XCTAssertEqual(d?.nextCloseElementsIncludingSelf.map{ $0.name }.joined(separator: ", "), "d, e, f")
        
    }
    
    func testWithNames() throws {
        
        let document = try parseXML(fromText: """
            <test><a/>text<b/><c/>text<c/><c/><d/><e/><e/>text<e/><f/>text<g/></test>
            """)
        
        let d = document.children.children("d").first
        XCTAssertNotNil(d)
        
        // previous:
        XCTAssertEqual(d?.previousElements("c").map{ $0.name }.joined(separator: ", "), "c, c, c")
        XCTAssertEqual(d?.previousElements(while: { $0.name == "c" }).map{ $0.name }.joined(separator: ", "), "c, c, c")
        XCTAssertEqual(d?.previousElementsIncludingSelf(while: { $0.name == "c" }).map{ $0.name }.joined(separator: ", "), "")
        XCTAssertEqual(d?.previousElementsIncludingSelf(while: { $0.name == "d" || $0.name == "c" }).map{ $0.name }.joined(separator: ", "), "d, c, c, c")
        XCTAssertEqual(d?.previousCloseElements(while: { $0.name == "c" }).map{ $0.name }.joined(separator: ", "), "c, c")
        XCTAssertEqual(d?.previousCloseElementsIncludingSelf("c").map{ $0.name }.joined(separator: ", "), "c, c")
        XCTAssertEqual(d?.previousCloseElementsIncludingSelf(while: { $0.name == "c" }).map{ $0.name }.joined(separator: ", "), "")
        XCTAssertEqual(d?.previousCloseElementsIncludingSelf(while: { $0.name == "d" || $0.name == "c" }).map{ $0.name }.joined(separator: ", "), "d, c, c")
        
        // next:
        XCTAssertEqual(d?.nextElements("e").map{ $0.name }.joined(separator: ", "), "e, e, e")
        XCTAssertEqual(d?.nextElements(while: { $0.name == "e" }).map{ $0.name }.joined(separator: ", "), "e, e, e")
        XCTAssertEqual(d?.nextElementsIncludingSelf(while: { $0.name == "e" }).map{ $0.name }.joined(separator: ", "), "")
        XCTAssertEqual(d?.nextElementsIncludingSelf(while: { $0.name == "d" || $0.name == "e" }).map{ $0.name }.joined(separator: ", "), "d, e, e, e")
        XCTAssertEqual(d?.nextCloseElements(while: { $0.name == "e" }).map{ $0.name }.joined(separator: ", "), "e, e")
        XCTAssertEqual(d?.nextCloseElementsIncludingSelf("e").map{ $0.name }.joined(separator: ", "), "e, e")
        XCTAssertEqual(d?.nextCloseElementsIncludingSelf(while: { $0.name == "e" }).map{ $0.name }.joined(separator: ", "), "")
        XCTAssertEqual(d?.nextCloseElementsIncludingSelf(while: { $0.name == "d" || $0.name == "e" }).map{ $0.name }.joined(separator: ", "), "d, e, e")
        
    }
}
