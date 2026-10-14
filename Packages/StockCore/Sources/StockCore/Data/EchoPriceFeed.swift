import Foundation

// MARK:  -  Echo Price Feed  -

/// Simulated live prices over a WebSocket echo server.
///
/// Each tick generates a random price, sends it, and treats the echoed copy as the live update.
/// If the connection drops, the feed reports `disconnected` and stops. Call `start()` to reconnect.
public actor EchoPriceFeed: PriceFeed {
    public nonisolated let updates: AsyncStream<PriceUpdate>
    public nonisolated let connectionStates: AsyncStream<ConnectionState>

    private let updateContinuation: AsyncStream<PriceUpdate>.Continuation
    private let stateContinuation: AsyncStream<ConnectionState>.Continuation
    private let endpoint: URL
    private let makeTransport: @Sendable () async -> any WebSocketTransport
    private let tickInterval: Duration
    private var generator: RandomPriceGenerator
    /// Bumped on every start and stop, so callbacks from an old session are ignored.
    private var generation = 0
    private var sessionTask: Task<Void, Never>?
    private var transport: (any WebSocketTransport)?

    public init(
        endpoint: URL,
        makeTransport: @escaping @Sendable () async -> any WebSocketTransport,
        generator: RandomPriceGenerator,
        tickInterval: Duration = .seconds(1)
    ) {
        let updatePair = AsyncStream.makeStream(of: PriceUpdate.self, bufferingPolicy: .bufferingNewest(100))
        // State changes are rare, so keep every one rather than only the latest.
        let statePair = AsyncStream.makeStream(of: ConnectionState.self, bufferingPolicy: .unbounded)
        self.updates = updatePair.stream
        self.updateContinuation = updatePair.continuation
        self.connectionStates = statePair.stream
        self.stateContinuation = statePair.continuation
        self.endpoint = endpoint
        self.makeTransport = makeTransport
        self.generator = generator
        self.tickInterval = tickInterval
    }

    public func start() async {
        guard sessionTask == nil else { return }
        generation += 1
        let current = generation
        sessionTask = Task { await self.runSession(generation: current) }
    }

    public func stop() async {
        generation += 1
        // Captured before the await, so a start() during the close makes this report stale.
        let stopGeneration = generation
        sessionTask?.cancel()
        sessionTask = nil
        let active = transport
        transport = nil
        await active?.close()
        report(.disconnected, generation: stopGeneration)
    }

    // MARK:  -  Session Lifecycle  -

    private func runSession(generation current: Int) async {
        report(.connecting, generation: current)
        let transport = await makeTransport()
        guard current == generation else {
            await transport.close()
            return
        }
        self.transport = transport

        do {
            try await transport.connect(to: endpoint)
            report(.connected, generation: current)
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { try await self.receiveLoop(transport) }
                group.addTask { try await self.sendLoop(transport) }
                // Both loops run forever, so the group only finishes by throwing or being cancelled.
                _ = try await group.next()
                group.cancelAll()
            }
        } catch {
            // The connection failed or dropped. The feed stays down until the user calls start() again.
        }

        await transport.close()
        // If stop() or a newer start() already took over, that code owns the state.
        guard current == generation else { return }
        self.transport = nil
        sessionTask = nil
        report(.disconnected, generation: current)
    }

    private func report(_ state: ConnectionState, generation current: Int) {
        guard current == generation else { return }
        stateContinuation.yield(state)
    }

    // MARK:  -  Loops  -

    private func receiveLoop(_ transport: any WebSocketTransport) async throws {
        while true {
            let text = try await transport.receive()
            // A malformed message is skipped so one bad echo doesn't drop the connection.
            guard let update = try? PriceMessageCodec.decode(text) else { continue }
            updateContinuation.yield(update)
        }
    }

    private func sendLoop(_ transport: any WebSocketTransport) async throws {
        while true {
            try await Task.sleep(for: tickInterval)
            let update = generator.nextUpdate(at: Date())
            try await transport.send(try PriceMessageCodec.encode(update))
        }
    }
}
