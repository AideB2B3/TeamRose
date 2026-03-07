import Foundation

// MARK: - Models
struct Device: Identifiable {
    let id = UUID()
    let name: String
    let icon: String // SF Symbol
}

struct Shop: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let price: String
    let rating: Double
    let isFastest: Bool
    let isMailIn: Bool
}
