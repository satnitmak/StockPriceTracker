import Foundation

// MARK:  -  WebSocket Transport  -

/// A generic WebSocket connection: open it, send text, receive text, close it.
public protocol WebSocketTransport: Sendable {
    func connect(to url: URL) async throws
    func send(_ text: String) async throws
    func receive() async throws -> String
    func close() async
}

public enum WebSocketTransportError: Error, Equatable {
    case notConnected
    case unsupportedMessage
}
