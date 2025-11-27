import SwiftUI
import HealthKit

struct HealthRecordsView: View {
    @StateObject private var healthKitService = HealthKitService.shared
    @StateObject private var epicService = EpicFHIRService.shared
    @StateObject private var careKitService = CareKitService.shared
    @State private var selectedTab: HealthTab = .vitals
    @State private var showEpicConnection = false
    @State private var showHealthKitAuth = false
    
    enum HealthTab {
        case vitals, records, medications, tasks
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Health Section", selection: $selectedTab) {
                    Text("Vitals").tag(HealthTab.vitals)
                    Text("Records").tag(HealthTab.records)
                    Text("Meds").tag(HealthTab.medications)
                    Text("Tasks").tag(HealthTab.tasks)
                }
                .pickerStyle(.segmented)
                .padding()
                
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
            }
            .navigationTitle("Health Records")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showHealthKitAuth = true }) {
                            Label(healthKitService.isAuthorized ? "HealthKit Connected" : "Connect HealthKit", systemImage: "heart.circle")
                        }
                        Button(action: { showEpicConnection = true }) {
                            Label(epicService.isConnected ? "Epic Connected" : "Connect Epic", systemImage: "link.circle")
                        }
                        Divider()
                        Button(action: syncAllData) {
                            Label("Sync All Data", systemImage: "arrow.triangle.2.circlepath")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showEpicConnection) {
                Text("Epic Connection - Configure with your Client ID")
            }
            .task {
                if healthKitService.isAuthorized {
                    await healthKitService.fetchLatestHealthData()
                }
            }
        }
    }
    
    private var vitalsView: some View {
        VStack(spacing: 16) {
            if !healthKitService.isAuthorized {
                EmptyStateCard(icon: "heart.circle", title: "Connect HealthKit", message: "Enable HealthKit to view vitals") {
                    Task { await healthKitService.requestAuthorization() }
                }
            } else {
                VitalCard(title: "Heart Rate", value: healthKitService.healthData.heartRate, unit: "bpm", icon: "heart.fill", color: .red)
                VitalCard(title: "Blood Pressure", value: healthKitService.healthData.bloodPressureSystolic, unit: "mmHg", icon: "waveform", color: .blue)
                VitalCard(title: "Steps Today", value: healthKitService.healthData.steps, unit: "steps", icon: "figure.walk", color: .green)
            }
        }
        .padding()
    }
    
    private var medicalRecordsView: some View {
        VStack {
            if epicService.isConnected {
                Text("Epic Records: \(epicService.observations.count) observations")
            } else {
                EmptyStateCard(icon: "link.circle", title: "Connect Epic", message: "View your medical records") {
                    showEpicConnection = true
                }
            }
        }
        .padding()
    }
    
    private var medicationsView: some View {
        VStack {
            Text("Medications: \(epicService.medications.count)")
        }
        .padding()
    }
    
    private var tasksView: some View {
        VStack {
            Text("Care Tasks: \(careKitService.tasks.count)")
        }
        .padding()
    }
    
    private func syncAllData() {
        Task {
            await healthKitService.fetchLatestHealthData()
        }
    }
}

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
            VStack(alignment: .leading) {
                Text(title).font(.caption).foregroundColor(.secondary)
                if let value = value {
                    Text("\(String(format: "%.1f", value)) \(unit)").font(.title3).bold()
                } else {
                    Text("--").foregroundColor(.secondary)
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
            Image(systemName: icon).font(.system(size: 50)).foregroundColor(.gray)
            Text(title).font(.headline)
            Text(message).font(.subheadline).foregroundColor(.secondary)
            Button(action: action) {
                Text("Connect").padding().background(Color.blue).foregroundColor(.white).cornerRadius(10)
            }
        }
        .padding(32)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
