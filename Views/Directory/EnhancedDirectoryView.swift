// BrainSAIT RHDTE - Enhanced Directory View
// Comprehensive list view with real facility data

import SwiftUI
import CoreLocation

struct EnhancedDirectoryView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var facilityDataManager: FacilityDataManager
    @State private var searchText = ""
    @State private var selectedSource: String?
    @State private var selectedType: String?
    @State private var sortOption: FacilitySortOption = .name
    @State private var showFilters = false
    @State private var minRating: Double?
    @State private var hasContactInfo = false
    
    var filteredFacilities: [HealthFacility] {
        let filtered = facilityDataManager.filterFacilities(
            by: selectedType,
            source: selectedSource,
            searchText: searchText,
            hasRating: minRating != nil,
            hasContactInfo: hasContactInfo,
            minRating: minRating
        )
        return facilityDataManager.sortFacilities(filtered, by: sortOption)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search facilities...", text: $searchText)
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: { showFilters.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(hasActiveFilters ? .blue : .primary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Quick Stats
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        StatCard(
                            icon: "building.2",
                            title: "Total",
                            value: "\(facilityDataManager.facilities.count)"
                        )
                        
                        StatCard(
                            icon: "star.fill",
                            title: "Avg Rating",
                            value: String(format: "%.1f", facilityDataManager.averageRating())
                        )
                        
                        StatCard(
                            icon: "phone.fill",
                            title: "With Contact",
                            value: "\(facilityDataManager.facilities.filter { $0.hasContactInfo }.count)"
                        )
                        
                        ForEach(Array(facilityDataManager.sourceStats.sorted(by: { $0.value > $1.value })), id: \.key) { source, count in
                            StatCard(
                                icon: sourceIcon(source),
                                title: sourceLabel(source),
                                value: "\(count)"
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Results Header
                HStack {
                    Text("\(filteredFacilities.count) facilities")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Menu {
                        ForEach([FacilitySortOption.name, .rating, .reviewCount, .source], id: \.self) { option in
                            Button(option.rawValue) {
                                sortOption = option
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("Sort: \(sortOption.rawValue)")
                                .font(.caption)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Facilities List
                if facilityDataManager.isLoading {
                    ProgressView("Loading facilities...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredFacilities.isEmpty {
                    EmptyResultsView(searchText: searchText)
                } else {
                    List {
                        ForEach(filteredFacilities) { facility in
                            EnhancedFacilityRow(facility: facility)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // Show detail sheet
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Directory")
            .sheet(isPresented: $showFilters) {
                DirectoryFiltersSheet(
                    selectedSource: $selectedSource,
                    selectedType: $selectedType,
                    minRating: $minRating,
                    hasContactInfo: $hasContactInfo,
                    facilityDataManager: facilityDataManager
                )
            }
        }
    }
    
    private var hasActiveFilters: Bool {
        selectedSource != nil || selectedType != nil || minRating != nil || hasContactInfo
    }
    
    private func sourceIcon(_ source: String) -> String {
        switch source {
        case "google_places": return "map.fill"
        case "hdx": return "globe"
        case "overpass": return "map"
        default: return "building.2"
        }
    }
    
    private func sourceLabel(_ source: String) -> String {
        switch source {
        case "google_places": return "Google"
        case "hdx": return "HDX"
        case "overpass": return "OSM"
        default: return source
        }
    }
}

struct EnhancedFacilityRow: View {
    let facility: HealthFacility
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: facility.icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(sourceColor)
                .cornerRadius(12)
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(facility.displayName)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Label(facility.facilityType, systemImage: "building.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let rating = facility.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                
                if !facility.displayAddress.isEmpty {
                    Text(facility.displayAddress)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    Label(facility.sourceDisplayName, systemImage: sourceIcon)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if let reviews = facility.userRatingsTotal, reviews > 0 {
                        Text("• \(reviews) reviews")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    if facility.phone != nil {
                        Image(systemName: "phone.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    
                    if facility.website != nil {
                        Image(systemName: "globe")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            // Save button
            Button(action: toggleSave) {
                Image(systemName: isSaved ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundColor(isSaved ? .red : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
    
    private var isSaved: Bool {
        appState.savedFacilities.contains(facility.id)
    }
    
    private func toggleSave() {
        if isSaved {
            appState.removeFacility(facility.id)
        } else {
            appState.saveFacility(facility.id)
        }
    }
    
    private var sourceColor: Color {
        switch facility.source {
        case "google_places": return .blue
        case "hdx": return .green
        case "overpass": return .orange
        default: return .gray
        }
    }
    
    private var sourceIcon: String {
        switch facility.source {
        case "google_places": return "map.fill"
        case "hdx": return "globe"
        case "overpass": return "map"
        default: return "building.2"
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(.blue)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 80)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct EmptyResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Results")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(searchText.isEmpty ? "No facilities found with current filters" : "No facilities found for '\(searchText)'")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DirectoryFiltersSheet: View {
    @Binding var selectedSource: String?
    @Binding var selectedType: String?
    @Binding var minRating: Double?
    @Binding var hasContactInfo: Bool
    let facilityDataManager: FacilityDataManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Data Source") {
                    ForEach(Array(facilityDataManager.sourceStats.keys.sorted()), id: \.self) { source in
                        Button(action: { selectedSource = selectedSource == source ? nil : source }) {
                            HStack {
                                Text(sourceDisplayName(source))
                                Spacer()
                                Text("\(facilityDataManager.sourceStats[source] ?? 0)")
                                    .foregroundColor(.secondary)
                                if selectedSource == source {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section("Facility Type") {
                    let types = facilityDataManager.facilitiesByType().keys.sorted()
                    ForEach(types, id: \.self) { type in
                        Button(action: { selectedType = selectedType == type ? nil : type }) {
                            HStack {
                                Text(type)
                                Spacer()
                                Text("\(facilityDataManager.facilitiesByType()[type] ?? 0)")
                                    .foregroundColor(.secondary)
                                if selectedType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section("Filters") {
                    Toggle("Has Contact Info", isOn: $hasContactInfo)
                    
                    Picker("Minimum Rating", selection: $minRating) {
                        Text("Any").tag(nil as Double?)
                        Text("3.0+").tag(3.0 as Double?)
                        Text("3.5+").tag(3.5 as Double?)
                        Text("4.0+").tag(4.0 as Double?)
                        Text("4.5+").tag(4.5 as Double?)
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        selectedSource = nil
                        selectedType = nil
                        minRating = nil
                        hasContactInfo = false
                    }
                }
            }
        }
    }
    
    private func sourceDisplayName(_ source: String) -> String {
        switch source {
        case "google_places": return "Google Places"
        case "hdx": return "HDX Data"
        case "overpass": return "OpenStreetMap"
        default: return source.capitalized
        }
    }
}
