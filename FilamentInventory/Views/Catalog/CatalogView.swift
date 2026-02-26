import SwiftUI
import SwiftData

struct CatalogView: View {
    @Query(sort: \Filament.createdAt, order: .reverse) private var allFilaments: [Filament]
    @State private var viewModel = CatalogViewModel()

    private var filaments: [Filament] {
        viewModel.filteredAndSorted(allFilaments)
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if allFilaments.isEmpty {
                    emptyState
                } else if filaments.isEmpty {
                    noResultsState
                } else {
                    scrollContent
                }
            }
            .navigationTitle("Catalog")
            .searchable(text: $viewModel.searchText, prompt: "Search filaments")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    filterButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    sortMenu
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showFilterSheet) {
                FilterSheetView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showAddSheet) {
                FilamentFormView(filament: nil)
            }
        }
    }

    private var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("\(filaments.count) filament\(filaments.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filaments, id: \.id) { filament in
                        NavigationLink(value: filament.id) {
                            FilamentCard(filament: filament)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationDestination(for: UUID.self) { id in
            if let filament = allFilaments.first(where: { $0.id == id }) {
                FilamentDetailView(filament: filament)
            }
        }
    }

    private var filterButton: some View {
        Button {
            viewModel.showFilterSheet = true
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "line.3.horizontal.decrease.circle")

                if viewModel.hasActiveFilters {
                    Text("\(viewModel.activeFilterCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(3)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .offset(x: 6, y: -6)
                }
            }
        }
    }

    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases) { option in
                Button {
                    viewModel.sortOption = option
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if viewModel.sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Filaments", systemImage: "cube")
        } description: {
            Text("Add your first filament to get started.")
        } actions: {
            Button("Add Filament") {
                viewModel.showAddSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var noResultsState: some View {
        ContentUnavailableView {
            Label("No Results", systemImage: "magnifyingglass")
        } description: {
            Text("Try adjusting your search or filters.")
        } actions: {
            if viewModel.hasActiveFilters {
                Button("Clear Filters") {
                    viewModel.clearAllFilters()
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
