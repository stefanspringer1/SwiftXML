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

final class FromReadmeTests: XCTestCase {
    
    func testParsingAndJoiningIDs() throws {
        let document = try parseXML(fromText: """
            <test>
              <b id="1"/>
              <b id="2"/>
              <b id="3"/>
            </test>
            """)
        
        XCTAssertEqual(document.children.children["id"].joined(separator: ", "), "1, 2, 3")
    }
    
    func testRemoveElementsWhileIteration() throws{
        let document = try parseXML(fromText: """
        <a><item id="1" remove="true"/><item id="2"/><item id="3" remove="true"/><item id="4"/></a>
        """)

        document.traverse { content in
            if let element = content as? XElement, element["remove"] == "true" {
                element.remove()
            }
        }
        
        XCTAssertEqual(document.children.children["id"].joined(separator: ", "), "2, 4")
    }
    
    func testPrintContentWithSourceRanges() throws{
        let document = try parseXML(fromText: """
        <a>
            <b>Hello</b>
        </a>
        """, textAllowedInElementWithName: { $0 == "b" })

        var output = ""
        document.allContent.forEach { content in
            if let sourceRange = content.sourceRange {
                output += "\(sourceRange): \(content)"
                print("\(sourceRange): \(content)")
            }
            else {
                content.echo()
            }
        }
        
        XCTAssertEqual(output, "1:1 - 3:4: <a>2:5 - 2:16: <b>2:8 - 2:12: Hello")
    }
    
    func testExistingItems() throws{
        let document = try parseXML(fromText: """
        <a><c/><b id="1"/><b id="2"/><d/><b id="3"/></a>
        """)

        if let theBs = document.descendants("b").existing {
            XCTAssertEqual(theBs["id"].joined(separator: ", "), "1, 2, 3")
        }
    }
    
    func testContentSequenceCondition() throws{
        let document = try parseXML(fromText: """
        <a><b/><c take="true"/><d/><e take="true"/></a>
        """)

        document
            .descendants({ element in element["take"] == "true" })
            .forEach { descendant in
                XCTAssertEqual(descendant["take"]!, "true")
            }
    }
    
    func testChainedIterators() throws{
        let document = try parseXML(fromText: """
        <a>
            <b>
                <c>
                    <d/>
                </c>
            </b>
        </a>
        """)
        
        var output = ""
        document.descendants.descendants.forEach{
            output += $0.serialized(pretty: true)
        }
        output = output.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
        XCTAssertEqual(output, "<b><c><d/></c></b><c><d/></c><d/><c><d/></c><d/><d/>")
    }
    
    func testFirstChildOfEachChild() throws{
        let element = XElement("z") {
            XElement("a") {
                XElement("a1")
                XElement("a2")
            }
            XElement("b") {
                XElement("b1")
                XElement("b2")
            }
        }
        
        var output = ""
        element.children.map{ $0.children.first }.forEach { output += $0?.name ?? "-" }
        XCTAssertEqual(output, "a1b1")
    }
    
    func testReplaceElementInHierarchy() throws{
        let b = XElement("b")

        let a = XElement("a") {
            b
            "Hello"
        }

        let expectedOutputBeforeReplace = "<a><b/>Hello</a>"
        
        XCTAssertEqual(a.serialized(), expectedOutputBeforeReplace)

        b.replace {
            XElement("wrapper1") {
                b
                XElement("wrapper2") {
                    b.next
                }
            }
        }

        let expectedOutputAfterReplace = """
            <a>
              <wrapper1>
                <b/>
                <wrapper2>Hello</wrapper2>
              </wrapper1>
            </a>
            """
        
        XCTAssertEqual(a.serialized(pretty: true), expectedOutputAfterReplace)
    }
    
    func testAddElementToDocument() throws {
        let document = try parseXML(fromText: """
        <a><b id="1"/><b id="2"/></a>
        """)

        document.elements("b").forEach { element in
            if element["id"] == "2" {
                element.insertNext {
                    XElement("c") {
                        element.previous
                    }
                }
            }
        }

        let expectedOutput = """
        <a><b id="2"/><c><b id="1"/></c></a>
        """

        XCTAssertEqual(document.serialized(), expectedOutput)
    }
    
    func testElementContentManipulation() throws {
        let element = XElement("top") {
            XElement("a1") {
                XElement("a2")
            }
            XElement("b1") {
                XElement("b2")
            }
            XElement("c1") {
                XElement("c2")
            }
        }

        XCTAssertEqual(element.serialized(), "<top><a1><a2/></a1><b1><b2/></b1><c1><c2/></c1></top>")
        
        print("\n---- 1 ----\n")

        element.content.forEach { content in
            content.replace(.skipping) {
                content.content
            }
        }

        XCTAssertEqual(element.serialized(), "<top><a2/><b2/><c2/></top>")
        
        print("\n---- 2 ----\n")

        element.contentReversed.forEach { content in
            content.insertPrevious(.skipping) {
                XElement("I" + ((content as? XElement)?.name ?? "?"))
            }
        }
        
        XCTAssertEqual(element.serialized(), "<top><Ia2/><a2/><Ib2/><b2/><Ic2/><c2/></top>")
    }
    
