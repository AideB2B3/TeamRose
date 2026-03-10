import SwiftUI

struct OrderRowCard: View {
    let order: CustomerOrder
    let statusAction: (CustomerOrder.OrderStatus) -> Void
    
    var statusColor: Color {
        switch order.status {
        case .pending: return .orange
        case .inProgress: return .blue
        case .waitingForParts: return .purple
        case .readyForPickup: return .green
        case .completed: return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header showing the status
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(order.status.rawValue.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(statusColor)
                
                Spacer()
                
                // Mail-in Badge
                if order.isMailIn {
                    HStack(spacing: 4) {
                        Image(systemName: "shippingbox.fill")
                        Text("MAIL-IN")
                    }
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
                }
            }
            .padding()
            .background(Color.primary.opacity(0.02))
            
            Divider()
            
            // Client & Device detail body
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.customerName)
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "phone.fill")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(order.customerPhone)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    // Interaction Menu to switch status
                    Menu {
                        ForEach(CustomerOrder.OrderStatus.allCases) { status in
                            Button(status.rawValue) {
                                statusAction(status)
                            }
                        }
                    } label: {
                        Text("Update")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.secondary.opacity(0.1))
                            .foregroundStyle(.primary)
                            .clipShape(Capsule())
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "candybarphone")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text(order.deviceModel)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    HStack(alignment: .top, spacing: 4) {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text(order.issue)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground).opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}
