import Foundation
@testable import StockCore

// MARK:  -  Mock Price Feed  -

/// A feed the test drives by hand: it records start and stop, and emits whatever the test sends.
actor MockPriceFeed: PriceFeed {
    nonisolated let updates: AsyncStream<PriceUpdate>
    nonisolated let connectionStates: AsyncStream<ConnectionState>

    private let updateContinuation: AsyncStream<PriceUpdate>.Continuation
    private let stateContinuation: AsyncStream<ConnectionState>.Continuation
    private(set) var startCount = 0
    private(set) var stopCount = 0

    init() {
        let updatePair = AsyncStream.makeStream(of: PriceUpdate.self, bufferingPolicy: .unbounded)
        let statePair = AsyncStream.makeStream(of: ConnectionState.self, bufferingPolicy: .unbounded)
        self.updates = updatePair.stream
        self.updateContinuation = updatePair.continuation
        self.connectionStates = statePair.stream
        self.stateContinuation = statePair.continuation
    }

    func start() async {
        startCount += 1
    }

    func stop() async {
        stopCount += 1
    }

    func emit(_ update: PriceUpdate) {
        updateContinuation.yield(update)
    }

    func setState(_ state: ConnectionState) {
        stateContinuation.yield(state)
    }
}
