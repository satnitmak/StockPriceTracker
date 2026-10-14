import Foundation

// MARK:  -  Stock  -

public enum PriceDirection: Sendable, Equatable {
    case up
    case down
    case flat
}

/// A tracked stock: its details, the session's opening price, and its latest price.
public struct Stock: Identifiable, Equatable, Sendable {
    public var id: String { symbol }
    public let symbol: String
    public let name: String
    public let summary: String
    /// Reference price for the session. Change is measured against it.
    public let openingPrice: Decimal
    public let price: Decimal
    public let updatedAt: Date

    /// A stock that starts the session at its opening price.
    public init(symbol: String, name: String, summary: String, openingPrice: Decimal, updatedAt: Date = .now) {
        self.symbol = symbol
        self.name = name
        self.summary = summary
        self.openingPrice = openingPrice
        self.price = openingPrice
        self.updatedAt = updatedAt
    }

    private init(copying stock: Stock, price: Decimal, updatedAt: Date) {
        self.symbol = stock.symbol
        self.name = stock.name
        self.summary = stock.summary
        self.openingPrice = stock.openingPrice
        self.price = price
        self.updatedAt = updatedAt
    }

    /// Returns a copy with a new latest price.
    public func updated(price: Decimal, at date: Date) -> Stock {
        Stock(copying: self, price: price, updatedAt: date)
    }

    public var change: Decimal { price - openingPrice }

    public var changePercent: Decimal {
        guard openingPrice != 0 else { return 0 }
        return change / openingPrice * 100
    }

    public var direction: PriceDirection {
        if change > 0 { return .up }
        if change < 0 { return .down }
        return .flat
    }
}
