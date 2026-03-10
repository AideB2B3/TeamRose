import SwiftUI
import Supabase

struct ShopSetupView: View {
    @StateObject private var auth = AuthManager.shared
    @State private var shopName: String = ""
    @State private var address: String = ""
    @State private var phoneNumber: String = ""
    @State private var businessHours: String = ""
    @State private var errorMessage: String? = nil
    @State private var showError = false
    @State var isSubmitting = false
    
    struct ShopProfileUpdate: Encodable {
        let shop_id: String
        let shop_name: String
        let address: String
        let phone_number: String
        let business_hours: String
        let verified: Bool
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Welcome! Let's set up your shop profile.")) {
                    TextField("Shop Name", text: $shopName)
                    TextField("Physical Address", text: $address)
                    TextField("Phone Number", text: $phoneNumber)
                    TextField("Business Hours (e.g. Mon-Fri 9-6)", text: $businessHours)
                }
                
                Section {
                    Button(action: saveProfile) {
                        if isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Complete Setup")
                                .bold()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.brandPrimary : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(!isFormValid || isSubmitting)
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Shop Setup")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign Out") {
                        Task { await auth.signOut() }
                    }
                }
            }
            .alert("Setup Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred. Please check your internet connection and try again.")
            }
        }
    }
    
    var isFormValid: Bool {
        !shopName.isEmpty && !address.isEmpty && !phoneNumber.isEmpty && !businessHours.isEmpty
    }
    
    @MainActor
    func saveProfile() {
        guard let userID = auth.currentUserID else { 
            self.errorMessage = "User session not found. Please sign out and sign in again."
            self.showError = true
            return 
        }
        
        self.isSubmitting = true
        
        Task {
            do {
                let payload: [String: AnyJSON] = [
                    "shop_id": .string(userID),
                    "shop_name": .string(shopName),
                    "address": .string(address),
                    "phone_number": .string(phoneNumber),
                    "business_hours": .string(businessHours),
                    "verified": .bool(false)
                ]
                
                try await supabase
                    .from("shops")
                    .upsert(payload)
                    .execute()
                
                print("✅ Shop profile completed for \(userID)")
                
                auth.needsProfileSetup = false
                self.isSubmitting = false
            } catch {
                print("❌ Setup error: \(error)")
                self.errorMessage = error.localizedDescription
                self.showError = true
                self.isSubmitting = false
            }
        }
    }
}
