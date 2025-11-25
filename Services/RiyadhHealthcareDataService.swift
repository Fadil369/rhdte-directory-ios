// Brainsait Maplinc - Riyadh Healthcare Data Service
// Service for extracting and managing healthcare facility data from Riyadh, Saudi Arabia

import Foundation
import CoreLocation
import Combine

// MARK: - Healthcare Category
enum HealthcareCategory: String, Codable, CaseIterable {
    case tertiary = "Tertiary Hospital"
    case secondary = "Secondary Hospital"
    case primary = "Primary Care"
    case specialty = "Specialty Center"
    case dental = "Dental"
    case pharmacy = "Pharmacy"
    case laboratory = "Laboratory"
    case imaging = "Imaging Center"
    case rehabilitation = "Rehabilitation"
    case homecare = "Home Healthcare"

    var arabicName: String {
        switch self {
        case .tertiary: return "مستشفى تخصصي"
        case .secondary: return "مستشفى عام"
        case .primary: return "رعاية أولية"
        case .specialty: return "مركز تخصصي"
        case .dental: return "طب أسنان"
        case .pharmacy: return "صيدلية"
        case .laboratory: return "مختبر"
        case .imaging: return "تصوير طبي"
        case .rehabilitation: return "تأهيل"
        case .homecare: return "رعاية منزلية"
        }
    }

    var icon: String {
        switch self {
        case .tertiary: return "building.2.crop.circle.fill"
        case .secondary: return "cross.circle.fill"
        case .primary: return "stethoscope"
        case .specialty: return "heart.text.square.fill"
        case .dental: return "mouth.fill"
        case .pharmacy: return "pills.fill"
        case .laboratory: return "testtube.2"
        case .imaging: return "waveform.path.ecg.rectangle"
        case .rehabilitation: return "figure.walk"
        case .homecare: return "house.fill"
        }
    }

    var color: String {
        switch self {
        case .tertiary: return "TertiaryHospital"
        case .secondary: return "SecondaryHospital"
        case .primary: return "PrimaryCare"
        case .specialty: return "SpecialtyCenter"
        case .dental: return "DentalCare"
        case .pharmacy: return "PharmacyGreen"
        case .laboratory: return "LabPurple"
        case .imaging: return "ImagingBlue"
        case .rehabilitation: return "RehabOrange"
        case .homecare: return "HomecareRed"
        }
    }
}

// MARK: - Riyadh District
enum RiyadhDistrict: String, Codable, CaseIterable {
    case alOlaya = "Al Olaya"
    case alMalaz = "Al Malaz"
    case alSulimaniyah = "Al Sulimaniyah"
    case alMuruj = "Al Muruj"
    case alRabwah = "Al Rabwah"
    case alNakheel = "Al Nakheel"
    case alYasmin = "Al Yasmin"
    case alNarjis = "Al Narjis"
    case hittin = "Hittin"
    case alSahafah = "Al Sahafah"
    case alAqiq = "Al Aqiq"
    case alGhadir = "Al Ghadir"
    case alShifa = "Al Shifa"
    case alAziziyah = "Al Aziziyah"
    case alBatha = "Al Batha"

    var arabicName: String {
        switch self {
        case .alOlaya: return "العليا"
        case .alMalaz: return "الملز"
        case .alSulimaniyah: return "السليمانية"
        case .alMuruj: return "المروج"
        case .alRabwah: return "الربوة"
        case .alNakheel: return "النخيل"
        case .alYasmin: return "الياسمين"
        case .alNarjis: return "النرجس"
        case .hittin: return "حطين"
        case .alSahafah: return "الصحافة"
        case .alAqiq: return "العقيق"
        case .alGhadir: return "الغدير"
        case .alShifa: return "الشفاء"
        case .alAziziyah: return "العزيزية"
        case .alBatha: return "البطحاء"
        }
    }

