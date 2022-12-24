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
    
    func testTypedIterator() throws {
        let document = try parseXML(fromText: documentSource1)
        let sequence = document.children.children.filter { $0.name == "b" }.drop(while: { Int($0["id"] ?? "1") ?? 1 < 2 }).filter { $0["drop"] != "yes" }
        var iterator = TypedIterator(for: sequence)
        let next: XElement? = iterator.next()
        XCTAssertEqual("\(next?.description ?? "-")", #"<b id="2">"#)
    }
    
    func testXContentLike() throws {
        do {
            let document = try parseXML(fromText: documentSource1)
            let element = XElement("test") {
                document.children
            }
            XCTAssertEqual(element.serialized(pretty: true), """
            <test>
              <a>
                <b id="1"/>
                <b id="2"/>
                <b drop="yes" id="3"/>
            </a>
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
        XCTAssertEqual([bs.first,bs.second,bs.third,].compactMap{ $0 }["id"].joined(separator: ", "), #"1, 2, 3"#)
    }

}
