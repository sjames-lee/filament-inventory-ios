import SwiftUI
import SwiftData

struct FilamentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var filament: Filament
    @State private var showDeleteConfirmation = false
    @State private var showEditSheet = false

    private var isLight: Bool { ColorHelpers.isLight(filament.colorHex) }
    private var heroTextColor: Color { isLight ? Color(.darkGray) : .white }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                colorHero
                contentBody
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                favoriteButton
                Button { showEditSheet = true } label: {
                    Image(systemName: "pencil")
                }
                Button { showDeleteConfirmation = true } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .confirmationDialog("Delete Filament", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { deleteFilament() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(filament.displayName)\"? This action cannot be undone.")
        }
        .sheet(isPresented: $showEditSheet) {
            FilamentFormView(filament: filament)
        }
    }

    // MARK: - Color Hero

    private var colorHero: some View {
        ZStack {
            ColorHelpers.color(from: filament.colorHex)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .overlay(
                    Rectangle()
                        .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                )

            VStack(spacing: 4) {
                Text(filament.colorName)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(heroTextColor)

                Text(filament.colorHex.uppercased())
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(heroTextColor.opacity(0.7))
            }
        }
    }

    // MARK: - Content

    private var contentBody: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title section
            VStack(alignment: .leading, spacing: 8) {
                MaterialBadgeView(material: filament.material)

                Text(filament.displayName)
                    .font(.title2.weight(.bold))
            }

            Divider()

            // Detail sections in a 2-column grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 16) {
                physicalSection
                temperatureSection
                colorSection
                purchaseSection
            }

            // Tags
            if !filament.tagList.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags")
                        .font(.subheadline.weight(.semibold))
                    TagPillsView(tags: filament.tagList)
                }
            }

            // Notes
            if let notes = filament.notes, !notes.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.subheadline.weight(.semibold))
                    Text(notes)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }

    // MARK: - Detail Sections

    private var physicalSection: some View {
        DetailSectionView(title: "Physical Properties") {
            DetailRow(label: "Diameter", value: "\(filament.diameter) mm")
            DetailRow(label: "Spool Weight", value: "\(Int(filament.spoolWeight)) g")
            DetailRow(label: "Quantity", value: filament.spoolLabel)
            if let w = filament.weightRemaining {
                DetailRow(label: "Remaining", value: "\(Int(w)) g")
            }
        }
    }

    private var temperatureSection: some View {
        DetailSectionView(title: "Temperature") {
            DetailRow(label: "Print Temp", value: filament.printTempRange ?? "--")
            DetailRow(label: "Bed Temp", value: filament.bedTempRange ?? "--")
        }
    }

    private var colorSection: some View {
        DetailSectionView(title: "Color") {
            HStack(spacing: 8) {
                ColorSwatchView(hex: filament.colorHex, size: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(filament.colorName)
                        .font(.subheadline)
                    Text(filament.colorFamily)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Text(filament.colorHex.uppercased())
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }

    private var purchaseSection: some View {
        DetailSectionView(title: "Purchase Info") {
            DetailRow(label: "Price", value: filament.formattedPrice)
            if let urlString = filament.purchaseUrl, let url = URL(string: urlString) {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Text("Purchase Link")
                            .font(.caption)
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private var favoriteButton: some View {
        Button {
            filament.favorite.toggle()
            filament.updatedAt = Date()
        } label: {
            Image(systemName: filament.favorite ? "star.fill" : "star")
                .foregroundStyle(filament.favorite ? .yellow : .secondary)
        }
    }

    private func deleteFilament() {
        modelContext.delete(filament)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Supporting Views

struct DetailSectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))

            VStack(alignment: .leading, spacing: 6) {
                content
            }
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
        }
    }
}
