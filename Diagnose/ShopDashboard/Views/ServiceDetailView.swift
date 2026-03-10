import SwiftUI

struct ServiceDetailView: View {
    let service: ServiceItem
    
    var body: some View {
        ZStack {
            PerfectBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Image
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.brandPrimary.opacity(0.15))
                            .frame(height: 200)
                        
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(Color.brandPrimary)
                            .shadow(color: .brandPrimary.opacity(0.3), radius: 10, x: 0, y: 10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Main info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(service.deviceBrand) \(service.deviceModel)")
                            .font(.title)
                            .fontWeight(.black)
                        
                        Text(service.issue)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    
                    // Info Cards
                    HStack(spacing: 16) {
                        DetailCard(title: "Price", value: String(format: "€%.2f", service.price), icon: "dollarsign.circle.fill")
                        DetailCard(title: "Device", value: service.deviceModel, icon: "iphone")
                    }
                    .padding(.horizontal)
                    
                    // Additional mock details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Service Description")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("Get your device back to perfect condition. This service covers the full diagnostic testing, replacement parts, and post-repair quality assurance. We only use certified premium components for every fix.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                        
                        Divider().padding(.vertical, 8)
                        
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Color.brandPrimary)
                            Text("Lifetime Guarantee Included")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Service Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(Color.brandPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        ServiceDetailView(service: ServiceItem(dbID: 1, deviceBrand: "Apple", deviceModel: "iPhone 15 Pro", issue: "Screen Replacement", price: 199.99))
    }
}
