import SwiftUI

struct DashboardHomeTab: View {
    @Bindable var viewModel: ShopDashboardViewModel
    @State private var selectedFilter: CustomerOrder.OrderStatus? = nil
    
    var filteredOrders: [CustomerOrder] {
        if let selectedFilter {
            return viewModel.customerOrders.filter { $0.status == selectedFilter }
        } else {
            return viewModel.customerOrders
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Removed Analytics Header
                
                // Track Customers Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Customer Tracking")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: { Task { await viewModel.refreshBookings() } }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.headline)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Shortcut Keys (Filters)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            FilterChip(title: "All", isSelected: selectedFilter == nil) {
                                withAnimation { selectedFilter = nil }
                            }
                            
                            ForEach(CustomerOrder.OrderStatus.allCases) { status in
                                FilterChip(title: status.rawValue, isSelected: selectedFilter == status) {
                                    withAnimation { selectedFilter = status }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if filteredOrders.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("No orders match this filter.")
                                .foregroundStyle(.secondary)
                            Text("Pull down to refresh or check your shop ID: \(AuthManager.shared.currentUserID ?? "Unknown")")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredOrders.prefix(10)) { order in
                                OrderRowCard(order: order) { newStatus in
                                    withAnimation {
                                        viewModel.updateOrderStatus(id: order.id, newStatus: newStatus)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Recent Reviews Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Recent Reviews")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.reviews) { review in
                            ReviewRowCard(review: review)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Bottom Spacing
                Spacer().frame(height: 40)
            }
            .padding(.top)
        }
        .refreshable {
            await viewModel.loadAll()
        }
    }
}

// Sub-Component for Analytics
struct AnalyticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.black)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }
}

// Sub-Component for the Tracking Filter Chips
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.footnote)
                .fontWeight(.bold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.brandPrimary : Color.secondary.opacity(0.1))
                .foregroundColor(isSelected ? .brandNeutral : .primary)
                .clipShape(Capsule())
                .shadow(color: isSelected ? Color.brandPrimary.opacity(0.3) : .clear, radius: 4, x: 0, y: 2)
        }
    }
}
