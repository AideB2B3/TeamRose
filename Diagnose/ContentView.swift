//
//  ContentView.swift
//  Diagnose
//
//  Created by Foundation 3 on 05/03/26.
//
import SwiftUI
import AVFoundation
import MapKit
struct ContentView: View {
    @State private var path = NavigationPath()
    
    // User Selection State
    @State private var selectedGadget: String?
    @State private var selectedBrand: String?
    @State private var selectedModel: String?
    @State private var selectedProblem: String?
    
    // Persistent Test Results
    @State private var testResults: [String: Bool] = [:]
    
    var body: some View {
        NavigationStack(path: $path) {
            // MARK: - Home Screen
            VStack {
                Spacer()
                ZStack {
                    Circle().fill(Color.blue.opacity(0.1)).frame(width: 220, height: 220)
                    Image(systemName: "wrench.and.iphone")
                        .font(.system(size: 90))
                        .foregroundColor(.blue)
                        .symbolEffect(.pulse)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Fixo")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                    Text("Intelligent diagnostics. Instant repairs.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 60)
                
                Button(action: { path.append("gadget") }) {
                    HStack {
                        Text("Start Diagnostic")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // Profile action
                    }) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                    }
                }
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "gadget":
                    GridSelectionView(title: "What are we fixing?", items: [
                        ("Phone", "iphone"),
                        ("Tablet", "ipad"),
                        ("Laptop", "macbook"),
                        ("Smartwatch", "applewatch")
                    ], selection: $selectedGadget) {
                        path.append("brand")
                    }
                case "brand":
                    BrandGridSelectionView(title: "Select Brand", items: [
                        ("Apple", "applelogo", true),         // System Symbol
                        ("Samsung", "samsung_logo", false),   // Photo in Assets
                        ("Google", "google_logo", false),     // Photo in Assets
                        ("Other", "questionmark.circle", true)
                    ], selection: $selectedBrand) {
                        path.append("model")
                    }
                case "model":
                    GridSelectionView(title: "Select Model", items: models(for: selectedGadget, brand: selectedBrand), selection: $selectedModel) {
                        path.append("problem")
                    }
                case "problem":
                    ListSelectionView(title: "What's the issue?", items: [
                        "I'm not sure (Run Test)", "Broken Screen", "Battery Issue", "Water Damage", "Camera Failure"
                    ], selection: $selectedProblem) {
                        if selectedProblem == "I'm not sure (Run Test)" {
                            path.append("dashboard")
                        } else {
                            path.append("shops")
                        }
                    }
                case "dashboard":
                    DiagnosticDashboardView(brand: selectedBrand ?? "Apple", model: selectedModel ?? "iPhone", testResults: $testResults, path: $path) {
                        path.append("shops")
                    }
                case "shops":
                    ShopListView(brand: selectedBrand ?? "Apple", model: selectedModel ?? "iPhone", problem: selectedProblem ?? "Analysis Completed", path: $path)
                
                // Audio & Visual Tests
                case "test_touch":
                    TouchDiagnosticView { passed in testResults["touch"] = passed; path.removeLast() }
                case "test_camera":
                    CameraDiagnosticView { passed in testResults["camera"] = passed; path.removeLast() }
                case "test_audio":
                    MicrophoneDiagnosticView { passed in testResults["audio"] = passed; path.removeLast() }
                case "test_pixels":
                    DeadPixelTestView { passed in testResults["pixels"] = passed; path.removeLast() }
                case "test_battery":
                    BatteryDiagnosticView { passed in testResults["battery"] = passed; path.removeLast() }
                case "test_buttons":
                    ButtonsDiagnosticView { passed in testResults["buttons"] = passed; path.removeLast() }
                case "test_haptics":
                    HapticsDiagnosticView { passed in testResults["haptics"] = passed; path.removeLast() }
                case "test_flashlight":
                    FlashlightDiagnosticView { passed in testResults["flashlight"] = passed; path.removeLast() }
                    
                default:
                    EmptyView()
                }
            }
            // Add navigation destination for shop structures
            .navigationDestination(for: ShopItem.self) { shop in
                ShopDetailView(shop: shop)
            }
        }
    }
    
    func models(for gadget: String?, brand: String?) -> [(String, String)] {
        if gadget == "Tablet" { return [("iPad Pro", "ipad"), ("iPad Air", "ipad"), ("Galaxy Tab S9", "ipad")] }
        if gadget == "Laptop" { return [("MacBook Pro 16\"", "macbook"), ("MacBook Air", "macbook")] }
        if gadget == "Smartwatch" { return [("Apple Watch Series 9", "applewatch"), ("Galaxy Watch 6", "applewatch")] }
        if brand == "Samsung" { return [("Galaxy S24", "iphone.gen3"), ("Galaxy Z Fold", "iphone.gen2")] }
        return [("iPhone 15 Pro", "iphone"), ("iPhone 15", "iphone"), ("iPhone 14 Pro", "iphone.gen3")]
    }
}

