import Foundation
@testable import FilamentInventory

enum TestHelpers {
    static func makeFilament(
        brand: String = "Hatchbox",
        material: String = "PLA",
        colorName: String = "Red",
        colorHex: String = "#FF0000",
        colorFamily: String = "Red",
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
        favorite: Bool = false,
        createdAt: Date? = nil
    ) -> Filament {
        let f = Filament(
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
            favorite: favorite
        )
        if let createdAt {
            f.createdAt = createdAt
        }
        return f
    }

    /// A standard set of filaments for tests that need variety.
    static func sampleFilaments() -> [Filament] {
        let now = Date()
        return [
            makeFilament(
                brand: "Hatchbox",
                material: "PLA",
                colorName: "Matte Black",
                colorFamily: "Black",
                quantity: 3,
                price: 24.99,
                tags: "matte,basic",
                favorite: true,
                createdAt: now.addingTimeInterval(-400)
            ),
            makeFilament(
                brand: "Polymaker",
                material: "PETG",
                colorName: "Ocean Blue",
                colorFamily: "Blue",
                quantity: 1,
                price: 29.99,
                tags: "translucent",
                createdAt: now.addingTimeInterval(-300)
            ),
            makeFilament(
                brand: "eSUN",
                material: "ABS",
                colorName: "Fire Red",
                colorFamily: "Red",
                quantity: 2,
                price: 19.99,
                tags: "heat-resistant",
                createdAt: now.addingTimeInterval(-200)
            ),
            makeFilament(
                brand: "Hatchbox",
                material: "PLA",
                colorName: "Snow White",
                colorFamily: "White",
                quantity: 0,
                price: 22.99,
                tags: "basic",
                createdAt: now.addingTimeInterval(-100)
            ),
            makeFilament(
                brand: "Polymaker",
                material: "TPU",
                colorName: "Neon Green",
                colorFamily: "Green",
                quantity: 1,
                price: nil,
                tags: "flexible,special",
                favorite: true,
                createdAt: now
            ),
        ]
    }
}
