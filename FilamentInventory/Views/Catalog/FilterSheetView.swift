import SwiftUI

struct FilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: CatalogViewModel

    var body: some View {
        NavigationStack {
            List {
                favoritesSection
                materialSection
                brandSection
                colorFamilySection
                statusSection
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.hasActiveFilters {
                        Button("Clear All") {
                            viewModel.clearAllFilters()
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var favoritesSection: some View {
        Section {
            Toggle("Favorites Only", isOn: $viewModel.showFavoritesOnly)
        }
    }

    private var materialSection: some View {
        Section("Material") {
            ForEach(Constants.materials, id: \.self) { material in
                Button {
                    viewModel.toggleMaterial(material)
                } label: {
                    HStack {
                        MaterialBadgeView(material: material)
                        Spacer()
                        if viewModel.selectedMaterials.contains(material) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
        }
    }

    private var brandSection: some View {
        Section("Brand") {
            ForEach(Constants.brands, id: \.self) { brand in
                Button {
                    viewModel.toggleBrand(brand)
                } label: {
                    HStack {
                        Text(brand)
                        Spacer()
                        if viewModel.selectedBrands.contains(brand) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
        }
    }

    private var colorFamilySection: some View {
        Section("Color Family") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                ForEach(Constants.colorFamilies, id: \.self) { family in
                    let hex = Constants.colorFamilyHex[family] ?? "#888888"
                    let isSelected = viewModel.selectedColorFamilies.contains(family)

                    Button {
                        viewModel.toggleColorFamily(family)
                    } label: {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(ColorHelpers.color(from: hex))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(isSelected ? Color.blue : Color(.systemGray3), lineWidth: isSelected ? 2.5 : 1)
                                )
                                .scaleEffect(isSelected ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.15), value: isSelected)

                            Text(family)
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var statusSection: some View {
        Section("Status") {
            ForEach(FilamentStatus.allCases) { status in
                Button {
                    viewModel.toggleStatus(status.rawValue)
                } label: {
                    HStack {
                        StockIndicatorView(status: status)
                        Spacer()
                        if viewModel.selectedStatuses.contains(status.rawValue) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
        }
    }
}
