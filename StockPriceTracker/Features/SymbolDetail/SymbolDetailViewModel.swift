import Observation
import StockCore

// MARK:  -  Symbol Detail View Model  -

/// Drives the detail screen for one symbol: its latest details and the connection status.
@MainActor
@Observable
final class SymbolDetailViewModel {
    let symbol: String

    private let store: PriceStore

    init(symbol: String, store: PriceStore) {
        self.symbol = symbol
        self.store = store
    }

    /// The latest stock for this symbol, or nil if the store doesn't track it.
    var stock: Stock? {
        store.stock(for: symbol)
    }

    var connectionState: ConnectionState {
        store.connectionState
    }
}
