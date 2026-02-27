import XCTest
@testable import FilamentInventory

final class CatalogViewModelTests: XCTestCase {

    private var vm: CatalogViewModel!
    private var filaments: [Filament]!

    override func setUp() {
        super.setUp()
        vm = CatalogViewModel()
        filaments = TestHelpers.sampleFilaments()
    }

    override func tearDown() {
        vm = nil
        filaments = nil
        super.tearDown()
    }

    // MARK: - Initial state

    func testInitialState() {
        XCTAssertEqual(vm.searchText, "")
        XCTAssertEqual(vm.sortOption, .newestFirst)
        XCTAssertTrue(vm.selectedMaterials.isEmpty)
        XCTAssertTrue(vm.selectedBrands.isEmpty)
        XCTAssertTrue(vm.selectedColorFamilies.isEmpty)
        XCTAssertFalse(vm.showFavoritesOnly)
        XCTAssertFalse(vm.showFilterSheet)
        XCTAssertFalse(vm.showAddSheet)
        XCTAssertFalse(vm.hasActiveFilters)
        XCTAssertEqual(vm.activeFilterCount, 0)
    }

    // MARK: - Toggle methods

    func testToggleMaterial_addsAndRemoves() {
        vm.toggleMaterial("PLA")
        XCTAssertTrue(vm.selectedMaterials.contains("PLA"))
        XCTAssertEqual(vm.activeFilterCount, 1)

        vm.toggleMaterial("PLA")
        XCTAssertFalse(vm.selectedMaterials.contains("PLA"))
        XCTAssertEqual(vm.activeFilterCount, 0)
    }

    func testToggleBrand_addsAndRemoves() {
        vm.toggleBrand("Hatchbox")
        XCTAssertTrue(vm.selectedBrands.contains("Hatchbox"))

        vm.toggleBrand("Hatchbox")
        XCTAssertFalse(vm.selectedBrands.contains("Hatchbox"))
    }

    func testToggleColorFamily_addsAndRemoves() {
        vm.toggleColorFamily("Red")
        XCTAssertTrue(vm.selectedColorFamilies.contains("Red"))

        vm.toggleColorFamily("Red")
        XCTAssertFalse(vm.selectedColorFamilies.contains("Red"))
    }

    func testToggle_multipleValuesInSameCategory() {
        vm.toggleMaterial("PLA")
        vm.toggleMaterial("PETG")
        XCTAssertEqual(vm.selectedMaterials, ["PLA", "PETG"])
        XCTAssertEqual(vm.activeFilterCount, 2)

        vm.toggleMaterial("PLA")
        XCTAssertEqual(vm.selectedMaterials, ["PETG"])
        XCTAssertEqual(vm.activeFilterCount, 1)
    }

    // MARK: - hasActiveFilters / activeFilterCount

    func testHasActiveFilters_reflectsFilterState() {
        XCTAssertFalse(vm.hasActiveFilters)

        vm.toggleMaterial("PLA")
        XCTAssertTrue(vm.hasActiveFilters)
    }

    func testActiveFilterCount_countsAcrossCategories() {
        vm.toggleMaterial("PLA")
        vm.toggleBrand("Hatchbox")
        vm.toggleColorFamily("Red")
        vm.showFavoritesOnly = true
        XCTAssertEqual(vm.activeFilterCount, 4)
    }

    // MARK: - clearAllFilters

    func testClearAllFilters() {
        vm.toggleMaterial("PLA")
        vm.toggleBrand("Hatchbox")
        vm.toggleColorFamily("Red")
        vm.showFavoritesOnly = true

        vm.clearAllFilters()

        XCTAssertTrue(vm.selectedMaterials.isEmpty)
        XCTAssertTrue(vm.selectedBrands.isEmpty)
        XCTAssertTrue(vm.selectedColorFamilies.isEmpty)
        XCTAssertFalse(vm.showFavoritesOnly)
        XCTAssertFalse(vm.hasActiveFilters)
        XCTAssertEqual(vm.activeFilterCount, 0)
    }

