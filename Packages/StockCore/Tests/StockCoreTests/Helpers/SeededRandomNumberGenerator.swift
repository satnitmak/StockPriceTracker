import Foundation

// MARK:  -  Seeded Random Number Generator  -

/// A linear congruential generator: each number is the last one times a fixed multiplier, plus a fixed offset.
/// The same seed always gives the same sequence. It's not high quality randomness, which doesn't matter for tests.
struct SeededRandomNumberGenerator: RandomNumberGenerator, Sendable {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        // Multiplier and increment are the standard Knuth/MMIX constants. &* and &+ wrap around on overflow instead of crashing.
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state
    }
}
