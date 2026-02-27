import SwiftUI
import SwiftData

struct FilamentFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let filament: Filament?

    @State private var brand = Constants.brands[0]
    @State private var material = Constants.materials[0]
    @State private var colorName = ""
    @State private var colorHex = "#3B82F6"
    @State private var colorFamily = Constants.colorFamilies[0]
    @State private var diameter = "1.75"
    @State private var spoolWeight = "1000"
    @State private var weightRemaining = ""
    @State private var quantity = 1
    @State private var favorite = false
    @State private var printTempMin = ""
    @State private var printTempMax = ""
    @State private var bedTempMin = ""
    @State private var bedTempMax = ""
    @State private var price = "20"
    @State private var purchaseUrl = ""
    @State private var tags = ""
    @State private var notes = ""
    @State private var showValidationError = false

    private var isEdit: Bool { filament != nil }

    private var availableMaterials: [String] {
        isEdit ? Constants.materials : FilamentPresets.materials(for: brand)
    }

    private var isValid: Bool {
        colorHex.range(of: #"^#[0-9a-fA-F]{6}$"#, options: .regularExpression) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                colorSection
                physicalSpecsSection
                inventorySection
                temperatureSection
                purchaseInfoSection
                notesTagsSection
            }
            .navigationTitle(isEdit ? "Edit Filament" : "Add Filament")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEdit ? "Save" : "Create") { save() }
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                }
            }
            .alert("Invalid Color", isPresented: $showValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enter a valid hex color (e.g. #3B82F6).")
            }
            .onAppear {
                populateFromFilament()
                if !isEdit { applyPresetIfNeeded() }
            }
            .onChange(of: brand) { _, _ in
                if !isEdit {
                    let available = FilamentPresets.materials(for: brand)
                    if !available.contains(material) {
                        material = available.first ?? Constants.materials[0]
                    }
                }
                applyPresetIfNeeded()
            }
            .onChange(of: material) { _, _ in applyPresetIfNeeded() }
        }
    }

    // MARK: - Form Sections

    private var basicInfoSection: some View {
        Section("Basic Information") {
            Picker("Brand", selection: $brand) {
                ForEach(Constants.brands, id: \.self) { Text($0) }
            }

            Picker("Material", selection: $material) {
                ForEach(availableMaterials, id: \.self) { Text($0) }
            }
        }
    }

    private var colorSection: some View {
        Section("Color") {
            TextField("Color name (e.g. Matte Black)", text: $colorName)
                .textInputAutocapitalization(.words)

            ColorPickerRow(hexString: $colorHex)

            Picker("Color Family", selection: $colorFamily) {
                ForEach(Constants.colorFamilies, id: \.self) { Text($0) }
            }
        }
    }

    private var physicalSpecsSection: some View {
        Section("Physical Specs") {
            HStack {
                Text("Diameter (mm)")
                Spacer()
                TextField("1.75", text: $diameter)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            HStack {
                Text("Spool Weight (g)")
                Spacer()
                TextField("1000", text: $spoolWeight)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            HStack {
                Text("Weight Remaining (g)")
                Spacer()
                TextField("Optional", text: $weightRemaining)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
        }
    }

    private var inventorySection: some View {
        Section("Inventory") {
            Stepper("Quantity: \(quantity)", value: $quantity, in: 0...999)

            Toggle("Mark as favorite", isOn: $favorite)
        }
    }

    private var temperatureSection: some View {
        Section("Temperature Settings") {
            HStack {
                Text("Print Temp Min (°C)")
                Spacer()
                TextField("190", text: $printTempMin)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            HStack {
                Text("Print Temp Max (°C)")
                Spacer()
                TextField("220", text: $printTempMax)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            HStack {
                Text("Bed Temp Min (°C)")
                Spacer()
                TextField("25", text: $bedTempMin)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }

            HStack {
                Text("Bed Temp Max (°C)")
                Spacer()
                TextField("60", text: $bedTempMax)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
        }
    }

    private var purchaseInfoSection: some View {
        Section("Purchase Info") {
            HStack {
                Text("Price ($)")
                Spacer()
                TextField("17.99", text: $price)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
            }

            TextField("Purchase URL", text: $purchaseUrl)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
    }

    private var notesTagsSection: some View {
        Section("Notes & Tags") {
            TextField("Tags (comma-separated, e.g. matte, basic)", text: $tags)
                .textInputAutocapitalization(.never)

            ZStack(alignment: .topLeading) {
                if notes.isEmpty {
                    Text("Any additional notes...")
                        .foregroundStyle(.tertiary)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                TextEditor(text: $notes)
                    .frame(minHeight: 80)
            }
        }
    }

    // MARK: - Actions

    private func populateFromFilament() {
        guard let f = filament else { return }
        brand = f.brand
        material = f.material
        colorName = f.colorName
        colorHex = f.colorHex
        colorFamily = f.colorFamily
        diameter = String(f.diameter)
        spoolWeight = String(f.spoolWeight)
        weightRemaining = f.weightRemaining.map { String($0) } ?? ""
        quantity = f.quantity
        favorite = f.favorite
        printTempMin = f.printTempMin.map { String($0) } ?? ""
        printTempMax = f.printTempMax.map { String($0) } ?? ""
        bedTempMin = f.bedTempMin.map { String($0) } ?? ""
        bedTempMax = f.bedTempMax.map { String($0) } ?? ""
        price = f.price.map { String($0) } ?? ""
        purchaseUrl = f.purchaseUrl ?? ""
        tags = f.tags
        notes = f.notes ?? ""
    }

    private func applyPresetIfNeeded() {
        guard !isEdit else { return }
        if let preset = FilamentPresets.lookup(brand: brand, material: material) {
            printTempMin = String(preset.printTempMin)
            printTempMax = String(preset.printTempMax)
            bedTempMin = String(preset.bedTempMin)
            bedTempMax = String(preset.bedTempMax)
        } else {
            printTempMin = ""
            printTempMax = ""
            bedTempMin = ""
            bedTempMax = ""
        }
    }

    private func save() {
        guard isValid else {
            showValidationError = true
            return
        }

        if let f = filament {
            applyValues(to: f)
            f.updatedAt = Date()
        } else {
            let newFilament = Filament(
                brand: brand,
                material: material,
                colorName: colorName.trimmingCharacters(in: .whitespaces),
                colorHex: colorHex,
                colorFamily: colorFamily,
                diameter: Double(diameter) ?? 1.75,
                spoolWeight: Double(spoolWeight) ?? 1000,
                quantity: quantity,
                weightRemaining: Double(weightRemaining),
                printTempMin: Int(printTempMin),
                printTempMax: Int(printTempMax),
                bedTempMin: Int(bedTempMin),
                bedTempMax: Int(bedTempMax),
                price: Double(price),
                purchaseUrl: purchaseUrl.isEmpty ? nil : purchaseUrl,
                notes: notes.isEmpty ? nil : notes,
                tags: tags,
                favorite: favorite
            )
            modelContext.insert(newFilament)
        }

        try? modelContext.save()
        dismiss()
    }

    private func applyValues(to f: Filament) {
        f.brand = brand
        f.material = material
        f.colorName = colorName.trimmingCharacters(in: .whitespaces)
        f.colorHex = colorHex
        f.colorFamily = colorFamily
        f.diameter = Double(diameter) ?? 1.75
        f.spoolWeight = Double(spoolWeight) ?? 1000
        f.quantity = quantity
        f.weightRemaining = Double(weightRemaining)
        f.favorite = favorite
        f.printTempMin = Int(printTempMin)
        f.printTempMax = Int(printTempMax)
        f.bedTempMin = Int(bedTempMin)
        f.bedTempMax = Int(bedTempMax)
        f.price = Double(price)
        f.purchaseUrl = purchaseUrl.isEmpty ? nil : purchaseUrl
        f.notes = notes.isEmpty ? nil : notes
        f.tags = tags
    }
}
