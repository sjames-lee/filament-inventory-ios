import Foundation

struct FilamentPreset {
    let printTempMin: Int
    let printTempMax: Int
    let bedTempMin: Int
    let bedTempMax: Int
    let productUrl: String?
}

enum FilamentPresets {

    static func lookup(brand: String, material: String) -> FilamentPreset? {
        let key = PresetKey(brand: brand, material: material)
        return presets[key]
    }

    static func materials(for brand: String) -> [String] {
        brandMaterials[brand] ?? Constants.materials
    }

    // MARK: - Private

    private struct PresetKey: Hashable {
        let brand: String
        let material: String
    }

    private static let brandMaterials: [String: [String]] = {
        var result = [String: Set<String>]()
        for key in presets.keys {
            result[key.brand, default: []].insert(key.material)
        }
        return result.mapValues { materialsSet in
            Constants.materials.filter { materialsSet.contains($0) }
        }
    }()

    private static let presets: [PresetKey: FilamentPreset] = {
        var dict = [PresetKey: FilamentPreset]()

        func add(_ brand: String, _ material: String,
                 _ printMin: Int, _ printMax: Int,
                 _ bedMin: Int, _ bedMax: Int,
                 url: String? = nil) {
            dict[PresetKey(brand: brand, material: material)] =
                FilamentPreset(printTempMin: printMin, printTempMax: printMax,
                               bedTempMin: bedMin, bedTempMax: bedMax,
                               productUrl: url)
        }

        // MARK: Bambu Lab
        add("Bambu Lab", "PLA",       190, 230, 35,  45, url: "https://us.store.bambulab.com/products/pla-basic-filament")
        add("Bambu Lab", "PLA Basic", 190, 230, 35,  45, url: "https://us.store.bambulab.com/products/pla-basic-filament")
        add("Bambu Lab", "PLA Matte", 190, 230, 35,  45, url: "https://us.store.bambulab.com/products/pla-matte")
        add("Bambu Lab", "PETG",      220, 260, 65,  75, url: "https://us.store.bambulab.com/products/petg-hf")
        add("Bambu Lab", "ABS",       240, 280, 90, 100, url: "https://us.store.bambulab.com/products/abs-filament")
        add("Bambu Lab", "ASA",       240, 280, 90, 100, url: "https://us.store.bambulab.com/products/asa-filament")
        add("Bambu Lab", "TPU",       220, 240, 30,  35, url: "https://us.store.bambulab.com/products/tpu-95a-hf")
        add("Bambu Lab", "Nylon",     260, 290, 80, 100, url: "https://us.store.bambulab.com/products/pa6-cf")
        add("Bambu Lab", "PC",        260, 290, 90, 110, url: "https://us.store.bambulab.com/products/pc-filament")
        add("Bambu Lab", "PVA",       220, 250, 35,  45, url: "https://us.store.bambulab.com/products/pva")
        add("Bambu Lab", "HIPS",      240, 250, 90, 100)
        add("Bambu Lab", "Silk",      210, 240, 35,  45, url: "https://us.store.bambulab.com/products/pla-silk-upgrade")

        // MARK: Polymaker
        add("Polymaker", "PLA",          190, 230, 25,  60, url: "https://shop.polymaker.com/products/polylite-pla")
        add("Polymaker", "PETG",         230, 260, 70,  80, url: "https://shop.polymaker.com/products/polylite-petg")
        add("Polymaker", "ABS",          245, 265, 90, 100, url: "https://shop.polymaker.com/products/polylite-abs")
        add("Polymaker", "ASA",          240, 260, 75,  95, url: "https://shop.polymaker.com/products/polymaker-asa")
        add("Polymaker", "TPU",          210, 230, 25,  60, url: "https://shop.polymaker.com/products/polyflex-tpu95")
        add("Polymaker", "Nylon",        280, 300, 25,  50, url: "https://shop.polymaker.com/products/polymide-copa")
        add("Polymaker", "PC",           250, 270, 90, 105, url: "https://shop.polymaker.com/products/polylite-pc")
        add("Polymaker", "PVA",          215, 225, 25,  60, url: "https://shop.polymaker.com/products/polydissolve-s1")
        add("Polymaker", "Silk",         190, 230, 25,  60, url: "https://shop.polymaker.com/products/panchroma-silk")
        add("Polymaker", "Carbon Fiber", 210, 230, 30,  70, url: "https://shop.polymaker.com/products/fiberon-pa6-cf20")

        // MARK: eSUN
        add("eSUN", "PLA+",         205, 225,  60,  80, url: "https://www.esun3d.com/pla-pro-product/")
        add("eSUN", "PETG",         230, 260,  75,  90, url: "https://www.esun3d.com/petg-product/")
        add("eSUN", "ABS",          230, 270,  95, 110, url: "https://www.esun3d.com/abs-pro-product/")
        add("eSUN", "ASA",          240, 270,  90, 110, url: "https://www.esun3d.com/asa-pro-product/")
        add("eSUN", "TPU",          220, 250,  45,  60, url: "https://www.esun3d.com/etpu-95a-product/")
        add("eSUN", "Nylon",        250, 290,  70,  90, url: "https://www.esun3d.com/epa-product/")
        add("eSUN", "PC",           240, 270,  80, 120, url: "https://www.esun3d.com/epc-product/")
        add("eSUN", "PVA",          180, 230,  45,  60, url: "https://www.esun3d.com/pva-pro-product/")
        add("eSUN", "HIPS",         230, 270, 100, 115, url: "https://www.esun3d.com/hips-product/")
        add("eSUN", "Wood",         210, 235,  45,  60, url: "https://www.esun3d.com/wood-product/")
        add("eSUN", "Silk",         190, 230,  45,  60, url: "https://www.esun3d.com/esilk-pla-product/")
        add("eSUN", "Marble",       190, 230,  45,  60, url: "https://www.esun3d.com/emarble-product/")
        add("eSUN", "Glow-in-Dark", 210, 230,  45,  60, url: "https://www.esun3d.com/pla-luminous-product/")
        add("eSUN", "Carbon Fiber", 260, 300,  60,  90, url: "https://www.esun3d.com/epa-cf-product/")

        // MARK: Prusament
        add("Prusament", "PLA",   200, 220,  40,  60, url: "https://prusament.com/materials/pla/")
        add("Prusament", "PETG",  240, 260,  70,  90, url: "https://prusament.com/materials/prusament-petg/")
        add("Prusament", "ASA",   255, 265, 105, 115, url: "https://prusament.com/materials/prusament-asa/")
        add("Prusament", "Nylon", 275, 295, 100, 120, url: "https://prusament.com/materials/prusament-pa11-nylon-carbon-fiber/")
        add("Prusament", "PC",    265, 285, 100, 120, url: "https://prusament.com/materials/prusament-pc-blend/")

        // MARK: Overture
        add("Overture", "PLA",          190, 220, 25, 60, url: "https://www.overture3d.com/products/overture-pla")
        add("Overture", "PLA+",         190, 230, 25, 60, url: "https://www.overture3d.com/products/overture-super-pla-3d-printer-filament-1-75mm")
        add("Overture", "PETG",         230, 250, 80, 90, url: "https://www.overture3d.com/products/overture-petg")
        add("Overture", "ABS",          245, 265, 80, 100, url: "https://www.overture3d.com/products/overture-abs-filament-1-75mm")
        add("Overture", "TPU",          210, 230, 25,  60, url: "https://www.overture3d.com/products/overture-tpu")
        add("Overture", "Nylon",        245, 260, 50,  50, url: "https://www.overture3d.com/products/easy-nylon-filament")
        add("Overture", "Silk",         200, 220, 50,  60, url: "https://www.overture3d.com/products/overture-silk-pla-3d-printer-filament-1-75mm")
        add("Overture", "Wood",         190, 230, 50,  70, url: "https://www.overture3d.com/products/overture-matte-pla")
        add("Overture", "Marble",       190, 220, 50,  70, url: "https://www.overture3d.com/products/overture-rock-pla-filament-1-75mm")
        add("Overture", "Glow-in-Dark", 190, 220, 25,  60, url: "https://www.overture3d.com/products/overture-glow-pla")

        // MARK: Sunlu
        add("Sunlu", "PLA",          200, 230, 60,  80, url: "https://store.sunlu.com/products/over-6kg-of-pla-pla-meta-3d-filaments-1kg-2-2lbs-fit-most-of-fdm-printer")
        add("Sunlu", "PLA+",         215, 235, 60,  80, url: "https://store.sunlu.com/products/moq-6kg-pla-2-0-upgraded-pla-pla-plus-3d-printer-filament-1kg")
        add("Sunlu", "PETG",         220, 250, 60,  80, url: "https://store.sunlu.com/products/over-6kg-bundle-sale-petg-3d-printer-filament-1-75mm-1kg-roll")
        add("Sunlu", "ABS",          250, 260, 80, 110, url: "https://store.sunlu.com/products/over-6kg-bundle-sale-abs-filament-1kg-roll")
        add("Sunlu", "ASA",          240, 260, 90, 110, url: "https://store.sunlu.com/products/sunlu-asa-filament-1-75mm")
        add("Sunlu", "TPU",          205, 230, 25,  60, url: "https://store.sunlu.com/products/moq-3kg-tpu-3d-printer-filament-1kg")
        add("Sunlu", "Silk",         205, 235, 50,  60, url: "https://store.sunlu.com/products/over-6kg-of-sunlu-silk-pla-3d-printer-filament-1-75mm-1kg-2-2lbs")
        add("Sunlu", "Wood",         190, 220, 25,  80, url: "https://store.sunlu.com/products/optimized-wood-pla-3d-printer-filament-1kg-optimized-and-upgraded-wood-texture")
        add("Sunlu", "Marble",       190, 230, 25,  60, url: "https://store.sunlu.com/products/pla-marble-1-75mm-filament-1kg-2-2lbs-fit-most-of-fdm-3d-printer")
        add("Sunlu", "Glow-in-Dark", 200, 210, 50,  65, url: "https://store.sunlu.com/products/1-75mm-sunlu-glow-in-the-darkluminous-3d-printer-filament-1kg-roll")

        return dict
    }()
}
