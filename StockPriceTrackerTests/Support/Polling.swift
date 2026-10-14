import Foundation

// MARK:  -  Polling  -

struct PollingTimeout: Error {}

/// Checks `condition` until it's true or the timeout passes. Used to wait for main-actor state to settle.
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
