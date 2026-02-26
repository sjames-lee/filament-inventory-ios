import Foundation

@Observable
final class DashboardViewModel {
    func totalSpools(_ filaments: [Filament]) -> Int {
        filaments.reduce(0) { $0 + $1.quantity }
    }

    func estimatedValue(_ filaments: [Filament]) -> Double {
        filaments.reduce(0) { $0 + ($1.price ?? 0) * Double($1.quantity) }
    }

    func uniqueMaterials(_ filaments: [Filament]) -> Int {
        Set(filaments.map(\.material)).count
    }

    func uniqueBrands(_ filaments: [Filament]) -> Int {
        Set(filaments.map(\.brand)).count
    }

    func countByStatus(_ filaments: [Filament], status: FilamentStatus) -> Int {
        filaments.filter { $0.status == status.rawValue }.count
    }

    func materialCounts(_ filaments: [Filament]) -> [(label: String, count: Int)] {
        var counts: [String: Int] = [:]
        for f in filaments { counts[f.material, default: 0] += f.quantity }
        return counts.sorted { $0.value > $1.value }
            .map { (label: $0.key, count: $0.value) }
    }

    func brandCounts(_ filaments: [Filament]) -> [(label: String, count: Int)] {
        var counts: [String: Int] = [:]
        for f in filaments { counts[f.brand, default: 0] += f.quantity }
        return counts.sorted { $0.value > $1.value }
            .map { (label: $0.key, count: $0.value) }
    }

    func needsAttention(_ filaments: [Filament]) -> [Filament] {
        filaments
            .filter { $0.status == "low" || $0.status == "empty" }
            .sorted { statusOrder($0.status) < statusOrder($1.status) }
    }

    private func statusOrder(_ status: String) -> Int {
        switch status {
        case "low": return 0
        case "empty": return 1
        default: return 2
        }
    }
}
