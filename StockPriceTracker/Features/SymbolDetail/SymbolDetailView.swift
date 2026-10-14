import StockCore
import SwiftUI

// MARK:  -  Symbol Detail View  -

/// Builds its own view model for one symbol from the store.
struct SymbolDetailView: View {
    private let viewModel: SymbolDetailViewModel

    init(symbol: String, store: PriceStore) {
        viewModel = SymbolDetailViewModel(symbol: symbol, store: store)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ConnectionStatusView(state: viewModel.connectionState)

                if let stock = viewModel.stock {
                    Text(PriceFormat.price(stock.price))
                        .font(.system(size: 44, weight: .bold).monospacedDigit())
                        .accessibilityIdentifier("detailPrice")
                    PriceChangeLabel(stock: stock)

                    Divider()

                    Text(stock.name)
                        .font(.title3.bold())
                    Text(stock.summary)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle(viewModel.symbol)
    }
}
