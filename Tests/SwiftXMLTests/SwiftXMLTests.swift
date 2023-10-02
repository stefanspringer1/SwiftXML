//===--- SwiftXMLTests.swift ----------------------------------------------===//
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

final class SwiftXMLTests: XCTestCase {
    
    let documentSource1 = """
        <a>
            <b id="1"/>
            <b id="2"/>
            <b id="3" drop="yes"/>
        </a>
        """
    
    func testForInLoop() throws {
        let document = try parseXML(fromText: """
            <a id="1">
                <b id="2"/>
                <b id="3"/>
            </a>
            """)
        for element in document.children {
            print(element.name)
        }
    }
    
    func testClone() throws {
        let source = """
            <a id="1">
                <b id="2"/>
                <b id="3"/>
            </a>
            """
        let document = try parseXML(fromText: source)
        let clone = document.clone()
        XCTAssertEqual(clone.serialized(), source)
    }
    
    func testAttributeSetting() throws {
        let element = XElement("test")
        element["att1"] = "val1"
        element["att2"] = "val2"
        element["att3"] = "val3"
        XCTAssertEqual(element["att1"], "val1")
        XCTAssertEqual(element["att2"], "val2")
        XCTAssertEqual(element["att3"], "val3")
        element["att2"] = nil
        XCTAssertEqual(element["att1"], "val1")
        XCTAssertEqual(element["att2"], nil)
        XCTAssertEqual(element["att3"], "val3")
    }
    
    func testAncestorsIterator() throws {
        let c = XElement("c")
        let a = XElement("a") {
            XElement("b") {
                c
            }
        }
        XCTAssertEqual(a.name, "a")
        let iterator = XAncestorsIterator(startNode: c)
        XCTAssertEqual(iterator.next()?.name, "b")
        XCTAssertEqual(iterator.next()?.name, "a")
        XCTAssertEqual(iterator.previous()?.name, "b")
        XCTAssertEqual(iterator.previous()?.name, nil)
        XCTAssertEqual(iterator.next()?.name, "b")
    }
    
    func testAncestorsIteratorIncludingSelf() throws {
        let c = XElement("c")
        let a = XElement("a") {
            XElement("b") {
                c
            }
        }
        XCTAssertEqual(a.name, "a")
        let iterator = XAncestorsIteratorIncludingSelf(startNode: c)
        XCTAssertEqual(iterator.next()?.name, "c")
        XCTAssertEqual(iterator.next()?.name, "b")
        XCTAssertEqual(iterator.next()?.name, "a")
        XCTAssertEqual(iterator.previous()?.name, "b")
        XCTAssertEqual(iterator.previous()?.name, "c")
        XCTAssertEqual(iterator.previous()?.name, nil)
        XCTAssertEqual(iterator.next()?.name, "c")
    }
    
