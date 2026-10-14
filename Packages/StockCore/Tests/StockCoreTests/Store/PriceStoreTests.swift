import Foundation
import Testing
@testable import StockCore

// MARK:  -  Price Store Tests  -

@MainActor
struct PriceStoreTests {
    private let apple = Stock(symbol: "AAPL", name: "Apple", summary: "", openingPrice: 100)
    private let nvidia = Stock(symbol: "NVDA", name: "NVIDIA", summary: "", openingPrice: 50)

    private func makeStore(feed: MockPriceFeed) -> PriceStore {
        PriceStore(stocks: [apple, nvidia], feed: feed)
    }

    @Test func startsWithEveryStockAtItsOpeningPrice() {
        let store = makeStore(feed: MockPriceFeed())
        #expect(store.stocks.map(\.price) == [100, 50])
        #expect(store.connectionState == .disconnected)
    }

    @Test func startAndStopPassThroughToTheFeed() async {
        let feed = MockPriceFeed()
        let store = makeStore(feed: feed)

        await store.start()
        await store.stop()

        #expect(await feed.startCount == 1)
        #expect(await feed.stopCount == 1)
    }

    @Test func updatesMatchingStockPrice() async throws {
        let feed = MockPriceFeed()
        let store = makeStore(feed: feed)

        await feed.emit(PriceUpdate(symbol: "AAPL", price: 120, timestamp: .now))

        try await waitUntilMain { store.stock(for: "AAPL")?.price == 120 }
        #expect(store.stock(for: "AAPL")?.change == 20)
        #expect(store.stock(for: "AAPL")?.openingPrice == 100)
    }

    @Test func updatesDoNotChangeOtherStocks() async throws {
        let feed = MockPriceFeed()
        let store = makeStore(feed: feed)

        await feed.emit(PriceUpdate(symbol: "AAPL", price: 120, timestamp: .now))

        try await waitUntilMain { store.stock(for: "AAPL")?.price == 120 }
        #expect(store.stock(for: "NVDA")?.price == 50)
    }

    @Test func unknownSymbolsAreIgnored() async throws {
        let feed = MockPriceFeed()
        let store = makeStore(feed: feed)

        await feed.emit(PriceUpdate(symbol: "ZZZZ", price: 999, timestamp: .now))
        await feed.emit(PriceUpdate(symbol: "NVDA", price: 60, timestamp: .now))

        try await waitUntilMain { store.stock(for: "NVDA")?.price == 60 }
        #expect(store.stocks.map(\.symbol) == ["AAPL", "NVDA"])
        #expect(store.stocks.map(\.price) == [100, 60])
    }

    @Test func updatesKeepListOrder() async throws {
        let feed = MockPriceFeed()
        let store = makeStore(feed: feed)

        await feed.emit(PriceUpdate(symbol: "NVDA", price: 200, timestamp: .now))

        try await waitUntilMain { store.stock(for: "NVDA")?.price == 200 }
        #expect(store.stocks.map(\.symbol) == ["AAPL", "NVDA"])
    }

    @Test func mirrorsConnectionStatesFromTheFeed() async throws {
        let feed = MockPriceFeed()
        let store = makeStore(feed: feed)

        await feed.setState(.connecting)
        try await waitUntilMain { store.connectionState == .connecting }

        await feed.setState(.connected)
        try await waitUntilMain { store.connectionState == .connected }

        await feed.setState(.disconnected)
        try await waitUntilMain { store.connectionState == .disconnected }
    }
}
