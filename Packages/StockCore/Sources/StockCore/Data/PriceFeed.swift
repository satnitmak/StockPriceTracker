import Foundation

// MARK:  -  Price Feed  -

/// A source of live prices. Implementations own the connection lifecycle.
public protocol PriceFeed: Sendable {
    var updates: AsyncStream<PriceUpdate> { get }
    var connectionStates: AsyncStream<ConnectionState> { get }
    func start() async
    func stop() async
}
