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
}
