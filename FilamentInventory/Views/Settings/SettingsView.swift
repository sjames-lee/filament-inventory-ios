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
    @State private var showDuplicateChoice = false
    @State private var pendingAnalysis: DataService.ImportAnalysis?

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
            .confirmationDialog(
                "Duplicates Found",
                isPresented: $showDuplicateChoice,
                presenting: pendingAnalysis
            ) { analysis in
                Button("Merge Quantities") {
                    performImport(analysis, merge: true)
                }
                Button("Skip Duplicates") {
                    performImport(analysis, merge: false)
                }
                Button("Cancel", role: .cancel) {
                    pendingAnalysis = nil
                }
            } message: { analysis in
                Text("\(analysis.duplicates.count) duplicate\(analysis.duplicates.count == 1 ? "" : "s") found. \(analysis.newFilaments.count) new filament\(analysis.newFilaments.count == 1 ? "" : "s") will be imported.")
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

    private func performImport(_ analysis: DataService.ImportAnalysis, merge: Bool) {
        for filament in analysis.newFilaments {
            modelContext.insert(filament)
        }

        if merge {
            for (existing, imported) in analysis.duplicates {
                existing.quantity += imported.quantity
                existing.updatedAt = Date()
            }
        }

        try? modelContext.save()

        var parts: [String] = []
        if !analysis.newFilaments.isEmpty {
            let count = analysis.newFilaments.count
            parts.append("Imported \(count) new filament\(count == 1 ? "" : "s")")
        }
        if !analysis.duplicates.isEmpty {
            let count = analysis.duplicates.count
            if merge {
                parts.append("merged quantities for \(count) existing")
            } else {
                parts.append("skipped \(count) duplicate\(count == 1 ? "" : "s")")
            }
        }

        alertTitle = "Import Successful"
        alertMessage = parts.joined(separator: ", ") + "."
        showAlert = true
        exportData = nil
        pendingAnalysis = nil
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
                let imported = try DataService.importJSON(data)
                let analysis = DataService.analyzeImport(imported, existing: filaments)

                if analysis.duplicates.isEmpty {
                    for filament in analysis.newFilaments {
                        modelContext.insert(filament)
                    }
                    try? modelContext.save()
                    alertTitle = "Import Successful"
                    alertMessage = "Imported \(analysis.newFilaments.count) filament\(analysis.newFilaments.count == 1 ? "" : "s")."
                    showAlert = true
                    exportData = nil
                } else {
                    pendingAnalysis = analysis
                    showDuplicateChoice = true
                }
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
