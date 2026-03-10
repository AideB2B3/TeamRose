import SwiftUI
import Combine

class AppRouter: ObservableObject {
    static let shared = AppRouter()
    
    @Published var selectedRole: UserRole = .customer
    
    enum UserRole {
        case customer
        case shop
    }
}
