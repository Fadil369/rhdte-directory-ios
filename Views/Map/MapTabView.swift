// BrainSAIT RHDTE - Map Tab View
// Interactive map showing healthcare facilities with clustering

import SwiftUI
import MapKit

struct MapTabView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = MapViewModel()
    @State private var searchText = ""
    @State private var showFilters = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753), // Riyadh
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    )
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Map
                Map(coordinateRegion: $region, annotationItems: viewModel.facilities) { facility in
                    MapAnnotation(coordinate: facility.coordinate) {
                        FacilityMapPin(facility: facility) {
                            appState.selectedFacility = facility
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                
                // Search & Filters Overlay
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
                    
                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "All", isSelected: viewModel.selectedType == nil) {
                                viewModel.selectedType = nil
                            }
                            
                            ForEach(FacilityType.allCases, id: \.self) { type in
                                FilterChip(
                                    title: type.rawValue,
                                    isSelected: viewModel.selectedType == type
                                ) {
                                    viewModel.selectedType = type
                                }
                            }
                        }
                    }
                }
                .padding()
                
                // Current Location Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: viewModel.centerOnUserLocation) {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color("BrainSAITGreen"))
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Healthcare Map")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showFilters) {
                FiltersSheet(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.loadFacilities()
        }
    }
}

// MARK: - Map Pin View
struct FacilityMapPin: View {
    let facility: Facility
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Image(systemName: facility.type.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(pinColor)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 3)
                
                Image(systemName: "triangle.fill")
                    .font(.system(size: 10))
                    .foregroundColor(pinColor)
                    .rotationEffect(.degrees(180))
                    .offset(y: -3)
            }
        }
    }
    
    var pinColor: Color {
        switch facility.type {
        case .hospital: return .red
        case .pharmacy: return .green
        case .dentalClinic: return .blue
        case .laboratory: return .purple
        default: return Color("BrainSAITGreen")
        }
    }
}

// MARK: - Filter Chip
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
                .background(isSelected ? Color("BrainSAITGreen") : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

// MARK: - Filters Sheet
struct FiltersSheet: View {
    @ObservedObject var viewModel: MapViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Facility Type") {
                    ForEach(FacilityType.allCases, id: \.self) { type in
                        Toggle(type.rawValue, isOn: Binding(
                            get: { viewModel.selectedTypes.contains(type) },
                            set: { isOn in
                                if isOn {
                                    viewModel.selectedTypes.insert(type)
                                } else {
                                    viewModel.selectedTypes.remove(type)
                                }
                            }
                        ))
                    }
                }
                
                Section("Features") {
                    Toggle("24 Hours", isOn: $viewModel.filter24Hours)
                    Toggle("Emergency Services", isOn: $viewModel.filterEmergency)
                    Toggle("Online Booking", isOn: $viewModel.filterOnlineBooking)
                }
                
                Section("Rating") {
                    Picker("Minimum Rating", selection: $viewModel.minRating) {
                        Text("Any").tag(0.0)
                        Text("3.0+").tag(3.0)
                        Text("3.5+").tag(3.5)
                        Text("4.0+").tag(4.0)
                        Text("4.5+").tag(4.5)
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        viewModel.applyFilters()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        viewModel.resetFilters()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Map View Model
class MapViewModel: ObservableObject {
    @Published var facilities: [Facility] = []
    @Published var selectedType: FacilityType?
    @Published var selectedTypes: Set<FacilityType> = []
    @Published var filter24Hours = false
    @Published var filterEmergency = false
    @Published var filterOnlineBooking = false
    @Published var minRating: Double = 0.0
    
    private let apiService = APIService.shared
    
    func loadFacilities() {
        // Load from API
        Task {
            do {
                let facilities = try await apiService.fetchFacilities()
                DispatchQueue.main.async {
                    self.facilities = facilities
                }
            } catch {
                print("Error loading facilities: \(error)")
                // Load sample data for demo
                DispatchQueue.main.async {
                    self.facilities = self.sampleFacilities()
                }
            }
        }
    }
    
    func centerOnUserLocation() {
        // Request location permission and center map
    }
    
    func applyFilters() {
        // Apply filters to facilities
    }
    
    func resetFilters() {
        selectedTypes = []
        filter24Hours = false
        filterEmergency = false
        filterOnlineBooking = false
        minRating = 0.0
    }
    
    private func sampleFacilities() -> [Facility] {
        [
            Facility(
                id: "1",
                placeId: "place_1",
                nameEn: "Kingdom Hospital",
                nameAr: "مستشفى المملكة",
                type: .hospital,
                address: "King Fahd Road, Olaya",
                district: "Olaya",
                city: "Riyadh",
                latitude: 24.7136,
                longitude: 46.6753,
                phone: "+966 11 123 4567",
                website: "https://kingdom-hospital.com",
                email: "info@kingdom-hospital.com",
                rating: 4.5,
                reviewCount: 342,
                isOpen: true,
                openingHours: nil,
                services: ["Emergency", "ICU", "Surgery"],
                insuranceAccepted: ["Bupa", "Tawuniya"],
                languages: ["Arabic", "English"],
                hasEmergency: true,
                is24Hours: true,
                hasOnlineBooking: true,
                hasWhatsApp: true,
                digitalScore: 85,
                maturityLevel: "integrated"
            ),
            Facility(
                id: "2",
                placeId: "place_2",
                nameEn: "Al Noor Dental Clinic",
                nameAr: "عيادة النور للأسنان",
                type: .dentalClinic,
                address: "Prince Sultan Road, Sahafa",
                district: "Sahafa",
                city: "Riyadh",
                latitude: 24.7719,
                longitude: 46.6425,
                phone: "+966 11 234 5678",
                website: nil,
                email: nil,
                rating: 4.2,
                reviewCount: 89,
                isOpen: true,
                openingHours: nil,
                services: ["General Dentistry", "Orthodontics"],
                insuranceAccepted: ["Medgulf"],
                languages: ["Arabic"],
                hasEmergency: false,
                is24Hours: false,
                hasOnlineBooking: false,
                hasWhatsApp: true,
                digitalScore: 35,
                maturityLevel: "brochure"
            )
        ]
    }
}
