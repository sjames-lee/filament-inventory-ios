import Foundation

enum DataService {
    static func exportJSON(_ filaments: [Filament]) throws -> Data {
        let codables = filaments.map { $0.toCodable() }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(codables)
    }

    static func importJSON(_ data: Data) throws -> [Filament] {
        let decoder = JSONDecoder()
        let codables = try decoder.decode([CodableFilament].self, from: data)
        return codables.map { $0.toFilament() }
    }

    struct ImportAnalysis {
        let newFilaments: [Filament]
        let duplicates: [(existing: Filament, imported: Filament)]
    }

    static func analyzeImport(
        _ importedFilaments: [Filament],
        existing: [Filament]
    ) -> ImportAnalysis {
        var newFilaments: [Filament] = []
        var duplicates: [(existing: Filament, imported: Filament)] = []
        for imported in importedFilaments {
            if let match = existing.first(where: { $0.matchesIdentity(of: imported) }) {
                duplicates.append((existing: match, imported: imported))
            } else {
                newFilaments.append(imported)
            }
        }
        return ImportAnalysis(newFilaments: newFilaments, duplicates: duplicates)
    }
}
