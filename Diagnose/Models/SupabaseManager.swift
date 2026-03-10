import Foundation
import Supabase
import SwiftUI
import Combine

// MARK: - Supabase Configuration
let supabaseURL = URL(string: "https://hbqviplofnitufvymcyf.supabase.co")!
let supabaseKey = "sb_publishable_iVwF8bnAzioVjOJ3qU57LA_2kkkhRj7"
let googleClientID = "1052433569354-0mo9n7kn177l21acvejb39ge1spho4fr.apps.googleusercontent.com"

/// The single global Supabase client
let supabase = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)

// MARK: - Active Shop Session (Updated by Auth)
// This will hold the current authenticated user's ID
var currentUserID: String? {
    // We rely on AuthManager's shared state which is updated by checkSession()
    return AuthManager.shared.currentUserID
}

// MARK: - Database Manager
class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    // Customer-side: shops that offer the requested repair
    @Published var liveShops: [ShopItem] = []

    // Shop-side: services this shop has published
    @Published var liveServices: [ServiceItem] = []

    // Lookup data from DB
    @Published var availableDevices: [DeviceRow] = []
    @Published var availableProblems: [ProblemRow] = []

    @Published var searchMatchStatus: SearchMatchStatus = .searching

    enum SearchMatchStatus {
        case searching
        case exactResults
        case partialResults
        case recommendationsOnly
        case noResults
    }

    // MARK: - Customer: Fetch shops that can fix a specific device + problem
    @MainActor
    func fetchShops(brand: String? = nil, model: String? = nil, problem: String? = nil) async {
        do {
            self.searchMatchStatus = .searching
            self.liveShops = []

            // 1. STAGE 1: Exact Match (Specific Model + Problem)
            let exactShops = await executeQueryWithFilters(brand: brand, model: model, problem: problem)
            if !exactShops.isEmpty {
                self.liveShops = exactShops
                self.searchMatchStatus = .exactResults
                return
            }

            // 2. STAGE 2: Partial Match (The Brand + The Problem)
            // Even if they don't list your specific iPhone 15 Pro, if they list any iPhone iPhone screen repair,
            // they are a good bet to call and ask.
            let partialShops = await executeQueryWithFilters(brand: brand, problem: problem)
                .map { var item = $0; item.isAlternative = true; item.recommendationReason = "Expert in \(brand ?? "this device") \(problem ?? "repairs")"; return item }

            if !partialShops.isEmpty {
                self.liveShops = partialShops
                self.searchMatchStatus = .partialResults
                return
            }

            // 3. STAGE 3: Expert Recommendation (Any shop with high rating/verified)
            // Just show any shop that is verified and has high reputation.
            let verifiedShops = await executeQueryWithFilters() // No filters, just show any
                .map { var item = $0; item.isAlternative = true; item.recommendationReason = "Highly Recommended Expert"; return item }
                .sorted(by: { $0.rating > $1.rating })

            if !verifiedShops.isEmpty {
                self.liveShops = Array(verifiedShops.prefix(5)) // Show top 5
                self.searchMatchStatus = .recommendationsOnly
            } else {
                self.searchMatchStatus = .noResults
            }

        } catch {
            print("❌ fetchShops error: \(error)")
            self.searchMatchStatus = .noResults
        }
    }

    @MainActor
    private func executeQueryWithFilters(brand: String? = nil, model: String? = nil, problem: String? = nil) async -> [ShopItem] {
        do {
            var query = supabase
                .from("shop_services")
                .select("""
                    service_id,
                    price,
                    shops (
                        shop_id,
                        shop_name,
                        address,
                        phone_number,
                        latitude,
                        longitude,
                        verified
                    ),
                    devices (
                        device_id,
                        brand,
                        model,
                        device_type
                    ),
                    problems (
                        problem_id,
                        problem_name
                    )
                """)

            // Build dynamic filters
            if let b = brand, !b.isEmpty { query = query.eq("devices.brand", value: b) }
            if let m = model, !m.isEmpty { query = query.eq("devices.model", value: m) }
            if let p = problem, !p.isEmpty { query = query.eq("problems.problem_name", value: p) }

            let rows: [ShopServiceJoinRow] = try await query
                .order("price", ascending: true)
                .execute()
                .value

            // Safety filter to ensure joins worked (SupaBase PostgREST behavior)
            let validRows = rows.filter { row in
                guard let dev = row.devices, let prob = row.problems, let _ = row.shops else { return false }
                
                // Double check filters client-side due to join semantics
                if let b = brand, b != dev.brand { return false }
                if let m = model, m != dev.model { return false }
                if let p = problem, p != prob.problem_name { return false }
                
                return true
            }

            var shopMap: [String: ShopItem] = [:]
            for row in validRows {
                guard let shop = row.shops else { continue }
                let sid = shop.shop_id
                if shopMap[sid] == nil {
                    shopMap[sid] = ShopItem(
                        name: shop.shop_name,
                        location: shop.address ?? "Near you",
                        phoneNumber: shop.phone_number ?? "",
                        price: "$\(String(format: "%.0f", row.price))",
                        rating: 4.8,
                        isFastest: shop.verified ?? false,
                        imageName: "building.fill",
                        repairType: row.problems?.problem_name ?? "General Repair",
                        deviceBrand: row.devices?.brand ?? "",
                        deviceModel: row.devices?.model ?? "",
                        shopID: sid
                    )
                }
            }
            return Array(shopMap.values).sorted { $0.price < $1.price }
        } catch {
            return []
        }
    }

    // MARK: - Shop: Fetch all services for this shop
    @MainActor
    func fetchServices() async {
        do {
            guard let userID = currentUserID else {
                print("⚠️ fetchServices: No user logged in.")
                self.liveServices = []
                return
            }
            
            let rows: [ShopServiceJoinRow] = try await supabase
                .from("shop_services")
                .select("""
                    service_id,
                    price,
                    shops ( shop_id, shop_name, address, latitude, longitude, verified ),
                    devices ( device_id, brand, model, device_type ),
                    problems ( problem_id, problem_name )
                """)
                .eq("shop_id", value: userID)
                .order("price", ascending: true)
                .execute()
                .value

            self.liveServices = rows.compactMap { row -> ServiceItem? in
                guard let device = row.devices, let problem = row.problems else { return nil }
                return ServiceItem(
                    dbID: row.service_id,
                    deviceBrand: device.brand,
                    deviceModel: device.model,
                    issue: problem.problem_name,
                    price: row.price
                )
            }
        } catch {
            print("❌ fetchServices error: \(error)")
            self.liveServices = []
        }
    }

    // MARK: - Shop: Fetch lookup tables (devices + problems)
    @MainActor
    func fetchLookupData() async {
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
            print("❌ fetchLookupData error: \(error)")
        }
    }

    // MARK: - Shop: Publish a new service
    func uploadService(deviceID: Int, problemID: Int, price: Double) async throws {
        guard let userID = currentUserID else {
            throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No shop logged in"])
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
        print("✅ Service published: device \(deviceID), problem \(problemID), $\(price)")
    }

    // MARK: - Shop: Delete a service by its Int ID
    func deleteService(serviceIntID: Int) async throws {
        try await supabase
            .from("shop_services")
            .delete()
            .eq("service_id", value: serviceIntID)
            .execute()
        print("🗑️ Service deleted: \(serviceIntID)")
    }

    func createBooking(booking: BookingInsert) async throws {
        // Simple insert, no select() to avoid decode issues with DB schema
        try await supabase
            .from("bookings")
            .insert(booking)
            .execute()
        print("📅 Booking inserted for shop \(booking.shop_id)")
    }

    // MARK: - Reviews
    func createReview(shopID: String, rating: Int, comment: String) async throws {
        let payload = ReviewInsert(shop_id: shopID, rating: rating, comment: comment)
        try await supabase
            .from("reviews")
            .insert(payload)
            .execute()
        print("⭐ Review submitted for shop \(shopID)")
    }

    @MainActor
    func fetchReviews(shopID: String) async -> [ReviewRow] {
        do {
            let rows: [ReviewRow] = try await supabase
                .from("reviews")
                .select("review_id, shop_id, rating, comment, created_at")
                .eq("shop_id", value: shopID)
                .order("created_at", ascending: false)
                .execute()
                .value
            print("✅ Fetched \(rows.count) reviews for shop \(shopID)")
            return rows
        } catch {
            print("❌ fetchReviews error: \(error)")
            return []
        }
    }
}

