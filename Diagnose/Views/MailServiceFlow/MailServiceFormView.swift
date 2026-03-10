
import SwiftUI

struct MailServiceFormView: View {
    let shop: ShopItem
    @StateObject private var auth = AuthManager.shared

    @State private var name = ""
    @State private var email = ""
    @State private var address = ""
    @State private var city = ""
    @State private var shouldNavigate = false
    @State private var isProcessing = false
    @State private var shipmentResult: ShipmentResult? = nil
    var onSuccess: () -> Void

    var isFormComplete: Bool {
        !name.isEmpty && email.contains("@") && !address.isEmpty && !city.isEmpty
    }

    var body: some View {
        Group {
            if auth.currentUserID != nil {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        headerSection
                        priceSpotlightCard
                        pickupLocationForm
                        summarySection
                        paymentActionSection
                    }
                }
                .navigationDestination(isPresented: $shouldNavigate) {
                    if let result = shipmentResult {
                        MailServiceConfirmationView(result: result) {
                            onSuccess()
                        }
                    }
                }
            } else {
                CustomerLoginView(isInline: true)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mail-In Service")
                .font(.system(size: 32, weight: .black, design: .rounded))
            Text("Professional tech repair from the comfort of your home. We handle the pickup and return.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }

    // MARK: - Pricing Card
    private var priceSpotlightCard: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("All-Inclusive Delivery").font(.headline)
                    Text("Fast DHL Express Pickup + Return").font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Text("€15.00")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(BrandColor.primary)
            }
            .padding(20)
            .background(Color.white)

            Divider()

            HStack(spacing: 15) {
                BenefitSmall(icon: "checkmark.shield.fill", text: "Insured")
                BenefitSmall(icon: "timer", text: "24h Transit")
                BenefitSmall(icon: "location.fill", text: "Real-time")
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(BrandColor.primary.opacity(0.03))
        }
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(BrandColor.primary.opacity(0.1), lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 8)
        .padding(.horizontal)
    }

    // MARK: - Form
    private var pickupLocationForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Pickup Location").font(.headline)
                Spacer()
                Button {
                    name = "ALESSANDRO ROSSI"
                    email = "rossi@academy.it"
                    address = "Via Appia Nuova, 12"
                    city = "Rome"
                } label: {
                    Text("USE DEMO DATA")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(BrandColor.primary)
                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(BrandColor.primary, lineWidth: 1))
                }
            }
            .padding(.horizontal)

            VStack(spacing: 16) {
                MailFormTextField(label: "Full Name", text: $name, placeholder: "Enter your name", icon: "person.fill")
                MailFormTextField(label: "Contact Email", text: $email, placeholder: "your@email.com", icon: "envelope.fill")
                MailFormTextField(label: "Street Address", text: $address, placeholder: "Street Name, No.", icon: "location.fill")
                MailFormTextField(label: "City", text: $city, placeholder: "Enter city", icon: "building.2.fill")
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Summary
    private var summarySection: some View {
        let repairPriceStr = shop.price.replacingOccurrences(of: "$", with: "")
        let repairPrice = Double(repairPriceStr) ?? 0.0
        let total = repairPrice + 15.0

        return VStack(alignment: .leading, spacing: 16) {
            Text("Total Summary").font(.headline).padding(.horizontal)
            VStack(spacing: 12) {
                SummaryRow(label: "Repair Cost", value: shop.price)
                SummaryRow(label: "Mail Service", value: "$15.00")
                Divider().padding(.vertical, 4)
                SummaryRow(label: "Estimated Total", value: "$\(String(format: "%.2f", total))", isTotal: true)
            }
            .padding(24)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(24)
            .padding(.horizontal)
        }
    }

    // MARK: - Action Button
    private var paymentActionSection: some View {
        VStack(spacing: 12) {
            if !isFormComplete {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                    Text("Please complete all fields above to proceed").font(.caption.bold())
                }
                .foregroundColor(.red.opacity(0.8))
                .padding(.bottom, 4)
            }

            Button {
                Task { await proceedToBooking() }
            } label: {
                HStack {
                    if isProcessing {
                        ProgressView().tint(.white)
                        Text("Processing...").bold()
                    } else {
                        Image(systemName: "shippingbox.fill")
                        Text("Confirm Order & Get Label")
                            .font(.headline.bold())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormComplete ? Color.brandPrimary : Color.gray.opacity(0.4))
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: Color.brandPrimary.opacity(0.3), radius: 10, y: 5)
            }
            .disabled(!isFormComplete || isProcessing)
        }
        .padding(.horizontal)
        .padding(.bottom, 50)
    }

    // MARK: - Book & Navigate (direct async, no onChange)
    @MainActor
    private func proceedToBooking() async {
        isProcessing = true

        // 1. Save booking to Supabase
        print("📡 [Booking] shopID=\(shop.shopID) | customerID=\(auth.currentUserID ?? "nil")")
        if !shop.shopID.isEmpty {
            let booking = BookingInsert(
                shop_id: shop.shopID,
                customer_id: auth.currentUserID,
                customer_name: name,
                customer_email: email,
                status: "Pending",
                is_mail_in: true,
                device_brand: shop.deviceBrand,
                device_model: shop.deviceModel,
                problem_name: shop.repairType
            )
            do {
                try await SupabaseManager.shared.createBooking(booking: booking)
                print("✅ [Booking] Saved to Supabase!")
            } catch {
                print("❌ [Booking] Save failed: \(error)")
            }
        } else {
            print("❌ [Booking] shopID is empty — check ShopItem population")
        }

        // 2. Generate shipping label (1 second delay)
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // 3. Build result & navigate
        shipmentResult = ShipmentResult(
            trackingCode: "EZ10\(Int.random(in: 100000...999999))ITALY",
            labelURL: "",
            carrier: "DHL Express",
            name: name,
            address: address,
            city: city,
            shopName: shop.name,
            shopAddress: shop.location,
            isInsured: true,
            shippingType: "Express Premium"
        )

        isProcessing = false
        shouldNavigate = true
    }
}

// MARK: - Supporting types
struct PaymentMethod: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}

struct BenefitSmall: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2).foregroundColor(BrandColor.primary)
            Text(text).font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
        }
    }
}
