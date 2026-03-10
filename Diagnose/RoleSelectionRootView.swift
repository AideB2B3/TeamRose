import SwiftUI

struct RoleSelectionRootView: View {
    @ObservedObject private var router = AppRouter.shared
    @StateObject private var auth = AuthManager.shared

    var body: some View {
        Group {
            switch router.selectedRole {
            case .customer:
                ContentView()
                    .transition(.move(edge: .leading))
            case .shop:
                Group {
                    if let _ = auth.currentUserID {
                        if auth.needsProfileSetup {
                            ShopSetupView()
                        } else {
                            MainDashboardView()
                        }
                    } else {
                        ShopLoginView()
                    }
                }
                .transition(.move(edge: .trailing))
            }
        }
    }
}
