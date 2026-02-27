import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CatalogView()
                .tabItem {
                    Label("Catalog", systemImage: "square.grid.2x2")
                }

            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
