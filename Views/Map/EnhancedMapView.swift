// BrainSAIT RHDTE - Enhanced Map View
// Interactive map with real facility data from multiple sources

import SwiftUI
import MapKit

struct EnhancedMapView: View {
    @EnvironmentObject var facilityDataManager: FacilityDataManager
    @State private var searchText = ""
    @State private var selectedSource: String?
    @State private var selectedFacilityType: String?
    @State private var showFilters = false
    @State private var minRating: Double?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    )
    
    var displayedFacilities: [HealthFacility] {
        facilityDataManager.filterFacilities(
            by: selectedFacilityType,
            source: selectedSource,
            searchText: searchText,
            minRating: minRating
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                // Map
                Map(coordinateRegion: $region, annotationItems: displayedFacilities) { facility in
                    MapAnnotation(coordinate: facility.coordinate) {
                        HealthFacilityMarker(facility: facility)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                
                // Search and Filters
                VStack(spacing: 12) {
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
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    
                    // Quick Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "All (\(facilityDataManager.facilities.count))", isSelected: selectedSource == nil && selectedFacilityType == nil) {
                                selectedSource = nil
                                selectedFacilityType = nil
                            }
                            
                            ForEach(Array(facilityDataManager.sourceStats.keys.sorted()), id: \.self) { source in
                                FilterChip(
                                    title: "\(sourceLabel(source)) (\(facilityDataManager.sourceStats[source] ?? 0))",
                                    isSelected: selectedSource == source
                                ) {
                                    selectedSource = selectedSource == source ? nil : source
                                }
                            }
                            
                            FilterChip(title: "Hospitals", isSelected: selectedFacilityType == "hospital") {
                                selectedFacilityType = selectedFacilityType == "hospital" ? nil : "hospital"
                            }
                            
                            FilterChip(title: "Clinics", isSelected: selectedFacilityType == "clinic") {
                                selectedFacilityType = selectedFacilityType == "clinic" ? nil : "clinic"
                            }
                            
                            FilterChip(title: "Pharmacies", isSelected: selectedFacilityType == "pharmacy") {
                                selectedFacilityType = selectedFacilityType == "pharmacy" ? nil : "pharmacy"
                            }
                            
                            FilterChip(title: "Rated", isSelected: minRating != nil) {
                                minRating = minRating == nil ? 3.0 : nil
                            }
                        }
                    }
                }
                .padding()
                
                // Results Count
                VStack {
                    Spacer()
                    HStack {
                        Text("\(displayedFacilities.count) facilities")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                        Spacer()
                    }
                    .padding(.leading)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Healthcare Map")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showFilters) {
                MapFiltersSheet(
                    selectedSource: $selectedSource,
                    selectedFacilityType: $selectedFacilityType,
                    minRating: $minRating,
                    facilityDataManager: facilityDataManager
                )
            }
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

struct HealthFacilityMarker: View {
    let facility: HealthFacility
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: facility.icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(markerColor)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 2)
            
            Image(systemName: "triangle.fill")
                .font(.system(size: 8))
                .foregroundColor(markerColor)
                .rotationEffect(.degrees(180))
                .offset(y: -2)
        }
    }
    
    var markerColor: Color {
        switch facility.source {
        case "google_places":
            return .blue
        case "hdx":
            return .green
        case "overpass":
            return .orange
        default:
            return .gray
        }
    }
}

struct MapFiltersSheet: View {
    @Binding var selectedSource: String?
    @Binding var selectedFacilityType: String?
    @Binding var minRating: Double?
    let facilityDataManager: FacilityDataManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Data Source") {
                    Button(action: { selectedSource = nil }) {
                        HStack {
                            Text("All Sources")
                            Spacer()
                            if selectedSource == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    ForEach(Array(facilityDataManager.sourceStats.keys.sorted()), id: \.self) { source in
                        Button(action: { selectedSource = source }) {
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
                    ForEach(["hospital", "clinic", "pharmacy", "doctors"], id: \.self) { type in
                        Button(action: { selectedFacilityType = type }) {
                            HStack {
                                Text(type.capitalized)
                                Spacer()
                                if selectedFacilityType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section("Rating") {
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
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        selectedSource = nil
                        selectedFacilityType = nil
                        minRating = nil
                    }
                }
            }
        }
    }
    
    private func sourceDisplayName(_ source: String) -> String {
        switch source {
        case "google_places": return "Google Places"
        case "hdx": return "HDX (Humanitarian Data)"
        case "overpass": return "OpenStreetMap"
        default: return source.capitalized
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}
