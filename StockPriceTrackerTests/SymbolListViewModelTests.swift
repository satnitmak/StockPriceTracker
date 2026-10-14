import StockCore
import Testing
@testable import StockPriceTracker

// MARK:  -  Symbol List View Model Tests  -

@MainActor
struct SymbolListViewModelTests {
    private let apple = Stock(symbol: "AAPL", name: "Apple", summary: "", openingPrice: 100)
    private let nvidia = Stock(symbol: "NVDA", name: "NVIDIA", summary: "", openingPrice: 50)
    private let tesla = Stock(symbol: "TSLA", name: "Tesla", summary: "", openingPrice: 200)

    private func makeViewModel(feed: StubPriceFeed) -> SymbolListViewModel {
        let store = PriceStore(stocks: [apple, nvidia, tesla], feed: feed)
        return SymbolListViewModel(store: store)
    }

    /// Prices chosen so the two sort orders differ:
    /// by price: TSLA 190, AAPL 150, NVDA 60. By change: AAPL +50%, NVDA +20%, TSLA -5%.
    private func emitPrices(_ feed: StubPriceFeed) async {
        await feed.emit(PriceUpdate(symbol: "AAPL", price: 150, timestamp: .now))
        await feed.emit(PriceUpdate(symbol: "NVDA", price: 60, timestamp: .now))
        await feed.emit(PriceUpdate(symbol: "TSLA", price: 190, timestamp: .now))
    }

    // MARK:  -  Live updates  -

    @Test func rowsShowTheUpdatedPriceAndReorder() async throws {
        let feed = StubPriceFeed()
        let viewModel = makeViewModel(feed: feed)
        // Opening order by price: TSLA 200, AAPL 100, NVDA 50.

        await feed.emit(PriceUpdate(symbol: "NVDA", price: 300, timestamp: .now))

        try await waitUntilMain { viewModel.rows.first?.symbol == "NVDA" }
        #expect(viewModel.rows.first?.price == 300)
        #expect(viewModel.rows.map(\.symbol) == ["NVDA", "TSLA", "AAPL"])
    }

    // MARK:  -  Sorting  -

    @Test func sortsByPriceHighestFirstByDefault() async throws {
        let feed = StubPriceFeed()
        let viewModel = makeViewModel(feed: feed)
        await emitPrices(feed)

        try await waitUntilMain { viewModel.rows.map(\.symbol) == ["TSLA", "AAPL", "NVDA"] }
        #expect(viewModel.sortOption == .price)
    }

    @Test func sortsByPriceChangeWhenSelected() async throws {
        let feed = StubPriceFeed()
        let viewModel = makeViewModel(feed: feed)
        await emitPrices(feed)

        viewModel.sortOption = .priceChange

        try await waitUntilMain { viewModel.rows.map(\.symbol) == ["AAPL", "NVDA", "TSLA"] }
    }

    // MARK:  -  Feed status  -

    @Test func feedIsInactiveWhenDisconnected() async throws {
        let feed = StubPriceFeed()
        let viewModel = makeViewModel(feed: feed)

        #expect(viewModel.connectionState == .disconnected)
        #expect(viewModel.isFeedActive == false)
    }

    @Test func feedIsActiveWhileConnectingOrConnected() async throws {
        let feed = StubPriceFeed()
        let viewModel = makeViewModel(feed: feed)

        await feed.setState(.connecting)
        try await waitUntilMain { viewModel.connectionState == .connecting }
        #expect(viewModel.isFeedActive)

        await feed.setState(.connected)
        try await waitUntilMain { viewModel.connectionState == .connected }
        #expect(viewModel.isFeedActive)

        await feed.setState(.disconnected)
        try await waitUntilMain { viewModel.connectionState == .disconnected }
        #expect(viewModel.isFeedActive == false)
    }

    // MARK:  -  Start and Stop  -

    @Test func toggleStartsTheFeedWhenInactive() async throws {
        let feed = StubPriceFeed()
        let viewModel = makeViewModel(feed: feed)

        await viewModel.toggleFeed()

        #expect(await feed.startCount == 1)
        #expect(await feed.stopCount == 0)
    }

    @Test func toggleStopsTheFeedWhenActive() async throws {
        let feed = StubPriceFeed()
        let viewModel = makeViewModel(feed: feed)
        await feed.setState(.connected)
        try await waitUntilMain { viewModel.isFeedActive }

        await viewModel.toggleFeed()

        #expect(await feed.stopCount == 1)
        #expect(await feed.startCount == 0)
    }
}
