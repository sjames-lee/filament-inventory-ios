import XCTest
@testable import FilamentInventory

final class DashboardViewModelTests: XCTestCase {

    private var vm: DashboardViewModel!
    private var filaments: [Filament]!

    override func setUp() {
        super.setUp()
        vm = DashboardViewModel()
        filaments = TestHelpers.sampleFilaments()
    }

    override func tearDown() {
        vm = nil
        filaments = nil
        super.tearDown()
    }

    // MARK: - totalSpools

    func testTotalSpools_sumsQuantities() {
        // 3 + 1 + 2 + 0 + 1 = 7
        XCTAssertEqual(vm.totalSpools(filaments), 7)
    }

    func testTotalSpools_emptyArray() {
        XCTAssertEqual(vm.totalSpools([]), 0)
    }

    func testTotalSpools_singleFilament() {
        let f = TestHelpers.makeFilament(quantity: 5)
        XCTAssertEqual(vm.totalSpools([f]), 5)
    }

    // MARK: - estimatedValue

    func testEstimatedValue_multipliesPriceByQuantity() {
        // Matte Black PLA: 24.99 * 3 = 74.97
        // Ocean Blue PETG: 29.99 * 1 = 29.99
        // Fire Red ABS:    19.99 * 2 = 39.98
        // Snow White PLA:  22.99 * 0 = 0.00
        // Flex Green TPU:  nil * 1   = 0.00
        // Total = 144.94
        XCTAssertEqual(vm.estimatedValue(filaments), 144.94, accuracy: 0.01)
    }

    func testEstimatedValue_emptyArray() {
        XCTAssertEqual(vm.estimatedValue([]), 0)
    }

    func testEstimatedValue_allNilPrices() {
        let items = [
            TestHelpers.makeFilament(quantity: 3, price: nil),
            TestHelpers.makeFilament(quantity: 2, price: nil),
        ]
        XCTAssertEqual(vm.estimatedValue(items), 0)
    }

    func testEstimatedValue_zeroQuantityIgnored() {
        let f = TestHelpers.makeFilament(quantity: 0, price: 50.0)
        XCTAssertEqual(vm.estimatedValue([f]), 0)
    }

    // MARK: - uniqueMaterials

    func testUniqueMaterials() {
        // PLA, PETG, ABS, TPU = 4
        XCTAssertEqual(vm.uniqueMaterials(filaments), 4)
    }

    func testUniqueMaterials_duplicatesCountedOnce() {
        let items = [
            TestHelpers.makeFilament(material: "PLA"),
            TestHelpers.makeFilament(material: "PLA"),
            TestHelpers.makeFilament(material: "PLA"),
        ]
        XCTAssertEqual(vm.uniqueMaterials(items), 1)
    }

    func testUniqueMaterials_emptyArray() {
        XCTAssertEqual(vm.uniqueMaterials([]), 0)
    }

    // MARK: - uniqueBrands

    func testUniqueBrands() {
        // Hatchbox, Polymaker, eSUN = 3
        XCTAssertEqual(vm.uniqueBrands(filaments), 3)
    }

    func testUniqueBrands_emptyArray() {
        XCTAssertEqual(vm.uniqueBrands([]), 0)
    }

    // MARK: - materialCounts

    func testMaterialCounts_sortedByCountDescending() {
        let counts = vm.materialCounts(filaments)

        // PLA: 3+0=3, ABS: 2, PETG: 1, TPU: 1
        XCTAssertEqual(counts.count, 4)
        XCTAssertEqual(counts[0].label, "PLA")
        XCTAssertEqual(counts[0].count, 3)
        XCTAssertEqual(counts[1].label, "ABS")
        XCTAssertEqual(counts[1].count, 2)
        // PETG and TPU both have count 1, order between them is dictionary-dependent
        let lastTwo = Set(counts[2...3].map(\.label))
        XCTAssertEqual(lastTwo, ["PETG", "TPU"])
        XCTAssertTrue(counts[2...3].allSatisfy { $0.count == 1 })
    }

    func testMaterialCounts_emptyArray() {
        let counts = vm.materialCounts([])
        XCTAssertTrue(counts.isEmpty)
    }

    func testMaterialCounts_usesQuantityNotFilamentCount() {
        let items = [
            TestHelpers.makeFilament(material: "PLA", quantity: 10),
            TestHelpers.makeFilament(material: "PLA", quantity: 5),
        ]
        let counts = vm.materialCounts(items)
        XCTAssertEqual(counts.count, 1)
        XCTAssertEqual(counts[0].label, "PLA")
        XCTAssertEqual(counts[0].count, 15)
    }

    // MARK: - brandCounts

    func testBrandCounts_sortedByCountDescending() {
        let counts = vm.brandCounts(filaments)

        // Hatchbox: 3+0=3, Polymaker: 1+1=2, eSUN: 2
        XCTAssertEqual(counts.count, 3)
        XCTAssertEqual(counts[0].label, "Hatchbox")
        XCTAssertEqual(counts[0].count, 3)
        // Polymaker and eSUN both have count 2
        let lastTwo = Set(counts[1...2].map(\.label))
        XCTAssertEqual(lastTwo, ["Polymaker", "eSUN"])
        XCTAssertTrue(counts[1...2].allSatisfy { $0.count == 2 })
    }

    func testBrandCounts_emptyArray() {
        let counts = vm.brandCounts([])
        XCTAssertTrue(counts.isEmpty)
    }
}
