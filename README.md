# StockPriceTracker

An iOS app that shows live prices for 25 stocks. The list screen can be sorted by price or price change, and each row opens a detail screen.

Prices are simulated. Each second the app makes up a new price for one stock, sends it to a WebSocket echo server (`wss://ws.postman-echo.com/raw`), and uses the echoed copy as the live update.

## Structure

- **`Packages/StockCore`**: all logic, with no UI. Its tests run with `swift test`.
  - `Models`: `Stock`, `PriceUpdate`, `ConnectionState`, sorting.
  - `Data`: the feed (`EchoPriceFeed`), the random price generator, the JSON codec, and the 25-stock catalog.
  - `Network`: a generic WebSocket connection.
  - `Store`: `PriceStore`, the shared source of prices and status.
- **`StockPriceTracker`** (app): SwiftUI screens, each with a view model. Text lives in `Localizable.xcstrings` and is read through `tr`.

Data flows one way: the feed feeds the store, the store feeds the view models, and the views display them.

## Requirements

Xcode 27, iOS 17 or later, Swift 6.

## Run

Open `StockPriceTracker.xcodeproj`, pick a simulator, and press Run. Tap **Start** to begin the feed.

The project is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen). After changing it, run `xcodegen generate`.

## Test

Package tests (run on the Mac):

```sh
cd Packages/StockCore && swift test
```

App tests (run on a simulator; get an ID from `xcrun simctl list devices available`):

```sh
xcodebuild -project StockPriceTracker.xcodeproj -scheme StockPriceTracker \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_ID>' test
```

Unit tests use Swift Testing, a mock socket, and a mock feed, so they never touch the network.

GitHub Actions runs the package tests on every pull request and on pushes to `main` (see `.github/workflows/package-tests.yml`). The app and UI tests run locally only.

The app test run also includes a UI test (`StockPriceTrackerUITests`). It launches the app on the simulator, taps Start, and opens the detail screen for a row. It uses the live echo server, so it needs network access. It launches in English, so text lookups work on any device language.

## Limits

- Prices are simulated, and the feed depends on the public echo server.
- One stock updates per second.
- A dropped connection needs Start again.
- CI runs only the package tests. App and UI tests run locally.
