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
    
    func testSequenceTypes() throws {
        
        let document = try parseXML(fromText: """
            <test><a/>text<b/><c/><d/><e/><f/>text<g/></test>
            """)
        
        let d = document.children.children("d").first
        XCTAssertNotNil(d)
        XCTAssertEqual(d?.previousElements.map{ $0.name }.joined(separator: ", "), "c, b, a")
        XCTAssertEqual(d?.previousElementsIncludingSelf.map{ $0.name }.joined(separator: ", "), "d, c, b, a")
        XCTAssertEqual(d?.previousCloseElements.map{ $0.name }.joined(separator: ", "), "c, b")
        XCTAssertEqual(d?.previousCloseElementsIncludingSelf.map{ $0.name }.joined(separator: ", "), "d, c, b")
        XCTAssertEqual(d?.nextElements.map{ $0.name }.joined(separator: ", "), "e, f, g")
        XCTAssertEqual(d?.nextElementsIncludingSelf.map{ $0.name }.joined(separator: ", "), "d, e, f, g")
        XCTAssertEqual(d?.nextCloseElements.map{ $0.name }.joined(separator: ", "), "e, f")
        XCTAssertEqual(d?.nextCloseElementsIncludingSelf.map{ $0.name }.joined(separator: ", "), "d, e, f")
    }
    
}
