//===--- UtilitiesTests.swift ---------------------------------------------===//
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

final class UtilitiesTest: XCTestCase {
    
    func testTwoTieredDictionaryWithStringKeys() throws {
        let dictionary = TwoTieredDictionaryWithStringKeys<String>()
        dictionary.put(key1: "3", key2: "z", value: "3z")
        dictionary.put(key1: "7", key2: "b", value: "7b")
        dictionary.put(key1: "2", key2: "u", value: "2u")
        dictionary.put(key1: "2", key2: "a", value: "2a")
        dictionary.put(key1: "3", key2: "d", value: "3d")
        dictionary.put(key1: "7", key2: "c", value: "7c")
        dictionary.put(key1: "3", key2: "a", value: "3a")
        
        XCTAssertEqual(dictionary["7", "b"], "7b")
        XCTAssertEqual(dictionary["2", "u"], "2u")
        XCTAssertEqual(dictionary["2", "a"], "2a")
        XCTAssertEqual(dictionary["3", "d"],  "3d")
        XCTAssertEqual(dictionary["7", "c"], "7c")
        XCTAssertEqual(dictionary["3", "a"], "3a")
        
        let keys = dictionary.keys.sorted(by: { $0.0 < $1.0 || ($0.0 == $1.0 && $0.1 < $1.1) })
        print(keys)
        XCTAssertTrue(
            areEqual(
                keys,
                [
                    ("2", "a"),
                    ("2", "u"),
                    ("3", "a"),
                    ("3", "d"),
                    ("3", "z"),
                    ("7", "b"),
                    ("7", "c"),
                ]
            )
        )
        
        let allSorted = dictionary.all.sorted(by: { $0.0 < $1.0 || ($0.0 == $1.0 && $0.1 < $1.1) || ($0.0 == $1.0 && $0.1 == $1.1 && $0.2 < $1.2) })
        print(allSorted)
        XCTAssertTrue(
            areEqual(
                allSorted,
                [
                    ("2", "a", "2a"),
                    ("2", "u", "2u"),
                    ("3", "a", "3a"),
                    ("3", "d", "3d"),
                    ("3", "z", "3z"),
                    ("7", "b", "7b"),
                    ("7", "c", "7c"),
                ]
            )
        )
        let sorted = dictionary.sorted
        print(sorted)
        XCTAssertTrue(
            areEqual(
                sorted,
                [
                    ("2", "a", "2a"),
                    ("2", "u", "2u"),
                    ("3", "a", "3a"),
                    ("3", "d", "3d"),
                    ("3", "z", "3z"),
                    ("7", "b", "7b"),
                    ("7", "c", "7c"),
                ]
            )
        )
    }
    
