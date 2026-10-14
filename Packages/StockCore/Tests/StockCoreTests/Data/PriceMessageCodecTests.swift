import Foundation
import Testing
@testable import StockCore

// MARK:  -  Price Message Codec Tests  -

struct PriceMessageCodecTests {
    @Test func roundTripsAnUpdate() throws {
        let original = PriceUpdate(symbol: "NVDA", price: 121.37, timestamp: Date(timeIntervalSince1970: 1_700_000_000.250))
        let text = try PriceMessageCodec.encode(original)
        #expect(try PriceMessageCodec.decode(text) == original)
    }

    @Test func encodesTimestampAsMilliseconds() throws {
        let update = PriceUpdate(symbol: "AAPL", price: 228.5, timestamp: Date(timeIntervalSince1970: 1_700_000_000))
        let text = try PriceMessageCodec.encode(update)
        #expect(text.contains("1700000000000"))
    }

    @Test func rejectsNonJSONText() {
        #expect(throws: (any Error).self) {
            _ = try PriceMessageCodec.decode("not json")
        }
    }

    @Test func rejectsJSONWithMissingFields() {
        #expect(throws: (any Error).self) {
            _ = try PriceMessageCodec.decode(#"{"symbol":"AAPL"}"#)
        }
    }
}
