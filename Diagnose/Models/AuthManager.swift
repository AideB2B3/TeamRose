import Foundation
import Supabase
import SwiftUI
import Combine
import GoogleSignIn

// MARK: - Auth State
enum AuthState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated(String) // Stores String ID
    case error(String)
}

class AuthManager: ObservableObject {
    @Published var state: AuthState = .unauthenticated
    @Published var currentUserID: String? = nil
    @Published var needsProfileSetup: Bool = false
    
    static let shared = AuthManager()
    
    private init() {
        // Initial check for session
        Task {
            await checkSession()
        }
    }
    
    @MainActor
    func checkSession() async {
        do {
            let session = try await supabase.auth.session
            self.currentUserID = session.user.id.uuidString
            self.state = .authenticated(session.user.id.uuidString)
            print("✅ User is already logged in: \(session.user.email ?? "Unknown")")
            
            // Check if they finished their profile
            await checkIfProfileComplete(userID: session.user.id.uuidString)
        } catch {
            self.state = .unauthenticated
            self.currentUserID = nil
            self.needsProfileSetup = false
            print("ℹ️ No active session")
        }
    }
    
    @MainActor
    private func checkIfProfileComplete(userID: String) async {
        do {
            let results: [ShopRow] = try await supabase
                .from("shops")
                .select()
                .eq("shop_id", value: userID)
                .execute()
                .value
            
            if let shop = results.first {
                // If any critical field is missing, they need setup
                if shop.address == nil || shop.phone_number == nil || shop.business_hours == nil {
                    self.needsProfileSetup = true
                } else {
                    self.needsProfileSetup = false
                }
            } else {
                // No shop record at all
                self.needsProfileSetup = true
            }
        } catch {
            print("⚠️ Profile check error: \(error)")
        }
    }
    
    /// Signs in with Google by exchanging the ID Token from GoogleSignIn SDK with Supabase
    @MainActor
    func signInWithGoogle() async {
        self.state = .authenticating
        
        do {
            // 1. Generate a random nonce for security
            let nonce = UUID().uuidString
            
            // 2. Get Google ID Token
            let configuration = GIDConfiguration(clientID: googleClientID)
            GIDSignIn.sharedInstance.configuration = configuration
            
            // We pass the nonce to Google so it's included in the ID Token
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: getRootViewController(),
                hint: nil,
                additionalScopes: nil,
                nonce: nonce
            )
            
            guard let idToken = result.user.idToken?.tokenString else {
                self.state = .error("Failed to get Google ID Token")
                return
            }
            
            // 3. Exchange ID Token for Supabase Session, providing the SAME nonce
            let session = try await supabase.auth.signInWithIdToken(
                credentials: .init(
                    provider: .google,
                    idToken: idToken,
                    nonce: nonce // Supabase will verify this against the token
                )
            )
            
            self.currentUserID = session.user.id.uuidString
            self.state = .authenticated(session.user.id.uuidString)
            print("✅ Successfully signed in with Google: \(session.user.email ?? "Unknown")")
            
            // 4. Determine if we are in Shop or Customer mode to sync the right record
            if AppRouter.shared.selectedRole == .shop {
                // Ensure the shop exists in the shops table
                await syncShopRecord(user: session.user)
                // Check if profile is complete
                await checkIfProfileComplete(userID: session.user.id.uuidString)
            } else {
                // Ensure the customer exists in the customers table
                await syncCustomerRecord(user: session.user)
            }
            
        } catch {
            print("❌ Google Sign-In Error: \(error)")
            self.state = .error(error.localizedDescription)
        }
    }
    
    /// Syncs the user auth record with the 'customers' table
    @MainActor
    private func syncCustomerRecord(user: User) async {
        do {
            // Check if customer already exists
            let existing: [CustomerRow] = try await supabase
                .from("customers")
                .select()
                .eq("customer_id", value: user.id.uuidString)
                .execute()
                .value
            
            if existing.isEmpty {
                // Create a basic customer profile for the new user
                let nameStr = user.userMetadata["full_name"]?.description ?? user.email ?? "New Customer"
                let newCustomerData: [String: AnyJSON] = [
                    "customer_id": .string(user.id.uuidString),
                    "full_name": .string(nameStr),
                    "email": .string(user.email ?? "")
                ]
                
                try await supabase
                    .from("customers")
                    .insert(newCustomerData)
                    .execute()
                print("✅ Created new customer record for userID: \(user.id.uuidString)")
            } else {
                print("✅ Customer record already exists for: \(user.id.uuidString)")
            }
        } catch {
            print("⚠️ Error syncing customer record: \(error)")
        }
    }
    
    /// Syncs the user auth record with the 'shops' table
    @MainActor
    private func syncShopRecord(user: User) async {
        do {
            // Check if shop already exists
            let existing: [ShopRow] = try await supabase
                .from("shops")
                .select()
                .eq("shop_id", value: user.id.uuidString)
                .execute()
                .value
            
            if existing.isEmpty {
                // Create a basic shop profile for the new user
                let newShopData: [String: AnyJSON] = [
                    "shop_id": .string(user.id.uuidString),
                    "shop_name": .string(user.userMetadata["full_name"]?.description ?? "New Shop"),
                    "verified": .bool(false)
                ]
                
                try await supabase
                    .from("shops")
                    .insert(newShopData)
                    .execute()
                print("✅ Created new shop record for userID: \(user.id.uuidString)")
            }
        } catch {
            print("⚠️ Error syncing shop record: \(error)")
        }
    }
    
    @MainActor
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            self.currentUserID = nil
            self.state = .unauthenticated
            print("👋 Signed out")
        } catch {
            print("❌ Sign out error: \(error)")
        }
    }
    
    // Helper to find the topmost view controller for login presentation
    @MainActor
    private func getRootViewController() -> UIViewController {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              var topController = windowScene.windows.first?.rootViewController else {
            return UIViewController()
        }
        
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        return topController
    }
}
