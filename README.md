# StockPriceTracker

An iOS app that shows live price updates for 25 stocks, with a list screen (sortable by price or price change) and a detail screen for each symbol.

Prices are simulated. Each second the app makes up a new price for one stock, sends it over a WebSocket to an echo server (`wss://ws.postman-echo.com/raw`), and treats the echoed copy as the live update. The opening prices are illustrative, not market data.

## Architecture

The code is split into two layers:

- **`Packages/StockCore`**: a Swift package with all the logic and no UI. It has no SwiftUI or UIKit imports, so its tests run on the Mac with `swift test`.
  - `Models`: plain value types. `Stock` (symbol, name, summary, opening price, latest price, change, direction), `PriceUpdate` (the wire message), `ConnectionState`, and `SortOption` with the sorting rules.
  - `Data`: where prices come from. `PriceFeed` is the protocol. `EchoPriceFeed` implements it on top of the socket. `RandomPriceGenerator` makes the prices. `PriceMessageCodec` converts updates to and from JSON. `SymbolCatalog` holds the 25 stocks.
  - `Network`: a generic WebSocket connection (`WebSocketTransport`, with a `URLSession` implementation). It knows nothing about stocks.
  - `Store`: `PriceStore`, the shared, observable source of truth for the stock list and the connection status.
- **`StockPriceTracker`** (the app target): SwiftUI only.
  - `App`: `AppConfiguration` (feed URL and stock list) and the app entry point, which creates the store and shows the list.
  - `Features/SymbolList` and `Features/SymbolDetail`: each screen has a view and a view model. Each view builds its own view model from the store.
  - `Shared`: reusable views (status indicator, change label), price formatting, and `tr`, the wrapper for localized strings.

**Data flow.** `EchoPriceFeed` emits updates and connection states. `PriceStore` subscribes once, applies each update to the matching stock, and mirrors the status. View models read from the store and expose what their screen needs. Views only display that, and send taps back to the view model. Start and Stop pass through the store to the feed, and the status comes back through the feed's stream, so the screen always shows what the feed reports.

**Feed behavior.** Each tick sends one update for one random stock, and the echo returns that same message. If the connection drops, the feed reports `disconnected` and stops. Start reconnects it. There is no automatic retry. Start and Stop can be pressed in quick succession; a generation counter makes sure an old session can't overwrite the status of a newer one.

**Localization.** All user-facing text lives in `StockPriceTracker/Localizable.xcstrings` (a String Catalog, English only) and is referenced through `tr` (in `Localizations.swift`). Keys are grouped by screen, for example `symbolList.start`.

## Requirements

- Xcode 27 (the project was built with it)
- iOS 17 or later to run the app
- Swift 6

## Running the app

1. Open `StockPriceTracker.xcodeproj` in Xcode.
2. Choose an iPhone simulator and press Run.
3. Press **Start** on the list screen to begin the feed. Tap a row to open its detail screen.

The Xcode project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen). If you change `project.yml`, regenerate the project:

```sh
brew install xcodegen
xcodegen generate
```

## Running the tests

Package tests (logic, feed, store). These run on the Mac and don't need a simulator:

```sh
cd Packages/StockCore
swift test
```

App tests (view models). These run on a simulator. List the simulators you have with `xcrun simctl list devices available`, then use one of their IDs:

```sh
xcodebuild -project StockPriceTracker.xcodeproj \
  -scheme StockPriceTracker \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_ID>' \
  test
```

## Testing approach

- **Framework:** Swift Testing (`import Testing`) in both test targets.
- **No real network in tests.** The feed tests use a mock socket (`MockWebSocketTransport`) that can echo messages, drop, or hold a close open. Store and view-model tests use a mock feed that the test drives by hand.
- **Repeatable randomness.** The price generator is tested with a seeded random source, so a failure can be replayed.
- **Waiting without sleeping.** Asynchronous results are checked with a polling helper (`waitUntil` / `waitUntilMain`) that times out, rather than fixed delays.
- **What's covered:**
  - Package: stock math and sorting, the JSON codec, price generation limits, the feed (connect, echo, malformed messages, drop with no retry, restart after a drop, stop closes the socket and stops sending, and a regression test for a start during a stop), and the store.
  - App: list sorting and feed status, Start/Stop, live row updates and reordering, detail lookup, live detail prices, and the unknown-symbol case.
- **Not covered yet:** UI tests that launch the app and tap through the screens, and continuous integration.

## Known limitations

- Prices are simulated, and the echo server is a public test service, so the feed depends on it being available.
- Only one stock updates per second.
- A dropped connection needs a manual restart.
