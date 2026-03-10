import SwiftUI

struct CustomerProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var ordersViewModel = CustomerOrdersViewModel()
    @ObservedObject private var auth = AuthManager.shared
    @ObservedObject private var router = AppRouter.shared
    @State private var selectedOrder: BookingRow? = nil

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if auth.currentUserID != nil {
                        HStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.brandPrimary)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Customer Account")
                                    .font(.headline)
                                Text("Linked to your orders")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    } else {
                        VStack(spacing: 12) {
                            Text("Sign in to track your repairs")
                                .font(.subheadline)
                            Button("Sign in with Google") {
                                Task { await auth.signInWithGoogle() }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                }

                if auth.currentUserID != nil {
                    Section("My Orders") {
                        if ordersViewModel.isLoading {
                            ProgressView()
                        } else if ordersViewModel.orders.isEmpty {
                            Text("No orders found").foregroundColor(.secondary)
                        } else {
                            ForEach(ordersViewModel.orders) { order in
                                Button {
                                    selectedOrder = order
                                } label: {
                                    HStack {
                                        let icon = (order.is_mail_in ?? false) ? "shippingbox.fill" : "calendar"
                                        Image(systemName: icon)
                                            .foregroundColor(.brandPrimary)
                                        VStack(alignment: .leading) {
                                            Text("\(order.device_brand ?? "") \(order.device_model ?? "")")
                                                .font(.subheadline.bold())
                                                .foregroundColor(.primary)
                                            Text(order.problem_name ?? "")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        HStack(spacing: 4) {
                                            Text(order.status ?? "Pending")
                                                .font(.caption2.bold())
                                                .padding(6)
                                                .background(Color.yellow.opacity(0.1))
                                                .cornerRadius(6)
                                            Image(systemName: "star.bubble")
                                                .font(.caption)
                                                .foregroundColor(.brandPrimary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Section {
                    Button(action: {
                        withAnimation {
                            router.selectedRole = .shop
                            dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.brandPrimary)
                            Text(AuthManager.shared.currentUserID == nil ? "Log in as Shop" : "Shop Dashboard")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } footer: {
                    Text("Switch to the shop dashboard to manage your repair services.")
                }

                Section {
                    Button("Support") { }
                    Button("Privacy Policy") { }
                    Button("Terms of Service") { }
                }

                if auth.currentUserID != nil {
                    Section {
                        Button(role: .destructive) {
                            Task { await auth.signOut() }
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await ordersViewModel.fetchOrders()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(item: $selectedOrder) { order in
                WriteReviewView(order: order)
            }
        }
    }
}
