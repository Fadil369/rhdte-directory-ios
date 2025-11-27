// BrainSAIT RHDTE - Profile View
// User profile and settings

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var facilityDataManager: FacilityDataManager
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Guest User")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("Not signed in")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Statistics Section
                Section("Your Stats") {
                    StatRow(icon: "heart.fill", label: "Saved Facilities", value: "\(appState.savedFacilities.count)")
                    StatRow(icon: "building.2", label: "Total Facilities", value: "\(facilityDataManager.facilities.count)")
                    StatRow(icon: "star.fill", label: "Avg Rating", value: String(format: "%.1f", facilityDataManager.averageRating()))
                }
                
                // Data Sources Section
                Section("Data Sources") {
                    ForEach(Array(facilityDataManager.sourceStats.sorted(by: { $0.value > $1.value })), id: \.key) { source, count in
                        HStack {
                            Image(systemName: sourceIcon(for: source))
                                .foregroundColor(sourceColor(for: source))
                            Text(sourceDisplayName(for: source))
                            Spacer()
                            Text("\(count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // App Info Section
                Section("About") {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About RHDTE", systemImage: "info.circle")
                    }
                    
                    NavigationLink {
                        DataSourcesView()
                    } label: {
                        Label("Data Sources", systemImage: "server.rack")
                    }
                    
                    Link(destination: URL(string: "https://brainsait.com")!) {
                        Label("BrainSAIT Website", systemImage: "globe")
                    }
                }
                
                // Settings Section
                Section {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
                
                // Version
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    private func sourceIcon(for source: String) -> String {
        switch source {
        case "google_places": return "map.fill"
        case "hdx": return "globe"
        case "overpass": return "map"
        default: return "building.2"
        }
    }
    
    private func sourceColor(for source: String) -> Color {
        switch source {
        case "google_places": return .blue
        case "hdx": return .green
        case "overpass": return .orange
        default: return .gray
        }
    }
    
    private func sourceDisplayName(for source: String) -> String {
        switch source {
        case "google_places": return "Google Places"
        case "hdx": return "HDX Data"
        case "overpass": return "OpenStreetMap"
        default: return source.capitalized
        }
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("RHDTE Directory")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Riyadh Health Digital Transformation Ecosystem")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                Text("About")
                    .font(.headline)
                
                Text("RHDTE Directory is a comprehensive healthcare facility directory for Riyadh and Saudi Arabia. We aggregate data from multiple trusted sources to provide you with the most complete and up-to-date information about healthcare facilities.")
                    .font(.body)
                
                Text("Data Sources")
                    .font(.headline)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 12) {
                    DataSourceItem(
                        name: "Google Places",
                        description: "Real-time facility data with ratings, reviews, and contact information",
                        count: "502 facilities"
                    )
                    
                    DataSourceItem(
                        name: "HDX (Humanitarian Data Exchange)",
                        description: "Comprehensive healthcare facility data across Saudi Arabia",
                        count: "2,154 facilities"
                    )
                    
                    DataSourceItem(
                        name: "OpenStreetMap",
                        description: "Community-maintained facility information",
                        count: "295 facilities"
                    )
                }
                
                Text("Developed by BrainSAIT")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DataSourceItem: View {
    let name: String
    let description: String
    let count: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(count)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct DataSourcesView: View {
    var body: some View {
        List {
            Section {
                Text("This app aggregates healthcare facility data from three trusted sources to provide comprehensive coverage:")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            
            Section("Google Places API") {
                Text("Rich metadata including ratings, reviews, phone numbers, websites, and business hours for facilities in Riyadh.")
                DetailRow(label: "Coverage", value: "Riyadh City")
                DetailRow(label: "Facilities", value: "502")
                DetailRow(label: "Features", value: "Ratings, Reviews, Contact Info")
            }
            
            Section("HDX - Humanitarian Data Exchange") {
                Text("Comprehensive healthcare facility data sourced from OpenStreetMap for all of Saudi Arabia.")
                DetailRow(label: "Coverage", value: "Saudi Arabia")
                DetailRow(label: "Facilities", value: "2,154")
                DetailRow(label: "Features", value: "Healthcare Classifications")
            }
            
            Section("OpenStreetMap (Overpass API)") {
                Text("Community-maintained healthcare facility information with detailed healthcare specialties.")
                DetailRow(label: "Coverage", value: "Saudi Arabia")
                DetailRow(label: "Facilities", value: "295")
                DetailRow(label: "Features", value: "Healthcare Specialties")
            }
            
            Section {
                Text("Total unique facilities: 2,951")
                    .font(.headline)
                    .padding(.vertical, 4)
            }
        }
        .navigationTitle("Data Sources")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.caption)
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("language") private var language = "en"
    @AppStorage("showRatings") private var showRatings = true
    @AppStorage("mapStyle") private var mapStyle = "standard"
    
    var body: some View {
        NavigationView {
            Form {
                Section("Display") {
                    Toggle("Show Ratings", isOn: $showRatings)
                    
                    Picker("Language", selection: $language) {
                        Text("English").tag("en")
                        Text("العربية").tag("ar")
                    }
                }
                
                Section("Map") {
                    Picker("Map Style", selection: $mapStyle) {
                        Text("Standard").tag("standard")
                        Text("Satellite").tag("satellite")
                        Text("Hybrid").tag("hybrid")
                    }
                }
                
                Section {
                    Button("Clear Cache") {
                        // Clear cache logic
                    }
                    
                    Button("Reset All Settings", role: .destructive) {
                        language = "en"
                        showRatings = true
                        mapStyle = "standard"
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
