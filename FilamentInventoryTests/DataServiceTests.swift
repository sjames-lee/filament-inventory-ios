import XCTest
@testable import FilamentInventory

final class DataServiceTests: XCTestCase {

    // MARK: - Round-trip

    func testExportImportRoundTrip() throws {
        let original = TestHelpers.makeFilament(
            brand: "Hatchbox",
            material: "PLA",
            colorName: "Red",
            colorHex: "#FF0000",
            colorFamily: "Red",
            diameter: 1.75,
            spoolWeight: 1000,
            quantity: 3,
            weightRemaining: 750.5,
            printTempMin: 190,
            printTempMax: 220,
            bedTempMin: 50,
            bedTempMax: 60,
            price: 24.99,
            purchaseUrl: "https://example.com",
            notes: "Great filament",
            tags: "matte,basic",
            favorite: true
        )

        let data = try DataService.exportJSON([original])
        let imported = try DataService.importJSON(data)

        XCTAssertEqual(imported.count, 1)
        let result = imported[0]

        XCTAssertEqual(result.brand, original.brand)
        XCTAssertEqual(result.material, original.material)
        XCTAssertEqual(result.colorName, original.colorName)
        XCTAssertEqual(result.colorHex, original.colorHex)
        XCTAssertEqual(result.colorFamily, original.colorFamily)
        XCTAssertEqual(result.diameter, original.diameter)
        XCTAssertEqual(result.spoolWeight, original.spoolWeight)
        XCTAssertEqual(result.quantity, original.quantity)
        XCTAssertEqual(result.weightRemaining, original.weightRemaining)
        XCTAssertEqual(result.printTempMin, original.printTempMin)
        XCTAssertEqual(result.printTempMax, original.printTempMax)
        XCTAssertEqual(result.bedTempMin, original.bedTempMin)
        XCTAssertEqual(result.bedTempMax, original.bedTempMax)
        XCTAssertEqual(result.price, original.price)
        XCTAssertEqual(result.purchaseUrl, original.purchaseUrl)
        XCTAssertEqual(result.notes, original.notes)
        XCTAssertEqual(result.tags, original.tags)
        XCTAssertEqual(result.favorite, original.favorite)
    }

    func testRoundTripMultipleFilaments() throws {
        let filaments = TestHelpers.sampleFilaments()

        let data = try DataService.exportJSON(filaments)
        let imported = try DataService.importJSON(data)

        XCTAssertEqual(imported.count, filaments.count)
        for (original, result) in zip(filaments, imported) {
            XCTAssertEqual(result.brand, original.brand)
            XCTAssertEqual(result.material, original.material)
            XCTAssertEqual(result.displayName, original.displayName)
        }
    }

    // MARK: - New UUIDs on import

    func testImportCreatesNewUUIDs() throws {
        let original = TestHelpers.makeFilament()
        let data = try DataService.exportJSON([original])
        let imported = try DataService.importJSON(data)

        XCTAssertEqual(imported.count, 1)
        XCTAssertNotEqual(imported[0].id, original.id)
    }

    func testImportCreatesFreshTimestamps() throws {
        let original = TestHelpers.makeFilament()
        // Backdate the original
        original.createdAt = Date.distantPast
        original.updatedAt = Date.distantPast

        let data = try DataService.exportJSON([original])
        let imported = try DataService.importJSON(data)

        XCTAssertEqual(imported.count, 1)
        // Imported filament should have recent timestamps, not distant past
        XCTAssertGreaterThan(imported[0].createdAt, Date.distantPast)
        XCTAssertGreaterThan(imported[0].updatedAt, Date.distantPast)
    }

    // MARK: - Empty array

    func testExportEmptyArray() throws {
        let data = try DataService.exportJSON([])
        let json = String(data: data, encoding: .utf8)
        XCTAssertNotNil(json)
        XCTAssertTrue(json!.contains("[]") || json!.contains("[ ]") || json!.trimmingCharacters(in: .whitespacesAndNewlines) == "[\n\n]")

        let imported = try DataService.importJSON(data)
        XCTAssertTrue(imported.isEmpty)
    }

    // MARK: - Nil optionals

    func testRoundTripWithNilOptionals() throws {
        let original = TestHelpers.makeFilament(
            weightRemaining: nil,
            printTempMin: nil,
            printTempMax: nil,
            bedTempMin: nil,
            bedTempMax: nil,
            price: nil,
            purchaseUrl: nil,
            notes: nil
        )

        let data = try DataService.exportJSON([original])
        let imported = try DataService.importJSON(data)

        XCTAssertEqual(imported.count, 1)
        let result = imported[0]
        XCTAssertNil(result.weightRemaining)
        XCTAssertNil(result.printTempMin)
        XCTAssertNil(result.printTempMax)
        XCTAssertNil(result.bedTempMin)
        XCTAssertNil(result.bedTempMax)
        XCTAssertNil(result.price)
        XCTAssertNil(result.purchaseUrl)
        XCTAssertNil(result.notes)
    }

    // MARK: - Malformed JSON

    func testImportMalformedJSONThrows() {
        let badData = "not valid json".data(using: .utf8)!
        XCTAssertThrowsError(try DataService.importJSON(badData))
    }

    func testImportWrongStructureThrows() {
        let wrongJSON = """
        {"name": "not an array"}
        """.data(using: .utf8)!
        XCTAssertThrowsError(try DataService.importJSON(wrongJSON))
    }

    // MARK: - Valid JSON output

    func testExportProducesValidJSON() throws {
        let filament = TestHelpers.makeFilament(price: 19.99)
        let data = try DataService.exportJSON([filament])

        let parsed = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed?.count, 1)
        XCTAssertEqual(parsed?[0]["brand"] as? String, "Hatchbox")
        XCTAssertEqual(parsed?[0]["price"] as? Double, 19.99)
    }
}
