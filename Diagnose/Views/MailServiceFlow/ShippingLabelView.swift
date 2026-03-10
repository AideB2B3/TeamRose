
import SwiftUI

struct ShippingLabelView: View {
    let result: ShipmentResult
    let name: String
    let address: String
    let city: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.carrier.uppercased())
                        .font(.system(size: 26, weight: .black, design: .rounded))
                    Text(result.shippingType.uppercased())
                        .font(.caption.bold())
                }
                Spacer()
                if result.isInsured {
                    VStack(spacing: 2) {
                        Image(systemName: "shield.fill")
                            .font(.title3)
                        Text("INSURED")
                            .font(.system(size: 8, weight: .bold))
                    }
                    .padding(8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            
            Divider().background(Color.black)
            
            // From/To Section
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 15) {
                    LabelSection(title: "FROM:", name: name, street: address, city: city)
                    
                    Divider()
                    
                    LabelSection(title: "TO:", name: result.shopName, street: result.shopAddress, city: "")
                }
                .padding()
                
                Spacer()
                
                Text("ROM")
                    .font(.system(size: 50, weight: .bold))
                    .padding()
                    .border(Color.black, width: 4)
                    .padding()
            }
            
            Divider().background(Color.black)
            
            // Barcode Section
            VStack(spacing: 20) {
                VStack(spacing: 5) {
                    HStack(spacing: 2) {
                        ForEach(0..<60) { _ in
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: CGFloat.random(in: 1...4), height: 70)
                        }
                    }
                    Text(result.trackingCode)
                        .font(.system(.callout, design: .monospaced))
                        .bold()
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("SERVICE: \(result.shippingType)")
                        Text("WEIGHT: 0.50 KG")
                        Text("INSURED: \(result.isInsured ? "YES" : "NO")")
                    }
                    .font(.system(size: 9, design: .monospaced))
                    Spacer()
                    HStack(spacing: 1) {
                        ForEach(0..<20) { _ in
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 2, height: 35)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 20)
            
            Spacer()
            
            Text("PEEL AND STICK ON THE TOP OF THE BOX")
                .font(.system(size: 10, weight: .bold))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.05))
        }
        .frame(width: 340, height: 480)
        .background(Color.white)
        .border(Color.black, width: 2)
        .padding()
    }
}

struct LabelSection: View {
    let title: String
    let name: String
    let street: String
    let city: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
            Text(name)
                .font(.headline)
            Text(street)
                .font(.subheadline)
            Text(city.uppercased())
                .font(.subheadline.bold())
        }
    }
}
