import SwiftUI

// MARK:  -  Localized Strings  -

/// Every user-facing string the app shows. Views use these keys instead of writing text inline.
/// The keys must match entries in `Localizable.xcstrings`.
enum tr {
    enum symbolList {
        static let title: LocalizedStringKey = "symbolList.title"
        static let sortLabel: LocalizedStringKey = "symbolList.sortLabel"
        static let sortByPrice: LocalizedStringKey = "symbolList.sortByPrice"
        static let sortByPriceChange: LocalizedStringKey = "symbolList.sortByPriceChange"
        static let start: LocalizedStringKey = "symbolList.start"
        static let stop: LocalizedStringKey = "symbolList.stop"
    }

    enum connectionStatus {
        static let connected: LocalizedStringKey = "connectionStatus.connected"
        static let connecting: LocalizedStringKey = "connectionStatus.connecting"
        static let disconnected: LocalizedStringKey = "connectionStatus.disconnected"
    }
}
