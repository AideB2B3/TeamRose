import SwiftUI
import Supabase
import GoogleSignIn

struct CustomerLoginView: View {
    @ObservedObject private var auth = AuthManager.shared
    @Environment(\.dismiss) var dismiss
    var isInline: Bool = false
    var onLoginSuccess: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Branding Section
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.brandPrimary)
                }
                
                Text("Customer Profile")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text("Create your Fixo account to save your repairs and track history in real-time.")
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
                        if auth.currentUserID != nil {
                            onLoginSuccess?()
                            if !isInline {
                                dismiss()
                            }
                        }
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "g.circle.fill")
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
                
                if !isInline {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.footnote.bold())
                    .foregroundColor(.brandPrimary)
                    .padding(.top, 10)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 60)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    CustomerLoginView()
}
