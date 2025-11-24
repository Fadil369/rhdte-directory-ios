// Brainsait Maplinc - Healthcare Directory App
// Main entry point for the Riyadh Healthcare Directory iOS App

import SwiftUI

@main
struct BrainsaitMaplincApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var dataService = RiyadhHealthcareDataService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(dataService)
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
    @EnvironmentObject var dataService: RiyadhHealthcareDataService
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Map Tab - Enhanced with Riyadh Healthcare Data
            EnhancedMapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(0)

            // Directory Tab - Healthcare Facilities List
            EnhancedDirectoryView()
                .tabItem {
                    Label("Directory", systemImage: "list.bullet")
                }
                .tag(1)

            // Saved Tab
            SavedFacilitiesView()
                .tabItem {
                    Label("Saved", systemImage: "heart.fill")
                }
                .tag(2)

            // Analytics Dashboard Tab
            AnalyticsDashboardView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(3)

            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .tint(Color("BrainSAITGreen"))
        .sheet(isPresented: $appState.showLeadMagnet) {
            LeadMagnetView()
        }
        .sheet(item: $appState.selectedFacility) { facility in
            FacilityDetailSheet(facility: facility)
        }
        .onAppear {
            // Load Riyadh healthcare data on launch
            dataService.loadSampleRiyadhData()
        }
    }
}
