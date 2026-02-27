import XCTest
@testable import FilamentInventory

final class FilamentPresetsTests: XCTestCase {

    // MARK: - Known combo returns preset

    func testLookup_knownCombo_returnsPreset() {
        let preset = FilamentPresets.lookup(brand: "Bambu Lab", material: "PLA")
        XCTAssertNotNil(preset)
        XCTAssertEqual(preset?.printTempMin, 190)
        XCTAssertEqual(preset?.printTempMax, 230)
        XCTAssertEqual(preset?.bedTempMin, 35)
        XCTAssertEqual(preset?.bedTempMax, 45)
    }

    func testLookup_hatchboxPETG_returnsPreset() {
        let preset = FilamentPresets.lookup(brand: "Hatchbox", material: "PETG")
        XCTAssertNotNil(preset)
        XCTAssertEqual(preset?.printTempMin, 230)
        XCTAssertEqual(preset?.printTempMax, 260)
        XCTAssertEqual(preset?.bedTempMin, 80)
        XCTAssertEqual(preset?.bedTempMax, 100)
    }

    func testLookup_eSUNPLAPlus_returnsPreset() {
        let preset = FilamentPresets.lookup(brand: "eSUN", material: "PLA+")
        XCTAssertNotNil(preset)
        XCTAssertEqual(preset?.printTempMin, 205)
        XCTAssertEqual(preset?.printTempMax, 225)
    }

    // MARK: - Other brand/material returns nil

    func testLookup_otherBrand_returnsNil() {
        XCTAssertNil(FilamentPresets.lookup(brand: "Other", material: "PLA"))
    }

    func testLookup_otherMaterial_returnsNil() {
        XCTAssertNil(FilamentPresets.lookup(brand: "Bambu Lab", material: "Other"))
    }

    func testLookup_bothOther_returnsNil() {
        XCTAssertNil(FilamentPresets.lookup(brand: "Other", material: "Other"))
    }

    // MARK: - Unknown combos return nil

    func testLookup_unknownBrand_returnsNil() {
        XCTAssertNil(FilamentPresets.lookup(brand: "MakerBot", material: "PLA"))
    }

    func testLookup_unknownMaterial_returnsNil() {
        XCTAssertNil(FilamentPresets.lookup(brand: "Bambu Lab", material: "Wax"))
    }

    func testLookup_caseSensitive_returnsNil() {
        XCTAssertNil(FilamentPresets.lookup(brand: "bambu lab", material: "pla"))
    }

    // MARK: - Coverage checks

    func testAllNonOtherBrands_havePLAOrPLAPlusPreset() {
        let brands = Constants.brands.filter { $0 != "Other" }
        for brand in brands {
            let hasPLA = FilamentPresets.lookup(brand: brand, material: "PLA") != nil
            let hasPLAPlus = FilamentPresets.lookup(brand: brand, material: "PLA+") != nil
            XCTAssertTrue(hasPLA || hasPLAPlus,
                          "\(brand) should have a PLA or PLA+ preset")
        }
    }

    func testAllPresets_haveValidTemperatureRanges() {
        let brands = Constants.brands.filter { $0 != "Other" }
        let materials = Constants.materials.filter { $0 != "Other" }

        for brand in brands {
            for material in materials {
                guard let preset = FilamentPresets.lookup(brand: brand, material: material) else {
                    continue
                }

                XCTAssertGreaterThan(preset.printTempMin, 0,
                                     "\(brand) \(material) printTempMin should be positive")
                XCTAssertGreaterThan(preset.printTempMax, 0,
                                     "\(brand) \(material) printTempMax should be positive")
                XCTAssertGreaterThanOrEqual(preset.printTempMax, preset.printTempMin,
                                            "\(brand) \(material) printTempMax should >= printTempMin")
                XCTAssertGreaterThan(preset.bedTempMin, 0,
                                     "\(brand) \(material) bedTempMin should be positive")
                XCTAssertGreaterThan(preset.bedTempMax, 0,
                                     "\(brand) \(material) bedTempMax should be positive")
                XCTAssertGreaterThanOrEqual(preset.bedTempMax, preset.bedTempMin,
                                            "\(brand) \(material) bedTempMax should >= bedTempMin")
            }
        }
    }
}
