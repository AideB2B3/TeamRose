import Foundation
import Supabase

// MARK: - Supabase Configuration
// Real Supabase Connection!
let supabaseURL = URL(string: "https://hbqviplofnitufvymcyf.supabase.co")!
let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhicXZpcGxvZm5pdHVmdnltY3lmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI4MDQxNTMsImV4cCI6MjA4ODM4MDE1M30.mYyZYE3lIuowUi1iKNTwMWJZAN_IZhEDjqVythgqWP4"

/// The single global instance of the Supabase Client
let supabase = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)

// MARK: - Database Services
/// A manager class to handle fetching and sending data to your live database
class SupabaseManager: ObservableObject {
    
    // Example: Fetch all shops from the 'shops' table
    @Published var liveShops: [ShopItem] = []
    
    @MainActor
    func fetchShops() async {
        do {
            // This reads the 'shops' table you just created!
            let fetchedShops: [ShopRow] = try await supabase
                .from("shops")
                .select()
                .execute()
                .value
            
            // Convert database model to UI model
            self.liveShops = fetchedShops.map { row in
                ShopItem(
                    name: row.shop_name,
                    location: row.city ?? "Unknown",
                    price: "$100", // Will eventually come from shop_services
                    rating: row.rating ?? 0.0,
                    isFastest: true,
                    imageName: "building.fill",
                    repairType: "Diagnostics"
                )
            }
        } catch {
            print("Error parsing / fetching Supabase Data: \(error)")
        }
    }
}

// MARK: - Database Row Models
// These match exactly what you wrote in your SQL!
struct ShopRow: Decodable {
    let id: Int
    let shop_name: String
    let city: String?
    let address: String?
    let phone: String?
    let rating: Double?
    let verified: Bool?
    let latitude: Double?
    let longitude: Double?
}
