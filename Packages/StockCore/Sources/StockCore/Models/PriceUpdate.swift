import Foundation

// MARK:  -  Price Update  -

/// A single new price for one symbol. This is also the wire format sent over the socket.
public struct PriceUpdate: Codable, Equatable, Sendable {
    public let symbol: String
    public let price: Decimal
    public let timestamp: Date

    public init(symbol: String, price: Decimal, timestamp: Date) {
        self.symbol = symbol
        self.price = price
        self.timestamp = timestamp
    }
}
