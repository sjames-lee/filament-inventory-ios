import SwiftUI
import SwiftData

@main
struct FilamentInventoryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Filament.self)
    }
}
