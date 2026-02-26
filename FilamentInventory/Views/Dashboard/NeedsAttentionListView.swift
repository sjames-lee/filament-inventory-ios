import SwiftUI

struct NeedsAttentionListView: View {
    let filaments: [Filament]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(filaments, id: \.id) { filament in
                HStack(spacing: 10) {
                    ColorSwatchView(hex: filament.colorHex, size: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(filament.name)
                            .font(.subheadline)
                            .lineLimit(1)
                        Text(filament.brand)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    StockIndicatorView(status: filament.statusEnum)

                    Text(filament.spoolLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }
}
