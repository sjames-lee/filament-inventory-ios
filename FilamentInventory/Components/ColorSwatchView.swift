import SwiftUI

struct ColorSwatchView: View {
    let hex: String
    var size: CGFloat = 32

    var body: some View {
        Circle()
            .fill(ColorHelpers.color(from: hex))
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(Color(.systemGray3), lineWidth: 1)
            )
    }
}
