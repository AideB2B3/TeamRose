import SwiftUI

struct ServiceRowCard: View {
    let service: ServiceItem
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon representing the repair style
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.brandPrimary.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.title2)
                    .foregroundStyle(Color.brandPrimary)
            }
            
            // Text Content Data
            VStack(alignment: .leading, spacing: 4) {
                Text(service.deviceModel)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text(service.issue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Price and Delete interaction
            VStack(alignment: .trailing, spacing: 8) {
                Text(String(format: "$%.2f", service.price))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .padding(6)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}
