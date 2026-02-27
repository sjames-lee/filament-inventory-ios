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
        XCTAssertNotNil(preset?.productUrl)
    }

    func testLookup_polymakerPETG_returnsPreset() {
        let preset = FilamentPresets.lookup(brand: "Polymaker", material: "PETG")
        XCTAssertNotNil(preset)
        XCTAssertEqual(preset?.printTempMin, 230)
        XCTAssertEqual(preset?.printTempMax, 260)
        XCTAssertEqual(preset?.bedTempMin, 70)
        XCTAssertEqual(preset?.bedTempMax, 80)
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

    // MARK: - materials(for:) tests

    func testMaterials_bambuLab_returns12Materials() {
        let materials = FilamentPresets.materials(for: "Bambu Lab")
        XCTAssertEqual(materials.count, 12)
        XCTAssertTrue(materials.contains("PLA"))
        XCTAssertTrue(materials.contains("PLA Basic"))
        XCTAssertTrue(materials.contains("PLA Matte"))
        XCTAssertTrue(materials.contains("PETG"))
        XCTAssertTrue(materials.contains("ABS"))
        XCTAssertTrue(materials.contains("TPU"))
        XCTAssertTrue(materials.contains("Silk"))
        XCTAssertFalse(materials.contains("PLA+"))
        XCTAssertFalse(materials.contains("Wood"))
    }

    func testMaterials_otherBrand_returnsAllMaterials() {
        let materials = FilamentPresets.materials(for: "Other")
        XCTAssertEqual(materials, Constants.materials)
    }

    func testMaterials_unknownBrand_returnsAllMaterials() {
        let materials = FilamentPresets.materials(for: "MakerBot")
        XCTAssertEqual(materials, Constants.materials)
    }

    func testMaterials_preservesConstantsOrdering() {
        let materials = FilamentPresets.materials(for: "eSUN")
        let constantsOrder = Constants.materials
        var lastIndex = -1
        for mat in materials {
            guard let idx = constantsOrder.firstIndex(of: mat) else {
                XCTFail("\(mat) not found in Constants.materials")
                continue
            }
            XCTAssertGreaterThan(idx, lastIndex,
                                 "\(mat) is out of Constants.materials order")
            lastIndex = idx
        }
    }

    func testMaterials_allBrandsHaveAtLeastOneMaterial() {
        let brands = Constants.brands.filter { $0 != "Other" }
        for brand in brands {
            let materials = FilamentPresets.materials(for: brand)
            XCTAssertFalse(materials.isEmpty,
                           "\(brand) should have at least one material")
            XCTAssertNotEqual(materials, Constants.materials,
                              "\(brand) should return a filtered list, not all materials")
        }
    }

    // MARK: - Temperature validation

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

    // MARK: - Product URL validation

    func testAllPresets_haveProductUrl_exceptBambuLabHIPS() {
        let brands = Constants.brands.filter { $0 != "Other" }
        let materials = Constants.materials.filter { $0 != "Other" }

        for brand in brands {
            for material in materials {
                guard let preset = FilamentPresets.lookup(brand: brand, material: material) else {
                    continue
                }

                if brand == "Bambu Lab" && material == "HIPS" {
                    XCTAssertNil(preset.productUrl,
                                 "Bambu Lab HIPS should not have a product URL")
                } else {
                    XCTAssertNotNil(preset.productUrl,
                                    "\(brand) \(material) should have a product URL")
                }
            }
        }
    }

    func testAllProductUrls_startWithHttps() {
        let brands = Constants.brands.filter { $0 != "Other" }
        let materials = Constants.materials.filter { $0 != "Other" }

        for brand in brands {
            for material in materials {
                guard let preset = FilamentPresets.lookup(brand: brand, material: material),
                      let url = preset.productUrl else {
                    continue
                }

                XCTAssertTrue(url.hasPrefix("https://"),
                              "\(brand) \(material) productUrl should start with https:// but was: \(url)")
            }
        }
    }
}
