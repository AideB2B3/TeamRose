
import SwiftUI
import VisionKit

struct CardEntrySheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var cardholderName = ""
    @State private var isProcessing = false
    @State private var showScanner = false
    
    var onCompletion: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 1. PREMIUM CARD DESIGN
                        cardPreview
                            .padding(.top, 10)
                        
                        // 2. SCAN PROMPT
                        Button {
                            showScanner = true
                        } label: {
                            HStack {
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 18, weight: .bold))
                                Text("Scan Real Card")
                                    .font(.system(.subheadline, design: .rounded).bold())
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(14)
                            .shadow(color: Color.black.opacity(0.04), radius: 10)
                        }
                        .padding(.horizontal)
                        
                        // 3. SECURE FORM
                        VStack(alignment: .leading, spacing: 20) {
                            Text("PAYMENT DETAILS")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 16) {
                                SecureCardInputField(label: "Full Name", text: $cardholderName, placeholder: "Cardholder's Name", icon: "person.fill")
                                
                                SecureCardInputField(label: "Card Number", text: $cardNumber, placeholder: "0000 0000 0000 0000", icon: "creditcard.fill", keyboardType: .numberPad)
                                    .onChange(of: cardNumber) { newValue in
                                        cardNumber = formatCardNumberForInput(newValue)
                                    }
                                
                                HStack(spacing: 16) {
                                    SecureCardInputField(label: "Expiry", text: $expiryDate, placeholder: "MM / YY", icon: "calendar", keyboardType: .numberPad)
                                        .onChange(of: expiryDate) { newValue in
                                            expiryDate = formatExpiry(newValue)
                                        }
                                    
                                    SecureCardInputField(label: "CVV", text: $cvv, placeholder: "•••", icon: "lock.fill", keyboardType: .numberPad)
                                        .onChange(of: cvv) { newValue in
                                            cvv = String(newValue.filter { $0.isNumber }.prefix(3))
                                        }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // 4. SECURITY BADGES
                        VStack(spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "shield.lefthalf.filled")
                                    .foregroundColor(.green)
                                Text("Secured by SSL (AES-256)")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            
                            HStack {
                                Image(systemName: "network")
                                Text("GATEWAY: STRIPE_v3_CLOUD")
                                Spacer()
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.blue)
                                Text("BANK VERIFIED")
                            }
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                        
                        Spacer(minLength: 60)
                    }
                }
                
                // 5. STICKY ACTION BUTTON (Native Feel)
                VStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Button {
                            processPayment()
                        } label: {
                            HStack {
                                if isProcessing {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Pay €115.00 Securely")
                                        .font(.system(.body, design: .rounded).bold())
                                    Image(systemName: "lock.fill").font(.caption)
                                }
                            }
                            .primaryButtonStyle()
                        }
                        .disabled(!isFormValid || isProcessing)
                        .opacity(isFormValid ? 1.0 : 0.6)
                        
                        Text("Your bank may require 3D Secure verification")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("Secure Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showScanner) {
                MockScannerView { scannedNum, scannedName in
                    cardNumber = scannedNum
                    cardholderName = scannedName
                    showScanner = false
                }
            }
        }
    }
    
    // UI COMPONENTS
    private var cardPreview: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "creditcard.fill").font(.title2)
                Spacer()
                Text(cardBrand).font(.system(size: 18, weight: .black, design: .rounded))
            }
            Spacer()
            Text(cardNumber.isEmpty ? "•••• •••• •••• ••••" : cardNumber)
                .font(.system(size: 22, weight: .semibold, design: .monospaced))
            
            HStack {
                VStack(alignment: .leading) {
                    Text("CARD HOLDER").font(.system(size: 9, weight: .bold))
                    Text(cardholderName.isEmpty ? "ACADEMY STUDENT" : cardholderName.uppercased()).font(.system(.headline, design: .rounded).bold())
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("EXPIRES").font(.system(size: 9, weight: .bold))
                    Text(expiryDate.isEmpty ? "MM/YY" : expiryDate).font(.system(.headline, design: .rounded).bold())
                }
            }
        }
        .padding(24)
        .frame(height: 190)
        .background(
            LinearGradient(
                colors: cardBrandColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundColor(.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.15), radius: 15, y: 10)
        .padding(.horizontal)
    }

    // LOGIC
    var cardBrand: String {
        let clean = cardNumber.replacingOccurrences(of: " ", with: "")
        if clean.hasPrefix("4") { return "VISA" }
        if clean.hasPrefix("5") { return "MASTERCARD" }
        return "BANK"
    }
    
    var cardBrandColors: [Color] {
        let clean = cardNumber.replacingOccurrences(of: " ", with: "")
        if clean.hasPrefix("4") { return [Color.blue.opacity(0.9), Color.blue] }
        if clean.hasPrefix("5") { return [Color.red.opacity(0.8), Color.orange.opacity(0.9)] }
        return [BrandColor.primary.opacity(0.9), BrandColor.primary]
    }
    
    var isFormValid: Bool {
        cardNumber.count >= 19 && expiryDate.count == 5 && cvv.count == 3 && !cardholderName.isEmpty
    }
    
    func formatCardNumberForInput(_ number: String) -> String {
        let clean = number.filter { $0.isNumber }
        var result = ""
        for (index, char) in clean.enumerated() {
            if index > 0 && index % 4 == 0 { result += " " }
            result.append(char)
        }
        return String(result.prefix(19))
    }
    
    func formatExpiry(_ number: String) -> String {
        let clean = number.filter { $0.isNumber }
        if clean.count >= 3 {
            return "\(clean.prefix(2))/\(clean.suffix(clean.count - 2).prefix(2))"
        }
        return String(clean.prefix(5))
    }
    
    func processPayment() {
        isProcessing = true
        
        // 🔒 CALLING THE REAL STRIPE API FLOW
        let cleanNum = cardNumber.replacingOccurrences(of: " ", with: "")
        
        // Extract Expiry
        let components = expiryDate.components(separatedBy: "/")
        let month = Int(components.first ?? "0") ?? 0
        let year = Int(components.last ?? "0") ?? 0
        
        StripeManager.shared.createPaymentToken(number: cleanNum, expMonth: month, expYear: year, cvc: cvv) { token in
            self.isProcessing = false
            dismiss()
            onCompletion()
        }
    }
}

// PREMIUM INPUT FIELD
struct SecureCardInputField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(BrandColor.primary)
                    .font(.system(size: 16))
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .font(.system(.body, design: .rounded))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
    }
}

// SCANNER COMPONENT (MOCK)
struct MockScannerView: View {
    var onScan: (String, String) -> Void
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 30) {
                Text("Scan Physical Card")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 320, height: 200)
                    
                    Rectangle()
                        .fill(Color.orange.opacity(0.3))
                        .frame(width: 320, height: 2)
                }
                
                Text( "Keep the card within the frame" )
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Button("Simulate OCR Detection") {
                    onScan("4242 4242 4242 4242", "STEFANO BIANCHI")
                }
                .foregroundColor(.white)
                .padding()
                .background(BrandColor.primary)
                .cornerRadius(16)
                
                Button("Cancel") { dismiss() }
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}
