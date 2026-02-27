import Foundation

struct CodableFilament: Codable {
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

    init(
        brand: String,
        material: String,
        colorName: String,
        colorHex: String,
        colorFamily: String,
        diameter: Double,
        spoolWeight: Double,
        quantity: Int,
        weightRemaining: Double?,
        printTempMin: Int?,
        printTempMax: Int?,
        bedTempMin: Int?,
        bedTempMax: Int?,
        price: Double?,
        purchaseUrl: String?,
        notes: String?,
        tags: String,
        imageUrl: String?,
        favorite: Bool
    ) {
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
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        brand = try container.decode(String.self, forKey: .brand)
        material = try container.decode(String.self, forKey: .material)
        colorName = try container.decodeIfPresent(String.self, forKey: .colorName) ?? ""
        colorHex = try container.decode(String.self, forKey: .colorHex)
        colorFamily = try container.decode(String.self, forKey: .colorFamily)
        diameter = try container.decodeIfPresent(Double.self, forKey: .diameter) ?? 1.75
        spoolWeight = try container.decodeIfPresent(Double.self, forKey: .spoolWeight) ?? 1000
        quantity = try container.decodeIfPresent(Int.self, forKey: .quantity) ?? 1
        weightRemaining = try container.decodeIfPresent(Double.self, forKey: .weightRemaining)
        printTempMin = try container.decodeIfPresent(Int.self, forKey: .printTempMin)
        printTempMax = try container.decodeIfPresent(Int.self, forKey: .printTempMax)
        bedTempMin = try container.decodeIfPresent(Int.self, forKey: .bedTempMin)
        bedTempMax = try container.decodeIfPresent(Int.self, forKey: .bedTempMax)
        price = try container.decodeIfPresent(Double.self, forKey: .price)
        purchaseUrl = try container.decodeIfPresent(String.self, forKey: .purchaseUrl)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        tags = try container.decodeIfPresent(String.self, forKey: .tags) ?? ""
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        favorite = try container.decodeIfPresent(Bool.self, forKey: .favorite) ?? false
    }
}

extension Filament {
    func toCodable() -> CodableFilament {
        CodableFilament(
            brand: brand,
            material: material,
            colorName: colorName,
            colorHex: colorHex,
            colorFamily: colorFamily,
            diameter: diameter,
            spoolWeight: spoolWeight,
            quantity: quantity,
            weightRemaining: weightRemaining,
            printTempMin: printTempMin,
            printTempMax: printTempMax,
            bedTempMin: bedTempMin,
            bedTempMax: bedTempMax,
            price: price,
            purchaseUrl: purchaseUrl,
            notes: notes,
            tags: tags,
            imageUrl: imageUrl,
            favorite: favorite
        )
    }
}

extension CodableFilament {
    func toFilament() -> Filament {
        Filament(
            brand: brand,
            material: material,
            colorName: colorName,
            colorHex: colorHex,
            colorFamily: colorFamily,
            diameter: diameter,
            spoolWeight: spoolWeight,
            quantity: quantity,
            weightRemaining: weightRemaining,
            printTempMin: printTempMin,
            printTempMax: printTempMax,
            bedTempMin: bedTempMin,
            bedTempMax: bedTempMax,
            price: price,
            purchaseUrl: purchaseUrl,
            notes: notes,
            tags: tags,
            imageUrl: imageUrl,
            favorite: favorite
        )
    }
}
