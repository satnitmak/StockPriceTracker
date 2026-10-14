import StockCore
import Testing
@testable import StockPriceTracker

// MARK:  -  Symbol Detail View Model Tests  -

@MainActor
struct SymbolDetailViewModelTests {
    private let apple = Stock(symbol: "AAPL", name: "Apple", summary: "Makes phones.", openingPrice: 100)

    private func makeViewModel(symbol: String, feed: StubPriceFeed) -> SymbolDetailViewModel {
        let store = PriceStore(stocks: [apple], feed: feed)
        return SymbolDetailViewModel(symbol: symbol, store: store)
    }

    @Test func exposesTheRequestedSymbol() async throws {
        let viewModel = makeViewModel(symbol: "AAPL", feed: StubPriceFeed())

        #expect(viewModel.symbol == "AAPL")
        #expect(viewModel.stock?.name == "Apple")
        #expect(viewModel.stock?.summary == "Makes phones.")
    }

    @Test func unknownSymbolHasNoStock() async throws {
        let viewModel = makeViewModel(symbol: "ZZZZ", feed: StubPriceFeed())

        #expect(viewModel.stock == nil)
    }

    @Test func showsTheLatestPriceForItsSymbol() async throws {
        let feed = StubPriceFeed()
        let viewModel = makeViewModel(symbol: "AAPL", feed: feed)

        await feed.emit(PriceUpdate(symbol: "AAPL", price: 130, timestamp: .now))

        try await waitUntilMain { viewModel.stock?.price == 130 }
        #expect(viewModel.stock?.change == 30)
    }

    @Test func unknownSymbolStaysEmptyWhenOtherStocksUpdate() async throws {
        let feed = StubPriceFeed()
        let store = PriceStore(stocks: [apple], feed: feed)
        let known = SymbolDetailViewModel(symbol: "AAPL", store: store)
        let unknown = SymbolDetailViewModel(symbol: "ZZZZ", store: store)

        await feed.emit(PriceUpdate(symbol: "AAPL", price: 130, timestamp: .now))
        await feed.emit(PriceUpdate(symbol: "ZZZZ", price: 999, timestamp: .now))

        // Once the known stock has the new price, the unknown symbol's update has been processed too.
        try await waitUntilMain { known.stock?.price == 130 }
        #expect(unknown.stock == nil)
    }

    @Test func mirrorsTheConnectionStatus() async throws {
        let feed = StubPriceFeed()
        let viewModel = makeViewModel(symbol: "AAPL", feed: feed)

        #expect(viewModel.connectionState == .disconnected)

        await feed.setState(.connected)
        try await waitUntilMain { viewModel.connectionState == .connected }
    }
}
