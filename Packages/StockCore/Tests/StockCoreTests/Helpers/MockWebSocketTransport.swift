import Foundation
@testable import StockCore

// MARK:  -  Fake WebSocket Transport  -

/// In-memory socket. With `echoes` on, every sent message is delivered back, like the echo server.
actor MockWebSocketTransport: WebSocketTransport {
    private(set) var sentMessages: [String] = []
    private(set) var closeCount = 0
    private(set) var connectedURL: URL?
    private let echoes: Bool
    private let continuation: AsyncThrowingStream<String, Error>.Continuation
    private let incoming: AsyncThrowingStream<String, Error>
    private var holdsNextClose: Bool
    private var closeHold: CheckedContinuation<Void, Never>?

    /// - Parameter holdsFirstCloseUntilReleased: when true, the first `close()` call waits until `releaseClose()`.
    init(echoes: Bool = true, holdsFirstCloseUntilReleased: Bool = false) {
        self.echoes = echoes
        self.holdsNextClose = holdsFirstCloseUntilReleased
        let pair = AsyncThrowingStream.makeStream(of: String.self, throwing: Error.self)
        self.continuation = pair.continuation
        self.incoming = pair.stream
    }

    func connect(to url: URL) async throws {
        connectedURL = url
    }

    func send(_ text: String) async throws {
        sentMessages.append(text)
        if echoes { continuation.yield(text) }
    }

    func receive() async throws -> String {
        // Only one receive runs at a time, so a fresh iterator reads the next buffered message.
        var iterator = incoming.makeAsyncIterator()
        guard let text = try await iterator.next() else {
            throw WebSocketTransportError.notConnected
        }
        return text
    }

    func close() async {
        closeCount += 1
        continuation.finish()
        if holdsNextClose {
            holdsNextClose = false
            await withCheckedContinuation { closeHold = $0 }
        }
    }

    /// Lets a held close finish.
    func releaseClose() {
        closeHold?.resume()
        closeHold = nil
    }

    /// Simulates the connection dropping mid-session.
    func fail(with error: Error) {
        continuation.finish(throwing: error)
    }

    /// Simulates a server message that isn't an echo of one of ours.
    func inject(_ text: String) {
        continuation.yield(text)
    }
}

struct TestConnectionError: Error {}
