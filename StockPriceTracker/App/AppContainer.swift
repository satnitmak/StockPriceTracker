import StockCore

// MARK:  -  App Container  -

/// Builds the app's shared objects from a configuration. This is the only place that wires them together.
@MainActor
final class AppContainer {
    let store: PriceStore
    let listViewModel: SymbolListViewModel

    init(configuration: AppConfiguration = .live) {
        let feed = EchoPriceFeed(
            endpoint: configuration.priceFeedURL,
            makeTransport: { URLSessionWebSocketTransport() },
            generator: RandomPriceGenerator(stocks: configuration.stocks)
        )
        store = PriceStore(stocks: configuration.stocks, feed: feed)
        listViewModel = SymbolListViewModel(store: store)
    }
}
