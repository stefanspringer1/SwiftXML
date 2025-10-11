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
import SwiftXMLInterfaces

final class SwiftXMLTests: XCTestCase {
    
    func testSerialized() throws {
        let source = """
            <a id="1"><b id="2"/><b id="3"/></a>
            """
        let document = try parseXML(fromText: source)
        
        XCTAssertEqual(document.serialized, """
            <a id="1"><b id="2"/><b id="3"/></a>
            """)
        
        XCTAssertEqual(document.serialized(pretty: true, indentation: "        "), """
            <a id="1">
                    <b id="2"/>
                    <b id="3"/>
            </a>
            """)
        
        // referencing the function:
        let f = document.serialized(pretty:textAllowedInElementWithName:indentation:overwritingPrefixesForNamespaceURIs:overwritingPrefixes:suppressDeclarationForNamespaceURIs:)
        let noTranslation: [String:String]? = nil
        XCTAssertEqual(f(true, nil, "  ", noTranslation, noTranslation, nil), """
            <a id="1">
              <b id="2"/>
              <b id="3"/>
            </a>
            """)
    }
    
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
        var names = [String]()
        for element in document.descendants {
            names.append(element.name)
        }
        XCTAssertEqual(names.joined(separator: ", "), "a, b, b")
    }
    
    func testAttributeFromDocument() throws {
        let document = try parseXML(fromText: """
            <a id="1">
                <b id="2"/>
                <b id="3"/>
            </a>
            """, registeringAttributes: .selected(["id"]))
        let element = document.children.first!
        XCTAssertEqual(element["id"], "1")
        XCTAssertEqual(document.registeredAttributes("id").map { attributeSpot in attributeSpot.value }.joined(separator: ", "), "1, 2, 3")
    }
    
    func testAttributeFromClonedDocumentDefault() throws {
        let document = try parseXML(fromText: """
            <a id="1">
                <b id="2"/>
                <b id="3"/>
            </a>
            """, registeringAttributes: .selected(["id"]))
        
        let element = document.children.first!
        element.attached["test"] = "hello"
        
        let clone = document.clone()
        let elementInClone = clone.children.first!
        XCTAssertEqual(elementInClone.attached["test"] as? String, nil)
        XCTAssertEqual(elementInClone["id"], "1")
        XCTAssertEqual(clone.registeredAttributes("id").map { attributeSpot in attributeSpot.value }.joined(separator: ", "), "1, 2, 3")
    }
    
    func testAttributeFromClonedDocumentNonDefault() throws {
        let document = try parseXML(fromText: """
            <a id="1">
                <b id="2"/>
                <b id="3"/>
            </a>
            """, registeringAttributes: .selected(["id"]))
        
        let element = document.children.first!
        element.attached["test"] = "hello"
        
        do {
            // the registering of attributes is the same by default:
            let clone = document.clone(keepAttachments: true)
            let elementInClone = clone.children.first!
            XCTAssertEqual(elementInClone.attached["test"] as? String, "hello")
            XCTAssertEqual(elementInClone["id"], "1")
            XCTAssertEqual(clone.registeredAttributes("id").map { attributeSpot in attributeSpot.value }.joined(separator: ", "), "1, 2, 3")
        }
        
        do {
            // the registering of attributes is changed by argument:
            let clone = document.clone(keepAttachments: true, registeringAttributes: AttributeRegisterMode.none)
            let elementInClone = clone.children.first!
            XCTAssertEqual(elementInClone.attached["test"] as? String, "hello")
            XCTAssertEqual(elementInClone["id"], "1")
            XCTAssertEqual(clone.registeredAttributes("id").map { attributeSpot in attributeSpot.value }.joined(separator: ", "), "")
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
        let clone = document.clone
        XCTAssertEqual(clone.serialized(), source)
    }
    
    func testCloningElementWithAttachments() throws {
        
        let element1 = XElement("element1", attached: ["test1": "hello 1"])
        let element2 = XElement("element2", attached: ["test2": "hello 2"]) {
            element1
        }
        
        do {
            let clone = element2.clone
            XCTAssertEqual(clone.attached["test2"] as? String, nil)
            XCTAssertEqual(clone.firstChild?.attached["test1"] as? String, nil)
        }
        
        do {
            let clone = element2.clone(keepAttachments: true)
            XCTAssertEqual(clone.attached["test2"] as? String, "hello 2")
            XCTAssertEqual(clone.firstChild?.attached["test1"] as? String, "hello 1")
        }
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
            """, registeringAttributes: .selected(["a", "c"]))
        
        let registeredAttributesInfo = document.registeredAttributes("a", "b", "c", "d").map{ "\($0.name)=\"\($0.value)\" in \($0.element)" }.joined(separator: ", ")
        XCTAssertEqual(registeredAttributesInfo, #"a="1" in <x a="1">, c="3" in <x c="3">"#)
        
        let allValuesInfo = document.elements("x").compactMap{
            if let name = $0.attributeNames.first, let value = $0[name] { "\(name)=\"\(value)\" in \($0)" } else { nil }
        }.joined(separator: ", ")
        XCTAssertEqual(allValuesInfo, #"a="1" in <x a="1">, b="2" in <x b="2">, c="3" in <x c="3">, d="4" in <x d="4">"#)
    }
    
    func testSomeAttributesRegisteredAfterMovingToNewDocument() throws {
        let oldDocument = try parseXML(fromText: """
            <test>
              <x a="1"/>
              <x b="2"/>
              <x c="3"/>
              <x d="4"/>
            </test>
            """, registeringAttributes: .selected(["a", "c"]))
        
        let document = XDocument(registeringAttributes: .selected(["a", "c"])) {
            oldDocument.children
        }
        
        let registeredAttributesInfo = document.registeredAttributes("a", "b", "c", "d").map{ "\($0.name)=\"\($0.value)\" in \($0.element)" }.joined(separator: ", ")
        XCTAssertEqual(registeredAttributesInfo, #"a="1" in <x a="1">, c="3" in <x c="3">"#)
        
        let allValuesInfo = document.elements("x").compactMap{
            if let name = $0.attributeNames.first, let value = $0[name] { "\(name)=\"\(value)\" in \($0)" } else { nil }
        }.joined(separator: ", ")
        XCTAssertEqual(allValuesInfo, #"a="1" in <x a="1">, b="2" in <x b="2">, c="3" in <x c="3">, d="4" in <x d="4">"#)
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
            """
        )
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
            """
        )
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
        
        do {
            var messages = [String]()
            
            document.traverse { node in
                messages.append("down: \(node)")
            } up: { node in
                messages.append("up: \(node)")
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
                messages.append(node.description)
            } up: { node in
                await a.f()
            }
            
            XCTAssertEqual(messages.joined(separator: "\n"), """
                down: <test>
                down: "
                  "
                down: <b id="1">
                up: <b id="1">
                down: "
                  "
                down: <b id="2">
                up: <b id="2">
                down: "
                  "
                down: <b id="3">
                up: <b id="3">
                down: "
                "
                up: <test>
                <test>
                "
                  "
                <b id="1">
                "
                  "
                <b id="2">
                "
                  "
                <b id="3">
                "
                "
                """
            )
            
        }
        
        // --------------------------------------------------------------------
        // forEach:
        // --------------------------------------------------------------------
        
        do {
            var messages = [String]()
            document.descendants.forEach { descendant in
                messages.append(descendant.description)
            }
            XCTAssertEqual(messages.joined(separator: ", "), #"<test>, <b id="1">, <b id="2">, <b id="3">"#)
        }
        
        // alternative:
        do {
            var messages = [String]()
            for descendant in document.descendants {
                messages.append(descendant.description)
            }
            XCTAssertEqual(messages.joined(separator: ", "), #"<test>, <b id="1">, <b id="2">, <b id="3">"#)
        }
        
        await document.children.forEachAsync { child in
            await a.f()
        }
        try await document.children.forEachAsync { child in
            try await a.g()
        }
        
        _ = [1, 2, 3].map { String($0) }  // okay: map does not throw because the closure does not throw
        _ = try ["1", "2", "3"].map { (string: String) -> Int in
            guard let result = Int(string) else { throw ErrorWithDescription("nanana") }
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
           """, registeringAttributes: .selected(["b", "c", "d"]))

        var collectedAttributeValues = [String]()

        do {
            var messages = [String]()
            document.registeredAttributes("b").forEach { attribute in
                messages.append("\(attribute.name)=\"\(attribute.value)\"")
            }
            XCTAssertEqual(messages.joined(separator: ", "), #"b="b1", b="b2""#)
        }
        
        document.registeredAttributes("b", "c", "d").forEach { attribute in
           collectedAttributeValues.append(attribute.value)
           if attribute.value == "c1" {
               attribute.element.insertPrevious { XElement("x", ["b": "bInserted1"]) }
           }
        }
        
        XCTAssertEqual(collectedAttributeValues.joined(separator: ", "), "b1, b2, c1, c2, d1, d2, bInserted1")
        
        do {
            var messages = [String]()
            
            let transformation = XTransformation {
                
                XRule(forRegisteredAttributes: "b") { b in
                    messages.append("rule for b=\"\(b.value)\" in \(b.element)")
                    if b.value == "bInserted1" {
                        document.firstChild!.addFirst { XElement("x", ["b": "bInserted2"]) }
                    }
                }
                
            }
            
            transformation.execute(inDocument: document)
            
            XCTAssertEqual(messages.joined(separator: "\n"), """
                rule for b="b1" in <x b="b1">
                rule for b="b2" in <x b="b2">
                rule for b="bInserted1" in <x b="bInserted1">
                rule for b="bInserted2" in <x b="bInserted2">
                """)
        }
        
    }
    
    func testSequencePart() {
        
        let a = XElement("a") { "hello"; XText(" world", isolated: true) }
        
        XCTAssertEqual(XElement("b") { a.content.dropLast() }.serialized(), #"<b>hello</b>"#)
    }
    
    func testTexts() throws {
        let document = try parseXML(fromText: """
            <paragraph>Hello <bold>world</bold>!</paragraph>
            """)
        XCTAssertEqual(document.children.first!.immediateTexts.map{ "\"\($0.value)\"" }.joined(separator: ", "), #""Hello ", "!""#)
    }
    
    func testExpressibleByStringLiteral() throws {
        let text: XText = "the text"
        XCTAssertEqual(String(describing: type(of: text)), "XText")
    }
    
    func testAllTexts() throws {
        let document = try parseXML(fromText: """
            <paragraph>Hello <bold>world</bold>!</paragraph>
            """)
        XCTAssertEqual(document.allTexts.map{ "\"\($0.value)\"" }.joined(separator: ", "), #""Hello ", "world", "!""#)
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
            """, registeringAttributes: .selected(["id"]))
        
        var elementFoundInfos = [String]()
        document.registeredAttributes("id").forEach { attributeSpot in
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
            """, registeringAttributes: .selected(["type", "id"]))
        
        var elementFoundInfos = [String]()
        document.registeredAttributes("type", "id").forEach { attributeSpot in
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
            <a xmlns:a="http://a" xmlns:b="http://b"/>
            """, namespaceAware: true)
        print(document.namespacePrefixesAndURIs)
        XCTAssertEqual([
            document.namespacePrefixesAndURIs
                .map{ (prefix,namespace) in "prefix \"\(prefix)\" for namespace \"\(namespace)\"" }
                .joined(separator: ", "),
            "\"\(document.prefix(forNamespaceURI: "http://b") ?? "")\""
        ].joined(separator: "\n"), """
        prefix "a" for namespace "http://a", prefix "b" for namespace "http://b"
        "b"
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
    
    func testPretty1() throws {
        
        do {
            let source = """
                <book>
                    <paragraph><emphasis>hello</emphasis></paragraph>
                </book>
                """
            
            let document = try parseXML(fromText: source)
            
            XCTAssertEqual(
                document.serialized,
                // like the original text because no adjustments when reading:
                """
                <book>
                    <paragraph><emphasis>hello</emphasis></paragraph>
                </book>
                """
            )
            
            XCTAssertEqual(
                document.serialized(usingProductionTemplate: PrettyPrintProductionTemplate()),
                // <book> itself is "mixed", so is everything inside:
                """
                <book>
                    <paragraph><emphasis>hello</emphasis></paragraph>
                </book>
                """
            )
            
            XCTAssertEqual(
                document.serialized(usingProductionTemplate: PrettyPrintProductionTemplate(
                    textAllowedInElementWithName: ["paragraph", "emphasis"]
                )),
                // the 'textAllowedInElementWithName' setting does not make a difference:
                """
                <book>
                    <paragraph><emphasis>hello</emphasis></paragraph>
                </book>
                """
            )
            
        }
        
        do {
            let source = """
                <book><paragraph><emphasis>hello</emphasis></paragraph></book>
                """
            
            let document = try parseXML(fromText: source)
            
            XCTAssertEqual(
                document.serialized,
                // like the original text because no adjustments when reading:
                """
                <book><paragraph><emphasis>hello</emphasis></paragraph></book>
                """
            )
            
            XCTAssertEqual(
                document.serialized(usingProductionTemplate: PrettyPrintProductionTemplate()),
                // only <emphasis> is obviously "mixed", the serialization does not know more:
                """
                <book>
                    <paragraph>
                        <emphasis>hello</emphasis>
                    </paragraph>
                </book>
                """
            )
            
            XCTAssertEqual(
                document.serialized(usingProductionTemplate: PrettyPrintProductionTemplate(
                    textAllowedInElementWithName: ["paragraph", "emphasis"]
                )),
                // the serialization knows from the 'usingProductionTemplate' setting the <paragraph> too is "mixed":
                """
                <book>
                    <paragraph><emphasis>hello</emphasis></paragraph>
                </book>
                """
            )
            
        }
        
        do {
            let source = """
                <book>
                    
                    <paragraph><emphasis>hello</emphasis></paragraph>
                    
                </book>
                """
            
            let document = try parseXML(fromText: source, textAllowedInElementWithName: ["paragraph", "emphasis"])
            
            XCTAssertEqual(
                document.serialized,
                // whitespace immediately in elements that are not mixed (that is knwon from the 'textAllowedInElementWithName' setting) is removed:
                """
                <book><paragraph><emphasis>hello</emphasis></paragraph></book>
                """
            )
            
            XCTAssertEqual(
                document.serialized(usingProductionTemplate: PrettyPrintProductionTemplate()),
                // here, the serialization does not know about the 'textAllowedInElementWithName' setting that was used when reading
                // (and also should not know, because the output could be a different type of document):
                """
                <book>
                    <paragraph>
                        <emphasis>hello</emphasis>
                    </paragraph>
                </book>
                """
            )
            
            XCTAssertEqual(
                document.serialized(usingProductionTemplate: PrettyPrintProductionTemplate(
                    textAllowedInElementWithName: ["paragraph", "emphasis"]
                )),
                // the serialization knows from the 'usingProductionTemplate' setting the <paragraph> too is "mixed":
                """
                <book>
                    <paragraph><emphasis>hello</emphasis></paragraph>
                </book>
                """
            )
            
        }
        
    }
    
    func testPretty2() {
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
            <sentence><word>Hello</word> <word>world</word></sentence>
            <sentence><word>Feel</word> <word>good</word></sentence>
        </sentences>
        """)
        
        XCTAssertEqual(document.elements("sentence").map{ "\"\($0.allTextsCombined)\"" }.joined(separator: ", "), #""Hello world", "Feel good""#)
    }
    
    func testReversedAllContent() throws {
        let document = try parseXML(fromText: """
        <sentences>
            <sentence><word>Hello</word>, <word>world</word></sentence>
            <sentence><word>Feel</word> <word>good</word></sentence>
        </sentences>
        """)
        
        let start = document.firstChild!.firstChild!
        
        let allContent = ["<word>", "\"Hello\"", "\", \"", "<word>", "\"world\""]
        
        XCTAssertEqual(Array(start.allContent.map{ $0.description }), allContent)
        XCTAssertEqual(Array(start.allContentReversed.map{ $0.description }), allContent.reversed())
    }
    
    func testReversedAllTexts() throws {
        let document = try parseXML(fromText: """
        <sentences>
            <sentence><word>Hello</word>, <word>world</word></sentence>
            <sentence><word>Feel</word> <word>good</word></sentence>
        </sentences>
        """)
        
        let start = document.firstChild!.firstChild!
        
        let allTexts = ["Hello", ", ", "world"]
        
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
    
    func testResolver() throws {
        
        struct MyInternalEntityResolver: InternalEntityResolver {
            func resolve(entityWithName entityName: String, forAttributeWithName attributeName: String?, atElementWithName elementName: String?) -> String? {
                if entityName == "ent1" {
                    "!"
                } else {
                    nil
                }
            }
        }
        
        let source = """
            <a>&ent1;&ent2;</a>
            """
        
        // parse without an internal entity resolver, all internal entities are kept with any notice:
        XCTAssertEqual(try parseXML(
            fromText: source
        ).serialized(), "<a>&ent1;&ent2;</a>")
        
        // leave unresolved internal entities:
        XCTAssertEqual(try parseXML(
            fromText: source,
            internalEntityResolver: MyInternalEntityResolver(),
            internalEntityResolverHasToResolve: false
        ).serialized(), "<a>!&ent2;</a>")
        
        // error unresolved internal entities:
        var errorMessage: String? = nil
        do {
            _ = try parseXML(
                fromText: source,
                internalEntityResolver: MyInternalEntityResolver(),
                internalEntityResolverHasToResolve: true
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        
        XCTAssertEqual(errorMessage, "1:15:E: internal entity resolver cannot resolve entity \"ent2\"")
    }
    
    func testReplaceByLazySequence() throws {
        let document = try parseXML(fromText: """
        <document><index.item>z</index.item><index.item>x</index.item><index.item>a</index.item><index.item>m</index.item></document>
        """)
        
        for indexItem in document.elements("index.item").filter({ ($0.nextTouching as? XElement)?.name != "index.item" }) {
            indexItem.replace {
                indexItem.previousCloseElementsIncludingSelf(while: { $0.name == "index.item" })
                  .sorted(by: { (first,second) in first.allTextsCombined < second.allTextsCombined })
            }
        }
        
        XCTAssertEqual(document.serialized(), "<document><index.item>a</index.item><index.item>m</index.item><index.item>x</index.item><index.item>z</index.item></document>")
    }
    
    func testBuildOptional() throws {
        
        let i = 2
        let element = XElement("X") {
            if i > 2 {
                XElement("A")
            }
            if i < 3 {
                XElement("B")
            }
            if i < 1 {
                nil
            }
            if i < 1 {
                XElement("C")
            } else {
                nil
            }
        }
        
        XCTAssertEqual(element.serialized(), "<X><B/></X>")
    }
    
    func testDescendantsMethodWithoutArguments() {
        
        let document = XDocument {
            XElement("A") {
                XElement("B")
            }
        }
        
        XCTAssertEqual(Array(document.descendants().map{ $0.name }), ["A", "B"])
        // ...which is the same as:
        XCTAssertEqual(Array(document.descendants.map{ $0.name }), ["A", "B"])
                         
    }
    
    func testCDATAInitialization() throws {
        
        let cdata1 = XCDATASection("hello")
        XCTAssertEqual(cdata1.serialized(), "<![CDATA[hello]]>")
        
        let condition1 = true
        let condition2 = false
        
        let cdata2 = XCDATASection {
            "hello"
            " world"
            if condition1 {
                " condition1"
                " condition1"
            }
            if condition2 {
                " condition2"
                " condition2"
            }
        }
        XCTAssertEqual(cdata2.serialized(), "<![CDATA[hello world condition1 condition1]]>")
    }
    
    func testCommentInitialization() throws {
        
        let cdata1a = XComment("hello")
        XCTAssertEqual(cdata1a.serialized(), "<!-- hello -->")
        
        let cdata1b = XComment("hello", withAdditionalSpace: false)
        XCTAssertEqual(cdata1b.serialized(), "<!--hello-->")
        
        let condition1 = true
        let condition2 = false
        
        let cdata2a = XComment {
            "hello"
            " world"
            if condition1 {
                " condition1"
                " condition1"
            }
            if condition2 {
                " condition2"
                " condition2"
            }
        }
        XCTAssertEqual(cdata2a.serialized(), "<!-- hello world condition1 condition1 -->")
        
        let cdata2b = XComment(withAdditionalSpace: false) {
            "hello"
            " world"
            if condition1 {
                " condition1"
                " condition1"
            }
            if condition2 {
                " condition2"
                " condition2"
            }
        }
        XCTAssertEqual(cdata2b.serialized(), "<!--hello world condition1 condition1-->")
    }
    
    func testRegisteredAttributeValues() throws {
        
        let source = """
            <a>
                <b id="1"/>
                <b id="2"/>
                <b refid="1">First reference to "1".</b>
                <b refid="1">Second reference to "1".</b>
            </a>
            """

        let document = try parseXML(fromText: source, registeringAttributeValuesFor: .selected(["id", "refid"]))
        
        // cannot find them by name only:
        XCTAssertEqual(
            document.registeredAttributes("id").map{ $0.element.description }.joined(separator: "\n"),
            """
            """
        )
        
        XCTAssertEqual(
            document.registeredValues( "1", forAttribute: "id").map{ $0.element.description }.joined(separator: "\n"),
            """
            <b id="1">
            """
        )
        
        XCTAssertEqual(
            document.registeredValues("1", forAttribute: "refid").map{ $0.element.serialized() }.joined(separator: "\n"),
            """
            <b refid="1">First reference to "1".</b>
            <b refid="1">Second reference to "1".</b>
            """
        )
        
        // same by first filling an array with the contents of the sequence:
        XCTAssertEqual(
            Array(document.registeredValues("1", forAttribute: "refid")).map{ $0.element.serialized() }.joined(separator: "\n"),
            """
            <b refid="1">First reference to "1".</b>
            <b refid="1">Second reference to "1".</b>
            """
        )
        
        // if the value according to an attribute name should be unique, find the according element by:
        let _: XElement? = document.registeredValues("1", forAttribute: "id").first?.element
        
        document.firstChild?.add {
            XElement("b", ["refid": "1"]) { #"Third reference to "1"."# }
        }
        
        XCTAssertEqual(
            document.registeredValues("1", forAttribute: "refid").map{ $0.element.serialized() }.joined(separator: "\n"),
            """
            <b refid="1">First reference to "1".</b>
            <b refid="1">Second reference to "1".</b>
            <b refid="1">Third reference to "1".</b>
            """
        )
        
        document.descendants({ $0["refid"] == "1" }).first?.remove()
        
        XCTAssertEqual(
            document.registeredValues("1", forAttribute: "refid").map{ $0.element.serialized() }.joined(separator: "\n"),
            """
            <b refid="1">Second reference to "1".</b>
            <b refid="1">Third reference to "1".</b>
            """
        )
    }
    
    func testAncestorScope() throws {
        
        let start = XElement("start")
        
        let middle = XElement("middle") {
            start
        }
        
        let stop = XElement("stop") {
            middle
        }
        
        let tree = XElement("tree") {
            XElement("target") {
                stop
            }
        }
        
        // --------------------
        // Looking for <a>, #1:
        // --------------------
        
        XCTAssertEqual(tree.serialized(pretty: true), """
            <tree>
                <target>
                    <stop>
                        <middle>
                            <start/>
                        </middle>
                    </stop>
                </target>
            </tree>
            """)
        
        XCTAssertEqual(start.ancestors("target").exist, true)
        
        // ...but stop at <stop>
        XCTAssertEqual(start.ancestors(until: { $0 === stop }).filter{ $0.name == "target" }.exist, false)
        
        // easier notation:
        XCTAssertEqual(start.ancestors("target", until: { $0 === stop }).exist, false)
        
        // --------------------
        // Looking for <a>, #2:
        // --------------------
        
        middle.setContent {
            XElement("target") {
                middle.content
            }
        }
        
        XCTAssertEqual(tree.serialized(pretty: true), """
            <tree>
                <target>
                    <stop>
                        <middle>
                            <target>
                                <start/>
                            </target>
                        </middle>
                    </stop>
                </target>
            </tree>
            """)
        
        XCTAssertEqual(start.ancestors("target").exist, true)
        
        // ...but stop at <stop>
        XCTAssertEqual(start.ancestors(until: { $0 === stop }).filter{ $0.name == "target" }.exist, true)
        
        // easier notation:
        XCTAssertEqual(start.ancestors("target", until: { $0 === stop }).exist, true)
        
    }
}