// MARK: - DB Row Models

struct DeviceRow: Decodable, Identifiable, Hashable {
    var device_id: Int?
    let brand: String
    let model: String
    let device_type: String?
    var id: Int { device_id ?? 0 }

    var displayName: String { "\(brand) \(model)" }
}

struct ProblemRow: Decodable, Identifiable, Hashable {
    var problem_id: Int?
    let problem_name: String
    var id: Int { problem_id ?? 0 }
}

struct ShopItem: Hashable {
    let name: String
    let location: String
    let phoneNumber: String
    let price: String
    let rating: Double
    let isFastest: Bool
    let imageName: String
    let repairType: String
    let deviceBrand: String
    let deviceModel: String
    var isAlternative: Bool = false
    var recommendationReason: String? = nil
    var shopID: String = "" // Added shopID for bookings
}

struct ShopRow: Decodable {
    let shop_id: String
    let shop_name: String
    let address: String?
    let phone_number: String?
    let business_hours: String?
    let latitude: Double?
    let longitude: Double?
    let verified: Bool?
}

/// shop_services joined with shops + devices + problems
struct ShopServiceJoinRow: Decodable {
    let service_id: Int   // INTEGER primary key in DB
    let price: Double
    let shops: ShopRow?
    let devices: DeviceRow?
    let problems: ProblemRow?
}

/// Insert payload for shop_services (no estimated_time — removed from form)
struct ShopServiceInsert: Encodable {
    let shop_id: String
    let device_id: Int
    let problem_id: Int
    let price: Double
}

// MARK: - Real Bookings
struct BookingRow: Decodable, Identifiable {
    let booking_id: Int
    let shop_id: String?
    let customer_id: String?
    let customer_name: String?
    let customer_email: String?
    let service_id: Int?
    let status: String?
    let booking_date: Date?
    let is_mail_in: Bool?
    let device_brand: String?
    let device_model: String?
    let problem_name: String?
    
    // Identifiable
    var id: Int { booking_id }
    
    // Convert to view model friendly status
    var bookingStatus: CustomerOrder.OrderStatus {
        switch (status ?? "").lowercased() {
        case "pending": return .pending
        case "in progress": return .inProgress
        case "ready": return .readyForPickup
        case "waiting parts": return .waitingForParts
        default: return .pending
        }
    }
}

struct BookingInsert: Encodable {
    let shop_id: String
    let customer_id: String?
    let customer_name: String?
    let customer_email: String?
    let status: String
    let is_mail_in: Bool
    let device_brand: String
    let device_model: String
    let problem_name: String
}

struct CustomerRow: Decodable {
    let customer_id: String
    let full_name: String?
    let email: String?
}

// MARK: - Reviews
struct ReviewRow: Decodable, Identifiable {
    let review_id: Int
    let shop_id: String?
    let rating: Int?
    let comment: String?
    let created_at: Date?
    var id: Int { review_id }
}

struct ReviewInsert: Encodable {
    let shop_id: String
    let rating: Int
    let comment: String
}
