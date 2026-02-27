import XCTest
@testable import FilamentInventory

final class FilterStateTests: XCTestCase {

    // MARK: - isEmpty

    func testIsEmpty_defaultState() {
        let state = FilterState()
        XCTAssertTrue(state.isEmpty)
    }

    func testIsEmpty_withMaterial() {
        let state = FilterState(materials: ["PLA"])
        XCTAssertFalse(state.isEmpty)
    }

    func testIsEmpty_withBrand() {
        let state = FilterState(brands: ["Hatchbox"])
        XCTAssertFalse(state.isEmpty)
    }

    func testIsEmpty_withColorFamily() {
        let state = FilterState(colorFamilies: ["Red"])
        XCTAssertFalse(state.isEmpty)
    }

    func testIsEmpty_withStatus() {
        let state = FilterState(statuses: ["low"])
        XCTAssertFalse(state.isEmpty)
    }

    func testIsEmpty_withFavoritesOnly() {
        let state = FilterState(favoritesOnly: true)
        XCTAssertFalse(state.isEmpty)
    }

    // MARK: - activeCount

    func testActiveCount_defaultIsZero() {
        let state = FilterState()
        XCTAssertEqual(state.activeCount, 0)
    }

    func testActiveCount_sumsAllCategories() {
        let state = FilterState(
            materials: ["PLA", "PETG"],
            brands: ["Hatchbox"],
            colorFamilies: ["Red", "Blue", "Green"],
            statuses: ["low"],
            favoritesOnly: true
        )
        // 2 + 1 + 3 + 1 + 1 = 8
        XCTAssertEqual(state.activeCount, 8)
    }

    func testActiveCount_favoritesOnlyCountsAsOne() {
        let state = FilterState(favoritesOnly: true)
        XCTAssertEqual(state.activeCount, 1)
    }
}

// MARK: - FilamentFilter

final class FilamentFilterTests: XCTestCase {

    private var filaments: [Filament]!

    override func setUp() {
        super.setUp()
        filaments = TestHelpers.sampleFilaments()
    }

    override func tearDown() {
        filaments = nil
        super.tearDown()
    }

    // MARK: - No filters

    func testApply_noFiltersOrSearch_returnsAll() {
        let result = FilamentFilter.apply(to: filaments, search: "", filters: FilterState())
        XCTAssertEqual(result.count, filaments.count)
    }

    // MARK: - Search

    func testSearch_matchesName() {
        let result = FilamentFilter.apply(to: filaments, search: "Ocean", filters: FilterState())
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Ocean Blue PETG")
    }

    func testSearch_matchesBrand() {
        let result = FilamentFilter.apply(to: filaments, search: "Polymaker", filters: FilterState())
        XCTAssertEqual(result.count, 2)
    }

    func testSearch_matchesColorName() {
        let result = FilamentFilter.apply(to: filaments, search: "Neon", filters: FilterState())
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Flex Green TPU")
    }

    func testSearch_matchesMaterial() {
        let result = FilamentFilter.apply(to: filaments, search: "PLA", filters: FilterState())
        XCTAssertEqual(result.count, 2) // Matte Black PLA + Snow White PLA
    }

    func testSearch_matchesTags() {
        let result = FilamentFilter.apply(to: filaments, search: "flexible", filters: FilterState())
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Flex Green TPU")
    }

    func testSearch_isCaseInsensitive() {
        let result = FilamentFilter.apply(to: filaments, search: "pLa", filters: FilterState())
        XCTAssertEqual(result.count, 2)
    }

    func testSearch_noMatch_returnsEmpty() {
        let result = FilamentFilter.apply(to: filaments, search: "nonexistent", filters: FilterState())
        XCTAssertTrue(result.isEmpty)
    }

    func testSearch_emptyString_returnsAll() {
        let result = FilamentFilter.apply(to: filaments, search: "", filters: FilterState())
        XCTAssertEqual(result.count, filaments.count)
    }

    func testSearch_partialMatch() {
        let result = FilamentFilter.apply(to: filaments, search: "Matt", filters: FilterState())
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Matte Black PLA")
    }

