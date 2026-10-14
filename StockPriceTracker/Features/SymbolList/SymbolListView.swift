import StockCore
import SwiftUI

// MARK:  -  Symbol List View  -

/// Builds its own view model from the store, and keeps it in state so the sort choice survives redraws.
struct SymbolListView: View {
    @State private var viewModel: SymbolListViewModel

    init(store: PriceStore) {
        _viewModel = State(initialValue: SymbolListViewModel(store: store))
    }

    var body: some View {
        List(viewModel.rows) { stock in
            NavigationLink(value: stock.symbol) {
                SymbolRowView(stock: stock)
            }
        }
        .animation(.default, value: viewModel.sortOption)
        .navigationTitle("Symbols")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ConnectionStatusView(state: viewModel.connectionState)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(viewModel.isFeedActive ? "Stop" : "Start") {
                    Task { await viewModel.toggleFeed() }
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.isFeedActive ? .red : .green)
                .accessibilityIdentifier("feedToggleButton")
            }
            ToolbarItem(placement: .bottomBar) {
                Picker("Sort", selection: Bindable(viewModel).sortOption) {
                    Text("Price").tag(SortOption.price)
                    Text("Price Change").tag(SortOption.priceChange)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}