    var coordinates: CLLocationCoordinate2D {
        switch self {
        case .alOlaya: return CLLocationCoordinate2D(latitude: 24.6877, longitude: 46.6856)
        case .alMalaz: return CLLocationCoordinate2D(latitude: 24.6602, longitude: 46.7265)
        case .alSulimaniyah: return CLLocationCoordinate2D(latitude: 24.6937, longitude: 46.7107)
        case .alMuruj: return CLLocationCoordinate2D(latitude: 24.7538, longitude: 46.6476)
        case .alRabwah: return CLLocationCoordinate2D(latitude: 24.7235, longitude: 46.6823)
        case .alNakheel: return CLLocationCoordinate2D(latitude: 24.7765, longitude: 46.6234)
        case .alYasmin: return CLLocationCoordinate2D(latitude: 24.8234, longitude: 46.6123)
        case .alNarjis: return CLLocationCoordinate2D(latitude: 24.8456, longitude: 46.6456)
        case .hittin: return CLLocationCoordinate2D(latitude: 24.7654, longitude: 46.6345)
        case .alSahafah: return CLLocationCoordinate2D(latitude: 24.8012, longitude: 46.6234)
        case .alAqiq: return CLLocationCoordinate2D(latitude: 24.7876, longitude: 46.6098)
        case .alGhadir: return CLLocationCoordinate2D(latitude: 24.8123, longitude: 46.6987)
        case .alShifa: return CLLocationCoordinate2D(latitude: 24.6123, longitude: 46.7456)
        case .alAziziyah: return CLLocationCoordinate2D(latitude: 24.6345, longitude: 46.7234)
        case .alBatha: return CLLocationCoordinate2D(latitude: 24.6456, longitude: 46.7123)
        }
    }
}

// MARK: - Enhanced Facility Model
struct EnhancedFacility: Identifiable, Codable {
    let id: String
    let placeId: String
    let nameEn: String
    let nameAr: String
    let type: FacilityType
    let category: HealthcareCategory
    let address: String
    let district: RiyadhDistrict
    let city: String
    let latitude: Double
    let longitude: Double

    // Contact Information
    let phone: String?
    let alternatePhone: String?
    let website: String?
    let email: String?
    let whatsapp: String?
    let socialMedia: SocialMediaLinks?

    // Images and Media
    let images: [FacilityImage]
    let logoUrl: String?
    let virtualTourUrl: String?

    // Ratings and Reviews
    let rating: Double?
    let reviewCount: Int
    let googleRating: Double?
    let healthcareRating: Double?

    // Operating Hours
    let isOpen: Bool?
    let openingHours: [DayHours]
    let is24Hours: Bool
    let hasEmergency: Bool

    // Services and Features
    let services: [String]
    let specialties: [String]
    let departments: [String]
    let insuranceAccepted: [String]
    let languages: [String]
    let amenities: [String]

    // Digital Features
    let hasOnlineBooking: Bool
    let hasWhatsApp: Bool
    let hasMobileApp: Bool
    let hasTelemedicine: Bool
    let digitalScore: Int?
    let maturityLevel: String?

    // Facility Details
    let bedCount: Int?
    let establishedYear: Int?
    let licenseNumber: String?
    let accreditations: [String]

    // Dashboard & Analytics
    var dashboardEnabled: Bool
    var paidServices: [PaidService]
    var analytics: FacilityAnalyticsData?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var displayName: String {
        Locale.current.language.languageCode?.identifier == "ar" ? nameAr : nameEn
    }

    var ratingStars: String {
        guard let rating = rating else { return "N/A" }
        return String(format: "%.1f", rating)
    }
}

// MARK: - Supporting Models

struct SocialMediaLinks: Codable {
    let twitter: String?
    let instagram: String?
    let facebook: String?
    let linkedin: String?
    let youtube: String?
    let snapchat: String?
    let tiktok: String?
}

struct FacilityImage: Codable, Identifiable {
    let id: String
    let url: String
    let caption: String?
    let type: ImageType
    let isPrimary: Bool

    enum ImageType: String, Codable {
        case exterior = "Exterior"
        case interior = "Interior"
        case reception = "Reception"
        case room = "Room"
        case equipment = "Equipment"
        case staff = "Staff"
        case logo = "Logo"
    }
}

struct DayHours: Codable {
    let day: String
    let dayAr: String
    let openTime: String
    let closeTime: String
    let isClosed: Bool
}

struct PaidService: Identifiable, Codable {
    let id: String
    let nameEn: String
    let nameAr: String
    let description: String
    let monthlyPrice: Double
    let isEnabled: Bool
    let features: [String]
    let category: ServiceCategory

    enum ServiceCategory: String, Codable {
        case visibility = "Visibility"
        case booking = "Booking"
        case analytics = "Analytics"
        case marketing = "Marketing"
        case premium = "Premium"
    }
}

struct FacilityAnalyticsData: Codable {
    let viewCount: Int
    let saveCount: Int
    let contactClicks: Int
    let bookingClicks: Int
    let directionClicks: Int
    let shareCount: Int
    let searchAppearances: Int
    let periodDays: Int
    let lastUpdated: Date
}

// MARK: - Riyadh Healthcare Data Service

