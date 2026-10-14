import StockCore
import SwiftUI

// MARK:  -  Connection Status View  -

struct ConnectionStatusView: View {
    let state: ConnectionState

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.caption.weight(.medium))
                .lineLimit(1)
                .fixedSize()
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("connectionStatus")
    }

    private var title: String {
        switch state {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        }
    }

    private var color: Color {
        switch state {
        case .disconnected: return .gray
        case .connecting: return .orange
        case .connected: return .green
        }
    }
}
