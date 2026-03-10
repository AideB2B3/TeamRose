import SwiftUI

struct PerfectBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Base background colors reacting to Light / Dark mode
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            if colorScheme == .dark {
                // Elegant dark mode gradients
                LinearGradient(
                    colors: [Color(white: 0.1), Color(white: 0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            } else {
                // Soft elegant light mode gradient
                LinearGradient(
                    colors: [Color(white: 0.98), Color(white: 0.94)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            
            // Subtle, beautiful frosted glass background blobs
            GeometryReader { geometry in
                Circle()
                    .fill(Color.brandPrimary.opacity(colorScheme == .dark ? 0.15 : 0.08))
                    .frame(width: geometry.size.width * 0.8)
                    .blur(radius: 60)
                    .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.1)
                
                Circle()
                    .fill(Color.brandPrimary.opacity(colorScheme == .dark ? 0.15 : 0.08))
                    .frame(width: geometry.size.width * 0.9)
                    .blur(radius: 80)
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.8)
            }
            .ignoresSafeArea()
        }
    }
}
