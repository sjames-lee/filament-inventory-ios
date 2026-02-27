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

    // MARK: - Identity Matching

    func testMatchesIdentitySameFields() {
        let a = TestHelpers.makeFilament()
        let b = TestHelpers.makeFilament()
        XCTAssertTrue(a.matchesIdentity(of: b))
    }

    func testMatchesIdentityDifferentBrand() {
        let a = TestHelpers.makeFilament(brand: "Hatchbox")
        let b = TestHelpers.makeFilament(brand: "Prusament")
        XCTAssertFalse(a.matchesIdentity(of: b))
    }

    func testMatchesIdentityDifferentMaterial() {
        let a = TestHelpers.makeFilament(material: "PLA")
        let b = TestHelpers.makeFilament(material: "PETG")
        XCTAssertFalse(a.matchesIdentity(of: b))
    }

    func testMatchesIdentityDifferentColorName() {
        let a = TestHelpers.makeFilament(colorName: "Red")
        let b = TestHelpers.makeFilament(colorName: "Blue")
        XCTAssertFalse(a.matchesIdentity(of: b))
    }

    func testMatchesIdentityDifferentColorHex() {
        let a = TestHelpers.makeFilament(colorHex: "#FF0000")
        let b = TestHelpers.makeFilament(colorHex: "#0000FF")
        XCTAssertFalse(a.matchesIdentity(of: b))
    }

    func testMatchesIdentityDifferentDiameter() {
        let a = TestHelpers.makeFilament(diameter: 1.75)
        let b = TestHelpers.makeFilament(diameter: 2.85)
        XCTAssertFalse(a.matchesIdentity(of: b))
    }

    func testMatchesIdentityDifferentSpoolWeight() {
        let a = TestHelpers.makeFilament(spoolWeight: 1000)
        let b = TestHelpers.makeFilament(spoolWeight: 500)
        XCTAssertFalse(a.matchesIdentity(of: b))
    }

    func testMatchesIdentityIgnoresQuantityAndPrice() {
        let a = TestHelpers.makeFilament(quantity: 1, price: 19.99)
        let b = TestHelpers.makeFilament(quantity: 5, price: 29.99)
        XCTAssertTrue(a.matchesIdentity(of: b))
    }

    // MARK: - Import Analysis

    func testAnalyzeImportNoDuplicates() {
        let existing = [TestHelpers.makeFilament(brand: "Hatchbox", colorName: "Red")]
        let imported = [TestHelpers.makeFilament(brand: "Prusament", colorName: "Blue")]

        let analysis = DataService.analyzeImport(imported, existing: existing)
        XCTAssertEqual(analysis.newFilaments.count, 1)
        XCTAssertEqual(analysis.duplicates.count, 0)
    }

    func testAnalyzeImportAllDuplicates() {
        let existing = [TestHelpers.makeFilament(brand: "Hatchbox", colorName: "Red")]
        let imported = [TestHelpers.makeFilament(brand: "Hatchbox", colorName: "Red")]

        let analysis = DataService.analyzeImport(imported, existing: existing)
        XCTAssertEqual(analysis.newFilaments.count, 0)
        XCTAssertEqual(analysis.duplicates.count, 1)
    }

    func testAnalyzeImportMixed() {
        let existing = [TestHelpers.makeFilament(brand: "Hatchbox", colorName: "Red")]
        let imported = [
            TestHelpers.makeFilament(brand: "Hatchbox", colorName: "Red"),
            TestHelpers.makeFilament(brand: "Prusament", colorName: "Blue"),
        ]

        let analysis = DataService.analyzeImport(imported, existing: existing)
        XCTAssertEqual(analysis.newFilaments.count, 1)
        XCTAssertEqual(analysis.duplicates.count, 1)
        XCTAssertEqual(analysis.newFilaments[0].brand, "Prusament")
    }

    func testAnalyzeImportEmptyImported() {
        let existing = [TestHelpers.makeFilament()]
        let analysis = DataService.analyzeImport([], existing: existing)
        XCTAssertEqual(analysis.newFilaments.count, 0)
        XCTAssertEqual(analysis.duplicates.count, 0)
    }

    func testAnalyzeImportEmptyExisting() {
        let imported = [TestHelpers.makeFilament(), TestHelpers.makeFilament()]
        let analysis = DataService.analyzeImport(imported, existing: [])
        XCTAssertEqual(analysis.newFilaments.count, 2)
        XCTAssertEqual(analysis.duplicates.count, 0)
    }
}
