import XCTest
import class Foundation.Bundle
@testable import SwiftXML

final class SwiftXMLTests: XCTestCase {
    
    func testTypedIterator() throws {
        let document = try parseXML(fromText: """
            <a>
                <b id="1"/>
                <b id="2"/>
                <b id="3" drop="yes"/>
            </a>
        """)
        let sequence = document.children.children.filter { $0.name == "b" }.drop(while: { Int($0["id"] ?? "1") ?? 1 < 2 }).filter { $0["drop"] != "yes" }
        var iterator = TypedIterator(for: sequence)
        let next: XElement? = iterator.next()
        assert("\(next?.description ?? "-")" == #"<b id="2">"#)
    }
}
