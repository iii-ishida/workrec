import XCTest
@testable import WorkrecSDK

final class WorkrecSDKTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(WorkrecSDK().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
