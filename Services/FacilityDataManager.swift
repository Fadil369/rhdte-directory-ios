// BrainSAIT RHDTE - Facility Data Manager
// Loads and manages healthcare facility data from GeoJSON

import Foundation
import Combine
import CoreLocation

class FacilityDataManager: ObservableObject {
    @Published var facilities: [HealthFacility] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var sourceStats: [String: Int] = [:]
    
    /// Expected minimum facility count; used to flag an incomplete bundle copy early.
    private let expectedMinimumFacilities = 2900
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadLocalData()
    }
    
    /// Loads the bundled GeoJSON file on a background queue and publishes the parsed facilities.
    func loadLocalData() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let facilities = try GeoJSONParser.loadFromBundle()
                
                DispatchQueue.main.async {
                    self?.facilities = facilities
                    self?.isLoading = false
                    self?.calculateSourceStats()
                    
                    if facilities.count < self?.expectedMinimumFacilities ?? 0 {
                        print("⚠️ Facility count (\(facilities.count)) is lower than expected (~2,951). Confirm the GeoJSON file is included in Copy Bundle Resources.")
                    }
                    print("✅ Loaded \(facilities.count) facilities")
                }
            } catch {
                DispatchQueue.main.async {
                    self?.error = error
                    self?.isLoading = false
                    print("❌ Error loading facilities: \(error)")
                }
            }
        }
    }
    
    private func calculateSourceStats() {
        sourceStats = Dictionary(grouping: facilities) { $0.source }
            .mapValues { $0.count }
    }
    
    // MARK: - Filtering
    
    func filterFacilities(
        by type: String? = nil,
        source: String? = nil,
        searchText: String = "",
        hasRating: Bool = false,
        hasContactInfo: Bool = false,
        minRating: Double? = nil
    ) -> [HealthFacility] {
        var filtered = facilities
        
        // Filter by type
        if let type = type {
            filtered = filtered.filter { facility in
                facility.amenity?.lowercased() == type.lowercased() ||
                facility.types?.contains { $0.lowercased().contains(type.lowercased()) } == true
            }
        }
        
        // Filter by source
        if let source = source {
            filtered = filtered.filter { $0.source == source }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { facility in
                facility.displayName.localizedCaseInsensitiveContains(searchText) ||
                facility.formattedAddress?.localizedCaseInsensitiveContains(searchText) == true ||
                facility.addressFull?.localizedCaseInsensitiveContains(searchText) == true ||
                facility.city?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // Filter by rating existence
        if hasRating {
            filtered = filtered.filter { $0.rating != nil }
        }
        
        // Filter by minimum rating
        if let minRating = minRating {
            filtered = filtered.filter { ($0.rating ?? 0) >= minRating }
        }
        
        // Filter by contact info
        if hasContactInfo {
            filtered = filtered.filter { $0.hasContactInfo }
        }
        
        return filtered
    }
    
    // MARK: - Sorting
    
    func sortFacilities(_ facilities: [HealthFacility], by sortOption: FacilitySortOption) -> [HealthFacility] {
        switch sortOption {
        case .name:
            return facilities.sorted { $0.displayName < $1.displayName }
        case .rating:
            return facilities.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
        case .reviewCount:
            return facilities.sorted { ($0.userRatingsTotal ?? 0) > ($1.userRatingsTotal ?? 0) }
        case .source:
            return facilities.sorted { $0.source < $1.source }
        }
    }
    
    // MARK: - Location-based
    
    func facilitiesNear(
        location: CLLocation,
        radiusKm: Double = 10.0,
        limit: Int = 50
    ) -> [HealthFacility] {
        var facilitiesWithDistance: [(facility: HealthFacility, distance: Double)] = []
        
        for facility in facilities {
            let facilityLocation = CLLocation(
                latitude: facility.latitude,
                longitude: facility.longitude
            )
            let distance = location.distance(from: facilityLocation) / 1000 // in km
            
            if distance <= radiusKm {
                facilitiesWithDistance.append((facility, distance))
            }
        }
        
        return facilitiesWithDistance
            .sorted { $0.distance < $1.distance }
            .prefix(limit)
            .map { $0.facility }
    }
    
    func distance(from location: CLLocation, to facility: HealthFacility) -> Double {
        let facilityLocation = CLLocation(
            latitude: facility.latitude,
            longitude: facility.longitude
        )
        return location.distance(from: facilityLocation) / 1000 // in km
    }
    
    // MARK: - Statistics
    
    func topRatedFacilities(limit: Int = 10) -> [HealthFacility] {
        facilities
            .filter { $0.rating != nil && $0.rating! > 0 }
            .sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
            .prefix(limit)
            .map { $0 }
    }
    
    func facilitiesByType() -> [String: Int] {
        Dictionary(grouping: facilities) { $0.facilityType }
            .mapValues { $0.count }
    }
    
    func facilitiesByCity() -> [String: Int] {
        Dictionary(grouping: facilities) { $0.city ?? $0.addressCity ?? "Unknown" }
            .mapValues { $0.count }
    }
    
    func facilitiesWithRatings() -> [HealthFacility] {
        facilities.filter { $0.rating != nil }
    }
    
    func averageRating() -> Double {
        let ratedFacilities = facilitiesWithRatings()
        guard !ratedFacilities.isEmpty else { return 0 }
        let total = ratedFacilities.reduce(0.0) { $0 + ($1.rating ?? 0) }
        return total / Double(ratedFacilities.count)
    }
}

// MARK: - Sort Options
enum FacilitySortOption: String, CaseIterable {
    case name = "Name"
    case rating = "Rating"
    case reviewCount = "Reviews"
    case source = "Source"
}

// MARK: - GeoJSON Parser
class GeoJSONParser {
    static let bundledFilename = "saudi_providers_unified"
    
    static func parseFacilities(from data: Data) throws -> [HealthFacility] {
        let decoder = JSONDecoder()
        let featureCollection = try decoder.decode(GeoJSONFeatureCollection.self, from: data)
        return featureCollection.features.map { $0.properties }
    }
    
    /// Loads the unified Saudi providers GeoJSON from the main bundle.
    /// Ensure `saudi_providers_unified.geojson` is listed under Copy Bundle Resources in Xcode.
    static func loadFromBundle(filename: String = bundledFilename) throws -> [HealthFacility] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "geojson") else {
            throw DataError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        return try parseFacilities(from: data)
    }
}

// MARK: - Data Errors
enum DataError: LocalizedError {
    case fileNotFound
    case parseFailed
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Data file not found in app bundle"
        case .parseFailed:
            return "Failed to parse facility data"
        }
    }
}
