import SwiftUI

struct BarChartView: View {
    let items: [(label: String, count: Int)]
    let barColor: Color

    private var maxCount: Int {
        items.map(\.count).max() ?? 1
    }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(items, id: \.label) { item in
                HStack(spacing: 8) {
                    Text(item.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 90, alignment: .leading)
                        .lineLimit(1)

                    GeometryReader { geo in
                        let fraction = maxCount > 0 ? CGFloat(item.count) / CGFloat(maxCount) : 0
                        RoundedRectangle(cornerRadius: 3)
                            .fill(barColor)
                            .frame(width: max(geo.size.width * fraction, 4))
                    }
                    .frame(height: 8)

                    Text("\(item.count)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 30, alignment: .trailing)
                }
            }
        }
    }
}
