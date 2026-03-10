
import SwiftUI

struct BrandColor {
    static let primary = Color(red: 241/255, green: 129/255, blue: 33/255) // #F18121 Fixo Orange
    static let accent = Color(red: 241/255, green: 129/255, blue: 33/255) 
    static let background = Color(UIColor.systemGroupedBackground)
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
}

struct SelectionCircle: View {
    var isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? BrandColor.primary : Color.gray.opacity(0.3), lineWidth: 2)
                .frame(width: 24, height: 24)
            
            if isSelected {
                Circle()
                    .fill(BrandColor.primary)
                    .frame(width: 14, height: 14)
            }
        }
    }
}

extension View {
    func cardStyle() -> some View {
        self.padding()
            .background(BrandColor.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    func primaryButtonStyle() -> some View {
        self.frame(maxWidth: .infinity)
            .padding()
            .background(BrandColor.primary)
            .foregroundColor(.white)
            .cornerRadius(12)
            .font(.headline)
    }
}

struct MailFormTextField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(BrandColor.primary)
                    .frame(width: 20)
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .frame(height: 44) // Ensures a predictable vertical tapping area
            }
            .padding(.horizontal)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

struct SummaryRow: View {
    let label: String
    let value: String
    var isTotal = false
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(isTotal ? .primary : .secondary)
                .fontWeight(isTotal ? .bold : .regular)
            Spacer()
            Text(value)
                .fontWeight(isTotal ? .bold : .regular)
                .foregroundColor(isTotal ? BrandColor.primary : .primary)
        }
    }
}
struct SecurityBadge: View {
    let icon: String
    let label: String
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(label)
                .font(.caption.bold())
        }
        .foregroundColor(.secondary)
    }
}
