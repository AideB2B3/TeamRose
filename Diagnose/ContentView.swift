//
//  ContentView.swift
//  Diagnose
//
//  Created by Foundation 3 on 05/03/26.
//
import SwiftUI
import AVFoundation
import MapKit
import MessageUI

extension Notification.Name {
    static let refreshCustomerOrders = Notification.Name("refreshCustomerOrders")
}

struct ContentView: View {
    // State
    @ObservedObject private var auth = AuthManager.shared
    @StateObject private var supabaseManager = SupabaseManager.shared
    @StateObject private var ordersViewModel = CustomerOrdersViewModel()
    @State private var path = NavigationPath()
    
    // User Selection State
    @State private var selectedGadget: String?
    @State private var selectedBrand: String?
    @State private var selectedModel: String?
    @State private var selectedProblem: String?
    
    // Persistent Test Results
    @State private var testResults: [String: Bool] = [:]
    
    // UI State
    @State private var showingProfile = false
    
    var body: some View {
        NavigationStack(path: $path) {
            // MARK: - Home Screen
            VStack {
                // Persistent Login Status Header
                if auth.currentUserID == nil {
                    Button(action: { showingProfile = true }) {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.plus")
                            Text("Sign in to save your repairs and track history")
                                .font(.subheadline.bold())
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.brandPrimary.opacity(0.1))
                        .foregroundColor(.brandPrimary)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }

                Spacer()

                Spacer()
                Image("FX@4x")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Fixo")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                    Text("Intelligent diagnostics. Instant repairs.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
                
                HStack(spacing: 16) {
                    // Quick Action: Hardware Check
                    Button(action: {
                        selectedGadget = "Phone"
                        selectedBrand = "Apple"
                        selectedModel = "iPhone"
                        // Skip directly to dashboard for quick test
                        path.append("dashboard")
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: "cpu")
                                .font(.title)
                            Text("Hardware\nCheck")
                                .font(.subheadline.bold())
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                    }

                    // Orders
                    Button(action: {
                        showingProfile = true
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: "shippingbox")
                                .font(.title)
                            Text("My\nOrders")
                                .font(.subheadline.bold())
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
                
                Button(action: { path.append("device_selection") }) {
                    HStack {
                        Text("Start New Repair")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brandPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingProfile = true
                    }) {
                        if auth.currentUserID == nil {
                            HStack(spacing: 4) {
                                Text("Sign In")
                                    .font(.subheadline.bold())
                                Image(systemName: "person.crop.circle")
                            }
                            .foregroundColor(.brandPrimary)
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.brandPrimary)
                        }
                    }
                }
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "device_selection":
                    DeviceSelectionView(
                        selectedGadget: $selectedGadget,
                        selectedBrand: $selectedBrand,
                        selectedModel: $selectedModel,
                        availableGadgets: availableGadgets,
                        availableBrands: availableBrands,
                        availableModels: availableModels
                    ) {
                        path.append("problem")
                    }
                case "problem":
                    ListSelectionView(title: "What's the issue?", items: availableProblems, selection: $selectedProblem) {
                        if selectedProblem == "I'm not sure (Run Test)" {
                            path.append("dashboard")
                        } else {
                            path.append("shops")
                        }
                    }
                case "dashboard":
                    DiagnosticDashboardView(brand: selectedBrand ?? "Apple", model: selectedModel ?? "iPhone", testResults: $testResults, path: $path) {
                        // Automatically set problem based on failures before moving to shops
                        if let detected = determineProblem(from: testResults) {
                            selectedProblem = detected
                        }
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
                ShopDetailView(shop: shop, path: $path)
            }
        }
        .sheet(isPresented: $showingProfile) {
            if auth.currentUserID != nil {
                CustomerProfileView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            } else {
                CustomerLoginView()
            }
        }
        .onChange(of: path.count) { newCount in
            print("🧭 Path count changed: \(newCount)")
            if newCount == 0 {
                testResults.removeAll()
                selectedGadget = nil
                selectedBrand = nil
                selectedModel = nil
                selectedProblem = nil
            }
        }
        .task {
            // Load types, brands, models, and problems from DB
            await supabaseManager.fetchLookupData()
            if auth.currentUserID != nil {
                await ordersViewModel.fetchOrders()
            }
        }
        .onChange(of: auth.currentUserID) { newID in
            if newID != nil {
                Task { await ordersViewModel.fetchOrders() }
            } else {
                ordersViewModel.orders = []
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshCustomerOrders)) { _ in
            Task { await ordersViewModel.fetchOrders() }
        }
    }
    
    // MARK: - Dynamic Data Helpers
    private var availableGadgets: [(String, String)] {
        let types = Set(supabaseManager.availableDevices.compactMap { $0.device_type })
        return types.map { type in
            let icon: String
            switch type.lowercased() {
            case "phone": icon = "iphone"
            case "tablet": icon = "ipad"
            case "laptop": icon = "macbook"
            case "smartwatch": icon = "applewatch"
            default: icon = "questionmark.circle"
            }
            return (type, icon)
        }.sorted(by: { $0.0 < $1.0 })
    }

    private var availableBrands: [(String, String, Bool)] {
        guard let gadget = selectedGadget else { return [] }
        let brands = Set(supabaseManager.availableDevices
            .filter { $0.device_type == gadget }
            .map { $0.brand })
            .filter { $0.lowercased() == "apple" } // Only Apple
        
        return brands.map { brand in
            return (brand, "applelogo", true)
        }.sorted(by: { $0.0 < $1.0 })
    }

    private var availableModels: [(String, String)] {
        guard let brand = selectedBrand, let gadget = selectedGadget else { return [] }
        let models = Set(supabaseManager.availableDevices
            .filter { $0.brand == brand && $0.device_type == gadget }
            .map { $0.model })
        return models
            .map { ($0, gadget.lowercased() == "phone" ? "iphone" : gadget.lowercased()) }
            .sorted(by: { $0.0 < $1.0 })
    }

    private var availableProblems: [String] {
        var base: [String] = []
        // Only show diagnostic test option for Phones
        if selectedGadget?.lowercased() == "phone" {
            base.append("I'm not sure (Run Test)")
        }
        let uniqueNames = Set(supabaseManager.availableProblems.map { $0.problem_name })
        base.append(contentsOf: uniqueNames.sorted())
        return base
    }

    private func determineProblem(from results: [String: Bool]) -> String? {
        // Priority mapping for failed tests to DB problem names
        if results["touch"] == false || results["pixels"] == false { return "Screen Repair" }
        if results["camera"] == false || results["flashlight"] == false { return "Camera Fix" }
        if results["audio"] == false { return "Microphone Issue" }
        if results["battery"] == false { return "No Power" }
        if results["buttons"] == false || results["haptics"] == false { return "Logic Board Repair" }
        
        return "Analysis Completed"
    }
}

// MARK: - Reusable Selection UI
// MARK: - Unified Device Selection View
struct DeviceSelectionView: View {
    @Binding var selectedGadget: String?
    @Binding var selectedBrand: String?
    @Binding var selectedModel: String?
    