    // MARK: - Material filter

    func testFilter_singleMaterial() {
        let filters = FilterState(materials: ["PLA"])
        let result = FilamentFilter.apply(to: filaments, search: "", filters: filters)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.material == "PLA" })
    }

    func testFilter_multipleMaterials() {
        let filters = FilterState(materials: ["PLA", "TPU"])
        let result = FilamentFilter.apply(to: filaments, search: "", filters: filters)
        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(result.allSatisfy { ["PLA", "TPU"].contains($0.material) })
    }

    func testFilter_materialWithNoMatch() {
        let filters = FilterState(materials: ["Nylon"])
        let result = FilamentFilter.apply(to: filaments, search: "", filters: filters)
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Brand filter

    func testFilter_singleBrand() {
        let filters = FilterState(brands: ["Hatchbox"])
        let result = FilamentFilter.apply(to: filaments, search: "", filters: filters)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.brand == "Hatchbox" })
    }

    func testFilter_multipleBrands() {
        let filters = FilterState(brands: ["Hatchbox", "eSUN"])
        let result = FilamentFilter.apply(to: filaments, search: "", filters: filters)
        XCTAssertEqual(result.count, 3)
    }

    // MARK: - Color family filter

    func testFilter_colorFamily() {
        let filters = FilterState(colorFamilies: ["Blue"])
        let result = FilamentFilter.apply(to: filaments, search: "", filters: filters)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Ocean Blue PETG")
    }

    func testFilter_multipleColorFamilies() {
        let filters = FilterState(colorFamilies: ["Black", "White"])
        let result = FilamentFilter.apply(to: filaments, search: "", filters: filters)
        XCTAssertEqual(result.count, 2)
    }

    // MARK: - Status filter

    func testFilter_singleStatus() {
        let filters = FilterState(statuses: ["in_stock"])
        let result = FilamentFilter.apply(to: filaments, search: "", filters: filters)
        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(result.allSatisfy { $0.status == "in_stock" })
    }

    func testFilter_multipleStatuses() {
        let filters = FilterState(statuses: ["low", "empty"])
        let result = FilamentFilter.apply(to: filaments, search: "", filters: filters)
        XCTAssertEqual(result.count, 2)
    }

    // MARK: - Favorites filter

    func testFilter_favoritesOnly() {
        let filters = FilterState(favoritesOnly: true)
        let result = FilamentFilter.apply(to: filaments, search: "", filters: filters)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.favorite })
    }

    // MARK: - Combined filters (AND logic)

    func testFilter_materialAndBrandCombined() {
        let filters = FilterState(materials: ["PLA"], brands: ["Hatchbox"])
        let result = FilamentFilter.apply(to: filaments, search: "", filters: filters)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.material == "PLA" && $0.brand == "Hatchbox" })
    }

    func testFilter_searchPlusMaterial() {
        let filters = FilterState(materials: ["PLA"])
        let result = FilamentFilter.apply(to: filaments, search: "Black", filters: filters)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "Matte Black PLA")
    }

    func testFilter_searchPlusStatusPlusFavorites() {
        let filters = FilterState(statuses: ["in_stock"], favoritesOnly: true)
        let result = FilamentFilter.apply(to: filaments, search: "", filters: filters)
        XCTAssertEqual(result.count, 2) // Matte Black PLA + Flex Green TPU
        XCTAssertTrue(result.allSatisfy { $0.favorite && $0.status == "in_stock" })
    }

    func testFilter_allFiltersCombined_noMatch() {
        let filters = FilterState(
            materials: ["PLA"],
            brands: ["eSUN"],
            colorFamilies: ["Black"],
            statuses: ["in_stock"],
            favoritesOnly: true
        )
        let result = FilamentFilter.apply(to: filaments, search: "", filters: filters)
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Empty input

    func testApply_emptyFilamentsArray() {
        let result = FilamentFilter.apply(to: [], search: "test", filters: FilterState(materials: ["PLA"]))
        XCTAssertTrue(result.isEmpty)
    }
}
