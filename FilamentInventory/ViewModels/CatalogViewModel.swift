import SwiftUI
import SwiftData

@Observable
final class CatalogViewModel {
    var searchText: String = ""
    var sortOption: SortOption = .newestFirst

    var selectedMaterials: Set<String> = []
    var selectedBrands: Set<String> = []
    var selectedColorFamilies: Set<String> = []
    var showFavoritesOnly: Bool = false

    var showFilterSheet: Bool = false
    var showAddSheet: Bool = false

    var hasActiveFilters: Bool {
        !filters.isEmpty
    }

    var activeFilterCount: Int {
        filters.activeCount
    }

    var filters: FilterState {
        FilterState(
            materials: selectedMaterials,
            brands: selectedBrands,
            colorFamilies: selectedColorFamilies,
            favoritesOnly: showFavoritesOnly
        )
    }

    func filteredAndSorted(_ filaments: [Filament]) -> [Filament] {
        let filtered = FilamentFilter.apply(to: filaments, search: searchText, filters: filters)
        return sorted(filtered)
    }

    func clearAllFilters() {
        selectedMaterials = []
        selectedBrands = []
        selectedColorFamilies = []
        showFavoritesOnly = false
    }

    func toggleMaterial(_ value: String) { toggle(&selectedMaterials, value) }
    func toggleBrand(_ value: String) { toggle(&selectedBrands, value) }
    func toggleColorFamily(_ value: String) { toggle(&selectedColorFamilies, value) }

    private func toggle(_ set: inout Set<String>, _ value: String) {
        if set.contains(value) { set.remove(value) } else { set.insert(value) }
    }

    private func sorted(_ filaments: [Filament]) -> [Filament] {
        switch sortOption {
        case .nameAsc: return filaments.sorted { $0.displayName.localizedCompare($1.displayName) == .orderedAscending }
        case .nameDesc: return filaments.sorted { $0.displayName.localizedCompare($1.displayName) == .orderedDescending }
        case .brandAsc: return filaments.sorted { $0.brand.localizedCompare($1.brand) == .orderedAscending }
        case .priceAsc: return filaments.sorted { ($0.price ?? .infinity) < ($1.price ?? .infinity) }
        case .priceDesc: return filaments.sorted { ($0.price ?? 0) > ($1.price ?? 0) }
        case .quantityDesc: return filaments.sorted { $0.quantity > $1.quantity }
        case .quantityAsc: return filaments.sorted { $0.quantity < $1.quantity }
        case .newestFirst: return filaments.sorted { $0.createdAt > $1.createdAt }
        case .oldestFirst: return filaments.sorted { $0.createdAt < $1.createdAt }
        }
    }
}