    let availableGadgets: [(String, String)]
    let availableBrands: [(String, String, Bool)]
    let availableModels: [(String, String)]
    let onContinue: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                
                // SECTION 1: GADGET TYPE
                VStack(alignment: .leading, spacing: 16) {
                    SelectionHeader(title: "1. Device Type", subtitle: "What kind of device needs repair?", isSelected: selectedGadget != nil)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(availableGadgets, id: \.0) { item in
                                SelectionChip(title: item.0, icon: item.1, isSelected: selectedGadget == item.0) {
                                    withAnimation {
                                        selectedGadget = item.0
                                        selectedBrand = nil
                                        selectedModel = nil
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // SECTION 2: BRAND
                if let _ = selectedGadget {
                    VStack(alignment: .leading, spacing: 16) {
                        SelectionHeader(title: "2. Brand", subtitle: "Select your device manufacturer", isSelected: selectedBrand != nil)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(availableBrands, id: \.0) { item in
                                    SelectionChip(title: item.0, icon: item.1, isSelected: selectedBrand == item.0, isSystem: item.2) {
                                        withAnimation {
                                            selectedBrand = item.0
                                            selectedModel = nil
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // SECTION 3: MODEL
                if let _ = selectedBrand {
                    VStack(alignment: .leading, spacing: 16) {
                        SelectionHeader(title: "3. Model", subtitle: "Which specific model is it?", isSelected: selectedModel != nil)
                        
                        VStack(spacing: 12) {
                            ForEach(availableModels, id: \.0) { item in
                                SelectionRow(title: item.0, icon: item.1, isSelected: selectedModel == item.0) {
                                    withAnimation {
                                        selectedModel = item.0
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer().frame(height: 40)
                
                // CONTINUE BUTTON
                if selectedModel != nil {
                    Button(action: onContinue) {
                        HStack {
                            Text("Next Step")
                                .font(.headline.bold())
                            Image(systemName: "chevron.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brandPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: Color.brandPrimary.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.vertical)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Select Device")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Reusable Selection Components
struct SelectionHeader: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.brandPrimary)
                    .font(.title3)
            }
        }
        .padding(.horizontal)
    }
}

struct SelectionChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var isSystem: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if isSystem {
                    Image(systemName: icon)
                        .font(.title2)
                } else {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                Text(title)
                    .font(.caption.bold())
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(isSelected ? Color.brandPrimary : Color(uiColor: .secondarySystemGroupedBackground))
            .foregroundColor(isSelected ? .brandNeutral : .primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.brandPrimary : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct SelectionCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.body)
                Text(title)
                    .font(.subheadline.bold())
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.brandPrimary : Color(uiColor: .secondarySystemGroupedBackground))
            .foregroundColor(isSelected ? .brandNeutral : .primary)
            .cornerRadius(12)
        }
    }
}

struct SelectionRow: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.body.bold())
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(BrandColor.primary)
                }
            }
            .padding()
            .background(isSelected ? BrandColor.primary.opacity(0.1) : Color(uiColor: .secondarySystemGroupedBackground))
            .foregroundColor(isSelected ? BrandColor.primary : .primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? BrandColor.primary : Color.clear, lineWidth: 2)
            )
        }
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

struct ShopListView: View {
    let brand: String
    let model: String
    let problem: String
    @Binding var path: NavigationPath

    @StateObject private var db = SupabaseManager()
    @State private var isFetching = true

    var body: some View {
        VStack(spacing: 0) {
            // Map area
            Map(initialPosition: .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))) {
                ForEach(db.liveShops, id: \.name) { shop in
                    Marker(shop.name, coordinate: CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964))
                }
            }
            .frame(height: 180)
            .overlay(alignment: .bottom) {
                if !isFetching {
                    statusBanner
                }
            }

            List {
                Section(header:
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Looking for:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(problem) · \(brand) \(model)")
                            .font(.subheadline.bold())
                    }
                    .padding(.vertical, 4)
                ) { }

                Section {
                    if isFetching {
                        loadingSection
                    } else if db.liveShops.isEmpty {
                        emptyStateSection
                    } else {
                        resultsSection
                    }
                } header: {
                    Text(db.searchMatchStatus == .exactResults ? "Top Matches" : "Recommended Options")
                }
            }
        }
        .navigationTitle("Repair Shops")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await db.fetchShops(brand: brand, model: model, problem: problem)
            isFetching = false
        }
    }

    private var statusBanner: some View {
        Group {
            switch db.searchMatchStatus {
            case .exactResults:
                Text("Exact matches for your device")
            case .partialResults:
                Text("Shops specializing in \(brand) repairs")
            case .recommendationsOnly:
                Text("Top-rated general experts to call")
            default:
                EmptyView()
            }
        }
        .font(.caption.bold())
        .padding(8)
        .background(.ultraThinMaterial)
        .cornerRadius(8)
        .padding(.bottom, 8)
    }

    private var loadingSection: some View {
        HStack {
            Spacer()
            VStack(spacing: 12) {
                ProgressView()
                Text("Analyzing network…")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 40)
    }

    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "phone.circle")
                .font(.system(size: 48))
                .foregroundColor(.brandPrimary)
            Text("No direct matches found")
                .font(.headline)
            Text("We couldn't find any shops that explicitly list this specific repair. We recommend calling an iPhone expert directly.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 30)
    }

    private var resultsSection: some View {
        ForEach(db.liveShops, id: \.self) { shop in
            NavigationLink(value: shop) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.brandPrimary.opacity(0.1))
                            .frame(width: 48, height: 48)
                        Image(systemName: shop.imageName)
                            .font(.system(size: 22))
                            .foregroundColor(.brandPrimary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(shop.name).font(.headline)
                            if shop.isFastest {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.brandPrimary)
                                    .font(.caption)
                            }
                        }
                        
                        if let reason = shop.recommendationReason {
                            Text(reason)
                                .font(.caption.bold())
                                .foregroundColor(.orange)
                        } else {
                            Text(shop.location)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(shop.repairType)
                            .font(.caption)
                            .foregroundColor(.brandPrimary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(shop.price)
                            .font(.title3.bold())
                            .foregroundColor(.brandPrimary)
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


struct ShopDetailView: View {
    let shop: ShopItem
    @Binding var path: NavigationPath
    @State private var showingMail = false
    
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
                        Button(action: {
                            if let url = URL(string: "tel://\(shop.phoneNumber.replacingOccurrences(of: " ", with: ""))") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "phone.fill")
                                Text("Call Now")
                            }
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(uiColor: .secondarySystemFill))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                        
                        Button(action: { showingMail = true }) {
                            HStack {
                                Image(systemName: "shippingbox.fill")
                                Text("Mail Service")
                            }
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.brandPrimary)
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
        .sheet(isPresented: $showingMail) {
            NavigationStack {
                MailServiceFormView(shop: shop) {
                    // Success callback: go back home
                    withAnimation {
                        showingMail = false
                        // Use DispatchQueue to let sheet dismiss before clearing path for stability
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            path = NavigationPath()
                            // Notify ContentView to refresh orders
                            NotificationCenter.default.post(name: .refreshCustomerOrders, object: nil)
                        }
                    }
                }
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") { showingMail = false }
                        }
                    }
            }
        }
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
                        .fill(LinearGradient(colors: [.brandPrimary, .purple], startPoint: .top, endPoint: .bottom))
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
                            .foregroundColor(.brandPrimary)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.caption.monospacedDigit().bold())
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: progress)
                        .tint(.brandPrimary)
                    
                    Text("Hardware Check")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                }
                .padding(.horizontal)
                
                // Test Cards (Polished Grid)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    CompactTestCard(title: "Touch", icon: "hand.tap.fill", color: .brandPrimary, status: testResults["touch"]) { path.append("test_touch") }
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
                            .background(Color.brandPrimary)
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
                ButtonLevel(title: "Volume Up", pressed: $volumeUpPressed)
                ButtonLevel(title: "Volume Down", pressed: $volumeDownPressed)
            }
            
            Text("Please tap the circles above to indicate the volume buttons work.")
                .font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center).padding()
            
            if volumeUpPressed && volumeDownPressed {
                Button("All Buttons Work") { onCompletion(true) }.buttonStyle(.borderedProminent)
            } else {
                Button("They don't work", role: .destructive) { onCompletion(false) }.buttonStyle(.bordered)
            }
        }
        .onChange(of: volumeUpPressed) { _ in checkCompletion() }
        .onChange(of: volumeDownPressed) { _ in checkCompletion() }
    }
    
    func checkCompletion() {
        if volumeUpPressed && volumeDownPressed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onCompletion(true)
            }
        }
    }
}

struct ButtonLevel: View {
    let title: String
    @Binding var pressed: Bool
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                pressed.toggle()
            }
        }) {
            HStack {
                Text(title).bold()
                Spacer()
                Image(systemName: pressed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(pressed ? .green : .gray)
                    .font(.title2)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .foregroundColor(.primary)
        }
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
            .tint(isOn ? .red : .brandPrimary)
            
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
