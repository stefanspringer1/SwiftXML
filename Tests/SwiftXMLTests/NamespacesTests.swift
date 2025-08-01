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

final class NamespacesTests: XCTestCase {
    
    func testPrefix() throws {
        
        let document = XDocument {
            XElement(prefix: "math", "math") {
                XElement(prefix: "math", "mi") { "a" }
                XElement(prefix: "math", "mo") { "+" }
                XElement(prefix: "math", "mi") { "b" }
            }
        }
        
        // prefix must be added in serialization:
        XCTAssertEqual(document.serialized(pretty: true), """
            <math:math>
              <math:mi>a</math:mi>
              <math:mo>+</math:mo>
              <math:mi>b</math:mi>
            </math:math>
            """
        )
        
        // must not be reached via name alone:
        XCTAssertEqual(Array(document.descendants("mi", "mo").map{ $0.immediateTextsCombined }), [])
        XCTAssertEqual(Array(document.elements("mi", "mo").map{ $0.immediateTextsCombined }), [])
        
        // must be reached via prefix and name:
        XCTAssertEqual(Array(document.descendants(prefix: "math", "mi", "mo").map{ $0.immediateTextsCombined }), ["a", "+", "b"])
        XCTAssertEqual(Array(document.elements(prefix: "math", "mi", "mo").map{ $0.immediateTextsCombined }), ["a", "b", "+"])
        
        // remove the prefixes:
        XTransformation {
            
            XRule(forPrefix: "math", forElements: "math", "mi", "mo") { mathElement in
                mathElement.prefix = nil
            }
            
        }.execute(inDocument: document)
        
        // prefix is gone:
        XCTAssertEqual(document.serialized(pretty: true), """
            <math>
              <mi>a</mi>
              <mo>+</mo>
              <mi>b</mi>
            </math>
            """
        )
        
        // now the queries above have their results interchanged:
        XCTAssertEqual(Array(document.descendants("mi", "mo").map{ $0.immediateTextsCombined }), ["a", "+", "b"])
        XCTAssertEqual(Array(document.elements("mi", "mo").map{ $0.immediateTextsCombined }), ["a", "b", "+"])
        XCTAssertEqual(Array(document.descendants(prefix: "math", "mi", "mo").map{ $0.immediateTextsCombined }), [])
        XCTAssertEqual(Array(document.elements(prefix: "math", "mi", "mo").map{ $0.immediateTextsCombined }), [])
        
        // explicitely `prefix: nil`:
        XCTAssertEqual(Array(document.descendants(prefix: nil, "mi", "mo").map{ $0.immediateTextsCombined }), ["a", "+", "b"])
    }
    
    func testNamespacesInSerialization() throws {
        
        let source = """
            <a xmlns:math="http://www.w3.org/1998/Math/MathML" some-attribute="blabla1" z-some-attribute="blabla2">
                <math:math><math:mi>x</math:mi><nonmath:a xmlns:nonmath="http://nonmath"/></math:math>
            </a>
            """
        
        let document = try parseXML(fromText: source, namespaceAware: true)
        
        XCTAssertEqual(document.serialized(pretty: true), """
            <a some-attribute="blabla1" z-some-attribute="blabla2" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:nonmath="http://nonmath">
                <math:math><math:mi>x</math:mi><nonmath:a/></math:math>
            </a>
            """)
    }
    
    func testNamespacesInPartialSerialization() throws {
        
        let source = """
            <a xmlns:math="http://www.w3.org/1998/Math/MathML" some-attribute="blabla1" z-some-attribute="blabla2">
                <math:math><math:mi>x</math:mi><nonmath:a xmlns:nonmath="http://nonmath"/></math:math>
            </a>
            """
        
        let document = try parseXML(fromText: source, namespaceAware: true)
        
        XCTAssertEqual(document.elements(prefix: "nonmath", "a").first?.serialized(pretty: true), """
            <nonmath:a xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:nonmath="http://nonmath"/>
            """)
    }
    
