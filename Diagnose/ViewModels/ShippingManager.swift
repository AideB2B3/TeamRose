
import Foundation
import Combine
import SwiftUI

class ShippingManager: ObservableObject {
    @Published var isLoading = false
    @Published var shipmentResult: ShipmentResult?
    @Published var errorMessage: String?
    
    private let apiKey = "YOUR_TEST_API_KEY" 
    
    func createShipment(name: String, street: String, city: String, shopName: String, shopAddress: String) {
        isLoading = true
        errorMessage = nil
        
        // Demo defaults
        let finalName = name.isEmpty ? "Academy Student" : name
        let finalStreet = street.isEmpty ? "Academy St, 1" : street
        let finalCity = city.isEmpty ? "Rome" : city
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [unowned self] in
            isLoading = false
            
            shipmentResult = ShipmentResult(
                trackingCode: "EZ10\(Int.random(in: 100000...999999))ITALY",
                labelURL: "",
                carrier: "DHL Express",
                name: finalName,
                address: finalStreet,
                city: finalCity,
                shopName: shopName,
                shopAddress: shopAddress,
                isInsured: true,
                shippingType: "Express Premium"
            )
        }
    }
}
