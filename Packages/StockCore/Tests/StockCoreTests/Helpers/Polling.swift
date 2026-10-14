import Foundation

// MARK:  -  Polling  -

struct PollingTimeout: Error {}

/// Checks `condition` until it's true or the timeout passes. Used to wait on async work without fixed sleeps.
func waitUntil(
    timeout: Duration = .seconds(2),
    _ condition: @escaping @Sendable () async -> Bool
) async throws {
    let deadline = ContinuousClock.now.advanced(by: timeout)
    while !(await condition()) {
        guard ContinuousClock.now < deadline else { throw PollingTimeout() }
        try await Task.sleep(for: .milliseconds(5))
    }
}

/// Main-actor version of `waitUntil`, for checking state that lives on the main actor, such as `PriceStore`.
@MainActor
func waitUntilMain(
    timeout: Duration = .seconds(2),
    _ condition: @escaping @MainActor () -> Bool
) async throws {
    let deadline = ContinuousClock.now.advanced(by: timeout)
    while !condition() {
        guard ContinuousClock.now < deadline else { throw PollingTimeout() }
        try await Task.sleep(for: .milliseconds(5))
    }
}
