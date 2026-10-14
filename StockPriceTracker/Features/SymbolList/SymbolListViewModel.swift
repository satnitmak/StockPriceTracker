import Observation
import StockCore

// MARK:  -  Symbol List View Model  -

/// Drives the symbol list screen: the sorted rows, the connection status, and the Start/Stop action.
@MainActor
@Observable
final class SymbolListViewModel {
    var sortOption: SortOption = .price

    private let store: PriceStore

    init(store: PriceStore) {
        self.store = store
    }

    var rows: [Stock] {
        store.stocks.sorted(by: sortOption)
    }

    var connectionState: ConnectionState {
        store.connectionState
    }

    /// True while the feed is connecting or connected, so the button should offer Stop.
    var isFeedActive: Bool {
        connectionState != .disconnected
    }

    func toggleFeed() async {
        if isFeedActive {
            await store.stop()
        } else {
            await store.start()
        }
    }
}