    func testEmptyPrefixesAndPrefixTranslations() throws {
        
        let source = """
            <a xmlns="http://a">
                <b>
                    <c xmlns="http://c">
                        <d/>
                    </c>
                </b>
            </a>
            """
        
        let document = try parseXML(fromText: source, namespaceAware: true)
        document.firstChild?.addFirst { XElement(prefix: "x", "x") }
        
        XCTAssertEqual(document.serialized(pretty: true), """
            <a:a xmlns:a="http://a" xmlns:c="http://c"><x:x/>
                <a:b>
                    <c:c>
                        <c:d/>
                    </c:c>
                </a:b>
            </a:a>
            """)
        
        XCTAssertEqual(document.serialized(pretty: true, overwritingPrefixes: ["a": ""]), """
            <a xmlns="http://a" xmlns:c="http://c"><x:x/>
                <b>
                    <c:c>
                        <c:d/>
                    </c:c>
                </b>
            </a>
            """)
        
        XCTAssertEqual(document.serialized(pretty: true, overwritingPrefixesForNamespaceURIs: ["http://a": ""]), """
            <a xmlns="http://a" xmlns:c="http://c"><x:x/>
                <b>
                    <c:c>
                        <c:d/>
                    </c:c>
                </b>
            </a>
            """)
        
        XCTAssertEqual(document.serialized(pretty: true, overwritingPrefixesForNamespaceURIs: ["http://a": ""], overwritingPrefixes: ["x": ""]), """
            <a xmlns="http://a" xmlns:c="http://c"><x/>
                <b>
                    <c:c>
                        <c:d/>
                    </c:c>
                </b>
            </a>
            """)
        
        XCTAssertEqual(document.serialized(pretty: true, overwritingPrefixesForNamespaceURIs: ["http://a": ""], overwritingPrefixes: ["x": ""], suppressDeclarationForNamespaceURIs: ["http://a"]), """
            <a xmlns:c="http://c"><x/>
                <b>
                    <c:c>
                        <c:d/>
                    </c:c>
                </b>
            </a>
            """)
    }
    
