import SwiftUI
import Supabase

@Observable
class ShopDashboardViewModel {

    // MARK: - Published State
    var services: [ServiceItem] = []
    var isLoading: Bool = false
    var isUploading: Bool = false
    var uploadError: String? = nil

    // Lookup data from DB
    var availableDevices: [DeviceRow] = []
    var availableProblems: [ProblemRow] = []
    
    // Shop Profile Data
    var shopProfile: ShopRow? = nil

    // Orders (will wire to bookings table later)
    var customerOrders: [CustomerOrder] = []

    var reviews: [ReviewRow] = []

    // MARK: - Computed
    var pendingOrdersCount: Int {
        customerOrders.filter { $0.status == .pending || $0.status == .inProgress || $0.status == .waitingForParts }.count
    }

    var averageRating: Double {
        let rated = reviews.compactMap { $0.rating }
        if rated.isEmpty { return 0 }
        return Double(rated.reduce(0, +)) / Double(rated.count)
    }

    // MARK: - Load everything on startup
    @MainActor
    func loadAll() async {
        isLoading = true
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.refreshServices() }
            group.addTask { await self.refreshLookupData() }
            group.addTask { await self.fetchShopProfile() }
            group.addTask { await self.refreshBookings() }
            group.addTask { await self.refreshReviews() }
        }
        isLoading = false
    }

    // MARK: - Fetch services directly (no intermediate object)
    @MainActor
    func refreshServices() async {
        do {
            guard let userID = currentUserID else {
                print("⚠️ refreshServices: No user logged in.")
                self.services = []
                return
            }
            
            let rows: [ShopServiceJoinRow] = try await supabase
                .from("shop_services")
                .select("service_id, price, devices(device_id, brand, model, device_type), problems(problem_id, problem_name)")
                .eq("shop_id", value: userID)
                .order("price", ascending: true)
                .execute()
                .value

            self.services = rows.compactMap { row in
                guard let device = row.devices, let problem = row.problems else {
                    print("⚠️ Missing device or problem for service \(row.service_id)")
                    return nil
                }
                return ServiceItem(
                    dbID: row.service_id,
                    deviceBrand: device.brand,
                    deviceModel: device.model,
                    issue: problem.problem_name,
                    price: row.price
                )
            }
            print("✅ Loaded \(self.services.count) services")
        } catch {
            print("❌ refreshServices error: \(error)")
        }
    }

    // MARK: - Fetch lookup tables directly
    @MainActor
    func refreshLookupData() async {
        do {
            let devices: [DeviceRow] = try await supabase
                .from("devices")
                .select()
                .order("brand")
                .execute()
                .value
            self.availableDevices = devices

            let problems: [ProblemRow] = try await supabase
                .from("problems")
                .select()
                .order("problem_name")
                .execute()
                .value
            self.availableProblems = problems
        } catch {
            print("❌ refreshLookupData error: \(error)")
        }
    }

    // MARK: - Fetch real bookings
    @MainActor
    func refreshBookings() async {
        do {
            guard let userID = currentUserID else { 
                print("⚠️ refreshBookings: No userID found")
                return 
            }
            print("📡 Fetching bookings for shop: \(userID)")
            
            let rows: [BookingRow] = try await supabase
                .from("bookings")
                .select("*")
                .eq("shop_id", value: userID)
                .order("booking_date", ascending: false)
                .execute()
                .value
            
            print("✅ Received \(rows.count) booking rows")
            
            self.customerOrders = rows.map { row in
                CustomerOrder(
                    id: UUID(),
                    dbID: row.booking_id,
                    customerName: row.customer_name ?? "Customer",
                    customerPhone: row.customer_email ?? "",
                    deviceBrand: row.device_brand ?? "",
                    deviceModel: row.device_model ?? "",
                    issue: row.problem_name ?? "",
                    price: 0,
                    status: row.bookingStatus,
                    dateReceived: row.booking_date ?? Date(),
                    isMailIn: row.is_mail_in ?? false
                )
            }
        } catch {
            print("❌ refreshBookings error: \(error)")
        }
    }

    // MARK: - Fetch Reviews from Supabase
    @MainActor
    func refreshReviews() async {
        guard let userID = currentUserID else { return }
        self.reviews = await SupabaseManager.shared.fetchReviews(shopID: userID)
    }
    
    // MARK: - Fetch Shop Profile
    @MainActor
    func fetchShopProfile() async {
        guard let userID = currentUserID else { return }
        do {
            let results: [ShopRow] = try await supabase
                .from("shops")
                .select()
                .eq("shop_id", value: userID)
                .execute()
                .value
            
            if let first = results.first {
                self.shopProfile = first
                print("✅ Loaded shop profile: \(first.shop_name)")
            }
        } catch {
            print("❌ fetchShopProfile error: \(error)")
        }
    }
    
    // MARK: - Update Shop Profile
    @MainActor
    func updateShopProfile(name: String, address: String, phone: String, hours: String) async {
        guard let userID = currentUserID else { return }
        isUploading = true
        do {
            try await supabase
                .from("shops")
                .update([
                    "shop_name": name,
                    "address": address,
                    "phone_number": phone,
                    "business_hours": hours
                ])
                .eq("shop_id", value: userID)
                .execute()
            
            // Refresh local state
            await fetchShopProfile()
            print("✅ Shop profile updated")
        } catch {
            print("❌ updateShopProfile error: \(error)")
        }
        isUploading = false
    }

    // MARK: - Add service → insert then refresh
    @MainActor
    func addService(deviceID: Int, problemID: Int, price: Double) async {
        isUploading = true
        uploadError = nil
        do {
            guard let userID = currentUserID else {
                self.uploadError = "No shop logged in"
                return
            }
            
            let payload = ShopServiceInsert(
                shop_id: userID,
                device_id: deviceID,
                problem_id: problemID,
                price: price
            )
            try await supabase
                .from("shop_services")
                .insert(payload)
                .execute()
            print("✅ Service inserted into DB")
            // Reload the list so the new item appears immediately
            await refreshServices()
        } catch {
            self.uploadError = error.localizedDescription
            print("❌ addService error: \(error)")
        }
        isUploading = false
    }

    // MARK: - Delete service
    func deleteService(id: UUID) {
        guard let service = services.first(where: { $0.id == id }) else { return }
        let dbID = service.dbID
        // Remove locally first for instant UI response
        services.removeAll(where: { $0.id == id })
        Task {
            do {
                try await supabase
                    .from("shop_services")
                    .delete()
                    .eq("service_id", value: dbID)
                    .execute()
                print("🗑️ Service \(dbID) deleted")
            } catch {
                print("❌ deleteService error: \(error)")
                // Reload to restore correct state if delete failed
                await refreshServices()
            }
        }
    }

    func updateOrderStatus(id: UUID, newStatus: CustomerOrder.OrderStatus) {
        guard let order = customerOrders.first(where: { $0.id == id }) else { return }
        let orderDBID = order.dbID
        
        // Optimistic UI update
        if let index = customerOrders.firstIndex(where: { $0.id == id }) {
            customerOrders[index].status = newStatus
        }
        
        Task {
            do {
                try await supabase
                    .from("bookings")
                    .update(["status": newStatus.rawValue])
                    .eq("id", value: orderDBID)
                    .execute()
                print("✅ Status updated in DB: \(orderDBID) to \(newStatus.rawValue)")
            } catch {
                print("❌ updateOrderStatus error: \(error)")
                await refreshBookings() // Revert UI if failed
            }
        }
    }
}
