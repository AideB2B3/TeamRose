import SwiftUI

struct MainDashboardView: View {
    @State private var viewModel = ShopDashboardViewModel()
    @State private var showingAddService = false
    @State private var showingProfile = false
    
    // Tab tracking
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                // Home Tab
                ZStack {
                    PerfectBackground()
                    DashboardHomeTab(viewModel: viewModel)
                        // Add some bottom padding so content isn't under native tab bar
                        .padding(.bottom, 20) 
                }
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "square.grid.2x2.fill" : "square.grid.2x2")
                    Text("Others")
                }
                .tag(0)
                
                // Services Tab
                ZStack {
                    PerfectBackground()
                    DashboardServicesTab(viewModel: viewModel, showingAddService: $showingAddService)
                }
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "wrench.and.screwdriver.fill" : "wrench.and.screwdriver")
                    Text("Services")
                }
                .tag(1)
            }
            .tint(.brandPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                // Load services + device/problem lookup tables from Supabase
                await viewModel.loadAll()
            }
            .toolbar {                
                ToolbarItem(placement: .topBarTrailing) {
                    // Profile Button on Top Right always available
                    Button(action: { showingProfile = true }) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(Color.brandPrimary)
                            .background(Circle().fill(.white))
                    }
                }
            }
            .sheet(isPresented: $showingAddService) {
                AddServiceView(viewModel: viewModel)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView(viewModel: viewModel)
                    .presentationDetents([.fraction(0.85), .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    MainDashboardView()
}
