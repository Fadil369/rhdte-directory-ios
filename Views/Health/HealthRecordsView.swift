import SwiftUI
import HealthKit
import CareKitStore
import SMART

/// HealthRecordsView displays health data from HealthKit, Epic FHIR, and CareKit
struct HealthRecordsView: View {
    @StateObject private var healthKitService = HealthKitService.shared
    @StateObject private var epicService = EpicFHIRService.shared
    @StateObject private var careKitService = CareKitService.shared
    @State private var selectedTab: HealthTab = .vitals
    @State private var showEpicConnection = false
    @State private var showHealthKitAuth = false
    @State private var epicClientId = ""
    @State private var isLoading = false
    @State private var showSyncSuccess = false
    
    enum HealthTab: String, CaseIterable {
        case vitals = "Vitals"
        case records = "Records"
        case medications = "Meds"
        case tasks = "Tasks"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab picker
                Picker("Health Section", selection: $selectedTab) {
                    ForEach(HealthTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                ScrollView {
                    switch selectedTab {
                    case .vitals:
                        vitalsView
                    case .records:
                        medicalRecordsView
                    case .medications:
                        medicationsView
                    case .tasks:
                        tasksView
                    }
                }
                .refreshable {
                    await refreshData()
                }
            }
            .navigationTitle("Health Records")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Section("Connections") {
                            Button(action: connectHealthKit) {
                                Label(
                                    healthKitService.isAuthorized ? "HealthKit Connected ✓" : "Connect HealthKit",
                                    systemImage: "heart.circle"
                                )
                            }
                            .disabled(healthKitService.isAuthorized)
                            
                            Button(action: { showEpicConnection = true }) {
                                Label(
                                    epicService.isConnected ? "Epic Connected ✓" : "Connect Epic",
                                    systemImage: "link.circle"
                                )
                            }
                        }
                        
                        Section("Actions") {
                            Button(action: syncAllData) {
                                Label("Sync All Data", systemImage: "arrow.triangle.2.circlepath")
                            }
                            .disabled(!healthKitService.isAuthorized && !epicService.isConnected)
                            
                            if epicService.isConnected {
                                Button(action: syncEpicToHealthKit) {
                                    Label("Sync Epic → HealthKit", systemImage: "arrow.right.circle")
                                }
                            }
                        }
                        
                        if epicService.isConnected {
                            Section {
                                Button(role: .destructive, action: disconnectEpic) {
                                    Label("Disconnect Epic", systemImage: "xmark.circle")
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showEpicConnection) {
                epicConnectionSheet
            }
            .overlay {
                if isLoading {
                    ProgressView("Loading...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .alert("Sync Complete", isPresented: $showSyncSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Health data has been synchronized successfully.")
            }
            .task {
                if healthKitService.isAuthorized {
                    await healthKitService.fetchLatestHealthData()
                }
                if careKitService.isInitialized {
                    await careKitService.fetchTasks()
                }
            }
        }
    }
    
    // MARK: - Epic Connection Sheet
    
    private var epicConnectionSheet: some View {
        NavigationView {
            Form {
                Section {
                    Text("Connect to your Epic MyChart account to view your medical records, medications, and clinical data.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Section("Epic Configuration") {
                    if !epicService.isConfigured {
                        TextField("Epic Client ID", text: $epicClientId)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        Button("Configure") {
                            guard !epicClientId.isEmpty else { return }
                            epicService.configure(clientId: epicClientId)
                        }
                        .disabled(epicClientId.isEmpty)
                    } else {
                        Label("Client ID Configured", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                if epicService.isConfigured {
                    Section {
                        Button(action: connectEpic) {
                            HStack {
                                Spacer()
                                if epicService.isConnected {
                                    Label("Connected", systemImage: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else {
                                    Text("Connect to Epic")
                                }
                                Spacer()
                            }
                        }
                        .disabled(epicService.isConnected)
                    }
                }
                
                if let error = epicService.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section("Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("HIPAA Compliant", systemImage: "lock.shield")
                        Label("Secure OAuth 2.0", systemImage: "key")
                        Label("Data stays on your device", systemImage: "iphone")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Epic Connection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showEpicConnection = false
                    }
                }
            }
        }
    }
    
    // MARK: - Vitals View
    
    private var vitalsView: some View {
        VStack(spacing: 16) {
            if !healthKitService.isAuthorized {
                EmptyStateCard(
                    icon: "heart.circle",
                    title: "Connect HealthKit",
                    message: "Enable HealthKit to view your health vitals"
                ) {
                    connectHealthKit()
                }
            } else {
                // Heart Rate Card
                VitalCard(
                    title: "Heart Rate",
                    value: healthKitService.healthData.heartRate,
                    unit: "bpm",
                    icon: "heart.fill",
                    color: .red
                )
                
                // Blood Pressure Row
                HStack(spacing: 12) {
                    VitalCard(
                        title: "Systolic",
                        value: healthKitService.healthData.bloodPressureSystolic,
                        unit: "mmHg",
                        icon: "arrow.up.heart",
                        color: .blue
                    )
                    VitalCard(
                        title: "Diastolic",
                        value: healthKitService.healthData.bloodPressureDiastolic,
                        unit: "mmHg",
                        icon: "arrow.down.heart",
                        color: .blue
                    )
                }
                
                // Steps Card
                VitalCard(
                    title: "Steps Today",
                    value: healthKitService.healthData.steps,
                    unit: "steps",
                    icon: "figure.walk",
                    color: .green
                )
                
                // Additional vitals in a grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    // Weight card - only show if weight data is available
                    if let weight = healthKitService.healthData.weight {
                        VitalCard(
                            title: "Weight",
                            value: weight,
                            unit: "kg",
                            icon: "scalemass",
                            color: .purple
                        )
                    }
                    
                    // SpO₂ - HealthKit stores as decimal (0-1), display as percentage
                    if let spo2 = healthKitService.healthData.oxygenSaturation {
                        VitalCard(
                            title: "SpO₂",
                            value: spo2 * 100, // Convert from decimal to percentage for display
                            unit: "%",
                            icon: "lungs",
                            color: .cyan
                        )
                    }
                    
                    if healthKitService.healthData.bodyTemperature != nil {
                        VitalCard(
                            title: "Temperature",
                            value: healthKitService.healthData.bodyTemperature,
                            unit: "°C",
                            icon: "thermometer",
                            color: .orange
                        )
                    }
                    
                    if healthKitService.healthData.bloodGlucose != nil {
                        VitalCard(
                            title: "Blood Glucose",
                            value: healthKitService.healthData.bloodGlucose,
                            unit: "mg/dL",
                            icon: "drop.fill",
                            color: .red
                        )
                    }
                }
            }
        }
        .padding()
    }
    
    // MARK: - Medical Records View
    
    private var medicalRecordsView: some View {
        VStack(spacing: 16) {
            if epicService.isConnected {
                // Patient Info
                if let patient = epicService.patient {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(patient.displayName)
                            .font(.headline)
                        if let birthDate = patient.birthDateString {
                            Text("DOB: \(birthDate)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                
                // Observations
                RecordsSectionView(
                    title: "Observations",
                    count: epicService.observations.count,
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
                
                // Conditions
                RecordsSectionView(
                    title: "Conditions",
                    count: epicService.conditions.count,
                    icon: "cross.case",
                    color: .orange
                )
                
                // Immunizations
                RecordsSectionView(
                    title: "Immunizations",
                    count: epicService.immunizations.count,
                    icon: "syringe",
                    color: .green
                )
                
                // Allergies
                RecordsSectionView(
                    title: "Allergies",
                    count: epicService.allergyIntolerances.count,
                    icon: "allergens",
                    color: .red
                )
            } else {
                EmptyStateCard(
                    icon: "link.circle",
                    title: "Connect Epic",
                    message: "Link your Epic MyChart account to view your complete medical records"
                ) {
                    showEpicConnection = true
                }
            }
        }
        .padding()
    }
    
    // MARK: - Medications View
    
    private var medicationsView: some View {
        VStack(spacing: 16) {
            if epicService.isConnected && !epicService.medications.isEmpty {
                ForEach(0..<min(epicService.medications.count, 10), id: \.self) { index in
                    MedicationCard(medication: epicService.medications[index])
                }
                
                if epicService.medications.count > 10 {
                    Text("And \(epicService.medications.count - 10) more...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if epicService.isConnected {
                VStack(spacing: 12) {
                    Image(systemName: "pills")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No medications found")
                        .font(.headline)
                    Text("Your medication list will appear here once loaded from Epic.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                EmptyStateCard(
                    icon: "pills",
                    title: "View Medications",
                    message: "Connect to Epic to see your current medications"
                ) {
                    showEpicConnection = true
                }
            }
        }
        .padding()
    }
    
    // MARK: - Tasks View
    
    private var tasksView: some View {
        VStack(spacing: 16) {
            if careKitService.isInitialized {
                if careKitService.tasks.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checklist")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No active tasks")
                            .font(.headline)
                        Text("Your care tasks will appear here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    ForEach(careKitService.tasks, id: \.id) { task in
                        TaskCard(task: task)
                    }
                }
            } else {
                ProgressView("Loading tasks...")
            }
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func connectHealthKit() {
        Task {
            isLoading = true
            _ = await healthKitService.requestAuthorization()
            if healthKitService.isAuthorized {
                await healthKitService.fetchLatestHealthData()
            }
            isLoading = false
        }
    }
    
    private func connectEpic() {
        Task {
            isLoading = true
            do {
                try await epicService.authorize()
                if epicService.isConnected {
                    try await epicService.fetchPatientData()
                    showEpicConnection = false
                }
            } catch {
                // Error will be shown in the sheet
            }
            isLoading = false
        }
    }
    
    private func disconnectEpic() {
        epicService.disconnect()
    }
    
    private func syncAllData() {
        Task {
            isLoading = true
            await refreshData()
            isLoading = false
            showSyncSuccess = true
        }
    }
    
    private func syncEpicToHealthKit() {
        Task {
            isLoading = true
            do {
                try await epicService.syncToHealthKit()
                await healthKitService.fetchLatestHealthData()
                showSyncSuccess = true
            } catch {
                // Handle error
            }
            isLoading = false
        }
    }
    
    private func refreshData() async {
        if healthKitService.isAuthorized {
            await healthKitService.fetchLatestHealthData()
        }
        if epicService.isConnected {
            do {
                try await epicService.fetchPatientData()
            } catch {
                // Handle error
            }
        }
        await careKitService.fetchTasks()
    }
}

// MARK: - Supporting Views

struct VitalCard: View {
    let title: String
    let value: Double?
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let value = value {
                    Text("\(String(format: "%.1f", value)) \(unit)")
                        .font(.title3)
                        .bold()
                } else {
                    Text("--")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct EmptyStateCard: View {
    let icon: String
    let title: String
    let message: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: action) {
                Text("Connect")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct RecordsSectionView: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 32)
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Text("\(count)")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct MedicationCard: View {
    let medication: MedicationRequest
    
    var body: some View {
        HStack {
            Image(systemName: "pills.fill")
                .foregroundColor(.purple)
                .font(.title2)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.medicationCodeableConcept?.text?.string ?? "Unknown Medication")
                    .font(.headline)
                
                if let status = medication.status?.rawValue {
                    Text(status.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct TaskCard: View {
    let task: OCKTask
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle")
                .foregroundColor(.green)
                .font(.title2)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title ?? "Task")
                    .font(.headline)
                
                if let instructions = task.instructions {
                    Text(instructions)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    HealthRecordsView()
}
