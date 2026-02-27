import SwiftUI

struct MaterialBadgeView: View {
    let material: String

    private var colors: (bg: Color, fg: Color) {
        Constants.materialColors[material] ?? (Color(.systemGray5), .secondary)
    }

    var body: some View {
        Text(material)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(colors.bg)
            .foregroundStyle(colors.fg)
            .clipShape(Capsule())
    }
}
