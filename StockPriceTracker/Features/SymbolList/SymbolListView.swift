import StockCore
import SwiftUI

// MARK:  -  Symbol List View  -

struct SymbolListView: View {
    @Bindable var viewModel: SymbolListViewModel

    var body: some View {
        List(viewModel.rows) { stock in
            SymbolRowView(stock: stock)
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
                Picker("Sort", selection: $viewModel.sortOption) {
                    Text("Price").tag(SortOption.price)
                    Text("Price Change").tag(SortOption.priceChange)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}
