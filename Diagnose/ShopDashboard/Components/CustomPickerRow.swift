import SwiftUI

struct CustomPickerRow: View {
    var title: String
    @Binding var selection: String
    var options: [String]
    var icon: String
    
    var body: some View {
        Picker(selection: $selection) {
            ForEach(options, id: \.self) { option in
                Text(option).tag(option)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(selection)
                    .foregroundColor(.primary)
            }
            .contentShape(Rectangle()) // Ensures the whole row is tappable
        }
        .pickerStyle(.menu)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }
}
