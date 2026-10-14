import Foundation

// MARK:  -  Random Price Generator  -

/// Simulates prices by moving a randomly chosen stock's last price up or down a little.
public struct RandomPriceGenerator: Sendable {
    private let symbols: [String]
    private var prices: [String: Decimal]
    private var random: AnyRandomNumberGenerator
    private let minimumPrice: Decimal = 0.01
    /// Largest move per update, as a fraction of the price (0.005 = 0.5%).
    private let maxStepFraction = 0.005

    /// - Parameters:
    ///   - stocks: The stocks to simulate. Each starts from its current price.
    ///   - random: The random source. Pass a seeded generator for repeatable output.
    public init(
        stocks: [Stock],
        random: any RandomNumberGenerator & Sendable = SystemRandomNumberGenerator()
    ) {
        precondition(!stocks.isEmpty, "RandomPriceGenerator needs at least one stock")
        self.symbols = stocks.map(\.symbol).sorted()
        self.prices = Dictionary(uniqueKeysWithValues: stocks.map { ($0.symbol, $0.price) })
        self.random = AnyRandomNumberGenerator(base: random)
    }

    public mutating func nextUpdate(at timestamp: Date) -> PriceUpdate {
        let symbol = symbols.randomElement(using: &random) ?? symbols[0]
        let step = Double.random(in: -maxStepFraction...maxStepFraction, using: &random)
        let current = prices[symbol] ?? minimumPrice
        let next = max((current * (1 + Decimal(step))).roundedToCents(), minimumPrice)
        prices[symbol] = next
        return PriceUpdate(symbol: symbol, price: next, timestamp: timestamp)
    }
}

// MARK:  -  Random Source  -

/// Concrete wrapper so any random source can be used with the standard `random(in:using:)` APIs.
private struct AnyRandomNumberGenerator: RandomNumberGenerator, Sendable {
    private var base: any RandomNumberGenerator & Sendable

    init(base: any RandomNumberGenerator & Sendable) {
        self.base = base
    }

    mutating func next() -> UInt64 {
        base.next()
    }
}

// MARK:  -  Decimal Rounding  -

private extension Decimal {
    func roundedToCents() -> Decimal {
        var source = self
        var result = Decimal()
        NSDecimalRound(&result, &source, 2, .plain)
        return result
    }
}
