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
