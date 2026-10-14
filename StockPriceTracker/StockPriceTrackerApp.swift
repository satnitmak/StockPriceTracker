import SwiftUI

// MARK:  -  App Entry  -

@main
struct StockPriceTrackerApp: App {
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SymbolListView(viewModel: container.listViewModel)
            }
        }
    }
}
