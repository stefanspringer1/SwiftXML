//===--- SwiftXMLTests.swift ----------------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
//-the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

import XCTest
import class Foundation.Bundle
@testable import SwiftXML
import SwiftXMLInterfaces

final class AttributeNamespacesTests: XCTestCase {
    
    func testManual() throws {
        
        let element = XElement(
            "test",
            ["attribute1": "value1"],
            [
                "prefix1": [
                    "attribute1": "prefix1-attribute1",
                    "attribute2": "prefix1-attribute2",
                ],
                "prefix2": [
                    "attribute1": "prefix2-attribute1"
                ]
            ]
        )
        
        element[nil,"attribute2"] = "value2"
        
        XCTAssertEqual(element["attribute1"], "value1")
        XCTAssertEqual(element["attribute2"], "value2")
        XCTAssertEqual(element["prefix1","attribute1"], "prefix1-attribute1")
        XCTAssertEqual(element["prefix1","attribute2"], "prefix1-attribute2")
        XCTAssertEqual(element["prefix2","attribute1"], "prefix2-attribute1")
        XCTAssertEqual(element["prefix2","attribute2"], nil)
        XCTAssertEqual(element["prefix3","attribute1"], nil)
        
        XCTAssertEqual(element.attributeNames, ["attribute1", "attribute2"])
        XCTAssertTrue(areEqual(element.attributeNamesWithPrefix, [(nil, "attribute1"), (nil, "attribute2"), ("prefix1", "attribute1"), ("prefix1", "attribute2"), ("prefix2", "attribute1")]))
        
        element[nil,"attribute1"] = nil
        element["prefix1","attribute2"] = nil
        element["prefix3","attribute1"] = "prefix3-attribute1"
        
        XCTAssertEqual(element["attribute1"], nil)
        XCTAssertEqual(element["attribute2"], "value2")
        XCTAssertEqual(element["prefix1","attribute1"], "prefix1-attribute1")
        XCTAssertEqual(element["prefix1","attribute2"], nil)
        XCTAssertEqual(element["prefix2","attribute1"], "prefix2-attribute1")
        XCTAssertEqual(element["prefix2","attribute2"], nil)
        XCTAssertEqual(element["prefix3","attribute1"], "prefix3-attribute1")
        
        XCTAssertEqual(element.description, #"<test attribute2="value2" prefix1:attribute1="prefix1-attribute1" prefix2:attribute1="prefix2-attribute1" prefix3:attribute1="prefix3-attribute1">"#)
        XCTAssertEqual(element.serialized, #"<test attribute2="value2" prefix1:attribute1="prefix1-attribute1" prefix2:attribute1="prefix2-attribute1" prefix3:attribute1="prefix3-attribute1"/>"#)
        
        let clone = element.clone
        XCTAssertEqual(clone.description, #"<test attribute2="value2" prefix1:attribute1="prefix1-attribute1" prefix2:attribute1="prefix2-attribute1" prefix3:attribute1="prefix3-attribute1">"#)
        XCTAssertEqual(clone.serialized, #"<test attribute2="value2" prefix1:attribute1="prefix1-attribute1" prefix2:attribute1="prefix2-attribute1" prefix3:attribute1="prefix3-attribute1"/>"#)
    }
    
}

fileprivate func areEqual(_ array1: [(String?,String)], _ array2: [(String?,String)]) -> Bool {
    let size = array1.count
    guard size == array2.count else { return false }
    for i in 0..<size {
        let tuple1 = array1[i]
        let tuple2 = array2[i]
        guard tuple1.0 == tuple2.0 else { return false }
        guard tuple1.1 == tuple2.1 else { return false }
    }
    return true
}
