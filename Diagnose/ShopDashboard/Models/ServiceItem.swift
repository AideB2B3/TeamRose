import Foundation

struct ServiceItem: Identifiable, Hashable {
    let id: UUID
    let dbID: Int          // Real integer primary key from shop_services
    var deviceBrand: String
    var deviceModel: String
    var issue: String
    var price: Double

    init(dbID: Int, deviceBrand: String, deviceModel: String, issue: String, price: Double) {
        // Derive a stable UUID from the integer ID so SwiftUI List works correctly
        var bytes = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) as (UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8)
        bytes.0 = UInt8((dbID >> 24) & 0xFF)
        bytes.1 = UInt8((dbID >> 16) & 0xFF)
        bytes.2 = UInt8((dbID >> 8) & 0xFF)
        bytes.3 = UInt8(dbID & 0xFF)
        self.id = UUID(uuid: bytes)
        self.dbID = dbID
        self.deviceBrand = deviceBrand
        self.deviceModel = deviceModel
        self.issue = issue
        self.price = price
    }
}
