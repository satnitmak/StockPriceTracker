import StockCore
import SwiftUI

// MARK:  -  App Entry  -

@main
struct StockPriceTrackerApp: App {
    private let store: PriceStore

    init() {
        let configuration = AppConfiguration.PROD
        let feed = EchoPriceFeed(
            endpoint: configuration.priceFeedURL,
            makeTransport: { URLSessionWebSocketTransport() },
            generator: RandomPriceGenerator(stocks: configuration.stocks)
        )
        store = PriceStore(stocks: configuration.stocks, feed: feed)
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SymbolListView(store: store)
                    .navigationDestination(for: String.self) { symbol in
                        SymbolDetailView(symbol: symbol, store: store)
                    }
            }
        }
    }
}
