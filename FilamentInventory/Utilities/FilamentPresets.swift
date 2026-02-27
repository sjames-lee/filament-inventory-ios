import Foundation

struct FilamentPreset {
    let printTempMin: Int
    let printTempMax: Int
    let bedTempMin: Int
    let bedTempMax: Int
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
                 _ bedMin: Int, _ bedMax: Int) {
            dict[PresetKey(brand: brand, material: material)] =
                FilamentPreset(printTempMin: printMin, printTempMax: printMax,
                               bedTempMin: bedMin, bedTempMax: bedMax)
        }

        // MARK: Bambu Lab
        add("Bambu Lab", "PLA",       190, 230, 35,  45)
        add("Bambu Lab", "PLA Basic", 190, 230, 35,  45)
        add("Bambu Lab", "PLA Matte", 190, 230, 35,  45)
        add("Bambu Lab", "PETG",      220, 260, 65,  75)
        add("Bambu Lab", "ABS",       240, 280, 90, 100)
        add("Bambu Lab", "ASA",       240, 280, 90, 100)
        add("Bambu Lab", "TPU",       220, 240, 30,  35)
        add("Bambu Lab", "Nylon",     260, 290, 80, 100)
        add("Bambu Lab", "PC",        260, 290, 90, 110)
        add("Bambu Lab", "PVA",       220, 250, 35,  45)
        add("Bambu Lab", "HIPS",      240, 250, 90, 100)
        add("Bambu Lab", "Silk",      210, 240, 35,  45)

        // MARK: Polymaker
        add("Polymaker", "PLA",          190, 230, 25,  60)
        add("Polymaker", "PETG",         230, 260, 70,  80)
        add("Polymaker", "ABS",          245, 265, 90, 100)
        add("Polymaker", "ASA",          240, 260, 75,  95)
        add("Polymaker", "TPU",          210, 230, 25,  60)
        add("Polymaker", "Nylon",        280, 300, 25,  50)
        add("Polymaker", "PC",           250, 270, 90, 105)
        add("Polymaker", "PVA",          215, 225, 25,  60)
        add("Polymaker", "Silk",         190, 230, 25,  60)
        add("Polymaker", "Carbon Fiber", 210, 230, 30,  70)

        // MARK: eSUN
        add("eSUN", "PLA+",         205, 225,  60,  80)
        add("eSUN", "PETG",         230, 260,  75,  90)
        add("eSUN", "ABS",          230, 270,  95, 110)
        add("eSUN", "ASA",          240, 270,  90, 110)
        add("eSUN", "TPU",          220, 250,  45,  60)
        add("eSUN", "Nylon",        250, 290,  70,  90)
        add("eSUN", "PC",           240, 270,  80, 120)
        add("eSUN", "PVA",          180, 230,  45,  60)
        add("eSUN", "HIPS",         230, 270, 100, 115)
        add("eSUN", "Wood",         210, 235,  45,  60)
        add("eSUN", "Silk",         190, 230,  45,  60)
        add("eSUN", "Marble",       190, 230,  45,  60)
        add("eSUN", "Glow-in-Dark", 210, 230,  45,  60)
        add("eSUN", "Carbon Fiber", 260, 300,  60,  90)

        // MARK: Prusament
        add("Prusament", "PLA",   200, 220,  40,  60)
        add("Prusament", "PETG",  240, 260,  70,  90)
        add("Prusament", "ASA",   255, 265, 105, 115)
        add("Prusament", "Nylon", 275, 295, 100, 120)
        add("Prusament", "PC",    265, 285, 100, 120)

        // MARK: Overture
        add("Overture", "PLA",          190, 220, 25, 60)
        add("Overture", "PLA+",         190, 230, 25, 60)
        add("Overture", "PETG",         230, 250, 80, 90)
        add("Overture", "ABS",          245, 265, 80, 100)
        add("Overture", "TPU",          210, 230, 25,  60)
        add("Overture", "Nylon",        245, 260, 50,  50)
        add("Overture", "Silk",         200, 220, 50,  60)
        add("Overture", "Wood",         190, 230, 50,  70)
        add("Overture", "Marble",       190, 220, 50,  70)
        add("Overture", "Glow-in-Dark", 190, 220, 25,  60)

        // MARK: Sunlu
        add("Sunlu", "PLA",          200, 230, 60,  80)
        add("Sunlu", "PLA+",         215, 235, 60,  80)
        add("Sunlu", "PETG",         220, 250, 60,  80)
        add("Sunlu", "ABS",          250, 260, 80, 110)
        add("Sunlu", "ASA",          240, 260, 90, 110)
        add("Sunlu", "TPU",          205, 230, 25,  60)
        add("Sunlu", "Silk",         205, 235, 50,  60)
        add("Sunlu", "Wood",         190, 220, 25,  80)
        add("Sunlu", "Marble",       190, 230, 25,  60)
        add("Sunlu", "Glow-in-Dark", 200, 210, 50,  65)

        return dict
    }()
}
