import XCTest
import class Foundation.Bundle
import SwiftXML
import SwiftXMLInterfaces

final class ProcessingInstructionIterationTests: XCTestCase {
    
    func test1() throws {
        
        let source = """
            <a>
                <b>Blabla.<?MyTarget Hello world!?></b>
                <b>Blabla.<?OtherTarget This has another target.?></b>
                <b>Blabla.<?MyTarget This has the same target.?></b>
            </a>
            """
        
        let document = try parseXML(fromText: source)
        
        XCTAssertEqual(
            document.processingInstructions("MyTarget")
                .map { $0.data ?? "" }.joined(separator: "\n"),
            """
            Hello world!
            This has the same target.
            """
        )
        
        XCTAssertEqual(
            document.processingInstructions("MyTarget", "OtherTarget")
                .map { $0.data ?? "" }.joined(separator: "\n"),
            """
            Hello world!
            This has the same target.
            This has another target.
            """
        )
        
        let firstProcessingInstructionOfTarget = document.processingInstructions("MyTarget").first?.removed()
        XCTAssertTrue(firstProcessingInstructionOfTarget?.document == nil)
        
        XCTAssertEqual(
            document.processingInstructions("MyTarget")
                .map { $0.data ?? "" }.joined(separator: "\n"),
            // The first processing instruction of the target is now missing:
            """
            This has the same target.
            """
        )
        
        let anotherDocument = XDocument {
            document.descendants("b").last
        }
        XCTAssertEqual(
            document.processingInstructions("MyTarget")
                .map { $0.data ?? "" }.joined(separator: "\n"),
            // Now the 2nd processing instruction of the target is also gone from the first document:
            """
            """
        )
        
        XCTAssertEqual(
            anotherDocument.processingInstructions("MyTarget")
                .map { $0.data ?? "" }.joined(separator: "\n"),
            // ...it is now in the second document:
            """
            This has the same target.
            """
        )
        
        anotherDocument.add {
            firstProcessingInstructionOfTarget
        }
        
        XCTAssertEqual(
            anotherDocument.processingInstructions("MyTarget")
                .map { $0.data ?? "" }.joined(separator: "\n"),
            // Now we also have the other processing instruction of the target in the other document:
            """
            This has the same target.
            Hello world!
            """
        )
        
        anotherDocument.processingInstructions("MyTarget").remove()
        
        XCTAssertEqual(
            anotherDocument.processingInstructions("MyTarget")
                .map { $0.data ?? "" }.joined(separator: "\n"),
            // All processing instructions of the target are now removed in the other document:
            """
            """
        )
        
    }
    
}
