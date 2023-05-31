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
}
