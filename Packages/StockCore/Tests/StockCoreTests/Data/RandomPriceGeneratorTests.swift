import Foundation
import Testing
@testable import StockCore

// MARK:  -  Random Price Generator Tests  -

struct RandomPriceGeneratorTests {
    @Test func sameSeedProducesSameSequence() {
        var first = RandomPriceGenerator(stocks: SymbolCatalog.all, random: SeededRandomNumberGenerator(seed: 7))
        var second = RandomPriceGenerator(stocks: SymbolCatalog.all, random: SeededRandomNumberGenerator(seed: 7))
        let date = Date(timeIntervalSince1970: 0)
        for _ in 0..<50 {
            #expect(first.nextUpdate(at: date) == second.nextUpdate(at: date))
        }
    }

    @Test func onlyEmitsKnownSymbols() {
        var generator = RandomPriceGenerator(stocks: SymbolCatalog.all, random: SeededRandomNumberGenerator(seed: 1))
        let known = Set(SymbolCatalog.all.map(\.symbol))
        for _ in 0..<200 {
            #expect(known.contains(generator.nextUpdate(at: .now).symbol))
        }
    }

    @Test func eachMoveIsWithinStepLimitOfThatSymbolsPreviousPrice() {
        let maxStep: Decimal = 0.005
        var generator = RandomPriceGenerator(stocks: SymbolCatalog.all, random: SeededRandomNumberGenerator(seed: 3))
        var lastPrice = Dictionary(uniqueKeysWithValues: SymbolCatalog.all.map { ($0.symbol, $0.price) })
        for _ in 0..<500 {
            let update = generator.nextUpdate(at: .now)
            let previous = lastPrice[update.symbol]!
            // Allow one cent of slack for rounding to whole cents.
            let allowed = previous * maxStep + Decimal(string: "0.01")!
            #expect(abs(update.price - previous) <= allowed)
            lastPrice[update.symbol] = update.price
        }
    }

    @Test func pricesStayPositiveAndRoundedToCents() {
        var generator = RandomPriceGenerator(stocks: SymbolCatalog.all, random: SeededRandomNumberGenerator(seed: 9))
        for _ in 0..<500 {
            let price = generator.nextUpdate(at: .now).price
            #expect(price >= Decimal(string: "0.01")!)
            let fractionDigits = price.description.split(separator: ".", omittingEmptySubsequences: false)
            #expect(fractionDigits.count == 1 || fractionDigits[1].count <= 2)
        }
    }
}
