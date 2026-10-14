import Foundation

// MARK:  -  URLSession WebSocket Transport  -

/// A WebSocketTransport backed by URLSession's WebSocket task.
public actor URLSessionWebSocketTransport: WebSocketTransport {
    private let session: URLSession
    private var task: URLSessionWebSocketTask?

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func connect(to url: URL) async throws {
        let task = session.webSocketTask(with: url)
        self.task = task
        task.resume()
    }

    public func send(_ text: String) async throws {
        guard let task else { throw WebSocketTransportError.notConnected }
        try await task.send(.string(text))
    }

    public func receive() async throws -> String {
        guard let task else { throw WebSocketTransportError.notConnected }
        switch try await task.receive() {
        case .string(let text):
            return text
        case .data(let data):
            return String(decoding: data, as: UTF8.self)
        @unknown default:
            throw WebSocketTransportError.unsupportedMessage
        }
    }

    public func close() async {
        task?.cancel(with: .normalClosure, reason: nil)
        task = nil
    }
}
