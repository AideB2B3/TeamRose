import SwiftUI

struct DashboardServicesTab: View {
    var viewModel: ShopDashboardViewModel
    @Binding var showingAddService: Bool
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    HStack {
                        Text("Offerings")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    LazyVStack(spacing: 16) {
                        if viewModel.services.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "tray")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.tertiary)
                                Text("No services yet.")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 60)
                        } else {
                            ForEach(viewModel.services) { service in
                                NavigationLink(destination: ServiceDetailView(service: service)) {
                                    ServiceRowCard(service: service, onDelete: {
                                        withAnimation {
                                            viewModel.deleteService(id: service.id)
                                        }
                                    })
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                .padding(.bottom, 100) // Space for FAB
            }
            
            // Add service Floating Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAddService = true }) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.title2.weight(.bold))
                            Text("New Service")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(Color.brandPrimary)
                        .clipShape(Capsule())
                        .shadow(color: .brandPrimary.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}
