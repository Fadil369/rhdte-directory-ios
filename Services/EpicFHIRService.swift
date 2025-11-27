import Foundation
import SMART

/// EpicFHIRService manages the connection to Epic's FHIR API using SMART on FHIR.
/// It handles OAuth authentication, patient data retrieval, and HealthKit synchronization.
class EpicFHIRService: ObservableObject {
    static let shared = EpicFHIRService()
    
    @Published var isConnected = false
    @Published var isConfigured = false
    @Published var patient: Patient?
    @Published var observations: [Observation] = []
    @Published var medications: [MedicationRequest] = []
    @Published var conditions: [Condition] = []
    @Published var immunizations: [Immunization] = []
    @Published var allergyIntolerances: [AllergyIntolerance] = []
    @Published var errorMessage: String?
    
    private var smart: Client?
    
    /// Epic FHIR Configuration - Configure these values from your Epic App registration
    struct EpicConfiguration {
        /// Your Epic Client ID from App Orchard registration
        var clientId: String
        /// OAuth redirect URI (must match your registration)
        var redirectUri: String
        /// FHIR scopes for data access
        var scope: String
        /// Epic FHIR server base URL
        var serverUrl: String
        
        /// Default sandbox configuration for testing
        static var sandbox: EpicConfiguration {
            EpicConfiguration(
                clientId: "YOUR_EPIC_CLIENT_ID",
                redirectUri: "brainsait-health://oauth/callback",
                scope: "patient/Patient.read patient/Observation.read patient/MedicationRequest.read patient/Condition.read patient/Immunization.read patient/AllergyIntolerance.read launch/patient openid fhirUser",
                serverUrl: "https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/R4"
            )
        }
        
        /// Production Epic configuration
        static var production: EpicConfiguration {
            EpicConfiguration(
                clientId: ProcessInfo.processInfo.environment["EPIC_CLIENT_ID"] ?? "YOUR_EPIC_CLIENT_ID",
                redirectUri: "brainsait-health://oauth/callback",
                scope: "patient/Patient.read patient/Observation.read patient/MedicationRequest.read patient/Condition.read patient/Immunization.read patient/AllergyIntolerance.read patient/Procedure.read launch/patient openid fhirUser",
                serverUrl: ProcessInfo.processInfo.environment["EPIC_FHIR_URL"] ?? "https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/R4"
            )
        }
    }
    
    private var config: EpicConfiguration
    
    private init() {
        // Use sandbox by default, can be switched to production
        self.config = EpicConfiguration.sandbox
        setupSMARTClient()
    }
    
    /// Configure the Epic service with custom credentials
    /// - Parameter configuration: The Epic configuration to use
    func configure(with configuration: EpicConfiguration) {
        self.config = configuration
        setupSMARTClient()
    }
    
    /// Configure with just a client ID (uses default URLs)
    /// - Parameter clientId: The Epic client ID from your registration
    func configure(clientId: String) {
        var newConfig = EpicConfiguration.production
        newConfig.clientId = clientId
        configure(with: newConfig)
    }
    
    private func setupSMARTClient() {
        guard config.clientId != "YOUR_EPIC_CLIENT_ID" else {
            isConfigured = false
            errorMessage = "Epic Client ID not configured. Please set your Epic credentials."
            return
        }
        
        let settings: [String: Any] = [
            "client_id": config.clientId,
            "redirect": config.redirectUri,
            "scope": config.scope
        ]
        
        guard let baseURL = URL(string: config.serverUrl) else {
            errorMessage = "Invalid Epic FHIR server URL"
            return
        }
        
        smart = Client(baseURL: baseURL, settings: settings)
        smart?.authProperties.authorizeEmbedded = false
        smart?.authProperties.granularity = .patientSelectNative
        
        isConfigured = true
    }
    
