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
        
        let copyOfStructure = copyXStructure(from: start!, to: end!, upTo: start!.ancestors({ $0.name == "sec" }).first! )?.content
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
        
        let copyOfStructure = copyXStructure(from: start!, to: end!, upTo: start!.ancestors({ $0.name == "sec" }).first!)?.content
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
        
        let copyOfStructure = copyXStructure(from: start!, to: end!, upTo: start!.ancestors({ $0.name == "sec" }).first!)?.content
        copyOfStructure?.echo(pretty: true)
        XCTAssertEqual(copyOfStructure?.map{ $0.serialized() }.joined(), #"""
            <p>Das folgende</p>
                    <p>ist</p>
                    <p>eine Aufzählung:<def-list list-type="alpha-lower" specific-use="descriptive.list alphabetic"><def-item><term><named-content content-type="label">a</named-content>Anleitung A</term></def-item></def-list></p>
            """#)
    }
    
    func testCopyXStructure4() throws {
        let document = try parseXML(fromText: """
            <p id="par-7.1-1">In <ref>Abschnitt 1</ref> und <ref>Abschnitt 2</ref> muss man schauen.</p>
            """)
        
        let start = document.allTexts.first
        let end = document.allTexts.dropFirst(4).first
        
        XCTAssertEqual(start?.serialized().replacing(regex: #"\s+"#, with: " ").trimming(), #"""
            In
            """#)
        XCTAssertEqual(end?.serialized().replacing(regex: #"\s+"#, with: " ").trimming(), #"""
            muss man schauen.
            """#)
        
        let copyOfStructure = copyXStructure(from: start!, to: end!, upTo: document.firstChild!)
        XCTAssertEqual(copyOfStructure?.serialized(), #"""
            <p id="par-7.1-1">In <ref>Abschnitt 1</ref> und <ref>Abschnitt 2</ref> muss man schauen.</p>
            """#)
    }
    
    func testCopyXStructure5() throws {
        let document = try parseXML(fromText: """
            <section>
                <p id="par-5.10-2"><begin/>Ja, </p>
                <p id="par-5.10-3">das ist so <span>1 %</span>, echt.<end/></p>
            </section>
            """, textAllowedInElementWithName: { ["p", "span"].contains($0) })
        
        let start = document.firstChild?.children.first?.allTexts.first
        let end = document.firstChild?.children.dropFirst().first?.allTexts.dropFirst(2).first
        
        XCTAssertEqual(start?.serialized().replacing(regex: #"\s+"#, with: " ").trimming(), #"""
            Ja,
            """#)
        XCTAssertEqual(end?.serialized().replacing(regex: #"\s+"#, with: " ").trimming(), #"""
            , echt.
            """#)
        
        let copyOfStructure = copyXStructure(from: start!, to: end!, upTo: document.firstChild!)
        XCTAssertEqual(copyOfStructure?.serialized(pretty: true, indentation: "    "), #"""
            <section>
                <p id="par-5.10-2">Ja, </p>
                <p id="par-5.10-3">das ist so <span>1 %</span>, echt.</p>
            </section>
            """#)
    }
    
    func testHTMLOutput0() throws {
        let source = """
            <div><h1>The title</h1><p>1st paragraph</p><a name="anchor1"/><p>2nd paragraph</p></div>
            """
        XCTAssertEqual(
            try parseXML(fromText: source).serialized(usingProductionTemplate: HTMLProductionTemplate()),
            """
            <!DOCTYPE html>
            <div>
              <h1>The title</h1>
              <p>1st paragraph</p>
              <a name="anchor1"></a>
              <p>2nd paragraph</p>
            </div>
            """
        )
    }
    
    func testHTMLOutput1() throws {
        let source = """
            <div><a><img/></a></div>
            """
        XCTAssertEqual(
            try parseXML(fromText: source).serialized(usingProductionTemplate: HTMLProductionTemplate()),
            """
            <!DOCTYPE html>
            <div><a><img/></a></div>
            """
        )
    }
    
    func testHTMLOutput2() throws {
        let source = """
            <div><a><img/></a><span></span></div>
            """
        XCTAssertEqual(
            try parseXML(fromText: source).serialized(usingProductionTemplate: HTMLProductionTemplate()),
            """
            <!DOCTYPE html>
            <div><a><img/></a><span></span></div>
            """
        )
    }
    
    func testHTMLOutput3() throws {
        let source = """
            <div><a><img/></a><p></p></div>
            """
        XCTAssertEqual(
            try parseXML(fromText: source).serialized(usingProductionTemplate: HTMLProductionTemplate()),
            """
            <!DOCTYPE html>
            <div>
              <a><img/></a>
              <p></p>
            </div>
            """
        )
    }
    
    func testHTMLOutput4() throws {
        let source = """
            <div><a name="anchor1"/><a name="anchor2"/><p></p></div>
            """
        XCTAssertEqual(
            try parseXML(fromText: source).serialized(
                usingProductionTemplate: HTMLProductionTemplate()
            ),
            """
            <!DOCTYPE html>
            <div>
              <a name="anchor1"></a>
              <a name="anchor2"></a>
              <p></p>
            </div>
            """
        )
    }
    
    func testHTMLOutput5() throws {
        let source = """
            <div><a name="anchor1"/><a name="anchor2"/><p></p></div>
            """
        XCTAssertEqual(
            try parseXML(fromText: source).serialized(
                usingProductionTemplate: HTMLProductionTemplate(
                    suppressUncessaryPrettyPrintAtAnchors: true
                )
            ),
            """
            <!DOCTYPE html>
            <div><a name="anchor1"></a><a name="anchor2"></a>
              <p></p>
            </div>
            """
        )
    }
    
    func testHTMLOutput6() throws {
        let source = """
            <div></div>
            """
        XCTAssertEqual(
            try parseXML(fromText: source).serialized(
                usingProductionTemplate: HTMLProductionTemplate(
                    suppressUncessaryPrettyPrintAtAnchors: true
                )
            ),
            """
            <!DOCTYPE html>
            <div></div>
            """
        )
    }
    
}

/// An error with a description.
///
/// When printing such an error, its descrition is printed.
public struct ErrorWithDescription: LocalizedError, CustomStringConvertible {

    private let message: String

    public init(_ message: String?) {
        self.message = message ?? "(unkown error))"
    }
    
    public var description: String { message }
    
    public var errorDescription: String? { message }
}

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