    func testTypedIterator() throws {
        let document = try parseXML(fromText: documentSource1)
        let sequence = document.children.filter { $0.name == "a" }.children.drop(while: { Int($0["id"] ?? "1") ?? 1 < 2 }).filter { $0["drop"] != "yes" }
        var iterator = TypedIterator(for: sequence)
        let next: XElement? = iterator.next()
        XCTAssertEqual("\(next?.description ?? "-")", #"<b id="2">"#)
    }
    
    func testLaziness() throws {
        let document = try parseXML(fromText: documentSource1)
        let sequence = document.children.filter { $0.name == "a" }.children
        document.children.filter { $0.name == "a" }.first?.add { XElement("b", ["id": "4"]) }
        XCTAssertEqual(sequence["id"].compactMap{ $0 }.joined(separator: ", "), #"1, 2, 3, 4"#)
    }
    
    func testXContentLike() throws {
        
        do {
            let document = try parseXML(fromText: documentSource1)
            let element = XElement("test") {
                XElement("title") {
                    "this is the title"
                }
                document.children.children
            }
            XCTAssertEqual(element.serialized(pretty: true), """
            <test>
              <title>this is the title</title>
              <b id="1"/>
              <b id="2"/>
              <b drop="yes" id="3"/>
            </test>
            """)
        }
        
        do {
            let document1 = try parseXML(fromText: documentSource1)
            let document2 = try parseXML(fromText: documentSource1)
            let element = XElement("test") {
                document1.children.children
                document2.children.children
            }
            
            XCTAssertEqual(element.serialized(pretty: true), """
            <test>
              <b id="1"/>
              <b id="2"/>
              <b drop="yes" id="3"/>
              <b id="1"/>
              <b id="2"/>
              <b drop="yes" id="3"/>
            </test>
            """)
        }
        
        do {
            let document = try parseXML(fromText: documentSource1)
            let element = XElement("test") {
                XElement("title") {
                    "this is the title"
                }
                document.children.children.filter { $0.name == "b" }.drop(while: { Int($0["id"] ?? "1") ?? 1 < 2 }).filter { $0["drop"] != "yes" }.asContent
            }
            
            XCTAssertEqual(element.serialized(pretty: true), """
        <test>
          <title>this is the title</title>
          <b id="2"/>
        </test>
        """)
        }
        
        do {
            let document = try parseXML(fromText: documentSource1)
            let element = XElement("test") {
                document.children.children.filter { $0.name == "b" }.drop(while: { Int($0["id"] ?? "1") ?? 1 < 2 }).filter { $0["drop"] != "yes" }
            }
            
            XCTAssertEqual(element.serialized(pretty: true), """
        <test>
          <b id="2"/>
        </test>
        """)
        }
        
        do {
            let document1 = try parseXML(fromText: documentSource1)
            let document2 = try parseXML(fromText: documentSource1)
            let element = XElement("test") {
                document1.children.children.filter { $0.name == "b" }.drop(while: { Int($0["id"] ?? "1") ?? 1 < 2 }).filter { $0["drop"] != "yes" }
                document2.children.children.filter { $0.name == "b" }.drop(while: { Int($0["id"] ?? "1") ?? 1 < 2 }).filter { $0["drop"] != "yes" }
            }
            
            XCTAssertEqual(element.serialized(pretty: true), """
        <test>
          <b id="2"/>
          <b id="2"/>
        </test>
        """)
        }
    }
    
    func testAttributeValueSequence() throws {
        let document = try parseXML(fromText: """
            <test>
              <b id="1"/>
              <b id="2"/>
              <b id="3"/>
            </test>
            """)
        let attributeValues = document.children.children["id"].joined(separator: ", ")
        XCTAssertEqual(attributeValues, #"1, 2, 3"#)
    }
    
    func testFirstSecondThird() throws {
        let document = try parseXML(fromText: """
            <test>
              <b id="1"/>
              <b id="2"/>
              <b id="3"/>
            </test>
            """)
        let bs = document.children.children
        XCTAssertEqual([
            bs.first,
            bs.dropFirst(1).first,
            bs.dropFirst(2).first
        ].compactMap{ $0 }["id"].joined(separator: ", "), #"1, 2, 3"#)
    }
    
    func testAsync() async throws {
        
        let document = try parseXML(fromText: """
            <test>
              <b id="1"/>
              <b id="2"/>
              <b id="3"/>
            </test>
            """)
        let a = A()
        
        actor A {
            
            func f() async {
                
            }
            
            func g() async throws {
                
            }
            
        }
        
        // --------------------------------------------------------------------
        // traversal:
        // --------------------------------------------------------------------
        
        document.traverse { node in
            print("down: \(node)")
        } up: { node in
            print("up: \(node)")
        }
        await document.traverse { node in
            await a.f()
        } up: { node in
            await a.f()
        }
        try await document.traverse { node in
            try await a.g()
        } up: { node in
            try await a.g()
        }
        // "mixed":
        await document.traverse { node in
            print(node)
        } up: { node in
            await a.f()
        }
        
        // --------------------------------------------------------------------
        // forEach:
        // --------------------------------------------------------------------
        
        document.children.forEach { child in
            print(child)
        }
        await document.children.forEachAsync { child in
            await a.f()
        }
        try await document.children.forEachAsync { child in
            try await a.g()
        }
        
        _ = [1, 2, 3].map { String($0) }  // okay: map does not throw because the closure does not throw
        _ = try ["1", "2", "3"].map { (string: String) -> Int in
            guard let result = Int(string) else { throw "nanana" }
            return result
        } // okay: map can throw because the closure can throw
    }
    
    func testElementsWithNames() async throws {
        
        let document = try parseXML(fromText: """
            <a>
                <b id="b1"/>
                <c id="c1"/>
                <d id="d1"/>
                <b id="b2"/>
                <c id="c2"/>
                <d id="d2"/>
            </a>
            """)
        
        var collectedIDs = [String]()
        
        document.elements("b", "c", "d").forEach { element in
            if let id = element["id"] {
                collectedIDs.append(id)
                if id == "c1" {
                    element.insertPrevious { XElement("b", ["id": "bInserted1"]) }
                }
            }
        }
        
        XCTAssertEqual(collectedIDs.joined(separator: ", "), "b1, b2, c1, c2, d1, d2, bInserted1")
    }
    
    func testTexts() throws {
        let document = try parseXML(fromText: """
            <paragraph>Hello <bold>World</bold>!</paragraph>
            """)
        XCTAssertEqual(document.children.first!.texts.map{ "\"\($0.value)\"" }.joined(separator: ", "), #""Hello ", "!""#)
    }
    
    func testExpressibleByStringLiteral() throws {
        let text: XText = "the text"
        XCTAssertEqual(String(describing: type(of: text)), "XText")
    }
    
    func testAllTexts() throws {
        let document = try parseXML(fromText: """
            <paragraph>Hello <bold>World</bold>!</paragraph>
            """)
        XCTAssertEqual(document.allTexts.map{ "\"\($0.value)\"" }.joined(separator: ", "), #""Hello ", "World", "!""#)
    }
    
    func testTraversalWithRemoval() throws {
        let document = try parseXML(fromText: """
            <a><b><c/></b>TEXT</a>
            """)
        
        var travesalEvents = [String]()
        document.traverse { node in
            travesalEvents.append("down: \(node)")
            if let text = node as? XText { text.remove() }
        } up: { node in
            travesalEvents.append("up: \(node)")
        }
        
        XCTAssertEqual(travesalEvents.joined(separator: "\n"), """
        down: <a>
        down: <b>
        down: <c>
        up: <c>
        up: <b>
        down: TEXT
        up: <a>
        """)
    }
    
    func testSingleElementNameIteratorWithRemoval() throws {
        let document = try parseXML(fromText: """
            <a><b id="1"/><b id="2"/></a>
            """)
        
        var elementFoundInfos = [String]()
        document.elements("b").forEach { element in
            elementFoundInfos.append(element.description)
            element.remove()
        }
        
        XCTAssertEqual(elementFoundInfos.joined(separator: "\n"), """
        <b id="1">
        <b id="2">
        """)
    }
    
    func testMultipleElementNamesIteratorWithRemoval() throws {
        let document = try parseXML(fromText: """
            <a><b id="1"/><b id="2"/></a>
            """)
        
        var elementFoundInfos = [String]()
        document.elements("a", "b").forEach { element in
            elementFoundInfos.append(element.description)
            if element.name == "b" {
                element.remove()
            }
        }
        
        XCTAssertEqual(elementFoundInfos.joined(separator: "\n"), """
        <a>
        <b id="1">
        <b id="2">
        """)
    }
    
    func testNamespacePrefixes() throws {
        let document = try parseXML(fromText: """
            <a xmlns:a="http://a"  xmlns:b="http://b"/>
            """)
        
        XCTAssertEqual([
            document.fullPrefixesForNamespaces
                .sorted(by: { $0.0 < $1.0 })
                .map{ (namespace,prefix) in "namespace: \"\(namespace)\": prefix \"\(prefix)\"" }
                .joined(separator: ", "),
            "\"\(document.fullPrefix(forNamespace: "http://b"))\""
        ].joined(separator: "\n"), """
        namespace: "http://a": prefix "a:", namespace: "http://b": prefix "b:"
        "b:"
        """)
    }
    
    func testContentLikeInConstruction() {
        let element1 = XElement("element1")
        
        let _ = XElement("element") {
            element1.content
        }
        let _ = XElement("element") {
            Array(element1.content)
        }
        let _ = XElement("element") {
            element1.texts
        }
        let _ = XElement("element") {
            Array(element1.texts)
        }
        
        let _ = XElement("element") {
            element1.content
            element1.texts
            XElement("element")
        }
        let _ = XElement("element") {
            element1.content
            "u"
        }
        let _ = XElement("element") {
            ["a", "b"].asContent
        }
        let _ = XElement("element") {
            [XElement("element"), XElement("element")]
        }
        let _ = XElement("element") {
            element1.texts.map{ $0.text }.asContent
        }
        let _ = XElement("element") {
            element1.content
            element1.texts.map{ $0.text }.asContent
            "u"
            XElement("element")
        }
    }
    
}
