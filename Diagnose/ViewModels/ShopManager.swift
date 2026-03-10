import SwiftUI
import Combine

class ShopManager: ObservableObject {
    @Published var activeOrders: [RepairOrder] = [
        RepairOrder(customerName: "Alice Smith", deviceModel: "iPhone 13 Pro Max", problem: "Screen Cracked", status: .shipped, date: Date(), price: 120),
        RepairOrder(customerName: "John Doe", deviceModel: "iPhone 14 Plus", problem: "Battery Replacement", status: .inProgress, date: Date(), price: 80),
        RepairOrder(customerName: "Pietro Navona", deviceModel: "iPhone 15", problem: "Charging Port", status: .pending, date: Date(), price: 90),
        RepairOrder(customerName: "Maria Rossi", deviceModel: "iPhone 12", problem: "Camera Repair", status: .ready, date: Date(), price: 110)
    ]
    
    @Published var services: [RepairService] = [
        RepairService(name: "Screen Replacement", basePrice: 120.0, category: .screen),
        RepairService(name: "Battery Replacement", basePrice: 80.0, category: .battery),
        RepairService(name: "Charging Port Repair", basePrice: 90.0, category: .charging),
        RepairService(name: "Camera Replacement", basePrice: 110.0, category: .camera)
    ]
    
    var totalEarnings: Double {
        activeOrders.reduce(0) { $0 + $1.price }
    }
}