    func testThreeTieredDictionaryWithStringKeys() throws {
        let dictionary = ThreeTieredDictionaryWithStringKeys<String>()
        dictionary.put(key1: "3", key2: "z", key3: "β", value: "3zβ")
        dictionary.put(key1: "7", key2: "b", key3: "α", value: "7bα")
        dictionary.put(key1: "2", key2: "u", key3: "γ", value: "2uγ")
        dictionary.put(key1: "2", key2: "a", key3: "β", value: "2aβ")
        dictionary.put(key1: "3", key2: "d", key3: "α", value: "3dα")
        dictionary.put(key1: "3", key2: "z", key3: "γ", value: "3zγ")
        dictionary.put(key1: "3", key2: "z", key3: "α", value: "3zα")
        dictionary.put(key1: "7", key2: "c", key3: "γ", value: "7cγ")
        dictionary.put(key1: "3", key2: "a", key3: "β", value: "3aβ")
        dictionary.put(key1: "7", key2: "c", key3: "α", value: "7cα")
        
        XCTAssertEqual(dictionary["3", "z", "β"], "3zβ")
        XCTAssertEqual(dictionary["7", "b", "α"], "7bα")
        XCTAssertEqual(dictionary["2", "u", "γ"], "2uγ")
        XCTAssertEqual(dictionary["2", "a", "β"], "2aβ")
        XCTAssertEqual(dictionary["3", "d", "α"], "3dα")
        XCTAssertEqual(dictionary["3", "z", "γ"], "3zγ")
        XCTAssertEqual(dictionary["3", "z", "α"], "3zα")
        XCTAssertEqual(dictionary["7", "c", "γ"], "7cγ")
        XCTAssertEqual(dictionary["3", "a", "β"], "3aβ")
        XCTAssertEqual(dictionary["7", "c", "α"], "7cα")
        
        let keys = dictionary.keys.sorted(by: { $0.0 < $1.0 || ($0.0 == $1.0 && $0.1 < $1.1) || ($0.0 == $1.0 && $0.1 == $1.1 && $0.2 < $1.2) })
        print(keys)
        XCTAssertTrue(
            areEqual(
                keys,
                [
                    ("2", "a", "β"),
                    ("2", "u", "γ"),
                    ("3", "a", "β"),
                    ("3", "d", "α"),
                    ("3", "z", "α"),
                    ("3", "z", "β"),
                    ("3", "z", "γ"),
                    ("7", "b", "α"),
                    ("7", "c", "α"),
                    ("7", "c", "γ"),
                ]
            )
        )
        
        let allSorted = dictionary.all.sorted(by: { $0.0 < $1.0 || ($0.0 == $1.0 && $0.1 < $1.1) || ($0.0 == $1.0 && $0.1 == $1.1 && $0.2 < $1.2) || ($0.0 == $1.0 && $0.1 == $1.1 && $0.2 == $1.2 && $0.3 < $1.3) })
        print(allSorted)
        XCTAssertTrue(
            areEqual(
                allSorted,
                [
                    ("2", "a", "β", "2aβ"),
                    ("2", "u", "γ", "2uγ"),
                    ("3", "a", "β", "3aβ"),
                    ("3", "d", "α", "3dα"),
                    ("3", "z", "α", "3zα"),
                    ("3", "z", "β", "3zβ"),
                    ("3", "z", "γ", "3zγ"),
                    ("7", "b", "α", "7bα"),
                    ("7", "c", "α", "7cα"),
                    ("7", "c", "γ", "7cγ"),
                ]
            )
        )
        
        let sorted = dictionary.sorted
        print(sorted)
        XCTAssertTrue(
            areEqual(
                sorted,
                [
                    ("2", "a", "β", "2aβ"),
                    ("2", "u", "γ", "2uγ"),
                    ("3", "a", "β", "3aβ"),
                    ("3", "d", "α", "3dα"),
                    ("3", "z", "α", "3zα"),
                    ("3", "z", "β", "3zβ"),
                    ("3", "z", "γ", "3zγ"),
                    ("7", "b", "α", "7bα"),
                    ("7", "c", "α", "7cα"),
                    ("7", "c", "γ", "7cγ"),
                ]
            )
        )
    }
    
}

fileprivate func areEqual(_ array1: [(String,String)], _ array2: [(String,String)]) -> Bool {
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

fileprivate func areEqual(_ array1: [(String,String,String)], _ array2: [(String,String,String)]) -> Bool {
    let size = array1.count
    guard size == array2.count else { return false }
    for i in 0..<size {
        let tuple1 = array1[i]
        let tuple2 = array2[i]
        guard tuple1.0 == tuple2.0 else { return false }
        guard tuple1.1 == tuple2.1 else { return false }
        guard tuple1.2 == tuple2.2 else { return false }
    }
    return true
}

fileprivate func areEqual(_ array1: [(String,String,String,String)], _ array2: [(String,String,String,String)]) -> Bool {
    let size = array1.count
    guard size == array2.count else { return false }
    for i in 0..<size {
        let tuple1 = array1[i]
        let tuple2 = array2[i]
        guard tuple1.0 == tuple2.0 else { return false }
        guard tuple1.1 == tuple2.1 else { return false }
        guard tuple1.2 == tuple2.2 else { return false }
        guard tuple1.3 == tuple2.3 else { return false }
    }
    return true
}
