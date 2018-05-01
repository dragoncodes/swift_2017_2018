import XCTest
@testable import FancyLanguage

final class FancyLanguageTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FancyLanguage().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
