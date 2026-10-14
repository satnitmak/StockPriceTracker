import Foundation
import Testing
@testable import StockCore

// MARK:  -  Stock Sorting Tests  -

struct StockSortingTests {
    private func stock(_ symbol: String, opening: Decimal, price: Decimal) -> Stock {
        Stock(symbol: symbol, name: symbol, summary: "", openingPrice: opening)
            .updated(price: price, at: .now)
    }

    @Test func sortsByPriceHighestFirst() {
        let stocks = [
            stock("LOW", opening: 10, price: 10),
            stock("HIGH", opening: 500, price: 500),
            stock("MID", opening: 100, price: 100),
        ]
        #expect(stocks.sorted(by: .price).map(\.symbol) == ["HIGH", "MID", "LOW"])
    }

    @Test func sortsByPriceChangePercentHighestFirst() {
        // AAA gains 10% but has the highest price; BBB gains 50% from a low base.
        let stocks = [
            stock("AAA", opening: 1000, price: 1100),
            stock("BBB", opening: 10, price: 15),
            stock("CCC", opening: 100, price: 90),
        ]
        #expect(stocks.sorted(by: .priceChange).map(\.symbol) == ["BBB", "AAA", "CCC"])
    }

    @Test func tiesFallBackToSymbolOrder() {
        let stocks = [
            stock("ZZZ", opening: 100, price: 110),
            stock("AAA", opening: 100, price: 110),
        ]
        #expect(stocks.sorted(by: .priceChange).map(\.symbol) == ["AAA", "ZZZ"])
    }
}
