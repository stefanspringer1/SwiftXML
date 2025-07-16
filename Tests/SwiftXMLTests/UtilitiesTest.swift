//===--- ToolsTests.swift -------------------------------------------------===//
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
import AutoreleasepoolShim
@testable import SwiftXML

final class UtilitiesTest: XCTestCase {
    
    func testSortableTieredDictionary() throws {
        let dictionary = SortableTieredDictionary<String, String, String>()
        dictionary.put(key1: "3", key2: "z", value: "3z")
        dictionary.put(key1: "7", key2: "b", value: "7b")
        dictionary.put(key1: "2", key2: "u", value: "2u")
        dictionary.put(key1: "2", key2: "a", value: "2a")
        dictionary.put(key1: "3", key2: "d", value: "3d")
        dictionary.put(key1: "7", key2: "c", value: "7c")
        dictionary.put(key1: "3", key2: "a", value: "3a")
        XCTAssertEqual(dictionary.sorted.description, #"[("2", "a", "2a"), ("2", "u", "2u"), ("3", "a", "3a"), ("3", "d", "3d"), ("3", "z", "3z"), ("7", "b", "7b"), ("7", "c", "7c")]"#)
    }
    
}
