import Foundation

/// Centralized configuration management for API endpoints, secrets, and app settings
/// Supports multiple environments (Debug, Release, Production) with secure secret storage
enum Configuration {

    // MARK: - Environment

    enum Environment {
        case debug
        case release
        case production

        static var current: Environment {
            #if DEBUG
            return .debug
            #else
            return ProcessInfo.processInfo.environment["APP_ENV"] == "production" ? .production : .release
            #endif
        }
    }

    // MARK: - API Endpoints

    enum API {
        /// CallLinc Healthcare AI Service
        static var callLincBaseURL: String {
            switch Environment.current {
            case .debug:
                return "https://calllinc-healthcare-ai-agent-469357002740.us-west1.run.app"
            case .release:
                return "https://calllinc-healthcare-ai-agent-469357002740.us-west1.run.app"
            case .production:
                return ProcessInfo.processInfo.environment["CALLLINC_URL"] ??
                       "https://calllinc-healthcare-ai-agent-469357002740.us-west1.run.app"
            }
        }

        /// Doctor Hub Appointment Booking Service
        static var doctorHubBaseURL: String {
            switch Environment.current {
            case .debug:
                return "https://brainsait-doctor-hub--fadil369.github.app/api"
            case .release:
                return "https://brainsait-doctor-hub--fadil369.github.app/api"
            case .production:
                return ProcessInfo.processInfo.environment["DOCTORHUB_URL"] ??
                       "https://brainsait-doctor-hub-production.herokuapp.com/api"
            }
        }

        /// Hospital Directory API
        static var hospitalDirectoryBaseURL: String {
            switch Environment.current {
            case .debug:
                return "http://localhost:8000/api"
            case .release:
                return "https://brainsait-backend-staging.herokuapp.com/api"
            case .production:
                return ProcessInfo.processInfo.environment["BACKEND_URL"] ??
                       "https://brainsait-backend.herokuapp.com/api"
            }
        }

        /// Epic FHIR Server
        static var epicFHIRBaseURL: String {
            return ProcessInfo.processInfo.environment["EPIC_FHIR_URL"] ??
                   "https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/R4"
        }
    }

    // MARK: - API Keys & Secrets

    enum Secrets {
        /// Epic FHIR Client ID (should be loaded from Keychain in production)
        static var epicClientID: String? {
            // First check environment variable
            if let envClientID = ProcessInfo.processInfo.environment["EPIC_CLIENT_ID"],
               !envClientID.isEmpty {
                return envClientID
            }

            // Then check Keychain
            if let keychainClientID = KeychainHelper.load(key: "epic_client_id") {
                return keychainClientID
            }

            // Debug fallback
            #if DEBUG
            return "YOUR_EPIC_CLIENT_ID" // Replace with sandbox credentials
            #else
            return nil
            #endif
        }

        /// CallLinc API Key (if needed for authentication)
        static var callLincAPIKey: String? {
            if let apiKey = ProcessInfo.processInfo.environment["CALLLINC_API_KEY"] {
                return apiKey
            }
            return KeychainHelper.load(key: "calllinc_api_key")
        }

        /// Doctor Hub API Key
        static var doctorHubAPIKey: String? {
            if let apiKey = ProcessInfo.processInfo.environment["DOCTORHUB_API_KEY"] {
                return apiKey
            }
            return KeychainHelper.load(key: "doctorhub_api_key")
        }
    }

    // MARK: - App Settings

    enum Settings {
        /// Request timeout in seconds
        static let networkTimeout: TimeInterval = 30.0

        /// Maximum retry attempts for failed requests
        static let maxRetryAttempts = 3

        /// Retry delay base (exponential backoff)
        static let retryDelayBase: TimeInterval = 2.0

        /// Maximum concurrent network requests
        static let maxConcurrentRequests = 5

        /// Cache duration in seconds
        static let cacheExpiration: TimeInterval = 300 // 5 minutes

        /// Maximum audio recording duration in seconds
        static let maxRecordingDuration: TimeInterval = 300 // 5 minutes

        /// WebSocket ping interval in seconds
        static let webSocketPingInterval: TimeInterval = 30.0

        /// Enable analytics
        static var analyticsEnabled: Bool {
            return Environment.current == .production
        }

        /// Enable verbose logging
        static var verboseLogging: Bool {
            return Environment.current == .debug
        }
    }

    // MARK: - Feature Flags

    enum Features {
        /// Enable AI voice triage
        static let voiceTriageEnabled = true

        /// Enable Epic FHIR integration
        static let epicFHIREnabled = true

        /// Enable ResearchKit surveys
        static let researchKitEnabled = true

        /// Enable offline mode
        static let offlineModeEnabled = false // TODO: Implement

        /// Enable push notifications
        static let pushNotificationsEnabled = false // TODO: Implement

