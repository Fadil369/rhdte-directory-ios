// BrainSAIT RHDTE Directory App
// Main entry point for the Healthcare Directory iOS App

import SwiftUI

@main
struct RHDTEDirectoryApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: UserProfile?
    @Published var selectedFacility: Facility?
    @Published var showLeadMagnet = false
    @Published var savedFacilities: [String] = []
    
    init() {
        // Load saved state from UserDefaults
        loadSavedState()
    }
    
    func loadSavedState() {
        if let data = UserDefaults.standard.data(forKey: "savedFacilities"),
           let facilities = try? JSONDecoder().decode([String].self, from: data) {
            savedFacilities = facilities
        }
    }
    
    func saveFacility(_ facilityId: String) {
        if !savedFacilities.contains(facilityId) {
            savedFacilities.append(facilityId)
            saveState()
        }
    }
    
    func removeFacility(_ facilityId: String) {
        savedFacilities.removeAll { $0 == facilityId }
        saveState()
    }
    
    private func saveState() {
        if let data = try? JSONEncoder().encode(savedFacilities) {
            UserDefaults.standard.set(data, forKey: "savedFacilities")
        }
    }
}

// MARK: - Content View
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Map Tab
            MapTabView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(0)
            
            // Directory Tab
            DirectoryView()
                .tabItem {
                    Label("Directory", systemImage: "list.bullet")
                }
                .tag(1)
            
            // AI Triage Tab
            VoiceTriageView()
                .tabItem {
                    Label("AI Triage", systemImage: "waveform.circle.fill")
                }
                .tag(2)
            
            // Health Records Tab
            HealthRecordsView()
                .tabItem {
                    Label("Health", systemImage: "heart.text.square.fill")
                }
                .tag(3)
            
            // Saved Tab
            SavedFacilitiesView()
                .tabItem {
                    Label("Saved", systemImage: "heart.fill")
                }
                .tag(4)
            
            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(5)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(6)
        }
        .tint(Color("BrainSAITGreen"))
        .sheet(isPresented: $appState.showLeadMagnet) {
            LeadMagnetView()
        }
        .sheet(item: $appState.selectedFacility) { facility in
            FacilityDetailSheet(facility: facility)
        }
    }
}
