import SwiftUI

// MARK: - Reusable UI Components
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title).bold()
                if let icon = icon {
                    Image(systemName: icon)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(16)
        }
    }
}
