import SwiftUI

struct ColorPickerRow: View {
    @Binding var hexString: String
    @State private var pickerColor: Color = .blue

    var body: some View {
        HStack(spacing: 12) {
            ColorPicker("", selection: $pickerColor, supportsOpacity: false)
                .labelsHidden()
                .frame(width: 44, height: 44)

            TextField("#RRGGBB", text: $hexString)
                .font(.system(.body, design: .monospaced))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)

            RoundedRectangle(cornerRadius: 8)
                .fill(ColorHelpers.color(from: hexString))
                .frame(width: 36, height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray3), lineWidth: 1)
                )
        }
        .onChange(of: pickerColor) { _, newColor in
            hexString = ColorHelpers.hex(from: newColor)
        }
        .onChange(of: hexString) { _, newHex in
            if newHex.count == 7, newHex.hasPrefix("#") {
                pickerColor = ColorHelpers.color(from: newHex)
            }
        }
        .onAppear {
            pickerColor = ColorHelpers.color(from: hexString)
        }
    }
}
