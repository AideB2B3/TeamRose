
import Foundation

// EasyPost API Response Models
struct EasyPostResponse: Codable {
    let id: String?
    let tracking_code: String?
    let postage_label: PostageLabel?
}

struct PostageLabel: Codable {
    let label_url: String?
}

// Internal model to pass data between screens
struct ShipmentResult: Equatable {
    let trackingCode: String
    let labelURL: String
    let carrier: String
    let name: String
    let address: String
    let city: String
    // Shop info for the "TO" part of the label
    let shopName: String
    let shopAddress: String
    // More options for the presentation
    let isInsured: Bool
    let shippingType: String // e.g., "Express 24h"
}
