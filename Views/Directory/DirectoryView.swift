// BrainSAIT RHDTE - Directory View
// List view of all healthcare facilities with search and filters

import SwiftUI

struct DirectoryView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = DirectoryViewModel()
    @State private var searchText = ""
    @State private var selectedType: FacilityType?
    @State private var sortOption: SortOption = .rating
    
    enum SortOption: String, CaseIterable {
        case rating = "Rating"
        case name = "Name"
        case distance = "Distance"
        case reviews = "Reviews"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search & Sort
                VStack(spacing: 12) {
                    // Search
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
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Filters & Sort
                    HStack {
                        // Type Picker
                        Menu {
                            Button("All Types") {
                                selectedType = nil
                            }
                            ForEach(FacilityType.allCases, id: \.self) { type in
                                Button(type.rawValue) {
                                    selectedType = type
                                }
                            }
                        } label: {
                            Label(selectedType?.rawValue ?? "All Types", systemImage: "line.3.horizontal.decrease.circle")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        // Sort Picker
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(option.rawValue) {
                                    sortOption = option
                                }
                            }
                        } label: {
                            Label(sortOption.rawValue, systemImage: "arrow.up.arrow.down")
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                
                // Results Count
                HStack {
                    Text("\(filteredFacilities.count) facilities")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                
                // Facilities List
                List {
                    ForEach(filteredFacilities) { facility in
                        FacilityListRow(facility: facility)
                            .onTapGesture {
                                appState.selectedFacility = facility
                            }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Directory")
        }
        .onAppear {
            viewModel.loadFacilities()
        }
    }
    
    private var filteredFacilities: [Facility] {
        var result = viewModel.facilities
        
        // Filter by search
        if !searchText.isEmpty {
            result = result.filter {
                $0.nameEn.localizedCaseInsensitiveContains(searchText) ||
                $0.nameAr.contains(searchText) ||
                $0.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by type
        if let type = selectedType {
            result = result.filter { $0.type == type }
        }
        
        // Sort
        switch sortOption {
        case .rating:
            result.sort { ($0.rating ?? 0) > ($1.rating ?? 0) }
        case .name:
            result.sort { $0.nameEn < $1.nameEn }
        case .distance:
            // TODO: Sort by distance from user
            break
        case .reviews:
            result.sort { $0.reviewCount > $1.reviewCount }
        }
        
        return result
    }
}

// MARK: - Facility List Row
struct FacilityListRow: View {
    let facility: Facility
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: facility.type.icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(iconColor)
                .cornerRadius(10)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(facility.displayName)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(facility.district)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    if let rating = facility.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                        }
                    }
                    
                    if facility.is24Hours {
                        Text("24h")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                    
                    if facility.hasOnlineBooking {
                        Image(systemName: "calendar.badge.plus")
                            .font(.caption2)
                            .foregroundColor(Color("BrainSAITGreen"))
                    }
                }
            }
            
            Spacer()
            
            // Save button
            Button(action: toggleSave) {
                Image(systemName: isSaved ? "heart.fill" : "heart")
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
    
    private var iconColor: Color {
        switch facility.type {
        case .hospital: return .red
        case .pharmacy: return .green
        case .dentalClinic: return .blue
        case .laboratory: return .purple
        default: return Color("BrainSAITGreen")
        }
    }
}

// MARK: - Saved Facilities View
struct SavedFacilitiesView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = DirectoryViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if savedFacilities.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Saved Facilities")
                            .font(.headline)
                        
                        Text("Tap the heart icon on any facility to save it here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(savedFacilities) { facility in
                            FacilityListRow(facility: facility)
                                .onTapGesture {
                                    appState.selectedFacility = facility
                                }
                        }
                        .onDelete(perform: deleteFacility)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Saved")
        }
        .onAppear {
            viewModel.loadFacilities()
        }
    }
    
    private var savedFacilities: [Facility] {
        viewModel.facilities.filter { appState.savedFacilities.contains($0.id) }
    }
    
    private func deleteFacility(at offsets: IndexSet) {
        for index in offsets {
            let facility = savedFacilities[index]
            appState.removeFacility(facility.id)
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if appState.isAuthenticated {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(Color("BrainSAITGreen"))
                            
                            VStack(alignment: .leading) {
                                Text(appState.currentUser?.nameEn ?? "User")
                                    .font(.headline)
                                Text(appState.currentUser?.email ?? "")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        Button(action: { appState.showLeadMagnet = true }) {
                            Label("Sign Up / Sign In", systemImage: "person.badge.plus")
                        }
                    }
                }
                
                Section("Subscription") {
                    HStack {
                        Text("Plan")
                        Spacer()
                        Text(appState.currentUser?.subscriptionTier.rawValue ?? "Free")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Upgrade to Premium") {
                        appState.showLeadMagnet = true
                    }
                }
                
                Section("Settings") {
                    NavigationLink("Notifications") {
                        Text("Notification Settings")
                    }
                    
                    NavigationLink("Language") {
                        Text("Language Settings")
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://brainsait.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://brainsait.com/terms")!)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Directory View Model
class DirectoryViewModel: ObservableObject {
    @Published var facilities: [Facility] = []
    @Published var isLoading = false
    
    func loadFacilities() {
        isLoading = true
        
        Task {
            do {
                let facilities = try await APIService.shared.fetchFacilities()
                DispatchQueue.main.async {
                    self.facilities = facilities
                    self.isLoading = false
                }
            } catch {
                // Load sample data
                DispatchQueue.main.async {
                    self.facilities = self.sampleData()
                    self.isLoading = false
                }
            }
        }
    }
    
    private func sampleData() -> [Facility] {
        // Same sample data as MapViewModel
        []
    }
}
