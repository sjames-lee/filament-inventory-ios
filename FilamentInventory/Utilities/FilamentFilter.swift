import SwiftData
import Foundation

struct FilterState: Equatable {
    var materials: Set<String> = []
    var brands: Set<String> = []
    var colorFamilies: Set<String> = []
    var statuses: Set<String> = []
    var favoritesOnly: Bool = false

    var isEmpty: Bool {
        materials.isEmpty && brands.isEmpty && colorFamilies.isEmpty &&
        statuses.isEmpty && !favoritesOnly
    }

    var activeCount: Int {
        materials.count + brands.count + colorFamilies.count +
        statuses.count + (favoritesOnly ? 1 : 0)
    }
}

enum FilamentFilter {
    static func apply(
        to filaments: [Filament],
        search: String,
        filters: FilterState
    ) -> [Filament] {
        var result = filaments

        // Search: OR across text fields
        if !search.isEmpty {
            let query = search.lowercased()
            result = result.filter { f in
                f.name.localizedCaseInsensitiveContains(query) ||
                f.brand.localizedCaseInsensitiveContains(query) ||
                f.colorName.localizedCaseInsensitiveContains(query) ||
                f.material.localizedCaseInsensitiveContains(query) ||
                f.tags.localizedCaseInsensitiveContains(query)
            }
        }

        // Material filter
        if !filters.materials.isEmpty {
            result = result.filter { filters.materials.contains($0.material) }
        }

        // Brand filter
        if !filters.brands.isEmpty {
            result = result.filter { filters.brands.contains($0.brand) }
        }

        // Color family filter
        if !filters.colorFamilies.isEmpty {
            result = result.filter { filters.colorFamilies.contains($0.colorFamily) }
        }

        // Status filter
        if !filters.statuses.isEmpty {
            result = result.filter { filters.statuses.contains($0.status) }
        }

        // Favorites
        if filters.favoritesOnly {
            result = result.filter { $0.favorite }
        }

        return result
    }
}
