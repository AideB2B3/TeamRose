import SwiftUI

struct HomeView: View {
    var onStart: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Circle().fill(Color.brandPrimary.opacity(0.1)).frame(width: 200, height: 200)
                Image(systemName: "wrench.and.iphone")
                    .font(.system(size: 80))
                    .foregroundColor(.brandPrimary)
                    .symbolEffect(.pulse)
            }
            Spacer()
            PrimaryButton(title: "Start Diagnostic", icon: "arrow.right", action: onStart)
                .padding()
        }
    }
}
