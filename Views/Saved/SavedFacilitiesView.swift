// BrainSAIT RHDTE - Saved Facilities View
// Shows user's saved/bookmarked facilities

import SwiftUI

struct SavedFacilitiesView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var facilityDataManager: FacilityDataManager
    @State private var searchText = ""
    
    var savedFacilities: [HealthFacility] {
        facilityDataManager.facilities.filter { facility in
            appState.savedFacilities.contains(facility.id)
        }
    }
    
    var filteredFacilities: [HealthFacility] {
        if searchText.isEmpty {
            return savedFacilities
        }
        return savedFacilities.filter { facility in
            facility.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if savedFacilities.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(filteredFacilities) { facility in
                            FacilityRow(facility: facility)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        appState.removeFacility(facility.id)
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search saved facilities")
                }
            }
            .navigationTitle("Saved Facilities")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !savedFacilities.isEmpty {
                        Text("\(savedFacilities.count) saved")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Saved Facilities")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Tap the heart icon on any facility to save it for quick access")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

struct FacilityRow: View {
    let facility: HealthFacility
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: facility.icon)
                    .foregroundColor(.blue)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(facility.displayName)
                        .font(.headline)
                    
                    Text(facility.facilityType)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let rating = facility.rating {
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        
                        if let reviews = facility.userRatingsTotal {
                            Text("\(reviews) reviews")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            if !facility.displayAddress.isEmpty {
                Text(facility.displayAddress)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Label(facility.sourceDisplayName, systemImage: "building.2")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if facility.hasContactInfo {
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
        .padding(.vertical, 4)
    }
}
