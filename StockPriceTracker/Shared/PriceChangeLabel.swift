import StockCore
import SwiftUI

// MARK:  -  Price Change Label  -

/// Shows a stock's change from its opening price, colored and arrowed by direction.
/// The detail screen uses the same view, so the indicator looks identical on both screens.
struct PriceChangeLabel: View {
    let stock: Stock

    var body: some View {
        Label {
            Text("\(PriceFormat.change(stock.change))  (\(PriceFormat.percent(stock.changePercent)))")
        } icon: {
            Image(systemName: iconName)
        }
        .font(.subheadline.monospacedDigit())
        .foregroundStyle(color)
    }

    private var iconName: String {
        switch stock.direction {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .flat: return "arrow.right"
        }
    }

    private var color: Color {
        switch stock.direction {
        case .up: return .green
        case .down: return .red
        case .flat: return .secondary
        }
    }
}
