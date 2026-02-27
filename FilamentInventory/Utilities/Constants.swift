import SwiftUI

enum FilamentStatus: String, CaseIterable, Identifiable {
    case inStock = "in_stock"
    case low = "low"
    case empty = "empty"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .inStock: return "In Stock"
        case .low: return "Low Stock"
        case .empty: return "Empty"
        }
    }

    var color: Color {
        switch self {
        case .inStock: return .green
        case .low: return Color(.systemOrange)
        case .empty: return .red
        }
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case nameAsc = "Name (A-Z)"
    case nameDesc = "Name (Z-A)"
    case brandAsc = "Brand (A-Z)"
    case priceAsc = "Price (Low)"
    case priceDesc = "Price (High)"
    case quantityDesc = "Quantity (Most)"
    case quantityAsc = "Quantity (Least)"
    case newestFirst = "Newest First"
    case oldestFirst = "Oldest First"

    var id: String { rawValue }

    var descriptor: SortDescriptor<Filament> {
        switch self {
        case .nameAsc: return SortDescriptor(\.name, order: .forward)
        case .nameDesc: return SortDescriptor(\.name, order: .reverse)
        case .brandAsc: return SortDescriptor(\.brand, order: .forward)
        case .priceAsc: return SortDescriptor(\.price, order: .forward)
        case .priceDesc: return SortDescriptor(\.price, order: .reverse)
        case .quantityDesc: return SortDescriptor(\.quantity, order: .reverse)
        case .quantityAsc: return SortDescriptor(\.quantity, order: .forward)
        case .newestFirst: return SortDescriptor(\.createdAt, order: .reverse)
        case .oldestFirst: return SortDescriptor(\.createdAt, order: .forward)
        }
    }
}

enum Constants {
    static let materials: [String] = [
        "PLA", "PLA Basic", "PLA Matte", "PLA+", "PETG", "ABS", "ASA", "TPU", "Nylon",
        "PC", "PVA", "HIPS", "Wood", "Carbon Fiber", "Silk",
        "Marble", "Glow-in-Dark", "Other"
    ]

    static let brands: [String] = [
        "Bambu Lab", "Polymaker", "eSUN", "Prusament",
        "Overture", "Sunlu", "Other"
    ]

    static let colorFamilies: [String] = [
        "Black", "White", "Gray", "Red", "Orange", "Yellow",
        "Green", "Blue", "Purple", "Pink", "Brown", "Gold",
        "Silver", "Clear", "Multi"
    ]

    static let colorFamilyHex: [String: String] = [
        "Black": "#1a1a1a", "White": "#f5f5f5", "Gray": "#9ca3af",
        "Red": "#dc2626", "Orange": "#f97316", "Yellow": "#eab308",
        "Green": "#16a34a", "Blue": "#3b82f6", "Purple": "#7c3aed",
        "Pink": "#ec4899", "Brown": "#92400e", "Gold": "#d4a843",
        "Silver": "#c0c0c0", "Clear": "#e2e8f0", "Multi": "#888888"
    ]

    static let materialColors: [String: (bg: Color, fg: Color)] = [
        "PLA": (Color.blue.opacity(0.15), Color.blue),
        "PLA+": (Color.blue.opacity(0.25), Color(red: 0.1, green: 0.2, blue: 0.7)),
        "PETG": (Color.green.opacity(0.15), Color(red: 0.0, green: 0.5, blue: 0.3)),
        "ABS": (Color.orange.opacity(0.15), Color.orange),
        "ASA": (Color.orange.opacity(0.25), Color(red: 0.6, green: 0.3, blue: 0.0)),
        "TPU": (Color.purple.opacity(0.15), Color.purple),
        "Nylon": (Color(.systemGray5), Color.secondary),
        "PC": (Color.cyan.opacity(0.15), Color.cyan),
        "PVA": (Color.green.opacity(0.1), Color(red: 0.3, green: 0.6, blue: 0.1)),
        "HIPS": (Color.yellow.opacity(0.15), Color(red: 0.5, green: 0.4, blue: 0.0)),
        "Wood": (Color(red: 1, green: 0.85, blue: 0.6).opacity(0.3), Color(red: 0.5, green: 0.3, blue: 0.0)),
        "Carbon Fiber": (Color(.systemGray4), Color.primary),
        "Silk": (Color.pink.opacity(0.15), Color.pink),
        "Marble": (Color(red: 0.95, green: 0.93, blue: 0.9), Color(red: 0.4, green: 0.35, blue: 0.3)),
        "Glow-in-Dark": (Color.green.opacity(0.15), Color(red: 0.0, green: 0.5, blue: 0.0)),
        "Other": (Color(.systemGray5), Color.secondary)
    ]
}
