import Foundation
import StockCore

// MARK:  -  App Configuration  -

/// Everything the app needs to know at startup. Tests and previews can build their own.
struct AppConfiguration {
    let priceFeedURL: URL
    let stocks: [Stock]

    static let PROD = AppConfiguration(
        priceFeedURL: URL(string: "wss://ws.postman-echo.com/raw")!,
        stocks: SymbolCatalog.all
    )
}
