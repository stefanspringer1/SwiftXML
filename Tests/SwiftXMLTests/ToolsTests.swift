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
@testable import SwiftXML

final class ToolsTests: XCTestCase {
    
    func testCopyXStructure1() throws {
        let document = try parseXML(fromText: """
            <standard><sec id="sub-9.4.1.1" sec-type="clause">
                    <label>9.4.1.1</label>
                    <title>Typ „alphabetisch“ (alphabetic)</title>
                    <p><marker/>Das folgende ist eine Aufzählung:<def-list
                            list-type="alpha-lower" specific-use="descriptive.list alphabetic"
                                        ><def-item><term><named-content content-type="label"
                                    >a</named-content>Anleitung A<marker/></term><def><p><marker/>Das ist zu tun.<marker/>
                                        <marker/>...usw. ...;<marker/></p></def></def-item><def-item><term><named-content content-type="label"
                                        ><marker/>b</named-content>Anleitung B<marker/></term><def><p><marker/>Und noch anderes.<marker/>
                                        <marker/>...usw. ...<marker/></p></def></def-item></def-list></p>
                </sec></standard>
            """)
        
        let start = document.descendants("sec").first?.firstChild("p")?.allTexts.first
        let end = document.descendants("sec").first?.firstChild("p")?.descendants("term").first?.allTexts.dropFirst().first!
        
        XCTAssertEqual(start?.serialized(), #"""
            Das folgende ist eine Aufzählung:
            """#)
        XCTAssertEqual(end?.serialized(), #"""
            Anleitung A
            """#)
        
        let copyOfStructure = copyStructure(from: start!, to: end!, upTo: start!.ancestors({ $0.name == "sec" }).first! )?.content
        XCTAssertEqual(copyOfStructure?.map{ $0.serialized() }.joined(), #"""
            <p>Das folgende ist eine Aufzählung:<def-list list-type="alpha-lower" specific-use="descriptive.list alphabetic"><def-item><term><named-content content-type="label">a</named-content>Anleitung A</term></def-item></def-list></p>
            """#)
    }
    
    func testCopyXStructure2() throws {
        let document = try parseXML(fromText: """
            <standard><sec id="sub-9.4.1.1" sec-type="clause">
                    <label>9.4.1.1</label>
                    <title>Typ „alphabetisch“ (alphabetic)</title>
                    <p><marker/>Das folgende ist eine Aufzählung:<def-list
                            list-type="alpha-lower" specific-use="descriptive.list alphabetic"
                                        ><def-item><term><named-content content-type="label"
                                    >a</named-content>Vorgang für Fall A<marker/></term><def><p><marker/>Das ist zu tun.<marker/>
                                        <marker/>... usw. ...;<marker/></p></def></def-item><def-item><term><named-content content-type="label"
                                        ><marker/>b</named-content>Vorgang für Fall B<marker/></term><def><p><marker/>Das ist dann zu tun.<marker/>
                                        <marker/>... usw. ...<marker/></p></def></def-item></def-list></p>
                </sec></standard>
            """)
        
        let start = document.descendants("sec").first?.children("p").first?.descendants("p").first?.allTexts.first
        let end = start
        
        XCTAssertEqual(start?.serialized().replacing(regex: #"\s+"#, with: " ").trimming(), #"""
            Das ist zu tun.
            """#)
        XCTAssertEqual(end?.serialized().replacing(regex: #"\s+"#, with: " ").trimming(), #"""
            Das ist zu tun.
            """#)
        
        let copyOfStructure = copyStructure(from: start!, to: end!, upTo: start!.ancestors({ $0.name == "sec" }).first!)?.content
        XCTAssertEqual(copyOfStructure?.map{ $0.serialized() }.joined(), #"""
            <p><def-list list-type="alpha-lower" specific-use="descriptive.list alphabetic"><def-item><def><p>Das ist zu tun.</p></def></def-item></def-list></p>
            """#)
    }
    
    func testCopyXStructure3() throws {
        let document = try parseXML(fromText: """
            <standard><sec id="sub-9.4.1.1" sec-type="clause">
                    <label>9.4.1.1</label>
                    <title>Der Titel</title>
                    <p><marker/>Das folgende</p>
                    <p>ist</p>
                    <p>eine Aufzählung:<def-list
                            list-type="alpha-lower" specific-use="descriptive.list alphabetic"
                                        ><def-item><term><named-content content-type="label"
                                    >a</named-content>Anleitung A<marker/></term><def><p><marker/>Das ist zu tun.<marker/>
                                        <marker/>... usw. ...;<marker/></p></def></def-item><def-item><term><named-content content-type="label"
                                        ><marker/>b</named-content>Anleitung B<marker/></term><def><p><marker/>Das ist dann zu tun.<marker/>
                                        <marker/>... usw. ....<marker/></p></def></def-item></def-list></p>
                </sec></standard>
            """)
        
        let start = document.descendants("sec").first?.firstChild("p")?.allTexts.first
        let end = document.descendants("sec").first?.children("p").dropFirst(2).first?.descendants("term").first?.allTexts.dropFirst().first!
        
        XCTAssertEqual(start?.serialized(), #"""
            Das folgende
            """#)
        XCTAssertEqual(end?.serialized(), #"""
            Anleitung A
            """#)
        
        let copyOfStructure = copyStructure(from: start!, to: end!, upTo: start!.ancestors({ $0.name == "sec" }).first!)?.content
        XCTAssertEqual(copyOfStructure?.map{ $0.serialized() }.joined(), #"""
            <p>Das folgende</p>
                    <p>ist</p>
                    <p>eine Aufzählung:<def-list list-type="alpha-lower" specific-use="descriptive.list alphabetic"><def-item><term><named-content content-type="label">a</named-content>Anleitung A</term></def-item></def-list></p>
            """#)
        
    }
    
}

extension String: Error {}

extension String {
    
    /// Replace all text matching a certain certain regular expression.
    ///
    /// Use lookarounds (e.g. lookaheads) to avoid having to apply your regular expression several times.
    func replacing(regex: String, with theReplacement: String) -> String {
        var result = self
        autoreleasepool {
            result = self.replacingOccurrences(of: regex, with: theReplacement, options: .regularExpression, range: nil)
        }
        return result
    }
    
    /// Trimming all whitespace.
    func trimming() -> String {
        return self.self.trimmingLeft().trimmingRight()
    }
    
    /// Trimming left whitespace.
    func trimmingLeft() -> String {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespacesAndNewlines) }) else {
            return ""
        }
        return String(self[index...])
    }
    
    /// Trimming right whitespace.
    func trimmingRight() -> String {
        guard let index = lastIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespacesAndNewlines) }) else {
            return ""
        }
        return String(self[...index])
    }
    
}
