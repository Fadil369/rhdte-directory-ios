import Foundation
import SMART

class EpicFHIRService: ObservableObject {
    static let shared = EpicFHIRService()
    
    @Published var isConnected = false
    @Published var patient: Patient?
    @Published var observations: [Observation] = []
    @Published var medications: [MedicationRequest] = []
    @Published var conditions: [Condition] = []
    @Published var immunizations: [Immunization] = []
    @Published var allergyIntolerances: [AllergyIntolerance] = []
    @Published var errorMessage: String?
    
    private var smart: Client?
    
    // Epic FHIR Configuration
    private let epicConfig = [
        "client_id": "YOUR_EPIC_CLIENT_ID", // Replace with actual Client ID from Epic
        "redirect": "brainsait-health://oauth/callback",
        "scope": "patient/Patient.read patient/Observation.read patient/MedicationRequest.read patient/Condition.read patient/Immunization.read patient/AllergyIntolerance.read launch/patient openid fhirUser",
        "authorize_uri": "https://fhir.epic.com/interconnect-fhir-oauth/oauth2/authorize",
        "token_uri": "https://fhir.epic.com/interconnect-fhir-oauth/oauth2/token",
        "server_url": "https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/R4"
    ]
    
    private init() {
        setupSMARTClient()
    }
    
    private func setupSMARTClient() {
        do {
            let settings = [
                "client_id": epicConfig["client_id"]!,
                "redirect": epicConfig["redirect"]!,
                "scope": epicConfig["scope"]!
            ]
            
            smart = Client(
                baseURL: URL(string: epicConfig["server_url"]!)!,
                settings: settings
            )
            
            smart?.authProperties.authorizeEmbedded = false
            smart?.authProperties.granularity = .patientSelectNative
            
        } catch {
            errorMessage = "Failed to setup SMART client: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func authorize() async throws {
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
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    func handleRedirect(url: URL) -> Bool {
        return smart?.didRedirect(to: url) ?? false
    }
    
    @MainActor
    func fetchPatientData() async throws {
        guard isConnected, let smart = smart else {
            throw FHIRError.notAuthorized
        }
        
        // Fetch patient information
        if let patientId = smart.patient?.id {
            patient = try await fetchPatient(id: patientId)
        }
        
        // Fetch clinical data in parallel
        async let observationsTask = fetchObservations()
        async let medicationsTask = fetchMedications()
        async let conditionsTask = fetchConditions()
        async let immunizationsTask = fetchImmunizations()
        async let allergiesTask = fetchAllergies()
        
        observations = try await observationsTask
        medications = try await medicationsTask
        conditions = try await conditionsTask
        immunizations = try await immunizationsTask
        allergyIntolerances = try await allergiesTask
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
    
    func disconnect() {
        smart?.reset()
        isConnected = false
        patient = nil
        observations = []
        medications = []
        conditions = []
        immunizations = []
        allergyIntolerances = []
    }
    
    // Helper method to sync Epic data to HealthKit
    func syncToHealthKit() async throws {
        let healthKitService = HealthKitService.shared
        
        // Sync vital signs observations to HealthKit
        for observation in observations {
            if let code = observation.code?.coding?.first?.code?.string,
               let value = observation.valueQuantity?.value?.decimal {
                
                switch code {
                case "8867-4": // Heart rate
                    try await healthKitService.writeHealthData(
                        type: .heartRate,
                        value: Double(truncating: value as NSNumber),
                        unit: .count().unitDivided(by: .minute())
                    )
                case "8480-6": // Systolic BP
                    try await healthKitService.writeHealthData(
                        type: .bloodPressureSystolic,
                        value: Double(truncating: value as NSNumber),
                        unit: .millimeterOfMercury()
                    )
                case "8462-4": // Diastolic BP
                    try await healthKitService.writeHealthData(
                        type: .bloodPressureDiastolic,
                        value: Double(truncating: value as NSNumber),
                        unit: .millimeterOfMercury()
                    )
                case "2339-0": // Blood glucose
                    try await healthKitService.writeHealthData(
                        type: .bloodGlucose,
                        value: Double(truncating: value as NSNumber),
                        unit: .gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci))
                    )
                case "29463-7": // Body weight
                    try await healthKitService.writeHealthData(
                        type: .bodyMass,
                        value: Double(truncating: value as NSNumber),
                        unit: .gramUnit(with: .kilo)
                    )
                default:
                    break
                }
            }
        }
    }
}

enum FHIRError: LocalizedError {
    case clientNotInitialized
    case notAuthorized
    case invalidResponse
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .clientNotInitialized:
            return "FHIR client not initialized"
        case .notAuthorized:
            return "Not authorized to access Epic FHIR data. Please connect first."
        case .invalidResponse:
            return "Invalid response from FHIR server"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
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
