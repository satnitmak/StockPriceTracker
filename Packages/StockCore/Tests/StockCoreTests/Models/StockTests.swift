import Foundation
import Testing
@testable import StockCore

// MARK:  -  Stock Tests  -

struct StockTests {
    private let base = Stock(symbol: "TEST", name: "Test", summary: "", openingPrice: 100)

    @Test func newStockStartsAtOpeningPrice() {
        #expect(base.price == 100)
        #expect(base.change == 0)
        #expect(base.direction == .flat)
    }

    @Test func changeIsPriceMinusOpeningPrice() {
        let moved = base.updated(price: 110, at: .now)
        #expect(moved.change == 10)
    }

    @Test func changePercentIsRelativeToOpeningPrice() {
        let moved = base.updated(price: 90, at: .now)
        #expect(moved.changePercent == -10)
    }

    @Test func directionReflectsSignOfChange() {
        #expect(base.updated(price: 101, at: .now).direction == .up)
        #expect(base.updated(price: 99, at: .now).direction == .down)
        #expect(base.updated(price: 100, at: .now).direction == .flat)
    }

    @Test func updatingKeepsOpeningPriceAndDetails() {
        let moved = base.updated(price: 150, at: .now)
        #expect(moved.openingPrice == 100)
        #expect(moved.symbol == "TEST")
        #expect(moved.name == "Test")
    }

    @Test func zeroOpeningPriceYieldsZeroPercentInsteadOfCrashing() {
        let zero = Stock(symbol: "ZERO", name: "Zero", summary: "", openingPrice: 0)
        #expect(zero.updated(price: 5, at: .now).changePercent == 0)
    }
}
