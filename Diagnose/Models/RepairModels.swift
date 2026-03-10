
import Foundation
import SwiftUI

struct RepairService: Identifiable {
    let id = UUID()
    let name: String
    let basePrice: Double
    let category: ServiceCategory
}

enum ServiceCategory: String, CaseIterable {
    case screen = "Screen"
    case battery = "Battery"
    case charging = "Charging Port"
    case camera = "Camera"
    case buttons = "Buttons"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .screen: return "iphone"
        case .battery: return "battery.100"
        case .charging: return "bolt.fill"
        case .camera: return "camera.fill"
        case .buttons: return "switch.2"
        case .other: return "wrench.and.screwdriver.fill"
        }
    }
}

struct RepairOrder: Identifiable {
    let id = UUID()
    let customerName: String
    let deviceModel: String
    let problem: String
    let status: OrderStatus
    let date: Date
    let price: Double
}

enum OrderStatus: String, CaseIterable {
    case pending = "Pending"
    case inProgress = "Repairing"
    case ready = "Ready"
    case shipped = "Shipped"
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .inProgress: return .blue
        case .ready: return .green
        case .shipped: return .purple
        }
    }
}
