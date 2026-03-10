import SwiftUI

struct AddServiceView: View {
    @Environment(\.dismiss) var dismiss
    var viewModel: ShopDashboardViewModel

    // MARK: - Step-by-step cascading selection
    @State private var selectedDeviceType: String = ""
    @State private var selectedBrand: String = ""
    @State private var selectedDevice: DeviceRow? = nil
    @State private var selectedProblem: ProblemRow? = nil
    @State private var priceString: String = ""

    // MARK: - Persistent Locks for fast creation
    @State private var isTypeLocked: Bool = false
    @State private var isBrandLocked: Bool = false
    @State private var isDeviceLocked: Bool = false

    @State private var isSaving = false
    @State private var errorMessage: String? = nil

    // MARK: - Derived filter lists
    var deviceTypes: [String] {
        Array(Set(viewModel.availableDevices.compactMap { $0.device_type })).sorted()
    }

    var brandsForType: [String] {
        guard !selectedDeviceType.isEmpty else { return [] }
        return Array(Set(
            viewModel.availableDevices
                .filter { $0.device_type == selectedDeviceType }
                .map { $0.brand }
                .filter { $0.lowercased() == "apple" } // Only show Apple
        )).sorted()
    }

    var modelsForBrand: [DeviceRow] {
        guard !selectedBrand.isEmpty else { return [] }
        let allFiltered = viewModel.availableDevices
            .filter { $0.device_type == selectedDeviceType && $0.brand == selectedBrand }
            .sorted { $0.model < $1.model }
        
        // Remove duplicates by model name
        var unique: [DeviceRow] = []
        var seen = Set<String>()
        for device in allFiltered {
            if !seen.contains(device.model) {
                unique.append(device)
                seen.insert(device.model)
            }
        }
        return unique
    }

    var isFormValid: Bool {
        selectedDevice != nil &&
        selectedProblem != nil &&
        (Double(priceString.replacingOccurrences(of: ",", with: ".")) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PerfectBackground()

                if viewModel.availableDevices.isEmpty {
                    VStack(spacing: 14) {
                        ProgressView()
                        Text("Loading options…")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Form {

                        // ─── Step 1: Device Type ───
                        Section {
                            HStack {
                                Picker("Device Type", selection: $selectedDeviceType) {
                                    Text("Select…").tag("")
                                    ForEach(deviceTypes, id: \.self) { type in
                                        Text(type).tag(type)
                                    }
                                }
                                .disabled(isTypeLocked)

                                LockToggle(isLocked: $isTypeLocked)
                                    .disabled(selectedDeviceType.isEmpty)
                            }
                            .onChange(of: selectedDeviceType) { _ in
                                if !isBrandLocked { selectedBrand = "" }
                                if !isDeviceLocked { selectedDevice = nil }
                            }
                        } header: {
                            Label("Device Type", systemImage: "laptopcomputer.and.iphone")
                        }

                        // ─── Step 2: Brand (only shows after type chosen) ───
                        if !selectedDeviceType.isEmpty {
                            Section {
                                HStack {
                                    Picker("Brand", selection: $selectedBrand) {
                                        Text("Select…").tag("")
                                        ForEach(brandsForType, id: \.self) { brand in
                                            Text(brand).tag(brand)
                                        }
                                    }
                                    .disabled(isBrandLocked)

                                    LockToggle(isLocked: $isBrandLocked)
                                        .disabled(selectedBrand.isEmpty)
                                }
                                .onChange(of: selectedBrand) { _ in
                                    if !isDeviceLocked { selectedDevice = nil }
                                }
                            } header: {
                                Label("Brand", systemImage: "tag")
                            }
                        }

                        // ─── Step 3: Model (only shows after brand chosen) ───
                        if !selectedBrand.isEmpty {
                            Section {
                                HStack {
                                    Picker("Model", selection: $selectedDevice) {
                                        Text("Select…").tag(nil as DeviceRow?)
                                        ForEach(modelsForBrand) { device in
                                            Text(device.model).tag(device as DeviceRow?)
                                        }
                                    }
                                    .disabled(isDeviceLocked)

                                    LockToggle(isLocked: $isDeviceLocked)
                                        .disabled(selectedDevice == nil)
                                }
                            } header: {
                                Label("Model", systemImage: "cpu")
                            }
                        }

                        // ─── Step 4: Problem (only shows after model chosen) ───
                        if selectedDevice != nil {
                            Section {
                                Picker("Problem", selection: $selectedProblem) {
                                    Text("Select…").tag(nil as ProblemRow?)
                                    ForEach(viewModel.availableProblems) { problem in
                                        Text(problem.problem_name).tag(problem as ProblemRow?)
                                    }
                                }
                            } header: {
                                Label("Problem Type", systemImage: "wrench.and.screwdriver")
                            }
                        }

                        // ─── Step 5: Price (only shows after problem chosen) ───
                        if selectedProblem != nil {
                            Section {
                                HStack {
                                    Text("€")
                                        .font(.title3.bold())
                                        .foregroundColor(.brandPrimary)
                                    TextField("Enter price", text: $priceString)
                                        .keyboardType(.decimalPad)
                                        .font(.title3)
                                }
                            } header: {
                                Label("Your Price", systemImage: "eurosign")
                            }
                        }

                        // ─── Error message ───
                        if let error = errorMessage {
                            Section {
                                Label(error, systemImage: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.subheadline)
                            }
                        }

                        // ─── Publish Button ───
                        if isFormValid {
                            Section {
                                Button(action: saveService) {
                                    HStack {
                                        Spacer()
                                        if isSaving {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        } else {
                                            Label(anyLocked ? "Publish & Next" : "Publish Service", systemImage: "icloud.and.arrow.up")
                                                .fontWeight(.bold)
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 6)
                                }
                                .listRowBackground(Color.brandPrimary)
                                .foregroundColor(.white)
                                .disabled(isSaving)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("New Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray.opacity(0.5), .gray.opacity(0.2))
                            .font(.title2)
                    }
                }
            }
        }
    }

    private var anyLocked: Bool {
        isTypeLocked || isBrandLocked || isDeviceLocked
    }

    private func saveService() {
        guard let device = selectedDevice, let problem = selectedProblem else { return }
        let price = Double(priceString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        guard price > 0 else { errorMessage = "Please enter a valid price."; return }

        isSaving = true
        errorMessage = nil

        Task {
            await viewModel.addService(
                deviceID: device.id,
                problemID: problem.id,
                price: price
            )
            await MainActor.run {
                isSaving = false
                if viewModel.uploadError == nil {
                    if anyLocked {
                        // Stay in the screen, reset only the unlocked parts
                        selectedProblem = nil
                        priceString = ""
                        
                        // Cascading reset logic
                        if !isDeviceLocked {
                            selectedDevice = nil
                            if !isBrandLocked {
                                selectedBrand = ""
                                if !isTypeLocked {
                                    selectedDeviceType = ""
                                }
                            }
                        }
                    } else {
                        dismiss()
                    }
                } else {
                    errorMessage = viewModel.uploadError
                }
            }
        }
    }
}

// MARK: - Lock Toggle Component
struct LockToggle: View {
    @Binding var isLocked: Bool
    
    var body: some View {
        Button(action: { withAnimation(.spring()) { isLocked.toggle() } }) {
            Image(systemName: isLocked ? "lock.fill" : "lock.open")
                .foregroundColor(isLocked ? .brandPrimary : .secondary)
                .font(.body.weight(.bold))
                .padding(8)
                .background(isLocked ? Color.brandPrimary.opacity(0.1) : Color.clear)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

