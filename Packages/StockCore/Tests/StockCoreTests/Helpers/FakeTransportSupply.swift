import Foundation
@testable import StockCore

// MARK:  -  Fake Transport Supply  -

/// Hands out transports in order, creating echoing ones once the scripted list runs out.
actor FakeTransportSupply {
    private var pending: [FakeWebSocketTransport]
    private(set) var issued: [FakeWebSocketTransport] = []

    init(_ transports: [FakeWebSocketTransport] = []) {
        self.pending = transports
    }

    func next() -> any WebSocketTransport {
        let transport = pending.isEmpty ? FakeWebSocketTransport() : pending.removeFirst()
        issued.append(transport)
        return transport
    }
}
