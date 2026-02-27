import SwiftData
import Foundation

@Model
final class Filament {
    var id: UUID
    var brand: String
    var material: String

    var colorName: String
    var colorHex: String
    var colorFamily: String

    var diameter: Double
    var spoolWeight: Double
    var quantity: Int
    var weightRemaining: Double?

    var printTempMin: Int?
    var printTempMax: Int?
    var bedTempMin: Int?
    var bedTempMax: Int?

    var price: Double?
    var purchaseUrl: String?

    var notes: String?
    var tags: String
    var imageUrl: String?
    var favorite: Bool

    var createdAt: Date
    var updatedAt: Date

    var displayName: String {
        colorName.isEmpty ? "\(brand) \(material)" : "\(brand) \(material) - \(colorName)"
    }

    init(
        brand: String,
        material: String,
        colorName: String,
        colorHex: String,
        colorFamily: String,
        diameter: Double = 1.75,
        spoolWeight: Double = 1000,
        quantity: Int = 1,
        weightRemaining: Double? = nil,
        printTempMin: Int? = nil,
        printTempMax: Int? = nil,
        bedTempMin: Int? = nil,
        bedTempMax: Int? = nil,
        price: Double? = nil,
        purchaseUrl: String? = nil,
        notes: String? = nil,
        tags: String = "",
        imageUrl: String? = nil,
        favorite: Bool = false
    ) {
        self.id = UUID()
        self.brand = brand
        self.material = material
        self.colorName = colorName
        self.colorHex = colorHex
        self.colorFamily = colorFamily
        self.diameter = diameter
        self.spoolWeight = spoolWeight
        self.quantity = quantity
        self.weightRemaining = weightRemaining
        self.printTempMin = printTempMin
        self.printTempMax = printTempMax
        self.bedTempMin = bedTempMin
        self.bedTempMax = bedTempMax
        self.price = price
        self.purchaseUrl = purchaseUrl
        self.notes = notes
        self.tags = tags
        self.imageUrl = imageUrl
        self.favorite = favorite
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var tagList: [String] {
        tags.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    var formattedPrice: String {
        guard let price else { return "--" }
        return String(format: "$%.2f", price)
    }

    var spoolLabel: String {
        "\(quantity) \(quantity == 1 ? "spool" : "spools")"
    }

    var printTempRange: String? {
        guard let min = printTempMin, let max = printTempMax else { return nil }
        return "\(min) - \(max) °C"
    }

    var bedTempRange: String? {
        guard let min = bedTempMin, let max = bedTempMax else { return nil }
        return "\(min) - \(max) °C"
    }

    func matchesIdentity(of other: Filament) -> Bool {
        brand == other.brand
            && material == other.material
            && colorName == other.colorName
            && colorHex == other.colorHex
            && diameter == other.diameter
            && spoolWeight == other.spoolWeight
    }
}
