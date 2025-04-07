import XCTest
import Combine
@testable import BindingSupport

final class BindingSupportTests: XCTestCase {
    func testExample() throws {
        let expectation = XCTestExpectation(description: "bind delivers value")
        var cancellables = Set<AnyCancellable>()
        
        let subject = PassthroughSubject<String, Never>()
        var receivedValue: String?

        subject
            .bind(storeIn: &cancellables) { value in
                receivedValue = value
                expectation.fulfill()
            }

        subject.send("Hello")

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValue, "Hello")
    }
}
