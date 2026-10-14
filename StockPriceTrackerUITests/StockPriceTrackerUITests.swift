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
}
