import SwiftUI
import Supabase
import GoogleSignIn

struct ShopLoginView: View {
    @StateObject private var auth = AuthManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Branding Section
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "building.2.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.brandPrimary)
                }
                
                Text("Shop Dashboard")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text("Manage your repair services and reach more customers.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Interaction Section
            VStack(spacing: 20) {
                switch auth.state {
                case .authenticating:
                    ProgressView("Signing you in...")
                        .tint(.brandPrimary)
                case .error(let msg):
                    Text("Error: \(msg)")
                        .font(.caption)
                        .foregroundColor(.red)
                default:
                    EmptyView()
                }
                
                // Google Login Button
                Button(action: {
                    Task {
                        await auth.signInWithGoogle()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "g.circle.fill") // Simplified icon for Google
                            .font(.title2)
                        
                        Text("Sign in with Google")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                .disabled(auth.state == .authenticating)
                
                // Demo / Direct Login (optional for testing)
                VStack(spacing: 8) {
                    Button("Try Demo Access") {
                        // Logic for testing or anonymous sign-in could go here
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    
                    Button("Back to Customer Experience") {
                        withAnimation {
                            AppRouter.shared.selectedRole = .customer
                        }
                    }
                    .font(.footnote.bold())
                    .foregroundColor(.brandPrimary)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 60)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    ShopLoginView()
}
