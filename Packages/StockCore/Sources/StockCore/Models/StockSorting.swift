// MARK:  -  Stock Sorting  -

public enum SortOption: Sendable, Equatable, CaseIterable {
    case price
    case priceChange
}

extension Collection where Element == Stock {
    /// Highest first. "Price change" ranks by percent so stocks with different
    /// opening prices compare fairly. Ties fall back to symbol order so rows
    /// don't shuffle between updates.
    public func sorted(by option: SortOption) -> [Stock] {
        sorted { lhs, rhs in
            let lhsValue = option == .price ? lhs.price : lhs.changePercent
            let rhsValue = option == .price ? rhs.price : rhs.changePercent
            if lhsValue != rhsValue { return lhsValue > rhsValue }
            return lhs.symbol < rhs.symbol
        }
    }
}
