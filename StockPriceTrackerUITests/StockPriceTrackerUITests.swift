import XCTest

// MARK:  -  Stock Price Tracker UI Tests  -

final class StockPriceTrackerUITests: XCTestCase {
    @MainActor
    func testStartThenOpenDetailShowsTheSymbol() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["Symbols"].waitForExistence(timeout: 5))

        let start = app.buttons["Start"]
        XCTAssertTrue(start.waitForExistence(timeout: 5))
        start.tap()
        XCTAssertTrue(app.buttons["Stop"].waitForExistence(timeout: 5))

        // The sort order changes with live prices, so tap whichever row is on screen first.
        let firstRow = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "symbolRow-")).firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
        let symbol = String(firstRow.identifier.dropFirst("symbolRow-".count))
        firstRow.tap()

        XCTAssertTrue(app.navigationBars[symbol].waitForExistence(timeout: 5))
    }

    @MainActor
    func testStatusFollowsStartAndStop() throws {
        let app = XCUIApplication()
        app.launch()

        let status = app.descendants(matching: .any).matching(identifier: "connectionStatus").firstMatch
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        XCTAssertTrue(waitForLabel(status, equalTo: "Disconnected"))

        app.buttons["Start"].tap()
        XCTAssertTrue(waitForLabel(status, equalTo: "Connected"))

        app.buttons["Stop"].tap()
        XCTAssertTrue(waitForLabel(status, equalTo: "Disconnected"))
        XCTAssertTrue(app.buttons["Start"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSortControlSelectsPriceChangeAndKeepsRows() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["Symbols"].waitForExistence(timeout: 5))

        let priceChange = app.buttons["Price Change"]
        XCTAssertTrue(priceChange.waitForExistence(timeout: 5))
        priceChange.tap()

        XCTAssertTrue(waitUntil { priceChange.isSelected })
        let rows = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "symbolRow-"))
        XCTAssertTrue(rows.firstMatch.waitForExistence(timeout: 5))
    }

    // MARK:  -  Helpers  -

    /// Waits until an element's accessibility label matches, since live updates can change it after a tap.
    @MainActor
    private func waitForLabel(_ element: XCUIElement, equalTo expected: String, timeout: TimeInterval = 10) -> Bool {
        let predicate = NSPredicate(format: "label == %@", expected)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }

    /// Polls a condition on the main thread until it's true or the timeout passes.
    @MainActor
    private func waitUntil(timeout: TimeInterval = 5, _ condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() {
            guard Date() < deadline else { return false }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return true
    }
}