        /// Enable biometric authentication
        static let biometricAuthEnabled = false // TODO: Implement
    }

    // MARK: - OAuth Configuration

    enum OAuth {
        /// Epic OAuth redirect URI
        static let epicRedirectURI = "brainsait-health://oauth/callback"

        /// Epic OAuth scopes
        static let epicScopes = "patient/Patient.read patient/Observation.read patient/MedicationRequest.read patient/Condition.read patient/Immunization.read patient/AllergyIntolerance.read patient/Procedure.read launch/patient openid fhirUser"

        /// OAuth token expiration buffer (refresh before expiry)
        static let tokenExpirationBuffer: TimeInterval = 300 // 5 minutes
    }
}

// MARK: - Keychain Helper

/// Secure storage helper for sensitive credentials
struct KeychainHelper {

    /// Save a value to Keychain
    /// - Parameters:
    ///   - key: The key to store the value under
    ///   - value: The string value to store
    /// - Returns: True if successful
    @discardableResult
    static func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        // Delete any existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Load a value from Keychain
    /// - Parameter key: The key to load
    /// - Returns: The stored string value, or nil if not found
    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status == errSecSuccess,
              let data = dataTypeRef as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    /// Delete a value from Keychain
    /// - Parameter key: The key to delete
    /// - Returns: True if successful
    @discardableResult
    static func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }

    /// Delete all values from Keychain for this app
    @discardableResult
    static func deleteAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}

// MARK: - Configuration Validator

extension Configuration {
    /// Validate that all required configuration is present
    static func validate() -> ValidationResult {
        var errors: [String] = []
        var warnings: [String] = []

        // Check Epic configuration
        if Features.epicFHIREnabled {
            if Secrets.epicClientID == nil || Secrets.epicClientID == "YOUR_EPIC_CLIENT_ID" {
                warnings.append("Epic Client ID not configured. Epic FHIR integration will not work.")
            }
        }

        // Check API endpoints are valid URLs
        let endpoints = [
            ("CallLinc", API.callLincBaseURL),
            ("DoctorHub", API.doctorHubBaseURL),
            ("Hospital Directory", API.hospitalDirectoryBaseURL),
            ("Epic FHIR", API.epicFHIRBaseURL)
        ]

        for (name, urlString) in endpoints {
            guard URL(string: urlString) != nil else {
                errors.append("\(name) base URL is invalid: \(urlString)")
                continue
            }
        }

        if errors.isEmpty {
            return .valid(warnings: warnings.isEmpty ? nil : warnings)
        } else {
            return .invalid(errors: errors)
        }
    }

    enum ValidationResult {
        case valid(warnings: [String]?)
        case invalid(errors: [String])

        var isValid: Bool {
            switch self {
            case .valid: return true
            case .invalid: return false
            }
        }
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension Configuration {
    /// Print current configuration (for debugging)
    static func printConfiguration() {
        print("""

        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        🔧 BrainSAIT Configuration
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        Environment: \(Environment.current)

        📡 API Endpoints:
        ├─ CallLinc: \(API.callLincBaseURL)
        ├─ DoctorHub: \(API.doctorHubBaseURL)
        ├─ Hospital Directory: \(API.hospitalDirectoryBaseURL)
        └─ Epic FHIR: \(API.epicFHIRBaseURL)

        🔐 Secrets:
        ├─ Epic Client ID: \(Secrets.epicClientID != nil ? "✓ Configured" : "✗ Missing")
        ├─ CallLinc API Key: \(Secrets.callLincAPIKey != nil ? "✓ Configured" : "✗ Missing")
        └─ DoctorHub API Key: \(Secrets.doctorHubAPIKey != nil ? "✓ Configured" : "✗ Missing")

        ⚙️  Settings:
        ├─ Network Timeout: \(Settings.networkTimeout)s
        ├─ Max Retries: \(Settings.maxRetryAttempts)
        ├─ Cache Expiration: \(Settings.cacheExpiration)s
        └─ Analytics: \(Settings.analyticsEnabled ? "Enabled" : "Disabled")

        🚀 Features:
        ├─ Voice Triage: \(Features.voiceTriageEnabled ? "✓" : "✗")
        ├─ Epic FHIR: \(Features.epicFHIREnabled ? "✓" : "✗")
        ├─ ResearchKit: \(Features.researchKitEnabled ? "✓" : "✗")
        └─ Offline Mode: \(Features.offlineModeEnabled ? "✓" : "✗")

        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        """)

        let validation = validate()
        switch validation {
        case .valid(let warnings):
            print("✅ Configuration is valid")
            if let warnings = warnings {
                print("⚠️  Warnings:")
                warnings.forEach { print("   - \($0)") }
            }
        case .invalid(let errors):
            print("❌ Configuration is invalid:")
            errors.forEach { print("   - \($0)") }
        }
        print()
    }
}
#endif