    func testClearAllFilters_doesNotResetSearchOrSort() {
        vm.searchText = "PLA"
        vm.sortOption = .nameAsc
        vm.toggleMaterial("PLA")

        vm.clearAllFilters()

        XCTAssertEqual(vm.searchText, "PLA")
        XCTAssertEqual(vm.sortOption, .nameAsc)
    }

    // MARK: - filteredAndSorted (integration)

    func testFilteredAndSorted_noFilters_returnsAllSortedByNewest() {
        vm.sortOption = .newestFirst
        let result = vm.filteredAndSorted(filaments)

        XCTAssertEqual(result.count, 5)
        // Newest first: Polymaker TPU - Neon Green was created last
        XCTAssertEqual(result.first?.displayName, "Polymaker TPU - Neon Green")
        XCTAssertEqual(result.last?.displayName, "Hatchbox PLA - Matte Black")
    }

    func testFilteredAndSorted_withSearch() {
        vm.searchText = "Blue"
        let result = vm.filteredAndSorted(filaments)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.displayName, "Polymaker PETG - Ocean Blue")
    }

    func testFilteredAndSorted_withMaterialFilter() {
        vm.toggleMaterial("PLA")
        let result = vm.filteredAndSorted(filaments)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.material == "PLA" })
    }

    // MARK: - Sorting

    func testSort_nameAscending() {
        vm.sortOption = .nameAsc
        let result = vm.filteredAndSorted(filaments)
        let names = result.map(\.displayName)
        XCTAssertEqual(names, names.sorted { $0.localizedCompare($1) == .orderedAscending })
    }

    func testSort_nameDescending() {
        vm.sortOption = .nameDesc
        let result = vm.filteredAndSorted(filaments)
        let names = result.map(\.displayName)
        XCTAssertEqual(names, names.sorted { $0.localizedCompare($1) == .orderedDescending })
    }

    func testSort_brandAscending() {
        vm.sortOption = .brandAsc
        let result = vm.filteredAndSorted(filaments)
        let brands = result.map(\.brand)
        // localizedCompare sorts "eSUN" before "Hatchbox" (case-insensitive locale sort)
        let expected = brands.sorted { $0.localizedCompare($1) == .orderedAscending }
        XCTAssertEqual(brands, expected)
    }

    func testSort_priceAscending() {
        vm.sortOption = .priceAsc
        let result = vm.filteredAndSorted(filaments)
        // Items with price should come before nil-priced items
        let prices = result.map { $0.price ?? .infinity }
        XCTAssertEqual(prices, prices.sorted())
    }

    func testSort_priceDescending() {
        vm.sortOption = .priceDesc
        let result = vm.filteredAndSorted(filaments)
        let prices = result.map { $0.price ?? 0 }
        XCTAssertEqual(prices, prices.sorted(by: >))
    }

    func testSort_quantityDescending() {
        vm.sortOption = .quantityDesc
        let result = vm.filteredAndSorted(filaments)
        let quantities = result.map(\.quantity)
        XCTAssertEqual(quantities, quantities.sorted(by: >))
    }

    func testSort_quantityAscending() {
        vm.sortOption = .quantityAsc
        let result = vm.filteredAndSorted(filaments)
        let quantities = result.map(\.quantity)
        XCTAssertEqual(quantities, quantities.sorted())
    }

    func testSort_oldestFirst() {
        vm.sortOption = .oldestFirst
        let result = vm.filteredAndSorted(filaments)
        let dates = result.map(\.createdAt)
        XCTAssertEqual(dates, dates.sorted())
    }

    // MARK: - Filter + Sort combined

    func testFilterAndSort_materialFilterWithPriceSort() {
        vm.toggleMaterial("PLA")
        vm.sortOption = .priceAsc
        let result = vm.filteredAndSorted(filaments)

        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.material == "PLA" })
        // Hatchbox PLA - Snow White ($22.99) before Hatchbox PLA - Matte Black ($24.99)
        XCTAssertEqual(result.first?.displayName, "Hatchbox PLA - Snow White")
        XCTAssertEqual(result.last?.displayName, "Hatchbox PLA - Matte Black")
    }
}