// MARK: - Reusable Selection UI
struct GridSelectionView: View {
    let title: String
    let items: [(String, String)] // (Title, IconName)
    @Binding var selection: String?
    let onSelected: () -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(items, id: \.0) { item in
                    Button(action: {
                        selection = item.0
                        onSelected()
                    }) {
                        VStack(spacing: 16) {
                            Image(systemName: item.1)
                                .font(.system(size: 40))
                                .foregroundColor(selection == item.0 ? .white : .blue)
                            Text(item.0)
                                .font(.headline)
                                .foregroundColor(selection == item.0 ? .white : .primary)
                        }
                        .frame(height: 140)
                        .frame(maxWidth: .infinity)
                        .background(selection == item.0 ? Color.blue : Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ListSelectionView: View {
    let title: String
    let items: [String]
    @Binding var selection: String?
    let onSelected: () -> Void
    
    var body: some View {
        List {
            ForEach(items, id: \.self) { item in
                Button(action: {
                    selection = item
                    onSelected()
                }) {
                    HStack {
                        if item.contains("Test") {
                            Image(systemName: "sparkles")
                                .foregroundColor(.yellow)
                        }
                        Text(item)
                            .foregroundColor(.primary)
                            .bold(item.contains("Test"))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle(title)
    }
}

// MARK: - Brand Selection View (Supports Custom Asset Photos)
struct BrandGridSelectionView: View {
    let title: String
    let items: [(String, String, Bool)] // (Title, ImageName, IsSystemSymbol)
    @Binding var selection: String?
    let onSelected: () -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(items, id: \.0) { item in
                    Button(action: {
                        selection = item.0
                        onSelected()
                    }) {
                        VStack(spacing: 16) {
                            if item.2 {
                                // Apple & Other (SF Symbols)
                                Image(systemName: item.1)
                                    .font(.system(size: 40))
                                    .foregroundColor(selection == item.0 ? .white : .blue)
                            } else {
                                // Samsung & Google (Real Photos)
                                Image(item.1)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .colorMultiply(selection == item.0 ? .white : .primary) // Blends color when selected
                            }
                            Text(item.0)
                                .font(.headline)
                                .foregroundColor(selection == item.0 ? .white : .primary)
                        }
                        .frame(height: 140)
                        .frame(maxWidth: .infinity)
                        .background(selection == item.0 ? Color.blue : Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
    }
}



// MARK: - Camera Diagnostic View (Safety Mock to prevent crash)
struct CameraDiagnosticView: View {
    @State private var isAnalyzing = true
    @State private var result: Bool? = nil
    @Environment(\.dismiss) var dismiss
    var onCompletion: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Camera Hardware Test")
                .font(.title2.bold())
            
            ZStack {
                // Mock Camera Preview
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(colors: [.black, .gray.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 350)
                    .overlay {
                        if isAnalyzing {
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .padding()
                                Text("Connecting to Sensors...")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        } else {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 80))
                                .foregroundColor(.white.opacity(0.5))
                                .symbolEffect(.pulse)
                        }
                    }
                
                if !isAnalyzing {
                    VStack {
                        Spacer()
                        Text("Lens Focus: OK")
                            .font(.caption.bold())
                            .padding(6)
                            .background(.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                            .padding(.bottom, 20)
                    }
                }
            }
            .padding()
            
            if !isAnalyzing {
                Text("Is the image clear and without artifacts?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 20) {
                    Button(role: .destructive) {
                        onCompletion(false)
                    } label: {
                        Label("Blurry/Fail", systemImage: "xmark.circle.fill")
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        onCompletion(true)
                    } label: {
                        Label("Perfect", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }

        .onAppear {
            // Simulate a loading time
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { isAnalyzing = false }
            }
        }
    }
}

// MARK: - Shop Data Models & Views
struct ShopItem: Hashable {
    let name: String
    let location: String
    let price: String
    let rating: Double
    let isFastest: Bool
    let imageName: String
    let repairType: String
}

struct ShopListView: View {
    let brand: String
    let model: String
    let problem: String
    @Binding var path: NavigationPath
    
    // Database Connection
    @StateObject private var db = SupabaseManager()
    @State private var isFetching = true
    
    // Fallback Dummy Data (in case your Supabase table is empty right now)
    var dummyShops: [ShopItem] {
        [
            ShopItem(name: "City Tech Repairs", location: "Rome (Mail-in)", price: "$89", rating: 4.8, isFastest: false, imageName: "building.2.crop.circle.fill", repairType: problem),
            ShopItem(name: "iFixed Milano", location: "Milan (Mail-in)", price: "$120", rating: 4.9, isFastest: true, imageName: "building.fill", repairType: problem),
            ShopItem(name: "Local Repair Center", location: "Nearby (Walk-in)", price: "$150", rating: 4.2, isFastest: false, imageName: "map.circle.fill", repairType: problem)
        ]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Real Apple Map
            Map(initialPosition: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964), // Default to Rome
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))) {
                Marker("City Tech Repairs", coordinate: CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964))
            }
            .frame(height: 200)
            .overlay(alignment: .bottom) {
                Text("Showing repair centers near you...")
                    .font(.caption.bold())
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .padding(.bottom, 8)
            }
            
            List {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "shippingbox.fill")
                                .foregroundColor(.blue)
                            Text("Secure Mail-in Available")
                                .font(.headline)
                        }
                        Text("Because of your hardware diagnostic results, mailing your \(model) to Milan will save you $30.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Recommended Shops") {
                    if isFetching {
                        HStack {
                            Spacer()
                            ProgressView("Querying Supabase...")
                            Spacer()
                        }
                    } else {
                        // Use Live DB shops! (If empty, show dummy ones just so the UI isn't blank)
                        let displayShops = db.liveShops.isEmpty ? dummyShops : db.liveShops
                        
                        ForEach(displayShops, id: \.name) { shop in
                            NavigationLink(value: shop) {
                                HStack(spacing: 16) {
                                    Image(systemName: shop.imageName)
                                        .font(.system(size: 30))
                                        .foregroundColor(.blue)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(shop.name).font(.headline)
                                        Text(shop.location).font(.subheadline).foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text(shop.price).font(.title3.bold()).foregroundColor(.blue)
                                        HStack(spacing: 2) {
                                            Image(systemName: "star.fill").foregroundColor(.orange)
                                            Text(String(format: "%.1f", shop.rating))
                                        }.font(.caption.bold())
                                    }
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Best Options")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // FIRE THE SUPABASE QUERY THE MILLISECOND THIS SCREEN OPENS!
            await db.fetchShops()
            isFetching = false
        }
    }
}

struct ShopDetailView: View {
    let shop: ShopItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Apple Maps Header
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964), 
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))) {
                    Marker(shop.name, coordinate: CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964))
                }
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                .padding(.top, 10)
                
                VStack(alignment: .leading, spacing: 24) {
                    // Title & Price Section
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(shop.name)
                                .font(.title.bold())
                                .foregroundColor(.primary)
                            Text(shop.location)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill").foregroundColor(.primary)
                                Text(String(format: "%.1f", shop.rating))
                                    .fontWeight(.bold)
                                Text("(128 Reviews)")
                                    .foregroundColor(.secondary)
                            }
                            .font(.caption)
                            .padding(.top, 2)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(shop.price)
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Text(shop.repairType)
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(uiColor: .tertiarySystemFill))
                                .cornerRadius(8)
                        }
                    }
                    
                    // Action Buttons (Hierarchy)
                    HStack(spacing: 12) {
                        Button(action: { }) {
                            Text("Book Appointment")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(uiColor: .secondarySystemFill))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                        
                        Button(action: { }) {
                            HStack {
                                Image(systemName: "shippingbox.fill")
                                Text("Mail Service")
                            }
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    // Hardware Features Highlights (Monochrome Grid)
                    HStack(spacing: 12) {
                        InfoBadge(icon: "checkmark.seal.fill", title: "Apple Parts")
                        InfoBadge(icon: "shield.fill", title: "1-Yr Warranty")
                        InfoBadge(icon: "clock.fill", title: shop.isFastest ? "Same Day" : "3-5 Days")
                    }
                    
                    Divider()
                    
                    // About Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About this Repair")
                            .font(.title3.bold())
                        Text("This specialized center will restore your device to factory condition. You can mail it in securely using our prepaid shipping box, or walk in today.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Reusable UI element for Shop Features (Monochrome)
struct InfoBadge: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.primary)
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Microphone Diagnostic View
struct MicrophoneDiagnosticView: View {
    @State private var levels: [CGFloat] = Array(repeating: 0.1, count: 30)
    @State private var isListening = false
    @State private var timer: Timer?
    @Environment(\.dismiss) var dismiss
    var onCompletion: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 12) {
                Text("Microphone Test")
                    .font(.title2.bold())
                Text("Speak into your phone's microphone.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Waveform Visualizer
            HStack(spacing: 4) {
                ForEach(0..<levels.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
                        .frame(width: 6, height: 20 + (levels[index] * 150))
                }
            }
            .frame(height: 200)
            
            if !isListening {
                Button("Start Recording") {
                    startListening()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                VStack(spacing: 20) {
                    Text("We detected audio input!")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    HStack(spacing: 20) {
                        Button("Fail", role: .destructive) {
                            onCompletion(false)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Works Great") {
                            onCompletion(true)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            Spacer()
        }
        .padding(.top, 40)
        .onDisappear { timer?.invalidate() }
    }
    
    func startListening() {
        withAnimation { isListening = true }
        // Simple mock of audio processing for stability
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                for i in 0..<levels.count {
                    levels[i] = CGFloat.random(in: 0.1...0.8)
                }
            }
        }
    }
}

// MARK: - Dead Pixel Test
struct DeadPixelTestView: View {
    @State private var colorIndex = 0
    let colors: [Color] = [.white, .red, .green, .blue, .black]
    @Environment(\.dismiss) var dismiss
    var onCompletion: (Bool) -> Void
    
    var body: some View {
        ZStack {
            colors[colorIndex]
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                VStack(spacing: 16) {
                    Text("Step \(colorIndex + 1) of \(colors.count)")
                        .font(.caption.bold())
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                    
                    Text("Look for any static dots or lines.")
                        .font(.headline)
                        .shadow(radius: 2)
                    
                    Button(colorIndex < colors.count - 1 ? "Next Color" : "Finish") {
                        if colorIndex < colors.count - 1 {
                            withAnimation { colorIndex += 1 }
                        } else {
                            showResults()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .foregroundColor(.black)
                }
                .padding(30)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
    
    func showResults() {
        // In a real app, we'd show a pass/fail alert here
        onCompletion(true)
    }
}

// MARK: - Updated Diagnostic Dashboard (Polished)
struct DiagnosticDashboardView: View {
    let brand: String
    let model: String
    @Binding var testResults: [String: Bool]
    @Binding var path: NavigationPath
    var onFinish: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                // Header (Polished)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("\(brand) \(model)")
                            .font(.subheadline.bold())
                            .foregroundColor(.blue)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.caption.monospacedDigit().bold())
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: progress)
                        .tint(.blue)
                    
                    Text("Hardware Check")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                }
                .padding(.horizontal)
                
                // Test Cards (Polished Grid)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    CompactTestCard(title: "Touch", icon: "hand.tap.fill", color: .blue, status: testResults["touch"]) { path.append("test_touch") }
                    CompactTestCard(title: "Camera", icon: "camera.fill", color: .purple, status: testResults["camera"]) { path.append("test_camera") }
                    CompactTestCard(title: "Audio", icon: "waveform", color: .orange, status: testResults["audio"]) { path.append("test_audio") }
                    CompactTestCard(title: "Pixels", icon: "square.grid.3x3.fill", color: .green, status: testResults["pixels"]) { path.append("test_pixels") }
                    CompactTestCard(title: "Battery", icon: "battery.100", color: .red, status: testResults["battery"]) { path.append("test_battery") }
                    CompactTestCard(title: "Buttons", icon: "switch.2", color: .gray, status: testResults["buttons"]) { path.append("test_buttons") }
                    CompactTestCard(title: "Haptics", icon: "iphone.radiowaves.left.and.right", color: .indigo, status: testResults["haptics"]) { path.append("test_haptics") }
                    CompactTestCard(title: "Flash", icon: "flashlight.on.fill", color: .yellow, status: testResults["flashlight"]) { path.append("test_flashlight") }
                }
                .padding(.horizontal)
                
                // Summary Box
                if testResults.count > 0 {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("DIAGNOSTIC SUMMARY")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        
                        ForEach(testResults.keys.sorted(), id: \.self) { key in
                            HStack {
                                Text(key.capitalized)
                                Spacer()
                                Image(systemName: testResults[key] == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(testResults[key] == true ? .green : .red)
                            }
                        }
                        
                        Divider()
                        
                        Button(action: onFinish) {
                            HStack {
                                Text("Get Repair Quote")
                                Image(systemName: "arrow.right")
                            }
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.top)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var progress: Double {
        Double(testResults.count) / 8.0
    }
}



struct CompactTestCard: View {
    let title: String
    let icon: String
    let color: Color
    let status: Bool?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    Spacer()
                    if let status = status {
                        Image(systemName: status ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(status ? .green : .red)
                            .font(.headline)
                    }
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct TouchDiagnosticView: View {
    let rows = 12
    let columns = 7
    @State private var touchedIndices: Set<Int> = []
    @State private var isTestFinished = false
    var onCompletion: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                let squareSize = geometry.size.width / CGFloat(columns)
                Canvas { context, size in
                    for row in 0..<rows {
                        for col in 0..<columns {
                            let index = row * columns + col
                            let rect = CGRect(x: CGFloat(col) * squareSize, y: CGFloat(row) * squareSize, width: squareSize, height: squareSize)
                            let color = touchedIndices.contains(index) ? Color.green : Color.red.opacity(0.2)
                            context.fill(Path(rect.insetBy(dx: 1, dy: 1)), with: .color(color))
                        }
                    }
                }
                .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                    let col = Int(value.location.x / squareSize)
                    let row = Int(value.location.y / squareSize)
                    if col >= 0 && col < columns && row >= 0 && row < rows {
                        let index = row * columns + col
                        if !touchedIndices.contains(index) {
                            touchedIndices.insert(index)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                    if touchedIndices.count == (rows * columns) { isTestFinished = true }
                })
            }
            VStack {
                if isTestFinished {
                    Text("All Zones Responsive").font(.headline).foregroundColor(.green)
                    Button("Finish & Pass") { onCompletion(true) }
                        .buttonStyle(.borderedProminent)
                        .padding(.bottom, 10)
                } else {
                    Button(action: { onCompletion(false) }) {
                        Label("Some areas are unresponsive", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.bordered)
                    .padding(.bottom, 10)
                }
            }
            .padding()
            .background(.ultraThinMaterial)

        }
        .navigationTitle("Touch Test")
    }
}

struct MockTestView: View {
    let testName: String
    var onCompletion: (Bool) -> Void
    var body: some View {
        VStack(spacing: 30) {
            Text("Simulating \(testName)...").font(.headline)
            Image(systemName: "slowmo").font(.system(size: 60)).symbolEffect(.variableColor.iterative.reversing)
            HStack(spacing: 40) {
                Button(role: .destructive) { onCompletion(false) } label: { Label("Fail", systemImage: "xmark") }.buttonStyle(.bordered)
                Button() { onCompletion(true) } label: { Label("Pass", systemImage: "checkmark") }.buttonStyle(.borderedProminent)
            }
        }.navigationTitle(testName.capitalized)
    }
}

// MARK: - Battery Diagnostic
struct BatteryDiagnosticView: View {
    @State private var health: Int = 0
    @State private var isAnalyzing = true
    var onCompletion: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Battery Health").font(.title2.bold())
            
            ZStack {
                Circle().stroke(Color.gray.opacity(0.2), lineWidth: 20).frame(width: 200, height: 200)
                Circle()
                    .trim(from: 0, to: CGFloat(health) / 100.0)
                    .stroke(health > 80 ? Color.green : Color.orange, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(health)%").font(.system(size: 40, weight: .bold, design: .rounded))
                    Text("Maximum Capacity").font(.caption).foregroundColor(.secondary)
                }
            }
            .animation(.easeOut(duration: 2.0), value: health)
            
            if isAnalyzing {
                ProgressView("Analyzing Chemical Aging...")
            } else {
                Text(health > 80 ? "Your battery is in good condition" : "Service Recommended")
                    .foregroundColor(health > 80 ? .green : .orange).bold()
                
                Button("Done") { onCompletion(true) }.buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                health = 87 // Simulation
                isAnalyzing = false
            }
        }
    }
}

// MARK: - Buttons Diagnostic
struct ButtonsDiagnosticView: View {
    @State private var volumeUpPressed = false
    @State private var volumeDownPressed = false
    var onCompletion: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Physical Buttons").font(.title2.bold())
            
            VStack(spacing: 20) {
                ButtonLevel(title: "Volume Up", pressed: volumeUpPressed)
                ButtonLevel(title: "Volume Down", pressed: volumeDownPressed)
            }
            
            Text("Please press the physical volume buttons on the side of your phone.")
                .font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center).padding()
            
            if volumeUpPressed && volumeDownPressed {
                Button("All Buttons Work") { onCompletion(true) }.buttonStyle(.borderedProminent)
            } else {
                Button("They don't work", role: .destructive) { onCompletion(false) }.buttonStyle(.bordered)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"))) { _ in
            // This is a simple way to detect volume button interacton for a prototype
            // In a real app we'd check the volume delta
            if !volumeUpPressed { volumeUpPressed = true }
            else if !volumeDownPressed { volumeDownPressed = true }
        }
    }
}

struct ButtonLevel: View {
    let title: String
    let pressed: Bool
    var body: some View {
        HStack {
            Text(title).bold()
            Spacer()
            Image(systemName: pressed ? "checkmark.circle.fill" : "circle")
                .foregroundColor(pressed ? .green : .gray)
                .font(.title2)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Haptics Diagnostic
struct HapticsDiagnosticView: View {
    var onCompletion: (Bool) -> Void
    var body: some View {
        VStack(spacing: 30) {
            Text("Haptic Motor").font(.title2.bold())
            
            Image(systemName: "vibrate.run").font(.system(size: 80)).foregroundColor(.indigo).symbolEffect(.bounce)
            
            Button("Test Vibration Pattern") {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { generator.impactOccurred() }
            }
            .buttonStyle(.bordered)
            
            Text("Did you feel a clean vibration?").font(.headline).padding(.top)
            
            HStack(spacing: 20) {
                Button("No, it feels weak") { onCompletion(false) }.buttonStyle(.bordered)
                Button("Yes, it's strong") { onCompletion(true) }.buttonStyle(.borderedProminent)
            }
        }
    }
}

// MARK: - Flashlight Diagnostic
struct FlashlightDiagnosticView: View {
    @State private var isOn = false
    var onCompletion: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Flashlight Test").font(.title2.bold())
            
            Image(systemName: isOn ? "lightbulb.fill" : "lightbulb")
                .font(.system(size: 100))
                .foregroundColor(isOn ? .yellow : .gray)
                .shadow(color: isOn ? .yellow : .clear, radius: 20)
            
            Button(isOn ? "TURN OFF" : "TURN ON") {
                toggleFlashlight()
            }
            .buttonStyle(.borderedProminent)
            .tint(isOn ? .red : .blue)
            
            Text("Did the LED on the back light up?").font(.headline).padding(.top)
            
            HStack(spacing: 20) {
                Button("No") { onCompletion(false) }.buttonStyle(.bordered)
                Button("Yes") { onCompletion(true) }.buttonStyle(.borderedProminent)
            }
        }
        .onDisappear {
            if isOn { toggleFlashlight() }
        }
    }
    
    func toggleFlashlight() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                isOn.toggle()
                device.torchMode = isOn ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        }
    }
}



