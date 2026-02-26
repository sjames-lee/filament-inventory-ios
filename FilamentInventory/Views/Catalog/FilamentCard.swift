import SwiftUI

struct FilamentCard: View {
    let filament: Filament

    private var cardColor: Color { ColorHelpers.color(from: filament.colorHex) }
    private var isLight: Bool { ColorHelpers.isLight(filament.colorHex) }
    private var textColor: Color { isLight ? Color(.darkGray) : .white }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Color header
            ZStack {
                cardColor
                    .frame(height: 140)
                    .frame(maxWidth: .infinity)

                if filament.favorite {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(isLight ? .yellow : .yellow.opacity(0.9))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .padding(10)
                }

                Text(filament.colorName)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(isLight ? Color.black.opacity(0.08) : Color.white.opacity(0.18))
                    .foregroundStyle(textColor)
                    .clipShape(Capsule())
            }

            // Info area
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    MaterialBadgeView(material: filament.material)
                    StockIndicatorView(status: filament.statusEnum)
                    Spacer()
                }

                Text(filament.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                Text(filament.brand)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    Text(filament.formattedPrice)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(filament.price != nil ? .primary : .tertiary)

                    Spacer()

                    Text(filament.spoolLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)
    }
}
