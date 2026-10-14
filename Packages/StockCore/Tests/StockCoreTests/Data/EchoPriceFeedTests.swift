import Foundation
import Testing
@testable import StockCore

// MARK:  -  Echo Price Feed Tests  -

/// Collects what the feed emits so tests can assert on it.
private actor FeedRecorder {
    private(set) var updates: [PriceUpdate] = []
    private(set) var states: [ConnectionState] = []

    func record(_ update: PriceUpdate) { updates.append(update) }
    func record(_ state: ConnectionState) { states.append(state) }
}

struct EchoPriceFeedTests {
    private let endpoint = URL(string: "wss://example.test/echo")!

    private func makeFeed(supply: FakeTransportSupply) -> EchoPriceFeed {
        EchoPriceFeed(
            endpoint: endpoint,
            makeTransport: { await supply.next() },
            generator: RandomPriceGenerator(stocks: SymbolCatalog.all, random: SeededRandomNumberGenerator(seed: 42)),
            tickInterval: .milliseconds(1)
        )
    }

    /// Starts recording the feed's updates and states in the background.
    private func record(_ feed: EchoPriceFeed) -> (recorder: FeedRecorder, tasks: [Task<Void, Never>]) {
        let recorder = FeedRecorder()
        let updates = Task {
            for await update in feed.updates { await recorder.record(update) }
        }
        let states = Task {
            for await state in feed.connectionStates { await recorder.record(state) }
        }
        return (recorder, [updates, states])
    }

    @Test func connectsToTheEndpoint() async throws {
        let transport = FakeWebSocketTransport()
        let supply = FakeTransportSupply([transport])
        let feed = makeFeed(supply: supply)

        await feed.start()
        try await waitUntil { await transport.connectedURL != nil }
        #expect(await transport.connectedURL == endpoint)
        await feed.stop()
    }

    @Test func reportsConnectingThenConnected() async throws {
        let feed = makeFeed(supply: FakeTransportSupply())
        let (recorder, tasks) = record(feed)

        await feed.start()
        try await waitUntil { await recorder.states.contains(.connected) }
        #expect(await recorder.states.prefix(2) == [.connecting, .connected])
        await feed.stop()
        tasks.forEach { $0.cancel() }
    }

    @Test func echoedPricesBecomeUpdates() async throws {
        let transport = FakeWebSocketTransport()
        let feed = makeFeed(supply: FakeTransportSupply([transport]))
        let (recorder, tasks) = record(feed)

        await feed.start()
        try await waitUntil { await recorder.updates.count >= 3 }
        await feed.stop()

        // Every update the feed emitted must match a message it actually sent.
        let sent = try await transport.sentMessages.map(PriceMessageCodec.decode)
        for update in await recorder.updates {
            #expect(sent.contains(update))
        }
        tasks.forEach { $0.cancel() }
    }

    @Test func malformedEchoesAreIgnoredWithoutDroppingTheConnection() async throws {
        let transport = FakeWebSocketTransport()
        let supply = FakeTransportSupply([transport])
        let feed = makeFeed(supply: supply)
        let (recorder, tasks) = record(feed)

        await feed.start()
        try await waitUntil { await recorder.updates.count >= 1 }
        await transport.inject("not a price")
        let countBefore = await recorder.updates.count
        try await waitUntil { await recorder.updates.count >= countBefore + 2 }

        #expect(!(await recorder.states.contains(.disconnected)))
        #expect(await supply.issued.count == 1)
        await feed.stop()
        tasks.forEach { $0.cancel() }
    }

    @Test func droppedConnectionReportsDisconnectedAndDoesNotRetry() async throws {
        let first = FakeWebSocketTransport()
        let supply = FakeTransportSupply([first])
        let feed = makeFeed(supply: supply)
        let (recorder, tasks) = record(feed)

        await feed.start()
        try await waitUntil { await first.sentMessages.count >= 1 }
        await first.fail(with: TestConnectionError())

        try await waitUntil { await recorder.states.last == .disconnected }
        // Give a retry a chance to happen; none should.
        try await Task.sleep(for: .milliseconds(50))
        #expect(await supply.issued.count == 1)
        tasks.forEach { $0.cancel() }
    }

    @Test func startAfterADropConnectsAgain() async throws {
        let first = FakeWebSocketTransport()
        let second = FakeWebSocketTransport()
        let supply = FakeTransportSupply([first, second])
        let feed = makeFeed(supply: supply)
        let (recorder, tasks) = record(feed)

        await feed.start()
        try await waitUntil { await first.sentMessages.count >= 1 }
        await first.fail(with: TestConnectionError())
        try await waitUntil { await recorder.states.last == .disconnected }

        await feed.start()
        try await waitUntil { await second.sentMessages.count >= 1 }
        #expect(await supply.issued.count == 2)
        await feed.stop()
        tasks.forEach { $0.cancel() }
    }

    @Test func stopClosesTheSocketAndStopsSending() async throws {
        let transport = FakeWebSocketTransport()
        let feed = makeFeed(supply: FakeTransportSupply([transport]))
        let (recorder, tasks) = record(feed)

        await feed.start()
        try await waitUntil { await transport.sentMessages.count >= 1 }
        await feed.stop()

        #expect(await transport.closeCount >= 1)
        try await waitUntil { await recorder.states.last == .disconnected }

        // A send that was already in flight may still land, so let it settle before checking.
        try await Task.sleep(for: .milliseconds(50))
        let settledCount = await transport.sentMessages.count
        try await Task.sleep(for: .milliseconds(100))
        #expect(await transport.sentMessages.count == settledCount)
        tasks.forEach { $0.cancel() }
    }
}
