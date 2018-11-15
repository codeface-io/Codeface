import XCTest
@testable import SPM

final class SPMTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SPM().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
