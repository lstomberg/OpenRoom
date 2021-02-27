import XCTest
@testable import Code

final class CodeTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Code().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
