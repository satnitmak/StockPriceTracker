import Foundation
import Observation

// MARK:  -  Price Store  -

/// The shared source of truth for stock prices and feed status. Both screens read from it.
///
/// The store subscribes to the feed once, when it's created. Start and Stop only pass through to the feed,
/// and the status comes back through the feed's stream, so no status update can be missed.
@MainActor
@Observable
public final class PriceStore {
    public private(set) var stocks: [Stock]
    public private(set) var connectionState: ConnectionState = .disconnected

    private let feed: any PriceFeed

    public init(stocks: [Stock], feed: any PriceFeed) {
        self.stocks = stocks
        self.feed = feed
        observe()
    }

    public func start() async {
        await feed.start()
    }

    public func stop() async {
        await feed.stop()
    }

    public func stock(for symbol: String) -> Stock? {
        stocks.first { $0.symbol == symbol }
    }

    // MARK:  -  Observation  -

    private func observe() {
        let updates = feed.updates
        let states = feed.connectionStates

        Task { [weak self] in
            for await update in updates {
                self?.apply(update)
            }
        }
        Task { [weak self] in
            for await state in states {
                self?.connectionState = state
            }
        }
    }

    private func apply(_ update: PriceUpdate) {
        // Unknown symbols are ignored. Matching keeps the list order unchanged.
        guard let index = stocks.firstIndex(where: { $0.symbol == update.symbol }) else { return }
        stocks[index] = stocks[index].updated(price: update.price, at: update.timestamp)
    }
}
