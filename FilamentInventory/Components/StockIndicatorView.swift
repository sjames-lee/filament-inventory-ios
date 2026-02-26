import SwiftUI

struct StockIndicatorView: View {
    let status: FilamentStatus

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)

            Text(status.label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
