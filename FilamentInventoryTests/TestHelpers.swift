import Foundation
@testable import FilamentInventory

enum TestHelpers {
    static func makeFilament(
        name: String = "Test Filament",
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
        status: String = "in_stock",
        favorite: Bool = false,
        createdAt: Date? = nil
    ) -> Filament {
        let f = Filament(
            name: name,
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
            status: status,
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
                name: "Matte Black PLA",
                brand: "Hatchbox",
                material: "PLA",
                colorName: "Matte Black",
                colorFamily: "Black",
                quantity: 3,
                price: 24.99,
                tags: "matte,basic",
                status: "in_stock",
                favorite: true,
                createdAt: now.addingTimeInterval(-400)
            ),
            makeFilament(
                name: "Ocean Blue PETG",
                brand: "Polymaker",
                material: "PETG",
                colorName: "Ocean Blue",
                colorFamily: "Blue",
                quantity: 1,
                price: 29.99,
                tags: "translucent",
                status: "low",
                createdAt: now.addingTimeInterval(-300)
            ),
            makeFilament(
                name: "Fire Red ABS",
                brand: "eSUN",
                material: "ABS",
                colorName: "Fire Red",
                colorFamily: "Red",
                quantity: 2,
                price: 19.99,
                tags: "heat-resistant",
                status: "in_stock",
                createdAt: now.addingTimeInterval(-200)
            ),
            makeFilament(
                name: "Snow White PLA",
                brand: "Hatchbox",
                material: "PLA",
                colorName: "Snow White",
                colorFamily: "White",
                quantity: 0,
                price: 22.99,
                tags: "basic",
                status: "empty",
                createdAt: now.addingTimeInterval(-100)
            ),
            makeFilament(
                name: "Flex Green TPU",
                brand: "Polymaker",
                material: "TPU",
                colorName: "Neon Green",
                colorFamily: "Green",
                quantity: 1,
                price: nil,
                tags: "flexible,special",
                status: "in_stock",
                favorite: true,
                createdAt: now
            ),
        ]
    }
}
