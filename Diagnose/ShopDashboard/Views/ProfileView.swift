import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    var viewModel: ShopDashboardViewModel
    
    @State private var isEditing = false
    @State private var editName = ""
    @State private var editAddress = ""
    @State private var editPhone = ""
    @State private var editHours = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                PerfectBackground()
                
                VStack(spacing: 24) {
                    // Profile Header
                    VStack {
                        ZStack {
                            Circle()
                                .fill(Color.brandPrimary.opacity(0.2))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "apple.logo") // Emphasize it's an Apple focused shop
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundStyle(Color.brandPrimary)
                                .background(
                                    Circle().fill(Color(.systemBackground)).frame(width: 100, height: 100)
                                )
                        }
                        .padding(.top, 40)
                        
                        Text(viewModel.shopProfile?.shop_name ?? "Loading...")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 8)
                        
                        Text(AuthManager.shared.currentUserID ?? "Account ID")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        // Added Location info
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.brandPrimary)
                            Text(viewModel.shopProfile?.address ?? "Address not set")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                    }
                    
                    // The Big Ratings Analytics Card Added to Profile
                    AnalyticsCard(
                        title: "Rating",
                        value: String(format: "%.1f", viewModel.averageRating),
                        icon: "star.fill",
                        color: .brandPrimary
                    )
                    .padding(.horizontal, 24)
                    
                    // Quick Stats Row
                    HStack(spacing: 20) {
                        ProfileStatItem(title: "Lifetime Fixes", value: "1,204")
                        Divider().frame(height: 40)
                        ProfileStatItem(title: "Apples Saved", value: "98%")
                        Divider().frame(height: 40)
                        ProfileStatItem(title: "Active Jobs", value: "\(viewModel.pendingOrdersCount)")
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal)
                    
                    // Options List
                    List {
                        Section("Public Information") {
                            HStack {
                                Label("Phone Number", systemImage: "phone")
                                Spacer()
                                Text(viewModel.shopProfile?.phone_number ?? "Not set").foregroundStyle(.secondary)
                            }
                            HStack {
                                Label("Business Hours", systemImage: "clock")
                                Spacer()
                                Text(viewModel.shopProfile?.business_hours ?? "Not set").foregroundStyle(.secondary)
                            }
                        }
                        
                        Section("Shop Details & Payment") {
                            HStack {
                                Label("Shop Details", systemImage: "storefront")
                                Spacer()
                                Text(viewModel.shopProfile?.shop_name ?? "FIXO").foregroundStyle(.secondary)
                            }
                            
                            HStack {
                                Label("Mail-in Address", systemImage: "envelope")
                                Spacer()
                                Text(viewModel.shopProfile?.address ?? "Not set").foregroundStyle(.secondary)
                            }
                            
                            HStack {
                                Label("Payment Methods", systemImage: "creditcard")
                                Spacer()
                                Text("Visa, Apple Pay").foregroundStyle(.secondary)
                            }
                        }
                        
                        Section("Account Options") {
                            Button(action: {
                                withAnimation {
                                    AppRouter.shared.selectedRole = .customer
                                    dismiss()
                                }
                            }) {
                                Label("I am a Customer", systemImage: "person.fill")
                                    .foregroundColor(.primary)
                            }
                            
                            Label("Support", systemImage: "questionmark.circle")
                            Button(role: .destructive) {
                                Task {
                                    await AuthManager.shared.signOut()
                                    dismiss()
                                }
                            } label: {
                                Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .navigationTitle("Shop Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if isEditing {
                        Button("Cancel") {
                            isEditing = false
                        }
                    } else {
                        Button("Edit") {
                            editName = viewModel.shopProfile?.shop_name ?? ""
                            editAddress = viewModel.shopProfile?.address ?? ""
                            editPhone = viewModel.shopProfile?.phone_number ?? ""
                            editHours = viewModel.shopProfile?.business_hours ?? ""
                            isEditing = true
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing {
                        Button("Save") {
                            Task {
                                await viewModel.updateShopProfile(name: editName, address: editAddress, phone: editPhone, hours: editHours)
                                isEditing = false
                            }
                        }
                        .fontWeight(.bold)
                    } else {
                        Button(action: { dismiss() }) {
                            Text("Done")
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                NavigationStack {
                    Form {
                        Section("Shop Details") {
                            TextField("Shop Name", text: $editName)
                            TextField("Address", text: $editAddress)
                            TextField("Phone Number", text: $editPhone)
                            TextField("Business Hours", text: $editHours)
                        }
                    }
                    .navigationTitle("Edit Profile")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") { isEditing = false }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Save") {
                                Task {
                                    await viewModel.updateShopProfile(name: editName, address: editAddress, phone: editPhone, hours: editHours)
                                    isEditing = false
                                }
                            }
                            .fontWeight(.bold)
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}

// Helper stat item view
struct ProfileStatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
