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
    
    func testRemovalInTransformation() throws {
        let document = try parseXML(fromText: """
            <a>
                <b><c/></b>
            </a>
            """)
        
        var foundC = false
        
        let transformation = XTransformation {
            
            XRule(forElements: "b") { b in
                b.replace {
                    XElement("d")
                }
            }
            
            XRule(forElements: "c") { b in
                foundC = true
            }
        }
        
        transformation.execute(inDocument: document)
        
        XCTAssertEqual(foundC, false)
    }
    
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
    
    func testAttributeFromDocument() throws {
        let document = try parseXML(fromText: """
            <a id="1">
                <b id="2"/>
                <b id="3"/>
            </a>
            """, registeringAttributes: ["id"])
        let element = document.children.first!
        XCTAssertEqual(element["id"], "1")
        XCTAssertEqual(document.attributes("id").map { attributeSpot in attributeSpot.value }.joined(separator: ", "), "1, 2, 3")
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
    
    func testAddingArrayOfElements() throws {
        
        let x = XElement("x") {
            [XElement("a"), XElement("b")]
        }
        
        XCTAssertEqual(x.serialized(), #"<x><a/><b/></x>"#)
    }
    
    func testXMLProperty() throws {
        
        struct MyStruct: XContentConvertible {
            
            let text1: String
            let text2: String
            
            func collectXML(by xmlCollector: inout XMLCollector) {
                xmlCollector.collect(XElement("text1") { text1 })
                xmlCollector.collect(XElement("text2") { text2 })
            }
            
        }
        
        let myStruct1 = MyStruct(text1: "hello", text2: "world")
        
        XCTAssertEqual(myStruct1.xml.map { $0.serialized() }.joined(), #"<text1>hello</text1><text2>world</text2>"#)
    }
    
    func testOptional() throws {
        
        let content: String? = "hello"
        let x = XElement("x") {
            content
        }
        
        XCTAssertEqual(x.serialized(), #"<x>hello</x>"#)
    }
    
    func testNil() throws {
        
        let content: String? = nil
        let x = XElement("x") {
            content
        }
        
        XCTAssertEqual(x.serialized(), #"<x/>"#)
        
        let y = XElement("y") {
            nil
        }
        
        XCTAssertEqual(y.serialized(), #"<y/>"#)
    }
    
    func testArrayOfOptionals() throws {
        
        let content: [XContentConvertible?] = ["hello", nil]
        let x = XElement("x") {
            content
        }
        
        XCTAssertEqual(x.serialized(), #"<x>hello</x>"#)
    }
    
    func testXMLConsumable() throws {
        
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
                document.children.children.filter { $0.name == "b" }.drop(while: { Int($0["id"] ?? "1") ?? 1 < 2 }).filter { $0["drop"] != "yes" }
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
    
    func testSomeAttributesRegistered() throws {
        let document = try parseXML(fromText: """
            <test>
              <x a="1"/>
              <x b="2"/>
              <x c="3"/>
              <x d="4"/>
            </test>
            """, registeringAttributes: ["a", "c"])
        
        let registeredValuesInfo = document.attributes("a", "b", "c", "d").map{ $0.value }.joined(separator: ", ")
        XCTAssertEqual(registeredValuesInfo, #"1, 3"#)
        
        let allValuesInfo = document.elements("x").compactMap{
            if let name = $0.attributeNames.first { $0[name] } else { nil }
        }.joined(separator: ", ")
        XCTAssertEqual(allValuesInfo, #"1, 2, 3, 4"#)
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
        // alternative:
        for child in document.children {
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
        
        for element in document.elements("b", "c", "d") {
            if let id = element["id"] {
                collectedIDs.append(id)
                if id == "c1" {
                    element.insertPrevious { XElement("b", ["id": "bInserted1"]) }
                }
            }
        }
        
        XCTAssertEqual(collectedIDs.joined(separator: ", "), "b1, b2, c1, c2, d1, d2, bInserted1")
    }
    
    func testAttributesWithNames() async throws {
           
        let document = try parseXML(fromText: """
           <a>
               <x b="b1"/>
               <x c="c1"/>
               <x d="d1"/>
               <x b="b2"/>
               <x c="c2"/>
               <x d="d2"/>
           </a>
           """, registeringAttributes: ["b", "c", "d"])

        var collectedAttributeValues = [String]()

        document.attributes("b").forEach { attribute in print(attribute) }

        document.attributes("b", "c", "d").forEach { attribute in
           collectedAttributeValues.append(attribute.value)
           if attribute.value == "c1" {
               attribute.element.insertPrevious { XElement("x", ["b": "bInserted1"]) }
           }
        }

        let _ = XTransformation {
           
           XRule(forElements: "table") { table in
               table.insertNext {
                   XElement("caption") {
                       "Table: "
                       table.children({ $0.name.contains("title") }).content
                   }
               }
           }
           
           XRule(forElements: "tbody", "tfoot") { tablePart in
               tablePart
                   .children("tr")
                   .children("th")
                   .forEach { cell in
                       cell.name = "td"
                   }
           }
           
           XRule(forAttributes: "id") { id in
               print("\n----- Rule for attribute \"id\" -----\n")
               print("  \(id.element) --> ", terminator: "")
               id.element["id"] = "done-" + id.value
               print(id.element)
           }
           
        }

        XCTAssertEqual(collectedAttributeValues.joined(separator: ", "), "b1, b2, c1, c2, d1, d2, bInserted1")
    }
    
    func testSequencePart() {
        
        let a = XElement("a") { "hello"; XText(" world", isolated: true) }
        
        XCTAssertEqual(XElement("b") { a.content.dropLast() }.serialized(), #"<b>hello</b>"#)
    }
    
    func testTexts() throws {
        let document = try parseXML(fromText: """
            <paragraph>Hello <bold>World</bold>!</paragraph>
            """)
        XCTAssertEqual(document.children.first!.immediateTexts.map{ "\"\($0.value)\"" }.joined(separator: ", "), #""Hello ", "!""#)
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
        down: "TEXT"
        up: <a>
        """)
    }
    
    func testSingleElementNameIteratorWithRemoval() throws {
        let document = try parseXML(fromText: """
            <a><b id="1"/><b id="2"/></a>
            """)
        
        var elementFoundInfos = [String]()
        for element in document.elements("b") {
            elementFoundInfos.append(element.description)
            element.remove()
        }
        
        XCTAssertEqual(elementFoundInfos.joined(separator: "\n"), """
        <b id="1">
        <b id="2">
        """)
    }
    
    func testSingleAttributeNameIteratorWithRemoval() throws {
        let document = try parseXML(fromText: """
            <a><b id="1"/><b id="2"/></a>
            """, registeringAttributes: ["id"])
        
        var elementFoundInfos = [String]()
        document.attributes("id").forEach { attributeSpot in
            elementFoundInfos.append(attributeSpot.element.description)
            attributeSpot.element.remove()
        }
        
        XCTAssertEqual(elementFoundInfos.joined(separator: "\n"), """
        <b id="1">
        <b id="2">
        """)
    }
    
    func testMultipleAttributeNamesIteratorWithRemoval() throws {
        let document = try parseXML(fromText: """
            <a type="type1"><b id="1"/><b id="2"/></a>
            """, registeringAttributes: ["type", "id"])
        
        var elementFoundInfos = [String]()
        document.attributes("type", "id").forEach { attributeSpot in
            elementFoundInfos.append(attributeSpot.element.description)
            if attributeSpot.name == "id" {
                attributeSpot.element.remove()
            }
        }
        
        XCTAssertEqual(elementFoundInfos.joined(separator: "\n"), """
        <a type="type1">
        <b id="1">
        <b id="2">
        """)
    }
    
    func testMultipleElementNamesIteratorWithRemoval() throws {
        let document = try parseXML(fromText: """
            <a><b id="1"/><b id="2"/></a>
            """)
        
        var elementFoundInfos = [String]()
        for element in document.elements("a", "b") {
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
    
    func testReplaceByNothing() throws {
        let a = XElement("a") { "hello" }
        let wrapper = XElement("wrapper") { a }
        
        XCTAssertEqual(wrapper.serialized(), "<wrapper><a>hello</a></wrapper>")
        
        a.replace {
            // nothing
        }
        
        XCTAssertEqual(wrapper.serialized(), "<wrapper/>")
    }
    
    func testContentLikeInConstruction() throws {
        let element1 = XElement("element1")
        
        let _ = XElement("element") {
            element1.content
        }
        let _ = XElement("element") {
            Array(element1.content)
        }
        let _ = XElement("element") {
            element1.immediateTexts
        }
        let _ = XElement("element") {
            Array(element1.immediateTexts)
        }
        
        let _ = XElement("element") {
            element1.content
            element1.immediateTexts
            XElement("element")
        }
        let _ = XElement("element") {
            element1.content
            "u"
        }
        let _ = XElement("element") {
            ["a", "b"]
        }
        let _ = XElement("element") {
            [XElement("element"), XElement("element")]
        }
        let _ = XElement("element") {
            element1.immediateTexts.map{ $0.allTextsCombined }
        }
        let _ = XElement("element") {
            element1.content
            element1.immediateTexts.map{ $0.allTextsCombined }
            "u"
            XElement("element")
        }
    }
    
    func testPretty() {
        let element1 = XElement("element1") { XInternalEntity("ent1")}
        
        XCTAssertEqual(element1.serialized(pretty: true), "<element1>&ent1;</element1>")
    }
    
    func testNewlineInAttribute() {
        let element1 = XElement("element1", ["att1": "hello\nworld"])
        
        XCTAssertEqual(element1.serialized(pretty: true), #"<element1 att1="hello&#x0A;world"/>"#)
    }
    
    func testNewlineInAttributeReverse() throws {
        let document = try parseXML(fromText: #"<element1 att1="hello&#x0A;world"/>"#)
        
        XCTAssertEqual(document.children.first?["att1"], "hello\nworld")
    }
    
    func testTextForElementSequence() throws {
        let document = try parseXML(fromText: """
        <sentences>
            <sentence><word>Hello</word> <word>World</word></sentence>
            <sentence><word>Feel</word> <word>good</word></sentence>
        </sentences>
        """)
        
        XCTAssertEqual(document.elements("sentence").map{ "\"\($0.allTextsCombined)\"" }.joined(separator: ", "), #""Hello World", "Feel good""#)
    }
    
    func testReversedAllContent() throws {
        let document = try parseXML(fromText: """
        <sentences>
            <sentence><word>Hello</word>, <word>World</word></sentence>
            <sentence><word>Feel</word> <word>good</word></sentence>
        </sentences>
        """)
        
        let start = document.firstChild!.firstChild!
        
        let allContent = ["<word>", "\"Hello\"", "\", \"", "<word>", "\"World\""]
        
        XCTAssertEqual(Array(start.allContent.map{ $0.description }), allContent)
        XCTAssertEqual(Array(start.allContentReversed.map{ $0.description }), allContent.reversed())
    }
    
    func testReversedAllTexts() throws {
        let document = try parseXML(fromText: """
        <sentences>
            <sentence><word>Hello</word>, <word>World</word></sentence>
            <sentence><word>Feel</word> <word>good</word></sentence>
        </sentences>
        """)
        
        let start = document.firstChild!.firstChild!
        
        let allTexts = ["Hello", ", ", "World"]
        
        XCTAssertEqual(Array(start.allTexts.map{ $0.value }), allTexts)
        XCTAssertEqual(Array(start.allTextsReversed.map{ $0.value }), allTexts.reversed())
    }
    
    func testDoubleHyphensInComment() throws {
        
        do {
            let comment = XComment("-----", withAdditionalSpace: false)
            XCTAssertEqual(comment.serialized(), "<!--(HYPHEN)(HYPHEN)(HYPHEN)(HYPHEN)(HYPHEN)-->")
        }
        
        do {
            let comment = XComment("-AAA", withAdditionalSpace: false)
            XCTAssertEqual(comment.serialized(), "<!--(HYPHEN)AAA-->")
        }
        
    }
    
    func testXXX() throws {
        let source = """
            <tr><paragraph><formula>α</formula> Hallo <formula>β</formula> Welt <formula>γ</formula></paragraph><paragraph><emphasis style="bold"><formula><bold>α</bold></formula> Hallo <formula><bold>β</bold></formula> Welt <formula><bold>γ</bold></formula></emphasis></paragraph><paragraph><emphasis style="italic"><formula><italic>α</italic></formula> Hallo <formula><italic>β</italic></formula> Welt <formula><italic>γ</italic></formula></emphasis></paragraph><paragraph><emphasis style="italic"><emphasis style="bold"><formula><bold><italic>α</italic></bold></formula> Hallo <formula><bold><italic>β</italic></bold></formula> Welt <formula><bold><italic>γ</italic></bold></formula></emphasis></emphasis></paragraph><paragraph><formula>φ</formula></paragraph></tr>
            """
        try parseXML(fromText: source).echo(pretty: true)
    }
}
