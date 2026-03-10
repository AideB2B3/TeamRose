import Foundation
import Combine
import Supabase

class CustomerOrdersViewModel: ObservableObject {
    @Published var orders: [BookingRow] = []
    @Published var isLoading = false
    
    @MainActor
    func fetchOrders() async {
        guard let userID = AuthManager.shared.currentUserID else {
            self.orders = []
            return
        }
        
        isLoading = true
        do {
            let response: [BookingRow] = try await supabase
                .from("bookings")
                .select()
                .eq("customer_id", value: userID)
                .order("booking_date", ascending: false)
                .execute()
                .value
            
            self.orders = response
            print("✅ Fetched \(response.count) orders for customer: \(userID)")
        } catch {
            print("❌ Error fetching customer orders: \(error)")
        }
        isLoading = false
    }
}
