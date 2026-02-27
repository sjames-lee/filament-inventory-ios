import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var filaments: [Filament]

    @State private var showImporter = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var exportData: Data?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    exportButton
                    importButton
                } header: {
                    Text("Data")
                } footer: {
                    Text("Export saves all filaments as a JSON file. Import adds filaments from a JSON file as new entries.")
                }
            }
            .navigationTitle("Settings")
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.json]
            ) { result in
                handleImport(result)
            }
        }
    }

    private var exportButton: some View {
        Group {
            if let data = exportData,
               let url = writeExportFile(data) {
                ShareLink(
                    item: url,
                    preview: SharePreview("FilamentInventory.json", image: Image(systemName: "doc"))
                ) {
                    Label("Export Filaments (\(filaments.count))", systemImage: "square.and.arrow.up")
                }
            } else {
                Button {
                    performExport()
                } label: {
                    Label("Export Filaments (\(filaments.count))", systemImage: "square.and.arrow.up")
                }
                .disabled(filaments.isEmpty)
            }
        }
    }

    private var importButton: some View {
        Button {
            showImporter = true
        } label: {
            Label("Import Filaments", systemImage: "square.and.arrow.down")
        }
    }

    private func performExport() {
        do {
            exportData = try DataService.exportJSON(filaments)
        } catch {
            alertTitle = "Export Failed"
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }

    private func writeExportFile(_ data: Data) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("FilamentInventory.json")
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            guard url.startAccessingSecurityScopedResource() else {
                alertTitle = "Import Failed"
                alertMessage = "Could not access the selected file."
                showAlert = true
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }

            do {
                let data = try Data(contentsOf: url)
                let newFilaments = try DataService.importJSON(data)
                for filament in newFilaments {
                    modelContext.insert(filament)
                }
                alertTitle = "Import Successful"
                alertMessage = "Imported \(newFilaments.count) filament\(newFilaments.count == 1 ? "" : "s")."
                showAlert = true
                exportData = nil
            } catch {
                alertTitle = "Import Failed"
                alertMessage = error.localizedDescription
                showAlert = true
            }

        case .failure(let error):
            alertTitle = "Import Failed"
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}
