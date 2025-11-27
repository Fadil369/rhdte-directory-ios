// BrainSAIT RHDTE - Feature Flags Service
// Controls feature rollout and versioning

import Foundation
import Combine

/// Service for managing feature flags from DoctorHub
class FeatureFlagsService: ObservableObject {
    static let shared = FeatureFlagsService()
    
    @Published private(set) var flags: [String: FeatureFlag] = [:]
    @Published private(set) var isLoaded = false
    @Published private(set) var lastUpdated: Date?
    
    private let doctorHubBaseURL = "https://brainsait-doctor-hub--fadil369.github.app/api"
    private let cacheKey = "feature_flags_cache"
    private let cacheExpiryKey = "feature_flags_cache_expiry"
    private let cacheTTL: TimeInterval = 3600 // 1 hour
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Feature Keys
    
    enum FeatureKey: String, CaseIterable {
        case videoConsultations = "video_consultations"
        case prescriptionManagement = "prescription_management"
        case labResults = "lab_results"
        case medicationReminders = "medication_reminders"
        case healthVault = "health_vault"
    }
    
    // MARK: - Initialization
    
    private init() {
        loadCachedFlags()
    }
    
    // MARK: - Public Methods
    
    /// Check if a feature is enabled
    func isEnabled(_ feature: FeatureKey) -> Bool {
        guard let flag = flags[feature.rawValue] else {
            return false
        }
        return flag.isEnabledForCurrentUser
    }
    
    /// Check if a feature is enabled by string key
    func isEnabled(_ key: String) -> Bool {
        guard let flag = flags[key] else {
            return false
        }
        return flag.isEnabledForCurrentUser
    }
    
    /// Check if the current app version meets minimum requirements for a feature
    func meetsMinimumVersion(_ feature: FeatureKey) -> Bool {
        guard let flag = flags[feature.rawValue],
              let minVersion = flag.minAppVersion else {
            return true
        }
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        return compareVersions(currentVersion, minVersion) >= 0
    }
    
    /// Fetch latest flags from server
    @MainActor
    func fetchFlags() async {
        do {
            let url = URL(string: "\(doctorHubBaseURL)/config/feature-flags")!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("⚠️ Failed to fetch feature flags, using cached values")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let config = try decoder.decode(FeatureFlagsConfig.self, from: data)
            
            flags = config.flags
            lastUpdated = Date()
            isLoaded = true
            
            // Cache the flags
            cacheFlags(data)
            
            print("✅ Loaded \(flags.count) feature flags")
            
        } catch {
            print("❌ Error fetching feature flags: \(error.localizedDescription)")
            // Use cached values if available
        }
    }
    
    /// Force refresh flags
    func refresh() {
        Task {
            await fetchFlags()
        }
    }
    
    // MARK: - Caching
    
    private func loadCachedFlags() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let expiryDate = UserDefaults.standard.object(forKey: cacheExpiryKey) as? Date,
              expiryDate > Date() else {
            // Load default flags if cache expired or missing
            loadDefaultFlags()
            return
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let config = try decoder.decode(FeatureFlagsConfig.self, from: data)
            flags = config.flags
            isLoaded = true
            print("✅ Loaded feature flags from cache")
        } catch {
            loadDefaultFlags()
        }
    }
    
    private func cacheFlags(_ data: Data) {
        UserDefaults.standard.set(data, forKey: cacheKey)
        UserDefaults.standard.set(Date().addingTimeInterval(cacheTTL), forKey: cacheExpiryKey)
    }
    
    private func loadDefaultFlags() {
        // Default flags when server is unreachable
        flags = [
            FeatureKey.videoConsultations.rawValue: FeatureFlag(
                enabled: true,
                minAppVersion: "1.0.0",
                rolloutPercentage: 100,
                enabledForUsers: nil,
                note: nil
            ),
            FeatureKey.prescriptionManagement.rawValue: FeatureFlag(
                enabled: true,
                minAppVersion: "1.0.0",
                rolloutPercentage: 100,
                enabledForUsers: nil,
                note: nil
            ),
            FeatureKey.labResults.rawValue: FeatureFlag(
                enabled: true,
                minAppVersion: "1.0.0",
                rolloutPercentage: 100,
                enabledForUsers: nil,
                note: nil
            ),
            FeatureKey.medicationReminders.rawValue: FeatureFlag(
                enabled: true,
                minAppVersion: "1.0.0",
                rolloutPercentage: 100,
                enabledForUsers: nil,
                note: nil
            ),
            FeatureKey.healthVault.rawValue: FeatureFlag(
                enabled: false,
                minAppVersion: "1.1.0",
                rolloutPercentage: 0,
                enabledForUsers: nil,
                note: "Phase 2 feature"
            )
        ]
        isLoaded = true
        print("⚠️ Loaded default feature flags")
    }
    
    // MARK: - Version Comparison
    
    private func compareVersions(_ version1: String, _ version2: String) -> Int {
        let v1Parts = version1.split(separator: ".").compactMap { Int($0) }
        let v2Parts = version2.split(separator: ".").compactMap { Int($0) }
        
        let maxLength = max(v1Parts.count, v2Parts.count)
        
        for i in 0..<maxLength {
            let v1 = i < v1Parts.count ? v1Parts[i] : 0
            let v2 = i < v2Parts.count ? v2Parts[i] : 0
            
            if v1 > v2 { return 1 }
            if v1 < v2 { return -1 }
        }
        
        return 0
    }
}

// MARK: - Data Models

struct FeatureFlagsConfig: Codable {
    let flags: [String: FeatureFlag]
    let deprecatedEndpoints: [DeprecatedEndpoint]?
    
    enum CodingKeys: String, CodingKey {
        case flags
        case deprecatedEndpoints = "deprecated_endpoints"
    }
}

struct FeatureFlag: Codable {
    let enabled: Bool
    let minAppVersion: String?
    let rolloutPercentage: Int
    let enabledForUsers: [String]?
    let note: String?
    
    enum CodingKeys: String, CodingKey {
        case enabled
        case minAppVersion = "min_app_version"
        case rolloutPercentage = "rollout_percentage"
        case enabledForUsers = "enabled_for_users"
        case note
    }
    
    /// Check if feature is enabled for current user
    var isEnabledForCurrentUser: Bool {
        guard enabled else { return false }
        
        // Check rollout percentage
        // For deterministic rollout, use user ID hash
        if rolloutPercentage < 100 {
            // TODO: Use actual user ID for rollout determination
            let randomValue = Int.random(in: 1...100)
            if randomValue > rolloutPercentage {
                return false
            }
        }
        
        // Check app version
        if let minVersion = minAppVersion {
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
            let v1Parts = currentVersion.split(separator: ".").compactMap { Int($0) }
            let v2Parts = minVersion.split(separator: ".").compactMap { Int($0) }
            
            let maxLength = max(v1Parts.count, v2Parts.count)
            
            for i in 0..<maxLength {
                let v1 = i < v1Parts.count ? v1Parts[i] : 0
                let v2 = i < v2Parts.count ? v2Parts[i] : 0
                
                if v1 < v2 { return false }
                if v1 > v2 { break }
            }
        }
        
        return true
    }
}

struct DeprecatedEndpoint: Codable {
    let endpoint: String
    let deprecatedAt: String
    let removalDate: String
    let replacement: String
    
    enum CodingKeys: String, CodingKey {
        case endpoint
        case deprecatedAt = "deprecated_at"
        case removalDate = "removal_date"
        case replacement
    }
}