    /// Authorize the Epic connection using OAuth2
    @MainActor
    func authorize() async throws {
        guard isConfigured else {
            throw FHIRError.clientNotInitialized
        }
        
        guard let smart = smart else {
            throw FHIRError.clientNotInitialized
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            smart.authorize { parameters, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    Task { @MainActor in
                        self.isConnected = true
                        self.errorMessage = nil
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    /// Handle OAuth redirect callback
    func handleRedirect(url: URL) -> Bool {
        guard let smart = smart else { return false }
        return smart.didRedirect(to: url)
    }
    
    /// Fetch all patient data from Epic FHIR server
    @MainActor
    func fetchPatientData() async throws {
        guard isConnected, let smart = smart else {
            throw FHIRError.notAuthorized
        }
        
        // Fetch patient information
        if let patientId = smart.patient?.id {
            patient = try await fetchPatient(id: patientId)
        }
        
        // Fetch clinical data in parallel for better performance
        async let observationsTask = fetchObservations()
        async let medicationsTask = fetchMedications()
        async let conditionsTask = fetchConditions()
        async let immunizationsTask = fetchImmunizations()
        async let allergiesTask = fetchAllergies()
        
        do {
            observations = try await observationsTask
            medications = try await medicationsTask
            conditions = try await conditionsTask
            immunizations = try await immunizationsTask
            allergyIntolerances = try await allergiesTask
        } catch {
            // Log errors but don't throw - partial data is still useful
            #if DEBUG
            debugPrint("Some data failed to load: \(error.localizedDescription)")
            #endif
            errorMessage = "Some data could not be loaded: \(error.localizedDescription)"
        }
    }
    
    private func fetchPatient(id: String) async throws -> Patient {
        guard let smart = smart else {
            throw FHIRError.clientNotInitialized
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            Patient.read(id, server: smart.server) { resource, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let patient = resource as? Patient {
                    continuation.resume(returning: patient)
                } else {
                    continuation.resume(throwing: FHIRError.invalidResponse)
                }
            }
        }
    }
    
    private func fetchObservations() async throws -> [Observation] {
        guard let smart = smart, let patientId = smart.patient?.id else {
            throw FHIRError.notAuthorized
        }
        
        let search = Observation.search(["patient": patientId, "_count": "100"])
        
        return try await withCheckedThrowingContinuation { continuation in
            smart.server.perform(request: search) { bundle, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let bundle = bundle as? Bundle {
                    let observations = bundle.entry?.compactMap { $0.resource as? Observation } ?? []
                    continuation.resume(returning: observations)
                } else {
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    private func fetchMedications() async throws -> [MedicationRequest] {
        guard let smart = smart, let patientId = smart.patient?.id else {
            throw FHIRError.notAuthorized
        }
        
        let search = MedicationRequest.search(["patient": patientId, "_count": "100"])
        
        return try await withCheckedThrowingContinuation { continuation in
            smart.server.perform(request: search) { bundle, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let bundle = bundle as? Bundle {
                    let medications = bundle.entry?.compactMap { $0.resource as? MedicationRequest } ?? []
                    continuation.resume(returning: medications)
                } else {
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    private func fetchConditions() async throws -> [Condition] {
        guard let smart = smart, let patientId = smart.patient?.id else {
            throw FHIRError.notAuthorized
        }
        
        let search = Condition.search(["patient": patientId, "_count": "100"])
        
        return try await withCheckedThrowingContinuation { continuation in
            smart.server.perform(request: search) { bundle, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let bundle = bundle as? Bundle {
                    let conditions = bundle.entry?.compactMap { $0.resource as? Condition } ?? []
                    continuation.resume(returning: conditions)
                } else {
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    private func fetchImmunizations() async throws -> [Immunization] {
        guard let smart = smart, let patientId = smart.patient?.id else {
            throw FHIRError.notAuthorized
        }
        
        let search = Immunization.search(["patient": patientId, "_count": "100"])
        
        return try await withCheckedThrowingContinuation { continuation in
            smart.server.perform(request: search) { bundle, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let bundle = bundle as? Bundle {
                    let immunizations = bundle.entry?.compactMap { $0.resource as? Immunization } ?? []
                    continuation.resume(returning: immunizations)
                } else {
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    private func fetchAllergies() async throws -> [AllergyIntolerance] {
        guard let smart = smart, let patientId = smart.patient?.id else {
            throw FHIRError.notAuthorized
        }
        
        let search = AllergyIntolerance.search(["patient": patientId, "_count": "100"])
        
        return try await withCheckedThrowingContinuation { continuation in
            smart.server.perform(request: search) { bundle, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let bundle = bundle as? Bundle {
                    let allergies = bundle.entry?.compactMap { $0.resource as? AllergyIntolerance } ?? []
                    continuation.resume(returning: allergies)
                } else {
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    /// Disconnect from Epic and clear all data
    @MainActor
    func disconnect() {
        smart?.reset()
        isConnected = false
        patient = nil
        observations = []
        medications = []
        conditions = []
        immunizations = []
        allergyIntolerances = []
        errorMessage = nil
    }
    
    /// Helper method to sync Epic data to HealthKit
    func syncToHealthKit() async throws {
        guard !observations.isEmpty else {
            return
        }
        
        let healthKitService = HealthKitService.shared
        
        // Ensure HealthKit is authorized
        guard healthKitService.isAuthorized else {
            let authorized = await healthKitService.requestAuthorization()
            guard authorized else {
                throw HealthKitError.notAuthorized
            }
        }
        
        // Sync vital signs observations to HealthKit
        for observation in observations {
            guard let code = observation.code?.coding?.first?.code?.string,
                  let value = observation.valueQuantity?.value?.decimal else {
                continue
            }
            
            let doubleValue = Double(truncating: value as NSNumber)
            
            do {
                switch code {
                case "8867-4": // Heart rate (LOINC)
                    try await healthKitService.writeHealthData(
                        type: .heartRate,
                        value: doubleValue,
                        unit: .count().unitDivided(by: .minute())
                    )
                case "8480-6": // Systolic BP (LOINC)
                    try await healthKitService.writeHealthData(
                        type: .bloodPressureSystolic,
                        value: doubleValue,
                        unit: .millimeterOfMercury()
                    )
                case "8462-4": // Diastolic BP (LOINC)
                    try await healthKitService.writeHealthData(
                        type: .bloodPressureDiastolic,
                        value: doubleValue,
                        unit: .millimeterOfMercury()
                    )
                case "2339-0": // Blood glucose (LOINC)
                    try await healthKitService.writeHealthData(
                        type: .bloodGlucose,
                        value: doubleValue,
                        unit: .gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci))
                    )
                case "29463-7": // Body weight (LOINC)
                    try await healthKitService.writeHealthData(
                        type: .bodyMass,
                        value: doubleValue,
                        unit: .gramUnit(with: .kilo)
                    )
                case "8310-5": // Body temperature (LOINC)
                    try await healthKitService.writeHealthData(
                        type: .bodyTemperature,
                        value: doubleValue,
                        unit: .degreeCelsius()
                    )
                case "9279-1": // Respiratory rate (LOINC)
                    try await healthKitService.writeHealthData(
                        type: .respiratoryRate,
                        value: doubleValue,
                        unit: .count().unitDivided(by: .minute())
                    )
                case "2708-6": // Oxygen saturation (LOINC)
                    // Epic provides SpO2 as percentage (e.g., 98), HealthKit stores as decimal (0-1)
                    try await healthKitService.writeHealthData(
                        type: .oxygenSaturation,
                        value: doubleValue / 100.0, // Convert percentage to decimal for HealthKit
                        unit: .percent()
                    )
                default:
                    break
                }
            } catch {
                // Log error but continue with other observations
                #if DEBUG
                debugPrint("Failed to sync observation \(code): \(error.localizedDescription)")
                #endif
            }
        }
    }
    
    /// Check if the service is properly configured with Epic credentials
    var isReady: Bool {
        return isConfigured && smart != nil
    }
}

enum FHIRError: LocalizedError {
    case clientNotInitialized
    case notAuthorized
    case invalidResponse
    case networkError(Error)
    case configurationMissing
    
    var errorDescription: String? {
        switch self {
        case .clientNotInitialized:
            return "FHIR client not initialized. Please configure Epic credentials first."
        case .notAuthorized:
            return "Not authorized to access Epic FHIR data. Please connect first."
        case .invalidResponse:
            return "Invalid response from FHIR server"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .configurationMissing:
            return "Epic configuration is missing. Please set your Epic Client ID."
        }
    }
}

// Extension to extract patient demographics
extension Patient {
    var displayName: String {
        guard let names = name, let name = names.first else {
            return "Unknown Patient"
        }
        
        let given = name.given?.compactMap { $0.string }.joined(separator: " ") ?? ""
        let family = name.family?.string ?? ""
        
        return "\(given) \(family)".trimmingCharacters(in: .whitespaces)
    }
    
    var birthDateString: String? {
        return birthDate?.description
    }
    
    var genderString: String? {
        return gender?.rawValue
    }
}
