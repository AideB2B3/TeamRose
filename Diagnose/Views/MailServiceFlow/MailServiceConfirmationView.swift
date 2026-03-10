
import SwiftUI

struct MailServiceConfirmationView: View {
    let result: ShipmentResult
    var onDone: () -> Void
    
    @State private var showContent = false
    @State private var showFullLabel = false
    @State private var buttonPressed = false
    
    var body: some View {
        ZStack {
            // 🎨 PREMIUM MESH GRADIENT BACKGROUND
            ZStack {
                Color.white.ignoresSafeArea()
                
                Circle()
                    .fill(BrandColor.primary.opacity(0.12))
                    .frame(width: 450, height: 450)
                    .blur(radius: 60)
                    .offset(x: -150, y: -250)
                
                Circle()
                    .fill(Color.orange.opacity(0.08))
                    .frame(width: 400, height: 400)
                    .blur(radius: 50)
                    .offset(x: 150, y: 150)
            }
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 35) {
                    Spacer(minLength: 40)
                    
                    // 1. ICON SECTION
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 140, height: 140)
                            .shadow(color: Color.black.opacity(0.06), radius: 25, x: 0, y: 12)
                        
                        Image(systemName: "shippingbox.and.arrow.backward.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60)
                            .foregroundColor(BrandColor.primary)
                    }
                    .scaleEffect(showContent ? 1 : 0.9)
                    .opacity(showContent ? 1 : 0)
                    
                    // 2. MAIN TITLES
                    VStack(spacing: 12) {
                        Text("Ready for Pickup!")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                        
                        Text(result.trackingCode)
                            .font(.system(.subheadline, design: .monospaced).bold())
                            .foregroundColor(BrandColor.primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                            )
                    }
                    .opacity(showContent ? 1 : 0)
                    
                    // 3. NEW: TRACKING TIMELINE
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Repair Journey")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            TrackingStep(title: "Label Created", subtitle: "Package ready for courier", date: "Just now", status: .completed)
                            TrackingStep(title: "Courier Pickup", subtitle: "Scheduled for today", date: "Incoming", status: .current)
                            TrackingStep(title: "Arrived at Lab", subtitle: "Ready for diagnosis", date: "--", status: .pending)
                            TrackingStep(title: "Shipped Back", subtitle: "Device repaired & tested", date: "--", status: .pending, isLast: true)
                        }
                        .padding()
                        .background(Color.white.opacity(0.6))
                        .background(.ultraThinMaterial)
                        .cornerRadius(24)
                        .padding(.horizontal)
                    }
                    .opacity(showContent ? 1 : 0)
                    
                    // 4. PRINT LABEL CTA
                    Button {
                        showFullLabel = true
                    } label: {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Print Shipping Label")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Carrier: \(result.carrier)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            Image(systemName: "printer.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(BrandColor.primary)
                                .clipShape(Circle())
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(22)
                        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
                    }
                    .padding(.horizontal, 24)
                    .opacity(showContent ? 1 : 0)
                    
                    // 5. SUCCESS BUTTON
                    Button {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { buttonPressed = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { onDone() }
                    } label: {
                        Text("Close with Success")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 240)
                            .padding(.vertical, 16)
                            .background(Capsule().fill(BrandColor.primary))
                            .shadow(color: BrandColor.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                            .scaleEffect(buttonPressed ? 0.94 : 1.0)
                    }
                    .padding(.bottom, 40)
                    .opacity(showContent ? 1 : 0)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { showContent = true }
        }
        .sheet(isPresented: $showFullLabel) {
            NavigationStack {
                VStack {
                    ScrollView {
                        ShippingLabelView(result: result, name: result.name, address: result.address, city: result.city)
                            .padding(.vertical, 20)
                            .scaleEffect(0.9)
                    }
                    Button { } label: { Label("Print using AirPrint", systemImage: "printer.fill").primaryButtonStyle() }.padding()
                }
                .navigationTitle("Shipping Label")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Close") { showFullLabel = false } } }
            }
        }
    }
}

// TIMELINE COMPONENTS
enum StepStatus { case completed, current, pending }

struct TrackingStep: View {
    let title: String
    let subtitle: String
    let date: String
    let status: StepStatus
    var isLast = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            VStack(spacing: 0) {
                Circle()
                    .fill(status == .completed ? BrandColor.primary : (status == .current ? BrandColor.primary : Color.gray.opacity(0.3)))
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 4)
                    )
                
                if !isLast {
                    Rectangle()
                        .fill(status == .completed ? BrandColor.primary : Color.gray.opacity(0.2))
                        .frame(width: 2, height: 40)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(status == .pending ? .secondary : .primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if status == .current {
                    Text(date)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(BrandColor.primary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(BrandColor.primary.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            Spacer()
            if status == .completed {
                Text(date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}