    func testSilentEmptyRootPrefix() throws {
        
        let source = """
            <a xmlns="http://a">
                <b>
                    <c xmlns="http://c">
                        <d/>
                    </c>
                </b>
            </a>
            """
        
        do {
            // normal reading while recognizing namespaces:
            let document = try parseXML(fromText: source, namespaceAware: true)
            XCTAssertEqual(document.namespacePrefixesAndURIs.map{ "\"\($0.0)\" -> \"\($0.1)\"" }.joined(separator: ", "), #""a" -> "http://a", "c" -> "http://c""#)
            XCTAssertEqual(document.firstChild?["xmlns"], nil)
            XCTAssertEqual(document.firstChild?.prefix, "a")
            XCTAssertEqual(document.serialized, """
                <a:a xmlns:a="http://a" xmlns:c="http://c">
                    <a:b>
                        <c:c>
                            <c:d/>
                        </c:c>
                    </a:b>
                </a:a>
                """)
            // just manipulating the output:
            XCTAssertEqual(document.serialized(overwritingPrefixesForNamespaceURIs: ["http://a": ""]), """
                <a xmlns="http://a" xmlns:c="http://c">
                    <b>
                        <c:c>
                            <c:d/>
                        </c:c>
                    </b>
                </a>
                """)
            // do not write the declaration for the silent namespace:
            XCTAssertEqual(document.firstChild?.firstChild?.serialized(overwritingPrefixesForNamespaceURIs: ["http://a": ""], suppressDeclarationForNamespaceURIs: ["http://a"]), """
                <b xmlns:c="http://c">
                        <c:c>
                            <c:d/>
                        </c:c>
                    </b>
                """)
        }
        
        do {
            // no prefix for prefixless namespace at root:
            let document = try parseXML(fromText: source, namespaceAware: true, silentEmptyRootPrefix: true)
            XCTAssertEqual(document.namespacePrefixesAndURIs.map{ "\"\($0.0)\" -> \"\($0.1)\"" }.joined(separator: ", "), #""" -> "http://a", "c" -> "http://c""#)
            XCTAssertEqual(document.firstChild?["xmlns"], nil)
            XCTAssertEqual(document.firstChild?.prefix, nil)
            XCTAssertEqual(document.serialized, """
                <a xmlns="http://a" xmlns:c="http://c">
                    <b>
                        <c:c>
                            <c:d/>
                        </c:c>
                    </b>
                </a>
                """)
            // writing just <b>:
            XCTAssertEqual(document.firstChild?.firstChild?.serialized, """
                <b xmlns="http://a" xmlns:c="http://c">
                        <c:c>
                            <c:d/>
                        </c:c>
                    </b>
                """)
            // do not write the declaration for the silent namespace:
            XCTAssertEqual(document.firstChild?.firstChild?.serialized(suppressDeclarationForNamespaceURIs: ["http://a"]), """
                <b xmlns:c="http://c">
                        <c:c>
                            <c:d/>
                        </c:c>
                    </b>
                """)
        }
    }
    
    func testNamespaceSearchVariations() throws {
    
        let source = """
            <a xmlns:math="http://www.w3.org/1998/Math/MathML">
                <math:math><math:mi>x</math:mi></math:math>
            </a>
            """
        
        let document = try parseXML(fromText: source, namespaceAware: true)
        
        XCTAssertEqual(Array(document.descendants(prefix: "math", "mi").map{ $0.name }), ["mi"])
        XCTAssertEqual(Array(document.descendants(prefix: "math").map{ $0.name }), ["math", "mi"])
        // but when explicitely telling "no name":
        XCTAssertEqual(Array(document.descendants(prefix: "math", []).map{ $0.name }), [])
        
        XCTAssertEqual(Array(document.descendants.map{ $0.name }), ["a", "math", "mi"])
        // but:
        XCTAssertEqual(Array(document.descendants().map{ $0.name }), ["a"])
        // ...which is the same as:
        XCTAssertEqual(Array(document.descendants(prefix: nil).map{ $0.name }), ["a"])
        
    }
    
    func testReadingWithNamespaces1() throws {
    
        let source = """
            <a xmlns:math="http://www.w3.org/1998/Math/MathML">
                <math:math><math:mi>x</math:mi></math:math>
            </a>
            """
        
        let document = try parseXML(fromText: source, namespaceAware: true)
        
        XCTAssertEqual(
            document.descendants.map { element in
                if let prefix = element.prefix {
                    "element of name \"\(element.name)\" with prefix \"\(prefix)\""
                } else {
                    "element of name \"\(element.name)\" without prefix"
                }
            }.joined(separator: "\n"),
            """
            element of name "a" without prefix
            element of name "math" with prefix "math"
            element of name "mi" with prefix "math"
            """
        )
        
        XCTAssertEqual(document.serialized(), source)
    }
    
    func testReadingWithNamespaces2() throws {
    
        let source = """
            <a>
                <math:math xmlns:math="http://www.w3.org/1998/Math/MathML"><math:mi>x</math:mi></math:math>
            </a>
            """
        
        let document = try parseXML(fromText: source, namespaceAware: true)
        
        XCTAssertEqual(
            document.descendants.map { element in
                if let prefix = element.prefix {
                    "element of name \"\(element.name)\" with prefix \"\(prefix)\""
                } else {
                    "element of name \"\(element.name)\" without prefix"
                }
            }.joined(separator: "\n"),
            """
            element of name "a" without prefix
            element of name "math" with prefix "math"
            element of name "mi" with prefix "math"
            """
        )
        
        XCTAssertEqual(document.serialized(), """
            <a xmlns:math="http://www.w3.org/1998/Math/MathML">
                <math:math><math:mi>x</math:mi></math:math>
            </a>
            """)
    }
    
    func testReadingWithNamespaces3() throws {
    
        let source = """
            <a>
                <math:math xmlns:math="http://www.w3.org/1998/Math/MathML"><math:mi>x</math:mi></math:math>
                <b xmlns:math2="http://www.w3.org/1998/Math/MathML">
                    <math2:math><math2:mi>x</math2:mi></math2:math>
                </b>
            </a>
            """
        
        let document = try parseXML(fromText: source, namespaceAware: true)
        
        XCTAssertEqual(
            document.descendants.map { element in
                if let prefix = element.prefix {
                    "element of name \"\(element.name)\" with prefix \"\(prefix)\""
                } else {
                    "element of name \"\(element.name)\" without prefix"
                }
            }.joined(separator: "\n"),
            """
            element of name "a" without prefix
            element of name "math" with prefix "math"
            element of name "mi" with prefix "math"
            element of name "b" without prefix
            element of name "math" with prefix "math"
            element of name "mi" with prefix "math"
            """
        )
        
        XCTAssertEqual(document.serialized(), """
            <a xmlns:math="http://www.w3.org/1998/Math/MathML">
                <math:math><math:mi>x</math:mi></math:math>
                <b>
                    <math:math><math:mi>x</math:mi></math:math>
                </b>
            </a>
            """)
    }
    
    func testSerachingOnlyByPrefix() throws {
        
        let source = """
            <a xmlns:myPrefix="http//:soandso">
                <myPrefix:b/>
            </a>
            """
        
        let document = try parseXML(fromText: source, namespaceAware: true)
        
        XCTAssertEqual(
            document.descendants(prefix: "myPrefix").map{ "element \"\($0.name)\" with prefix \"\($0.prefix ?? "")\"" }.joined(separator: "\n"),
            #"element "b" with prefix "myPrefix""#
        )
    }
    
    func testChangingNamespaceAndName() throws {
        
        let source = """
            <a xmlns:myPrefix="http//:soandso">
                <myPrefix:b/>
            </a>
            """
        
        let document = try parseXML(fromText: source, namespaceAware: true)

        for b in document.descendants(prefix: "myPrefix", "b") {
            b.set(prefix: "newPrefix", name: "c")
            XCTAssertTrue(b.has(prefix: "newPrefix", name: "c"))
        }
        
        XCTAssertEqual(
            document.descendants(prefix: "newPrefix", "c").map{ "element \"\($0.name)\" with prefix \"\($0.prefix ?? "")\"" }.joined(separator: "\n"),
            #"element "c" with prefix "newPrefix""#
        )
    }
    
    func testSerializedAndDescriptionAndXPathWithNamespaces() throws {
        let element = XElement(prefix: "math", "mi", ["style": "italic"]) { "b" }
        let document = XDocument {
            XElement("a") {
                XElement(prefix: "math", "math") {
                    XElement(prefix: "math", "mi") { "a" }
                    XElement(prefix: "math", "mo") { "+" }
                    element
                }
            }
        }
        XCTAssertEqual(document.serialized(), #"<a><math:math><math:mi>a</math:mi><math:mo>+</math:mo><math:mi style="italic">b</math:mi></math:math></a>"#)
        XCTAssertEqual(element.description, #"<math:mi style="italic">"#)
        XCTAssertEqual(element.xPath, "/a[1]/math:math[1]/math:mi[2]")
    }
    
    func testNamespacesWithConflictingPrefixes() throws {
        
        let source = """
            <a>
                <math:math xmlns:math="http://www.w3.org/1998/Math/MathML"><math:mi>x</math:mi></math:math>
                <!-- conflicting prefixes (note the changed URL): -->
                <math:math xmlns:math="http://www.w3.org/1998/Math/MathML2"><math:mi>x</math:mi></math:math>
            </a>
            """

        let document = try parseXML(fromText: source, namespaceAware: true, keepComments: true)
        
        XCTAssertEqual(
            document.serialized(),
            """
            <a xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:math2="http://www.w3.org/1998/Math/MathML2">
                <math:math><math:mi>x</math:mi></math:math>
                <!-- conflicting prefixes (note the changed URL): -->
                <math2:math><math2:mi>x</math2:mi></math2:math>
            </a>
            """
        )
    }
    
    func testNamespacesWithEmptyPrefixes() throws {
        
        let source = """
            <a>
                <math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi>
                    <non-math xmlns="http://nonmath">This is no math.</non-math>
                </math>
                <math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi>
                    <non-math xmlns="http://nonmath">This is again no math.</non-math>
                </math>
                <!-- conflicting prefixes (note the changed URLs): -->
                <math xmlns="http://www.w3.org/1998/Math/MathML2"><mi>x</mi>
                    <non-math xmlns="http://nonmath2">This is again, again no math.</non-math>
                </math>
            </a>
            """

        let document = try parseXML(fromText: source, namespaceAware: true, keepComments: true)
        
        XCTAssertEqual(
            document.serialized(),
            """
            <a xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:math2="http://www.w3.org/1998/Math/MathML2" xmlns:non-math="http://nonmath" xmlns:non-math2="http://nonmath2">
                <math:math><math:mi>x</math:mi>
                    <non-math:non-math>This is no math.</non-math:non-math>
                </math:math>
                <math:math><math:mi>x</math:mi>
                    <non-math:non-math>This is again no math.</non-math:non-math>
                </math:math>
                <!-- conflicting prefixes (note the changed URLs): -->
                <math2:math><math2:mi>x</math2:mi>
                    <non-math2:non-math>This is again, again no math.</non-math2:non-math>
                </math2:math>
            </a>
            """
        )
    }
    
    func testNamespacesWithOuterDeadPrefix() throws {
        
        // The "math" prefix at the root is "dead" because there is no declared namespace for it.
        // For this reason, this prefix cannot be used for "http://www.w3.org/1998/Math/MathML".
        let source = """
            <math:math>
                <math:math xmlns:math="http://www.w3.org/1998/Math/MathML"><math:mi>x</math:mi></math:math>
            </math:math>
            """

        let document = try parseXML(fromText: source, namespaceAware: true, keepComments: true)
        
        XCTAssertEqual(
            document.serialized(),
            """
            <math:math xmlns:math2="http://www.w3.org/1998/Math/MathML">
                <math2:math><math2:mi>x</math2:mi></math2:math>
            </math:math>
            """
        )
        
        XCTAssertEqual(
            document.elements(prefix: "math2", "math").first?.serialized(),
            """
            <math2:math xmlns:math2="http://www.w3.org/1998/Math/MathML"><math2:mi>x</math2:mi></math2:math>
            """
        )
        
        XCTAssertEqual(
            document.elements("math:math").first?.serialized(),
            """
            <math:math xmlns:math2="http://www.w3.org/1998/Math/MathML">
                <math2:math><math2:mi>x</math2:mi></math2:math>
            </math:math>
            """
        )
    }
    
    func testNamespacesWithInnerDeadPrefix() throws {
        
        // The following pathological case (note the inner element with the prefix that we would like to set for <math>)
        // is handled as a correction after the document has already been built:
        let source = """
            <a>
                <math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi><math:math/></math>
                <math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi><math:math/></math>
            </a>
            """
        
        let document = try parseXML(fromText: source, namespaceAware: true, keepComments: true)
        
        XCTAssertEqual(
            document.serialized(),
            """
            <a xmlns:math2="http://www.w3.org/1998/Math/MathML">
                <math2:math><math2:mi>x</math2:mi><math:math/></math2:math>
                <math2:math><math2:mi>x</math2:mi><math:math/></math2:math>
            </a>
            """
        )
        
        XCTAssertEqual(
            document.elements(prefix: "math2", "math").first?.serialized(),
            """
            <math2:math xmlns:math2="http://www.w3.org/1998/Math/MathML"><math2:mi>x</math2:mi><math:math/></math2:math>
            """
        )
        
        XCTAssertEqual(
            document.elements("math:math").first?.serialized(),
            """
            <math:math xmlns:math2="http://www.w3.org/1998/Math/MathML"/>
            """
        )
    }
    
    func testNamespacesWithAndWithoutEmptyPrefixes() throws {
        
        let source = """
            <a xmlns:math="http://www.w3.org/1998/Math/MathML">
                <math:math><math:mi>x</math:mi></math:math>
                <math xmlns="http://www.w3.org/1998/Math/MathML"><mi>y</mi></math>
            </a>
            """

        let document = try parseXML(fromText: source, namespaceAware: true, keepComments: true)
        
        XCTAssertEqual(
            document.serialized(),
            """
            <a xmlns:math="http://www.w3.org/1998/Math/MathML">
                <math:math><math:mi>x</math:mi></math:math>
                <math:math><math:mi>y</math:mi></math:math>
            </a>
            """
        )
    }
    
    func testNamespacesSameURLDifferentPrefixes() throws {
        
        let source = """
            <a xmlns:math="http://www.w3.org/1998/Math/MathML">
                <math:math><math:mi>x</math:mi></math:math>
                <math xmlns="http://www.w3.org/1998/Math/MathML"><mi>y</mi></math>
                <math2:math xmlns:math2="http://www.w3.org/1998/Math/MathML"><math2:mi>z</math2:mi></math2:math>
            </a>
            """
        
        let document = try parseXML(fromText: source, namespaceAware: true, keepComments: true)
        
        XCTAssertEqual(
            document.serialized(),
            """
            <a xmlns:math="http://www.w3.org/1998/Math/MathML">
                <math:math><math:mi>x</math:mi></math:math>
                <math:math><math:mi>y</math:mi></math:math>
                <math:math><math:mi>z</math:mi></math:math>
            </a>
            """
        )
    }
    
    func testNestedNamespacesWithEmptyPrefixes() throws {
        
        let source = """
            <a>
                <math xmlns="http://www.w3.org/1998/Math/MathML"><mi>x</mi><non-math xmlns="http://nonmath">This is <emphasis>no</emphasis> math.</non-math></math>
            </a>
            """
        
        let document = try parseXML(fromText: source, namespaceAware: true, keepComments: true)
        
        XCTAssertEqual(
            document.serialized(),
            """
            <a xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:non-math="http://nonmath">
                <math:math><math:mi>x</math:mi><non-math:non-math>This is <non-math:emphasis>no</non-math:emphasis> math.</non-math:non-math></math:math>
            </a>
            """
        )
    }
    
    func testNestedNamespacesDefineForeignNamespace() throws {
        
        // Here, a namespace is defined at an element which actually has another namespace:
        let source = """
            <a xmlns:math="http://www.w3.org/1998/Math/MathML">
                <math:math xmlns:nonmath="http://nonmath"><math:mi>x</math:mi><nonmath:non-math>This is <nonmath:emphasis>no</nonmath:emphasis> math.</nonmath:non-math></math:math>
            </a>
            """
        
        let document = try parseXML(fromText: source, namespaceAware: true, keepComments: true)
        
        XCTAssertEqual(
            document.serialized(),
            """
            <a xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:nonmath="http://nonmath">
                <math:math><math:mi>x</math:mi><nonmath:non-math>This is <nonmath:emphasis>no</nonmath:emphasis> math.</nonmath:non-math></math:math>
            </a>
            """
        )
    }
    
    func testNestedNamespacesWithShiftedDefinitions() throws {
        
        // Here, the defintions of the namespaces are not "at the right place",
        // and the algorithm has to be careful not to choose a prefix which contains the colon:
        let source = """
            <base:a xmlns:base="http://base" xmlns="http://www.w3.org/1998/Math/MathML">
                <math xmlns:nonmath="http://nonmath"><mi>x</mi><nonmath:non-math>This is <nonmath:emphasis>no</nonmath:emphasis> math.</nonmath:non-math></math>
            </base:a>
            """
        
        let document = try parseXML(fromText: source, namespaceAware: true, keepComments: true)
        
        XCTAssertEqual(
            document.serialized(),
            """
            <base:a xmlns:base="http://base" xmlns:mathml="http://www.w3.org/1998/Math/MathML" xmlns:nonmath="http://nonmath">
                <mathml:math><mathml:mi>x</mathml:mi><nonmath:non-math>This is <nonmath:emphasis>no</nonmath:emphasis> math.</nonmath:non-math></mathml:math>
            </base:a>
            """
        )
    }
    
    func testInsertWithNamespaces() throws {
        
        let source1 = """
            <document xmlns:math="http://www.w3.org/1998/Math/MathML">
                <math:math><math:mi>x</math:mi></math:math>
            </document>
            """
        
        let document1 = try parseXML(fromText: source1, namespaceAware: true, keepComments: true)
        
        let source2 = """
            <document xmlns:math2="http://www.w3.org/1998/Math/MathML">
                <math2:math><math2:mi>y</math2:mi></math2:math>
            </document>
            """
        
        let document2 = try parseXML(fromText: source2, namespaceAware: true, keepComments: true)
        
        let clone = document2.elements(prefix: document2.prefix(forNamespaceURI: "http://www.w3.org/1998/Math/MathML"), "math").first?.clone
        
        document1.elements(prefix: document1.prefix(forNamespaceURI: "http://www.w3.org/1998/Math/MathML"), "math").first?.insertNext {
            document2.elements(prefix: document2.prefix(forNamespaceURI: "http://www.w3.org/1998/Math/MathML"), "math").clone
            clone
        }
        
        XCTAssertEqual(
            document1.serialized, """
            <document xmlns:math="http://www.w3.org/1998/Math/MathML">
                <math:math><math:mi>x</math:mi></math:math><math:math><math:mi>y</math:mi></math:math><math:math><math:mi>y</math:mi></math:math>
            </document>
            """
        )
        
    }
    
    func testNamespaceOfRemovedElementOrClone() throws {
        
        let mathMLNamespaceURI = "http://www.w3.org/1998/Math/MathML"
        
        let source = """
            <document xmlns:math="\(mathMLNamespaceURI)">
                <math:math><math:mi>x</math:mi></math:math>
            </document>
            """
        
        var document: XDocument? = try parseXML(fromText: source, namespaceAware: true, keepComments: true)
        
        let math = document?.descendants(prefix: "math").first
        XCTAssertNotNil(math)
        
        XCTAssertEqual(math?.prefix, "math")
        XCTAssertEqual(math?.namespaceURI, mathMLNamespaceURI)
        
        let cloneBeforeRemoval = math?.clone
        
        // remove:
        math?.remove(); math?.remove() // even calling it twice
        
        let cloneAfterRemoval = math?.clone
        let cloneOfCloneAfterRemoval = cloneAfterRemoval?.clone
        
        // prefix is kept and still knowing the namespace:
        XCTAssertEqual(math?.prefix, "math")
        XCTAssertEqual(cloneBeforeRemoval?.prefix, "math")
        XCTAssertEqual(cloneAfterRemoval?.prefix, "math")
        XCTAssertEqual(cloneOfCloneAfterRemoval?.prefix, "math")
        XCTAssertEqual(math?.namespaceURI, mathMLNamespaceURI)
        XCTAssertEqual(cloneBeforeRemoval?.namespaceURI, mathMLNamespaceURI)
        XCTAssertEqual(cloneAfterRemoval?.namespaceURI, mathMLNamespaceURI)
        XCTAssertEqual(cloneOfCloneAfterRemoval?.namespaceURI, mathMLNamespaceURI)
        
        // discarding the document:
        document = nil
        // now, the prefix is still there, but the namespace is unknwon:
        XCTAssertEqual(math?.prefix, "math")
        XCTAssertEqual(cloneBeforeRemoval?.prefix, "math")
        XCTAssertEqual(cloneAfterRemoval?.prefix, "math")
        XCTAssertEqual(cloneOfCloneAfterRemoval?.prefix, "math")
        XCTAssertEqual(math?.namespaceURI, nil)
        XCTAssertEqual(cloneBeforeRemoval?.namespaceURI, nil)
        XCTAssertEqual(cloneAfterRemoval?.namespaceURI, nil)
        XCTAssertEqual(cloneOfCloneAfterRemoval?.namespaceURI, nil)
    }
    
    func testAvoidingLiteralPrefixes1() throws {
        
        let root = XElement("math:a") // element starts with a name with a literal prefix
        let document = XDocument {
            root
        }
        
        // The registered prefix will not (!) be "math" to avoid the collision with the literal prefix "math":
        let mathMLPrefix = document.register(namespaceURI: "http://www.w3.org/1998/Math/MathML", withPrefixSuggestion: "math")
        
        root.add {
            XElement(prefix: mathMLPrefix, "math")
        }
        
        XCTAssertEqual(
            document.serialized(pretty: true), """
            <math:a xmlns:math2="http://www.w3.org/1998/Math/MathML">
              <math2:math/>
            </math:a>
            """
        )
        
    }
    
    func testAvoidingLiteralPrefixes2() throws {
        
        let root = XElement("a") // element starts with a name without a literal prefix
        let document = XDocument {
            root
        }
        root.name = "math:a" // the literal prefix is set when the element is already in the document
        
        // The registered prefix will not (!) be "math" to avoid the collision with the literal prefix "math":
        let mathMLPrefix = document.register(namespaceURI: "http://www.w3.org/1998/Math/MathML", withPrefixSuggestion: "math")
        
        root.add {
            XElement(prefix: mathMLPrefix, "math")
        }
        
        XCTAssertEqual(
            document.serialized(pretty: true), """
            <math:a xmlns:math2="http://www.w3.org/1998/Math/MathML">
              <math2:math/>
            </math:a>
            """
        )
        
    }
    
    func testNamespacesFromReadme() throws {
        
        let source = """
            <a>
                <math:math xmlns:math="http://www.w3.org/1998/Math/MathML"><math:mi>x</math:mi></math:math>
                <b xmlns:math2="http://www.w3.org/1998/Math/MathML">
                    <math2:math><math2:mi>n</math2:mi><math2:mo>!</math2:mo></math2:math>
                </b>
            </a>
            """

        let document = try parseXML(fromText: source, namespaceAware: true)

        XCTAssertEqual(
            document.serialized(),
            """
            <a xmlns:math="http://www.w3.org/1998/Math/MathML">
                <math:math><math:mi>x</math:mi></math:math>
                <b>
                    <math:math><math:mi>n</math:mi><math:mo>!</math:mo></math:math>
                </b>
            </a>
            """
        )
        
        XCTAssertEqual(
            document.descendants(prefix: document.prefix(forNamespaceURI: "http://www.w3.org/1998/Math/MathML"), "math", "mo", "mi").map {
                "element \"\($0.name)\" with prefix \"\($0.prefix ?? "")\""
            }.joined(separator: "\n"),
            """
            element "math" with prefix "math"
            element "mi" with prefix "math"
            element "math" with prefix "math"
            element "mi" with prefix "math"
            element "mo" with prefix "math"
            """
        )
    }
    
}
