import Foundation
import Testing
@testable import StockCore

// MARK:  -  Price Update Tests  -

struct PriceUpdateTests {
    @Test func roundTripsThroughJSONWithExactDecimalPrice() throws {
        let original = PriceUpdate(symbol: "NVDA", price: 121.37, timestamp: Date(timeIntervalSince1970: 1_700_000_000))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PriceUpdate.self, from: data)
        #expect(decoded == original)
    }
}
