// BrainSAIT RHDTE - Enhanced Health Facility Model
// Supports HDX, OSM, and Google Places data sources

import Foundation
import CoreLocation

// MARK: - Health Facility (Real Data Model)
struct HealthFacility: Codable, Identifiable {
    var id: String {
        osmId ?? placeId ?? UUID().uuidString
    }
    
    // Common fields
    let name: String?
    let nameEn: String?
    let nameAr: String?
    let latitude: Double
    let longitude: Double
    let source: String
    
    // HDX/OSM specific
    let osmId: String?
    let amenity: String?
    let healthcare: String?
    let healthcareSpecialty: String?
    let operatorType: String?
    let capacityPersons: Int?
    let addressFull: String?
    let addressCity: String?
    
    // Google Places specific
    let placeId: String?
    let formattedAddress: String?
    let types: [String]?
    let businessStatus: String?
    let rating: Double?
    let userRatingsTotal: Int?
    let phone: String?
    let website: String?
    let openingHours: OpeningHours?
    let vicinity: String?
    let city: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var displayName: String {
        nameEn ?? name ?? nameAr ?? "Unknown Facility"
    }
    
    var facilityType: String {
        if let amenity = amenity {
            return amenity.capitalized
        }
        if let types = types, !types.isEmpty {
            let type = types.first ?? "health"
            return type.replacingOccurrences(of: "_", with: " ").capitalized
        }
        return "Health Facility"
    }
    
    var icon: String {
        let type = amenity ?? types?.first ?? ""
        switch type.lowercased() {
        case "hospital":
            return "cross.case.fill"
        case "clinic":
            return "stethoscope"
        case "pharmacy":
            return "pills.fill"
        case "doctors":
            return "stethoscope"
        case "dentist", "dental":
            return "mouth.fill"
        default:
            return "cross.fill"
        }
    }
    
    var displayAddress: String {
        formattedAddress ?? addressFull ?? vicinity ?? city ?? "No address available"
    }
    
    var isOperational: Bool {
        if let status = businessStatus {
            return status.lowercased() == "operational"
        }
        return true
    }
    
    var hasContactInfo: Bool {
        phone != nil || website != nil
    }
    
    var sourceDisplayName: String {
        switch source {
        case "google_places":
            return "Google Places"
        case "hdx":
            return "HDX (Humanitarian Data)"
        case "overpass":
            return "OpenStreetMap"
        default:
            return source.capitalized
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name, latitude, longitude, source
        case nameEn = "name_en"
        case nameAr = "name_ar"
        case osmId = "osm_id"
        case amenity, healthcare
        case healthcareSpecialty = "healthcare_specialty"
        case operatorType = "operator_type"
        case capacityPersons = "capacity_persons"
        case addressFull = "address_full"
        case addressCity = "address_city"
        case placeId = "place_id"
        case formattedAddress = "formatted_address"
        case types
        case businessStatus = "business_status"
        case rating
        case userRatingsTotal = "user_ratings_total"
        case phone, website
        case openingHours = "opening_hours"
        case vicinity, city
    }
}

struct OpeningHours: Codable {
    let openNow: Bool?
    let weekdayText: [String]?
    
    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
        case weekdayText = "weekday_text"
    }
}

// MARK: - GeoJSON Models
struct GeoJSONFeatureCollection: Codable {
    let type: String
    let features: [GeoJSONFeature]
}

struct GeoJSONFeature: Codable {
    let type: String
    let geometry: GeoJSONGeometry
    let properties: HealthFacility
}

struct GeoJSONGeometry: Codable {
    let type: String
    let coordinates: [Double]
}
