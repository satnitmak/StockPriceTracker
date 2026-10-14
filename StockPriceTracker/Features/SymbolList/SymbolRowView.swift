import StockCore
import SwiftUI

// MARK:  -  Symbol Row View  -

struct SymbolRowView: View {
    let stock: Stock

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(stock.symbol)
                    .font(.headline)
                Text(stock.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(PriceFormat.price(stock.price))
                    .font(.headline.monospacedDigit())
                PriceChangeLabel(stock: stock)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