class RiyadhHealthcareDataService: ObservableObject {
    @Published var facilities: [EnhancedFacility] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var lastUpdated: Date?

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadSampleRiyadhData()
    }

    // MARK: - Data Loading

    func loadSampleRiyadhData() {
        isLoading = true

        // Generate comprehensive Riyadh healthcare facility data
        facilities = generateRiyadhHealthcareFacilities()
        lastUpdated = Date()
        isLoading = false
    }

    // MARK: - Filtering

    func filterFacilities(
        category: HealthcareCategory? = nil,
        district: RiyadhDistrict? = nil,
        minRating: Double? = nil,
        is24Hours: Bool? = nil,
        hasEmergency: Bool? = nil,
        hasOnlineBooking: Bool? = nil,
        searchQuery: String? = nil
    ) -> [EnhancedFacility] {
        var filtered = facilities

        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }

        if let district = district {
            filtered = filtered.filter { $0.district == district }
        }

        if let minRating = minRating {
            filtered = filtered.filter { ($0.rating ?? 0) >= minRating }
        }

        if let is24Hours = is24Hours, is24Hours {
            filtered = filtered.filter { $0.is24Hours }
        }

        if let hasEmergency = hasEmergency, hasEmergency {
            filtered = filtered.filter { $0.hasEmergency }
        }

        if let hasOnlineBooking = hasOnlineBooking, hasOnlineBooking {
            filtered = filtered.filter { $0.hasOnlineBooking }
        }

        if let query = searchQuery, !query.isEmpty {
            filtered = filtered.filter {
                $0.nameEn.localizedCaseInsensitiveContains(query) ||
                $0.nameAr.contains(query) ||
                $0.services.contains { $0.localizedCaseInsensitiveContains(query) } ||
                $0.specialties.contains { $0.localizedCaseInsensitiveContains(query) }
            }
        }

        return filtered
    }

    // MARK: - Statistics

    func getStatistics() -> HealthcareStatistics {
        let totalFacilities = facilities.count
        let avgRating = facilities.compactMap { $0.rating }.reduce(0, +) / Double(max(1, facilities.count))

        var categoryBreakdown: [HealthcareCategory: Int] = [:]
        for category in HealthcareCategory.allCases {
            categoryBreakdown[category] = facilities.filter { $0.category == category }.count
        }

        var districtBreakdown: [RiyadhDistrict: Int] = [:]
        for district in RiyadhDistrict.allCases {
            districtBreakdown[district] = facilities.filter { $0.district == district }.count
        }

        return HealthcareStatistics(
            totalFacilities: totalFacilities,
            totalDistricts: RiyadhDistrict.allCases.count,
            averageRating: avgRating,
            categoryBreakdown: categoryBreakdown,
            districtBreakdown: districtBreakdown,
            facilitiesWith24Hours: facilities.filter { $0.is24Hours }.count,
            facilitiesWithEmergency: facilities.filter { $0.hasEmergency }.count,
            facilitiesWithOnlineBooking: facilities.filter { $0.hasOnlineBooking }.count,
            facilitiesWithTelemedicine: facilities.filter { $0.hasTelemedicine }.count
        )
    }

    // MARK: - Generate Sample Data

    private func generateRiyadhHealthcareFacilities() -> [EnhancedFacility] {
        var facilities: [EnhancedFacility] = []

        // Tertiary Hospitals
        facilities.append(contentsOf: [
            createFacility(
                id: "KF001",
                nameEn: "King Faisal Specialist Hospital & Research Centre",
                nameAr: "مستشفى الملك فيصل التخصصي ومركز الأبحاث",
                type: .hospital,
                category: .tertiary,
                district: .alMalaz,
                lat: 24.6890, lng: 46.6720,
                phone: "+966 11 464 7272",
                website: "https://www.kfshrc.edu.sa",
                email: "info@kfshrc.edu.sa",
                rating: 4.8,
                reviewCount: 3250,
                is24Hours: true,
                hasEmergency: true,
                hasOnlineBooking: true,
                bedCount: 894,
                establishedYear: 1975,
                specialties: ["Oncology", "Organ Transplant", "Cardiology", "Neurology", "Pediatrics"],
                accreditations: ["JCI", "CBAHI", "CAP", "ASHI"],
                services: ["Emergency", "ICU", "Surgery", "Radiology", "Laboratory", "Pharmacy", "Physical Therapy"]
            ),
            createFacility(
                id: "KSU001",
                nameEn: "King Saud University Medical City",
                nameAr: "المدينة الطبية بجامعة الملك سعود",
                type: .hospital,
                category: .tertiary,
                district: .alMalaz,
                lat: 24.7234, lng: 46.6234,
                phone: "+966 11 467 0000",
                website: "https://ksumc.med.sa",
                email: "info@ksumc.med.sa",
                rating: 4.6,
                reviewCount: 2890,
                is24Hours: true,
                hasEmergency: true,
                hasOnlineBooking: true,
                bedCount: 1200,
                establishedYear: 1956,
                specialties: ["Surgery", "Internal Medicine", "Pediatrics", "OB/GYN", "Orthopedics"],
                accreditations: ["JCI", "CBAHI"],
                services: ["Emergency", "ICU", "NICU", "Surgery", "Radiology", "Blood Bank"]
            ),
            createFacility(
                id: "SH001",
                nameEn: "King Salman Hospital",
                nameAr: "مستشفى الملك سلمان",
                type: .hospital,
                category: .tertiary,
                district: .alSahafah,
                lat: 24.8123, lng: 46.6456,
                phone: "+966 11 445 5555",
                website: "https://ksh.gov.sa",
                email: "info@ksh.gov.sa",
                rating: 4.5,
                reviewCount: 1856,
                is24Hours: true,
                hasEmergency: true,
                hasOnlineBooking: true,
                bedCount: 600,
                establishedYear: 2013,
                specialties: ["Emergency Medicine", "Surgery", "Internal Medicine", "Pediatrics"],
                accreditations: ["CBAHI", "JCI"],
                services: ["Emergency", "ICU", "Surgery", "Radiology", "Laboratory"]
            )
        ])

        // Secondary Hospitals
        facilities.append(contentsOf: [
            createFacility(
                id: "DAL001",
                nameEn: "Dallah Hospital - Al Nakheel",
                nameAr: "مستشفى دله - النخيل",
                type: .hospital,
                category: .secondary,
                district: .alNakheel,
                lat: 24.7765, lng: 46.6234,
                phone: "+966 11 454 0000",
                website: "https://www.dfrh.gov.sa",
                email: "info@dallah.com",
                rating: 4.4,
                reviewCount: 2100,
                is24Hours: true,
                hasEmergency: true,
                hasOnlineBooking: true,
                bedCount: 350,
                establishedYear: 1987,
                specialties: ["Cardiology", "Orthopedics", "General Surgery", "Internal Medicine"],
                accreditations: ["JCI", "CBAHI"],
                services: ["Emergency", "ICU", "Surgery", "Cardiac Cath Lab", "MRI", "CT Scan"]
            ),
            createFacility(
                id: "SMC001",
                nameEn: "Saudi German Hospital Riyadh",
                nameAr: "المستشفى السعودي الألماني الرياض",
                type: .hospital,
                category: .secondary,
                district: .alSulimaniyah,
                lat: 24.6937, lng: 46.7107,
                phone: "+966 920 007 997",
                website: "https://www.sghgroup.com",
                email: "riyadh@sghgroup.com",
                rating: 4.3,
                reviewCount: 1890,
                is24Hours: true,
                hasEmergency: true,
                hasOnlineBooking: true,
                bedCount: 400,
                establishedYear: 1999,
                specialties: ["Surgery", "Internal Medicine", "Orthopedics", "Cardiology", "Pediatrics"],
                accreditations: ["JCI", "CBAHI", "ISO"],
                services: ["Emergency", "ICU", "Surgery", "Radiology", "Laboratory", "Rehabilitation"]
            ),
            createFacility(
                id: "IMC001",
                nameEn: "International Medical Center",
                nameAr: "المركز الطبي الدولي",
                type: .hospital,
                category: .secondary,
                district: .alOlaya,
                lat: 24.6877, lng: 46.6856,
                phone: "+966 11 463 9999",
                website: "https://www.imc.med.sa",
                email: "info@imc.med.sa",
                rating: 4.5,
                reviewCount: 1650,
                is24Hours: true,
                hasEmergency: true,
                hasOnlineBooking: true,
                bedCount: 300,
                establishedYear: 2006,
                specialties: ["Internal Medicine", "Surgery", "Pediatrics", "Cardiology"],
                accreditations: ["JCI", "CBAHI"],
                services: ["Emergency", "ICU", "Surgery", "Radiology", "Laboratory"]
            )
        ])

        // Primary Care / Medical Centers
        facilities.append(contentsOf: [
            createFacility(
                id: "AMC001",
                nameEn: "Al Mousa Medical Center",
                nameAr: "مركز الموسى الطبي",
                type: .medicalCenter,
                category: .primary,
                district: .alOlaya,
                lat: 24.6912, lng: 46.6890,
                phone: "+966 11 462 7777",
                website: "https://www.almousamc.com",
                email: "info@almousamc.com",
                rating: 4.2,
                reviewCount: 980,
                is24Hours: false,
                hasEmergency: false,
                hasOnlineBooking: true,
                bedCount: nil,
                establishedYear: 1998,
                specialties: ["Family Medicine", "Internal Medicine", "Pediatrics", "Dermatology"],
                accreditations: ["CBAHI"],
                services: ["Consultation", "Laboratory", "Radiology", "Pharmacy", "Vaccination"]
            ),
            createFacility(
                id: "HMC001",
                nameEn: "Health First Medical Center",
                nameAr: "مركز هيلث فيرست الطبي",
                type: .medicalCenter,
                category: .primary,
                district: .alYasmin,
                lat: 24.8234, lng: 46.6123,
                phone: "+966 11 453 8888",
                website: "https://www.healthfirst.sa",
                email: "info@healthfirst.sa",
                rating: 4.3,
                reviewCount: 756,
                is24Hours: false,
                hasEmergency: false,
                hasOnlineBooking: true,
                bedCount: nil,
                establishedYear: 2015,
                specialties: ["Family Medicine", "Pediatrics", "Internal Medicine"],
                accreditations: ["CBAHI"],
                services: ["Consultation", "Laboratory", "Pharmacy", "Health Checkup"]
            )
        ])

        // Specialty Centers
        facilities.append(contentsOf: [
            createFacility(
                id: "MEC001",
                nameEn: "Maghrabi Eye Hospital",
                nameAr: "مستشفى المغربي للعيون",
                type: .clinic,
                category: .specialty,
                district: .alOlaya,
                lat: 24.6845, lng: 46.6912,
                phone: "+966 920 000 667",
                website: "https://www.magrabi.com.sa",
                email: "info@magrabi.com",
                rating: 4.6,
                reviewCount: 2340,
                is24Hours: false,
                hasEmergency: true,
                hasOnlineBooking: true,
                bedCount: 50,
                establishedYear: 1977,
                specialties: ["Ophthalmology", "LASIK", "Cataract Surgery", "Retina"],
                accreditations: ["JCI", "CBAHI"],
                services: ["Eye Examination", "Surgery", "Laser Treatment", "Optical Shop"]
            ),
            createFacility(
                id: "MHC001",
                nameEn: "Riyadh Care Heart Center",
                nameAr: "مركز رياض كير للقلب",
                type: .clinic,
                category: .specialty,
                district: .hittin,
                lat: 24.7654, lng: 46.6345,
                phone: "+966 11 456 7890",
                website: "https://www.riyadhcare.com",
                email: "info@riyadhcare.com",
                rating: 4.7,
                reviewCount: 1120,
                is24Hours: false,
                hasEmergency: true,
                hasOnlineBooking: true,
                bedCount: 80,
                establishedYear: 2010,
                specialties: ["Cardiology", "Cardiac Surgery", "Interventional Cardiology"],
                accreditations: ["JCI", "CBAHI"],
                services: ["Cardiac Consultation", "ECG", "Echo", "Stress Test", "Angioplasty"]
            )
        ])

        // Dental Clinics
        facilities.append(contentsOf: [
            createFacility(
                id: "ADC001",
                nameEn: "Advanced Dental Center",
                nameAr: "مركز الأسنان المتقدم",
                type: .dentalClinic,
                category: .dental,
                district: .alMuruj,
                lat: 24.7538, lng: 46.6476,
                phone: "+966 11 455 1234",
                website: "https://www.advanceddental.sa",
                email: "info@advanceddental.sa",
                rating: 4.5,
                reviewCount: 890,
                is24Hours: false,
                hasEmergency: false,
                hasOnlineBooking: true,
                bedCount: nil,
                establishedYear: 2012,
                specialties: ["Orthodontics", "Implants", "Cosmetic Dentistry", "Pediatric Dentistry"],
                accreditations: ["CBAHI"],
                services: ["Dental Cleaning", "Fillings", "Root Canal", "Crowns", "Veneers", "Whitening"]
            ),
            createFacility(
                id: "SDC001",
                nameEn: "Smile Design Dental Clinic",
                nameAr: "عيادة سمايل ديزاين لطب الأسنان",
                type: .dentalClinic,
                category: .dental,
                district: .alRabwah,
                lat: 24.7235, lng: 46.6823,
                phone: "+966 11 458 9999",
                website: "https://www.smiledesign.sa",
                email: "info@smiledesign.sa",
                rating: 4.4,
                reviewCount: 654,
                is24Hours: false,
                hasEmergency: false,
                hasOnlineBooking: true,
                bedCount: nil,
                establishedYear: 2018,
                specialties: ["Cosmetic Dentistry", "Orthodontics", "Implants"],
                accreditations: ["CBAHI"],
                services: ["Dental Consultation", "Invisalign", "Veneers", "Implants", "Teeth Whitening"]
            )
        ])

        // Pharmacies
        facilities.append(contentsOf: [
            createFacility(
                id: "NAH001",
                nameEn: "Al Nahdi Pharmacy - Al Olaya",
                nameAr: "صيدلية النهدي - العليا",
                type: .pharmacy,
                category: .pharmacy,
                district: .alOlaya,
                lat: 24.6901, lng: 46.6878,
                phone: "+966 920 005 885",
                website: "https://www.nahdionline.com",
                email: "info@nahdi.sa",
                rating: 4.3,
                reviewCount: 1234,
                is24Hours: true,
                hasEmergency: false,
                hasOnlineBooking: false,
                bedCount: nil,
                establishedYear: 1986,
                specialties: [],
                accreditations: ["SFDA"],
                services: ["Prescription Drugs", "OTC Medications", "Health Products", "Delivery"]
            ),
            createFacility(
                id: "DWA001",
                nameEn: "Al Dawaa Pharmacy - Al Yasmin",
                nameAr: "صيدلية الدواء - الياسمين",
                type: .pharmacy,
                category: .pharmacy,
                district: .alYasmin,
                lat: 24.8256, lng: 46.6145,
                phone: "+966 920 003 001",
                website: "https://www.al-dawaa.com",
                email: "info@al-dawaa.com",
                rating: 4.2,
                reviewCount: 987,
                is24Hours: true,
                hasEmergency: false,
                hasOnlineBooking: false,
                bedCount: nil,
                establishedYear: 1991,
                specialties: [],
                accreditations: ["SFDA"],
                services: ["Prescription Drugs", "OTC Medications", "Cosmetics", "Baby Products"]
            )
        ])

        // Laboratories
        facilities.append(contentsOf: [
            createFacility(
                id: "BIO001",
                nameEn: "Biolab Medical Laboratory",
                nameAr: "مختبر بيولاب الطبي",
                type: .laboratory,
                category: .laboratory,
                district: .alNarjis,
                lat: 24.8456, lng: 46.6456,
                phone: "+966 920 007 272",
                website: "https://www.biolab.com.sa",
                email: "info@biolab.com.sa",
                rating: 4.4,
                reviewCount: 765,
                is24Hours: false,
                hasEmergency: false,
                hasOnlineBooking: true,
                bedCount: nil,
                establishedYear: 2001,
                specialties: ["Clinical Pathology", "Microbiology", "Molecular Diagnostics"],
                accreditations: ["CAP", "CBAHI"],
                services: ["Blood Tests", "Urine Analysis", "Genetic Testing", "Home Collection"]
            ),
            createFacility(
                id: "ALB001",
                nameEn: "AlBorg Medical Laboratories",
                nameAr: "مختبرات البرج الطبية",
                type: .laboratory,
                category: .laboratory,
                district: .alGhadir,
                lat: 24.8123, lng: 46.6987,
                phone: "+966 920 002 030",
                website: "https://www.alborg.com.sa",
                email: "info@alborg.com.sa",
                rating: 4.5,
                reviewCount: 1456,
                is24Hours: false,
                hasEmergency: false,
                hasOnlineBooking: true,
                bedCount: nil,
                establishedYear: 1999,
                specialties: ["Clinical Chemistry", "Hematology", "Immunology", "Histopathology"],
                accreditations: ["CAP", "CBAHI", "ISO"],
                services: ["Blood Tests", "Hormone Tests", "Allergy Testing", "Mobile Collection"]
            )
        ])

        // Imaging Centers
        facilities.append(contentsOf: [
            createFacility(
                id: "RAD001",
                nameEn: "Riyadh Radiology Center",
                nameAr: "مركز الرياض للأشعة",
                type: .radiology,
                category: .imaging,
                district: .alAqiq,
                lat: 24.7876, lng: 46.6098,
                phone: "+966 11 459 1234",
                website: "https://www.riyadhradiology.com",
                email: "info@riyadhradiology.com",
                rating: 4.3,
                reviewCount: 543,
                is24Hours: false,
                hasEmergency: false,
                hasOnlineBooking: true,
                bedCount: nil,
                establishedYear: 2008,
                specialties: ["MRI", "CT Scan", "Ultrasound", "X-Ray", "Mammography"],
                accreditations: ["CBAHI", "ACR"],
                services: ["Diagnostic Imaging", "3D Mammography", "Cardiac CT", "PET Scan"]
            )
        ])

        // Rehabilitation Centers
        facilities.append(contentsOf: [
            createFacility(
                id: "RHB001",
                nameEn: "Riyadh Rehab & Physiotherapy",
                nameAr: "مركز الرياض للتأهيل والعلاج الطبيعي",
                type: .physiotherapy,
                category: .rehabilitation,
                district: .alShifa,
                lat: 24.6123, lng: 46.7456,
                phone: "+966 11 456 7777",
                website: "https://www.riyadhrehab.com",
                email: "info@riyadhrehab.com",
                rating: 4.4,
                reviewCount: 432,
                is24Hours: false,
                hasEmergency: false,
                hasOnlineBooking: true,
                bedCount: nil,
                establishedYear: 2014,
                specialties: ["Physical Therapy", "Occupational Therapy", "Sports Medicine"],
                accreditations: ["CBAHI"],
                services: ["Physiotherapy", "Rehabilitation", "Sports Injury", "Post-Surgery Rehab"]
            )
        ])

        // Home Healthcare
        facilities.append(contentsOf: [
            createFacility(
                id: "HHC001",
                nameEn: "HomeCare Plus",
                nameAr: "هوم كير بلس",
                type: .clinic,
                category: .homecare,
                district: .alAziziyah,
                lat: 24.6345, lng: 46.7234,
                phone: "+966 920 008 888",
                website: "https://www.homecareplus.sa",
                email: "info@homecareplus.sa",
                rating: 4.6,
                reviewCount: 321,
                is24Hours: true,
                hasEmergency: false,
                hasOnlineBooking: true,
                bedCount: nil,
                establishedYear: 2017,
                specialties: ["Home Nursing", "Elderly Care", "Post-Surgery Care"],
                accreditations: ["CBAHI"],
                services: ["Home Visits", "Nursing Care", "Lab Collection", "IV Therapy", "Wound Care"]
            )
        ])

        return facilities
    }

    // MARK: - Helper Methods

    private func createFacility(
        id: String,
        nameEn: String,
        nameAr: String,
        type: FacilityType,
        category: HealthcareCategory,
        district: RiyadhDistrict,
        lat: Double,
        lng: Double,
        phone: String?,
        website: String?,
        email: String?,
        rating: Double?,
        reviewCount: Int,
        is24Hours: Bool,
        hasEmergency: Bool,
        hasOnlineBooking: Bool,
        bedCount: Int?,
        establishedYear: Int?,
        specialties: [String],
        accreditations: [String],
        services: [String]
    ) -> EnhancedFacility {

        let paidServices = generatePaidServices(for: id)

        return EnhancedFacility(
            id: id,
            placeId: "gmaps_\(id)",
            nameEn: nameEn,
            nameAr: nameAr,
            type: type,
            category: category,
            address: "\(district.rawValue), Riyadh, Saudi Arabia",
            district: district,
            city: "Riyadh",
            latitude: lat,
            longitude: lng,
            phone: phone,
            alternatePhone: nil,
            website: website,
            email: email,
            whatsapp: phone?.replacingOccurrences(of: " ", with: ""),
            socialMedia: SocialMediaLinks(
                twitter: "https://twitter.com/\(id.lowercased())",
                instagram: "https://instagram.com/\(id.lowercased())",
                facebook: nil,
                linkedin: nil,
                youtube: nil,
                snapchat: nil,
                tiktok: nil
            ),
            images: generateImages(for: id, type: type),
            logoUrl: "https://cdn.brainsait.com/logos/\(id.lowercased()).png",
            virtualTourUrl: nil,
            rating: rating,
            reviewCount: reviewCount,
            googleRating: rating,
            healthcareRating: rating != nil ? rating! - 0.1 : nil,
            isOpen: true,
            openingHours: generateOpeningHours(is24Hours: is24Hours),
            is24Hours: is24Hours,
            hasEmergency: hasEmergency,
            services: services,
            specialties: specialties,
            departments: specialties,
            insuranceAccepted: ["Bupa", "Tawuniya", "Medgulf", "CCHI", "AXA", "Malath"],
            languages: ["Arabic", "English", "Urdu", "Tagalog"],
            amenities: ["Parking", "Wheelchair Access", "Cafe", "ATM", "Prayer Room"],
            hasOnlineBooking: hasOnlineBooking,
            hasWhatsApp: phone != nil,
            hasMobileApp: bedCount ?? 0 > 200,
            hasTelemedicine: hasOnlineBooking,
            digitalScore: Int.random(in: 60...95),
            maturityLevel: rating ?? 0 > 4.5 ? "Advanced" : "Intermediate",
            bedCount: bedCount,
            establishedYear: establishedYear,
            licenseNumber: "MOH-\(id)-2024",
            accreditations: accreditations,
            dashboardEnabled: true,
            paidServices: paidServices,
            analytics: FacilityAnalyticsData(
                viewCount: Int.random(in: 500...5000),
                saveCount: Int.random(in: 50...500),
                contactClicks: Int.random(in: 100...1000),
                bookingClicks: Int.random(in: 50...500),
                directionClicks: Int.random(in: 200...2000),
                shareCount: Int.random(in: 20...200),
                searchAppearances: Int.random(in: 1000...10000),
                periodDays: 30,
                lastUpdated: Date()
            )
        )
    }

    private func generateImages(for id: String, type: FacilityType) -> [FacilityImage] {
        return [
            FacilityImage(
                id: "\(id)_img_1",
                url: "https://cdn.brainsait.com/facilities/\(id.lowercased())/exterior.jpg",
                caption: "Main Building Exterior",
                type: .exterior,
                isPrimary: true
            ),
            FacilityImage(
                id: "\(id)_img_2",
                url: "https://cdn.brainsait.com/facilities/\(id.lowercased())/reception.jpg",
                caption: "Reception Area",
                type: .reception,
                isPrimary: false
            ),
            FacilityImage(
                id: "\(id)_img_3",
                url: "https://cdn.brainsait.com/facilities/\(id.lowercased())/interior.jpg",
                caption: "Interior View",
                type: .interior,
                isPrimary: false
            )
        ]
    }

    private func generateOpeningHours(is24Hours: Bool) -> [DayHours] {
        let days = [
            ("Sunday", "الأحد"),
            ("Monday", "الإثنين"),
            ("Tuesday", "الثلاثاء"),
            ("Wednesday", "الأربعاء"),
            ("Thursday", "الخميس"),
            ("Friday", "الجمعة"),
            ("Saturday", "السبت")
        ]

        return days.map { day in
            DayHours(
                day: day.0,
                dayAr: day.1,
                openTime: is24Hours ? "00:00" : "08:00",
                closeTime: is24Hours ? "24:00" : "22:00",
                isClosed: day.0 == "Friday" && !is24Hours
            )
        }
    }

    private func generatePaidServices(for facilityId: String) -> [PaidService] {
        return [
            PaidService(
                id: "\(facilityId)_boost",
                nameEn: "Profile Boost",
                nameAr: "تعزيز الملف",
                description: "Increase visibility in search results and map",
                monthlyPrice: 299,
                isEnabled: false,
                features: ["Priority listing", "Featured badge", "Top search results"],
                category: .visibility
            ),
            PaidService(
                id: "\(facilityId)_booking",
                nameEn: "Online Booking Integration",
                nameAr: "تكامل الحجز الإلكتروني",
                description: "Enable patients to book appointments directly",
                monthlyPrice: 499,
                isEnabled: false,
                features: ["Appointment calendar", "SMS reminders", "Patient management"],
                category: .booking
            ),
            PaidService(
                id: "\(facilityId)_analytics",
                nameEn: "Advanced Analytics",
                nameAr: "تحليلات متقدمة",
                description: "Detailed insights on patient engagement",
                monthlyPrice: 199,
                isEnabled: false,
                features: ["Visitor demographics", "Conversion tracking", "Competitor analysis"],
                category: .analytics
            ),
            PaidService(
                id: "\(facilityId)_marketing",
                nameEn: "Marketing Campaign",
                nameAr: "حملة تسويقية",
                description: "Targeted advertising to potential patients",
                monthlyPrice: 799,
                isEnabled: false,
                features: ["Social media ads", "Email campaigns", "Push notifications"],
                category: .marketing
            ),
            PaidService(
                id: "\(facilityId)_premium",
                nameEn: "Premium Listing",
                nameAr: "قائمة متميزة",
                description: "Complete premium package with all features",
                monthlyPrice: 1499,
                isEnabled: false,
                features: ["All services included", "Dedicated account manager", "Custom branding", "API access"],
                category: .premium
            )
        ]
    }
}

// MARK: - Statistics Model

struct HealthcareStatistics {
    let totalFacilities: Int
    let totalDistricts: Int
    let averageRating: Double
    let categoryBreakdown: [HealthcareCategory: Int]
    let districtBreakdown: [RiyadhDistrict: Int]
    let facilitiesWith24Hours: Int
    let facilitiesWithEmergency: Int
    let facilitiesWithOnlineBooking: Int
    let facilitiesWithTelemedicine: Int
}
