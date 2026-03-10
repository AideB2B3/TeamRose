import Foundation

struct CustomerOrder: Identifiable, Hashable {
    let id: UUID
    let dbID: Int
    var customerName: String
    var customerPhone: String
    var deviceBrand: String
    var deviceModel: String
    var issue: String
    var price: Double
    var status: OrderStatus
    var dateReceived: Date
    var isMailIn: Bool
    
    enum OrderStatus: String, CaseIterable, Identifiable {
        case pending = "Pending"
        case inProgress = "In Progress"
        case waitingForParts = "Waiting Parts"
        case readyForPickup = "Ready"
        case completed = "Completed"
        var id: String { self.rawValue }
    }
}

struct CustomerReview: Identifiable, Hashable {
    let id: UUID
    var customerName: String
    var rating: Int // 1-5
    var comment: String
    var date: Date
}

