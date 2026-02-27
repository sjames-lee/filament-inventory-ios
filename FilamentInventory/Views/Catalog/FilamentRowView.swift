import SwiftUI

struct FilamentRowView: View {
    let filament: Filament

    var body: some View {
        HStack(spacing: 12) {
            // Color swatch
            RoundedRectangle(cornerRadius: 8)
                .fill(ColorHelpers.color(from: filament.colorHex))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .frame(width: 44, height: 44)

            // Center info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(filament.brand)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    MaterialBadgeView(material: filament.material)
                }

                if !filament.colorName.isEmpty {
                    Text(filament.colorName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Right info
            VStack(alignment: .trailing, spacing: 3) {
                HStack(spacing: 4) {
                    if filament.favorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                    Text(filament.spoolLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }


            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }
}