    func testAddElementToDescendants() throws {
        let e = XElement("a") {
            XElement("b")
            XElement("c")
        }

        e.descendants({ $0.name != "added" }).add {
            XElement("added")
        }

        XCTAssertEqual(e.serialized(), "<a><b><added/></b><c><added/></c></a>")
    }
    
    func testAddElementToSelectedDescendants() throws {
        let myElement = XElement("a") {
            XElement("to-add")
            XElement("b")
            XElement("c")
        }

        myElement.descendants({ $0.name != "to-add" }).add {
            myElement.descendants("to-add")
        }

        XCTAssertEqual(myElement.serialized(), "<a><b/><c><to-add/></c></a>")
    }
    
    func testInsertNextElementToSelectedDescendants() throws {
        let myElement = XElement("top") {
            XElement("a")
        }

        myElement.descendants.forEach { element in
            if element.name == "a" {
                element.insertNext() {
                    XElement("b")
                }
            }
            else if element.name == "b" {
                element.insertNext {
                    XElement("c")
                }
            }
        }

        XCTAssertEqual(myElement.serialized(), "<top><a/><b/><c/></top>")
    }
    
    func testInsertNextElementToSelectedDescendantsButSkipping() throws {
        let myElement = XElement("top") {
            XElement("a")
        }

        myElement.descendants.forEach { element in
            if element.name == "a" {
                element.insertNext(.skipping) {
                    XElement("b")
                }
            }
            else if element.name == "b" {
                element.insertNext {
                    XElement("c")
                }
            }
        }

        XCTAssertEqual(myElement.serialized(), "<top><a/><b/></top>")
    }
    
    func testReplaceNodeWithContent() throws {
        let document = try parseXML(fromText: """
            <text><bold><bold>Hello</bold></bold></text>
            """)
        document.descendants("bold").forEach { b in b.replace { b.content } }
        
        XCTAssertEqual(document.serialized(), "<text>Hello</text>")
    }
    
    func testDescendants() throws {
        let element = XElement("z") {
            XElement("a") {
                XElement("a1")
                XElement("a2")
            }
            XElement("b") {
                XElement("b1")
                XElement("b2")
            }
        }
        
        XCTAssertEqual(element.descendants.map{ $0.description }.joined(separator: ", "), "<a>, <a1>, <a2>, <b>, <b1>, <b2>")
    }
    
    func testWithAndWhen() throws {
        
        let element1 = XElement("a") {
            XElement("child-of-a") {
                XElement("more", ["special": "yes"])
            }
        }

        let element2 = XElement("b")
        
        if let childOfA = element1.fullfilling({ $0.name == "a" })?.children.first,
           childOfA.children.first?.fullfills({ $0["special"] == "yes" && $0["moved"] != "yes"  }) == true {
            element2.add {
                childOfA.applying { $0["moved"] = "yes" }
            }
        }
        
        XCTAssertEqual(element2.serialized(), #"<b><child-of-a moved="yes"><more special="yes"/></child-of-a></b>"#)
    }
    
    func testApplyingForSequence() throws {
        
        let myElement = XElement("a") {
            XElement("b", ["inserted": "yes"]) {
                XElement("c", ["inserted": "yes"])
            }
        }
        
        let inserted = Array(myElement.descendants.filter{ $0["inserted"] == "yes" }.applying{ $0["found"] = "yes" })
        
        XCTAssertEqual(inserted.description, #"[<b found="yes" inserted="yes">, <c found="yes" inserted="yes">]"#)
    }
    
    func testTransformWithTraversal() throws {
        
        let document = XDocument {
            XElement("document") {
                XElement("section") {
                    XElement("hint") {
                        XElement("paragraph") {
                            "This is a hint."
                        }
                    }
                    XElement("warning") {
                        XElement("paragraph") {
                            "This is a warning."
                        }
                    }
                }
            }
        }
        
        for section in document.elements("section") {
            section.traverse { node in
                // -
            } up: { node in
                if let element = node as? XElement {
                    guard node !== section else { return }
                    switch element.name {
                    case "paragraph":
                        let style: String? = if element.parent?.name == "warning" {
                            "color:Red"
                        } else {
                            nil
                        }
                        element.replace(.skipping) {
                            XElement("p", ["style": style]) {
                                element.content
                            }
                        }
                    case "hint", "warning":
                        element.replace(.skipping) {
                            XElement("div") {
                                XElement("p", ["style": "bold"]) {
                                    element.name.uppercased()
                                }
                                element.content
                            }
                        }
                    default:
                        break
                    }
                }
            }
        }
        
        XCTAssertEqual(
            document.serialized(pretty: true),
            """
            <document>
              <section>
                <div>
                  <p style="bold">HINT</p>
                  <p>This is a hint.</p>
                </div>
                <div>
                  <p style="bold">WARNING</p>
                  <p style="color:Red">This is a warning.</p>
                </div>
              </section>
            </document>
            """
        )
    }
}
