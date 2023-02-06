import XCTest
import class Foundation.Bundle
@testable import SwiftXML

extension String: Error {}

final class SwiftXMLTests: XCTestCase {
    
    let documentSource1 = """
        <a>
            <b id="1"/>
            <b id="2"/>
            <b id="3" drop="yes"/>
        </a>
        """
    
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
        
        if #available(macOS 13.0.0, *) {
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
        }
        
        if #available(macOS 13.0.0, *) {
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
            bs.first(),
            bs.dropFirst(1).first(),
            bs.dropFirst(2).first()
        ].compactMap{ $0 }["id"].joined(separator: ", "), #"1, 2, 3"#)
    }
    
    func testAsync() async throws {
        
        let attachments = Attachments()
        attachments["f"] = nil
        
        let e = XElement("u")
        e.attached["ii"] = nil
        
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
        
        document.elements(ofNames: "b", "c", "d").forEach { element in
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
            """)
        
        var collectedAttributeValues = [String]()
        
        document.attributes(ofNames: "b", "c", "d").forEach { attribute in
            collectedAttributeValues.append(attribute.value)
            if attribute.value == "c1" {
                attribute.element.insertPrevious { XElement("x", ["b": "bInserted1"]) }
            }
        }
        
        XCTAssertEqual(collectedAttributeValues.joined(separator: ", "), "b1, b2, c1, c2, d1, d2, bInserted1")
    }
    
}
