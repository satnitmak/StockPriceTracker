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
        .navigationTitle(tr.symbolList.title)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                ConnectionStatusView(state: viewModel.connectionState)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(viewModel.isFeedActive ? tr.symbolList.stop : tr.symbolList.start) {
                    Task { await viewModel.toggleFeed() }
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.isFeedActive ? .red : .green)
                .accessibilityIdentifier("feedToggleButton")
            }
            ToolbarItem(placement: .bottomBar) {
                Picker(selection: Bindable(viewModel).sortOption) {
                    Text(tr.symbolList.sortByPrice).tag(SortOption.price)
                    Text(tr.symbolList.sortByPriceChange).tag(SortOption.priceChange)
                } label: {
                    Text(tr.symbolList.sortLabel)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}
