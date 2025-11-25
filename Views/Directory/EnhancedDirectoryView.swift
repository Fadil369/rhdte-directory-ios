// Brainsait Maplinc - Enhanced Directory View
// Comprehensive healthcare facilities directory with search and filtering

import SwiftUI

struct EnhancedDirectoryView: View {
    @EnvironmentObject var dataService: RiyadhHealthcareDataService
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedCategory: HealthcareCategory?
    @State private var selectedDistrict: RiyadhDistrict?
    @State private var sortOption: SortOption = .rating
    @State private var showFilters = false
    @State private var selectedFacility: EnhancedFacility?

    enum SortOption: String, CaseIterable {
        case name = "Name"
        case rating = "Rating"
        case reviews = "Reviews"
        case category = "Category"
    }

    var filteredAndSortedFacilities: [EnhancedFacility] {
        var results = dataService.filterFacilities(
            category: selectedCategory,
            district: selectedDistrict,
            searchQuery: searchText.isEmpty ? nil : searchText
        )

        switch sortOption {
        case .name:
            results.sort { $0.nameEn < $1.nameEn }
        case .rating:
            results.sort { ($0.rating ?? 0) > ($1.rating ?? 0) }
        case .reviews:
            results.sort { $0.reviewCount > $1.reviewCount }
        case .category:
            results.sort { $0.category.rawValue < $1.category.rawValue }
        }

        return results
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Header
                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)

                        TextField("Search facilities, specialties...", text: $searchText)
                            .textFieldStyle(.plain)

                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // Quick Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            // Sort Menu
                            Menu {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Button {
                                        sortOption = option
                                    } label: {
                                        HStack {
                                            Text(option.rawValue)
                                            if sortOption == option {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.up.arrow.down")
                                    Text(sortOption.rawValue)
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }

                            // Category Filter
                            Menu {
                                Button {
                                    selectedCategory = nil
                                } label: {
                                    HStack {
                                        Text("All Categories")
                                        if selectedCategory == nil {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }

                                ForEach(HealthcareCategory.allCases, id: \.self) { category in
                                    Button {
                                        selectedCategory = category
                                    } label: {
                                        HStack {
                                            Label(category.rawValue, systemImage: category.icon)
                                            if selectedCategory == category {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                    Text(selectedCategory?.rawValue ?? "Category")
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedCategory != nil ? Color("BrainSAITGreen").opacity(0.2) : Color(.systemGray6))
                                .foregroundColor(selectedCategory != nil ? Color("BrainSAITGreen") : .primary)
                                .cornerRadius(8)
                            }

                            // District Filter
                            Menu {
                                Button {
                                    selectedDistrict = nil
                                } label: {
                                    HStack {
                                        Text("All Districts")
                                        if selectedDistrict == nil {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }

                                ForEach(RiyadhDistrict.allCases, id: \.self) { district in
                                    Button {
                                        selectedDistrict = district
                                    } label: {
                                        HStack {
                                            Text("\(district.rawValue) (\(district.arabicName))")
                                            if selectedDistrict == district {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "mappin.circle")
                                    Text(selectedDistrict?.rawValue ?? "District")
                                }
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedDistrict != nil ? Color("BrainSAITGreen").opacity(0.2) : Color(.systemGray6))
                                .foregroundColor(selectedDistrict != nil ? Color("BrainSAITGreen") : .primary)
                                .cornerRadius(8)
                            }
                        }
                    }

                    // Results Count
                    HStack {
                        Text("\(filteredAndSortedFacilities.count) facilities")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        if selectedCategory != nil || selectedDistrict != nil {
                            Button("Clear filters") {
                                selectedCategory = nil
                                selectedDistrict = nil
                            }
                            .font(.caption)
                            .foregroundColor(Color("BrainSAITGreen"))
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))

                // Facilities List
                if filteredAndSortedFacilities.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()

                        Image(systemName: "building.2")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)

                        Text("No facilities found")
                            .font(.headline)

                        Text("Try adjusting your search or filters")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()
                    }
                } else {
                    List(filteredAndSortedFacilities) { facility in
                        FacilityListRow(facility: facility)
                            .onTapGesture {
                                selectedFacility = facility
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Directory")
            .sheet(item: $selectedFacility) { facility in
                EnhancedFacilityDetailSheet(facility: facility)
            }
        }
    }
}

// MARK: - Facility List Row

struct FacilityListRow: View {
    let facility: EnhancedFacility
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: facility.category.icon)
                    .font(.title3)
                    .foregroundColor(categoryColor)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(facility.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(facility.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(facility.district.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Rating and Features
                HStack(spacing: 8) {
                    if let rating = facility.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }

                    if facility.is24Hours {
                        Label("24/7", systemImage: "clock")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }

                    if facility.hasEmergency {
                        Label("ER", systemImage: "cross.circle")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }

                    if facility.hasOnlineBooking {
                        Image(systemName: "calendar.badge.clock")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
            }

            Spacer()

            // Save Button
            Button {
                if appState.savedFacilities.contains(facility.id) {
                    appState.removeFacility(facility.id)
                } else {
                    appState.saveFacility(facility.id)
                }
            } label: {
                Image(systemName: appState.savedFacilities.contains(facility.id) ? "heart.fill" : "heart")
                    .foregroundColor(appState.savedFacilities.contains(facility.id) ? .red : .gray)
            }
            .buttonStyle(.plain)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var categoryColor: Color {
        switch facility.category {
        case .tertiary: return .red
        case .secondary: return .orange
        case .primary: return .blue
        case .specialty: return .purple
        case .dental: return .cyan
        case .pharmacy: return .green
        case .laboratory: return .indigo
        case .imaging: return .teal
        case .rehabilitation: return .mint
        case .homecare: return .pink
        }
    }
}
