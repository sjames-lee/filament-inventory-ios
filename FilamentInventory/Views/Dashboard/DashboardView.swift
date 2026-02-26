import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var filaments: [Filament]
    @State private var viewModel = DashboardViewModel()

    private let statColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if filaments.isEmpty {
                        emptyState
                    } else {
                        statsGrid
                        statusOverview
                        needsAttentionCard
                        byMaterialCard
                        byBrandCard
                        colorPaletteCard
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dashboard")
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: statColumns, spacing: 12) {
            StatCardView(
                label: "Filaments",
                value: "\(filaments.count)"
            )
            StatCardView(
                label: "Total Spools",
                value: "\(viewModel.totalSpools(filaments))"
            )
            StatCardView(
                label: "Est. Value",
                value: viewModel.estimatedValue(filaments)
                    .formatted(.currency(code: "USD").precision(.fractionLength(0)))
            )
            StatCardView(
                label: "Materials",
                value: "\(viewModel.uniqueMaterials(filaments))",
                subtitle: "\(viewModel.uniqueBrands(filaments)) brands"
            )
        }
    }

    // MARK: - Status Overview

    private var statusOverview: some View {
        HStack(spacing: 12) {
            ForEach(FilamentStatus.allCases) { status in
                VStack(spacing: 4) {
                    Text("\(viewModel.countByStatus(filaments, status: status))")
                        .font(.title3.weight(.bold))
                    HStack(spacing: 4) {
                        Circle()
                            .fill(status.color)
                            .frame(width: 8, height: 8)
                        Text(status.label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
    }

    // MARK: - Needs Attention

    private var needsAttentionCard: some View {
        let attention = viewModel.needsAttention(filaments)
        return Group {
            if !attention.isEmpty {
                DashboardCard(title: "Needs Attention") {
                    NeedsAttentionListView(filaments: attention)
                }
            }
        }
    }

    // MARK: - By Material

    private var byMaterialCard: some View {
        let data = viewModel.materialCounts(filaments)
        return Group {
            if !data.isEmpty {
                DashboardCard(title: "By Material") {
                    BarChartView(items: data, barColor: Color(.darkGray))
                }
            }
        }
    }

    // MARK: - By Brand

    private var byBrandCard: some View {
        let data = viewModel.brandCounts(filaments)
        return Group {
            if !data.isEmpty {
                DashboardCard(title: "By Brand") {
                    BarChartView(items: data, barColor: .blue)
                }
            }
        }
    }

    // MARK: - Color Palette

    private var colorPaletteCard: some View {
        DashboardCard(title: "Color Palette") {
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(36), spacing: 8), count: 8), spacing: 8) {
                ForEach(filaments, id: \.id) { filament in
                    ColorSwatchView(hex: filament.colorHex, size: 32)
                }
            }
        }
    }

    // MARK: - Empty

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Data", systemImage: "chart.bar")
        } description: {
            Text("Add filaments to see dashboard analytics.")
        }
    }
}

// MARK: - Dashboard Card

struct DashboardCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
