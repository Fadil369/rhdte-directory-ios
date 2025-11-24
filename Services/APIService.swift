// BrainSAIT RHDTE - API Service
// Integration with RHDTE backend API

import Foundation

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:8000/api"
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config)
    }
    
    // MARK: - Facilities
    
    func fetchFacilities(
        district: String? = nil,
        type: FacilityType? = nil,
        minRating: Double? = nil
    ) async throws -> [Facility] {
        var components = URLComponents(string: "\(baseURL)/facilities")!
        var queryItems: [URLQueryItem] = []
        
        if let district = district {
            queryItems.append(URLQueryItem(name: "district", value: district))
        }
        if let type = type {
            queryItems.append(URLQueryItem(name: "type", value: type.rawValue))
        }
        if let minRating = minRating {
            queryItems.append(URLQueryItem(name: "min_rating", value: String(minRating)))
        }
        
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        let (data, _) = try await session.data(from: components.url!)
        return try JSONDecoder().decode([Facility].self, from: data)
    }
    
    func fetchFacilityDetails(id: String) async throws -> Facility {
        let url = URL(string: "\(baseURL)/facilities/\(id)")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(Facility.self, from: data)
    }
    
    // MARK: - Districts
    
    func fetchDistricts() async throws -> [String] {
        let url = URL(string: "\(baseURL)/districts")!
        let (data, _) = try await session.data(from: url)
        
        struct DistrictsResponse: Codable {
            let districts: [DistrictInfo]
        }
        
        struct DistrictInfo: Codable {
            let key: String
            let nameAr: String
            
            enum CodingKeys: String, CodingKey {
                case key
                case nameAr = "name_ar"
            }
        }
        
        let response = try JSONDecoder().decode(DistrictsResponse.self, from: data)
        return response.districts.map { $0.key }
    }
    
    // MARK: - Search
    
    func searchFacilities(query: String) async throws -> [Facility] {
        var components = URLComponents(string: "\(baseURL)/facilities/search")!
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        
        let (data, _) = try await session.data(from: components.url!)
        return try JSONDecoder().decode([Facility].self, from: data)
    }
    
    // MARK: - Lead Magnet
    
    func submitLeadMagnet(_ submission: LeadMagnetSubmission) async throws {
        let url = URL(string: "\(baseURL)/leads/subscribe")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(submission)
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.subscriptionFailed
        }
    }
    
    // MARK: - Dashboard
    
    func fetchDashboardStats() async throws -> DashboardStats {
        let url = URL(string: "\(baseURL)/analytics/summary")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(DashboardStats.self, from: data)
    }
    
    // MARK: - User
    
    func fetchUserProfile(userId: String) async throws -> UserProfile {
        let url = URL(string: "\(baseURL)/users/\(userId)")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(UserProfile.self, from: data)
    }
    
    func updateUserProfile(_ profile: UserProfile) async throws {
        let url = URL(string: "\(baseURL)/users/\(profile.id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(profile)
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.updateFailed
        }
    }
    
    func saveFacility(userId: String, facilityId: String) async throws {
        let url = URL(string: "\(baseURL)/users/\(userId)/saved/\(facilityId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (_, _) = try await session.data(for: request)
    }
    
    func removeSavedFacility(userId: String, facilityId: String) async throws {
        let url = URL(string: "\(baseURL)/users/\(userId)/saved/\(facilityId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, _) = try await session.data(for: request)
    }
    
    // MARK: - Scoring (Premium Feature)
    
    func fetchDigitalScore(facilityId: String) async throws -> FacilityScore {
        let url = URL(string: "\(baseURL)/score/\(facilityId)")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(FacilityScore.self, from: data)
    }
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case subscriptionFailed
    case updateFailed
    case networkError
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .subscriptionFailed:
            return "Failed to complete subscription. Please try again."
        case .updateFailed:
            return "Failed to update. Please try again."
        case .networkError:
            return "Network error. Please check your connection."
        case .unauthorized:
            return "Session expired. Please sign in again."
        }
    }
}

// MARK: - Facility Score

struct FacilityScore: Codable {
    let facilityId: String
    let score: Int
    let level: String
    let breakdown: ScoreBreakdown
    let gaps: [String]
    let recommendation: RecommendedBundle
    
    struct ScoreBreakdown: Codable {
        let website: Int
        let ssl: Int
        let mobile: Int
        let arabic: Int
        let booking: Int
        let social: Int
        let rating: Int
    }
    
    struct RecommendedBundle: Codable {
        let bundleKey: String
        let nameEn: String
        let nameAr: String
        let priceSar: Int
    }
}
