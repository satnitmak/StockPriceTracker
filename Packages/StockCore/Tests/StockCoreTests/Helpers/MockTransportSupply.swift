import Foundation
@testable import StockCore

// MARK:  -  Fake Transport Supply  -

/// Hands out transports in order, creating echoing ones once the scripted list runs out.
actor MockTransportSupply {
    private var pending: [MockWebSocketTransport]
    private(set) var issued: [MockWebSocketTransport] = []

    init(_ transports: [MockWebSocketTransport] = []) {
        self.pending = transports
    }

    func next() -> any WebSocketTransport {
        let transport = pending.isEmpty ? MockWebSocketTransport() : pending.removeFirst()
        issued.append(transport)
        return transport
    }
}
