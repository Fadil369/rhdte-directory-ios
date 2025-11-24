// BrainSAIT RHDTE - Healthcare Facility Model
// Data models for facilities, subscriptions, and user profiles

import Foundation
import CoreLocation

// MARK: - Facility Type
enum FacilityType: String, Codable, CaseIterable {
    case hospital = "Hospital"
    case clinic = "Clinic"
    case dentalClinic = "Dental Clinic"
    case pharmacy = "Pharmacy"
    case laboratory = "Laboratory"
    case radiology = "Radiology"
    case physiotherapy = "Physiotherapy"
    case opticalCenter = "Optical Center"
    case polyclinic = "Polyclinic"
    case medicalCenter = "Medical Center"
    
    var arabicName: String {
        switch self {
        case .hospital: return "مستشفى"
        case .clinic: return "عيادة"
        case .dentalClinic: return "عيادة أسنان"
        case .pharmacy: return "صيدلية"
        case .laboratory: return "مختبر"
        case .radiology: return "أشعة"
        case .physiotherapy: return "علاج طبيعي"
        case .opticalCenter: return "بصريات"
        case .polyclinic: return "مجمع عيادات"
        case .medicalCenter: return "مركز طبي"
        }
    }
    
    var icon: String {
        switch self {
        case .hospital: return "cross.circle.fill"
        case .clinic: return "stethoscope"
        case .dentalClinic: return "mouth.fill"
        case .pharmacy: return "pills.fill"
        case .laboratory: return "testtube.2"
        case .radiology: return "waveform.path.ecg"
        case .physiotherapy: return "figure.walk"
        case .opticalCenter: return "eyeglasses"
        case .polyclinic: return "building.2.fill"
        case .medicalCenter: return "cross.case.fill"
        }
    }
}

// MARK: - Facility Model
struct Facility: Identifiable, Codable {
    let id: String
    let placeId: String
    let nameEn: String
    let nameAr: String
    let type: FacilityType
    let address: String
    let district: String
    let city: String
    let latitude: Double
    let longitude: Double
    let phone: String?
    let website: String?
    let email: String?
    let rating: Double?
    let reviewCount: Int
    let isOpen: Bool?
    let openingHours: [String]?
    let services: [String]
    let insuranceAccepted: [String]
    let languages: [String]
    let hasEmergency: Bool
    let is24Hours: Bool
    let hasOnlineBooking: Bool
    let hasWhatsApp: Bool
    let digitalScore: Int?
    let maturityLevel: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var displayName: String {
        Locale.current.language.languageCode?.identifier == "ar" ? nameAr : nameEn
    }
    
    var ratingStars: String {
        guard let rating = rating else { return "N/A" }
        return String(format: "%.1f ⭐️", rating)
    }
}

// MARK: - User Subscription
enum SubscriptionTier: String, Codable {
    case free = "Free"
    case basic = "Basic"
    case premium = "Premium"
    case enterprise = "Enterprise"
    
    var monthlyPrice: Double {
        switch self {
        case .free: return 0
        case .basic: return 49
        case .premium: return 149
        case .enterprise: return 499
        }
    }
    
    var features: [String] {
        switch self {
        case .free:
            return ["View facilities", "Basic search", "5 saves per month"]
        case .basic:
            return ["All Free features", "Unlimited saves", "Contact info", "Ratings & reviews"]
        case .premium:
            return ["All Basic features", "Digital score insights", "Direct booking", "Priority support"]
        case .enterprise:
            return ["All Premium features", "API access", "Custom reports", "Dedicated manager"]
        }
    }
}

// MARK: - User Profile
struct UserProfile: Codable {
    let id: String
    let email: String
    let nameEn: String?
    let nameAr: String?
    let phone: String?
    let subscriptionTier: SubscriptionTier
    let subscriptionStartDate: Date?
    let savedFacilities: [String]
    let searchHistory: [String]
    let isVerified: Bool
}

// MARK: - Lead Magnet
struct LeadMagnetSubmission: Codable {
    let email: String
    let name: String?
    let phone: String?
    let facilityType: FacilityType?
    let district: String?
    let source: String
    let consentMarketing: Bool
    let timestamp: Date
}

// MARK: - Facility Analytics
struct FacilityAnalytics: Codable {
    let facilityId: String
    let viewCount: Int
    let saveCount: Int
    let contactClicks: Int
    let bookingClicks: Int
    let periodDays: Int
}

// MARK: - Dashboard Stats
struct DashboardStats: Codable {
    let totalFacilities: Int
    let totalDistricts: Int
    let avgRating: Double
    let facilityTypeBreakdown: [String: Int]
    let topDistricts: [String]
}
