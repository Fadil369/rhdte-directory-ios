import Foundation
import HealthKit

class HealthKitService: ObservableObject {
    static let shared = HealthKitService()
    
    @Published var isAuthorized = false
    @Published var healthData: HealthData = HealthData()
    @Published var errorMessage: String?
    
    private let healthStore = HKHealthStore()
    
    struct HealthData: Codable {
        var heartRate: Double?
        var bloodPressureSystolic: Double?
        var bloodPressureDiastolic: Double?
        var steps: Double?
        var weight: Double?
        var height: Double?
        var bloodGlucose: Double?
        var oxygenSaturation: Double?
        var bodyTemperature: Double?
        var respiratoryRate: Double?
        
        var bmi: Double? {
            guard let weight = weight, let height = height, height > 0 else { return nil }
            return weight / (height * height)
        }
    }
    
    private init() {
        checkAuthorization()
    }
    
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "HealthKit is not available on this device"
            return false
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bloodGlucose)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
            HKObjectType.clinicalType(forIdentifier: .allergyRecord)!,
            HKObjectType.clinicalType(forIdentifier: .conditionRecord)!,
            HKObjectType.clinicalType(forIdentifier: .immunizationRecord)!,
            HKObjectType.clinicalType(forIdentifier: .labResultRecord)!,
            HKObjectType.clinicalType(forIdentifier: .medicationRecord)!,
            HKObjectType.clinicalType(forIdentifier: .procedureRecord)!,
            HKObjectType.clinicalType(forIdentifier: .vitalSignRecord)!
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
            await MainActor.run {
                isAuthorized = true
            }
            return true
        } catch {
            await MainActor.run {
                errorMessage = "Authorization failed: \(error.localizedDescription)"
                isAuthorized = false
            }
            return false
        }
    }
    
    private func checkAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let status = healthStore.authorizationStatus(for: heartRateType)
        
        isAuthorized = (status == .sharingAuthorized)
    }
    
    @MainActor
    func fetchLatestHealthData() async {
        guard isAuthorized else {
            let authorized = await requestAuthorization()
            guard authorized else { return }
        }
        
        async let heartRate = fetchLatestQuantity(for: .heartRate, unit: .count().unitDivided(by: .minute()))
        async let systolic = fetchLatestQuantity(for: .bloodPressureSystolic, unit: .millimeterOfMercury())
        async let diastolic = fetchLatestQuantity(for: .bloodPressureDiastolic, unit: .millimeterOfMercury())
        async let steps = fetchTodaySteps()
        async let weight = fetchLatestQuantity(for: .bodyMass, unit: .gramUnit(with: .kilo))
        async let height = fetchLatestQuantity(for: .height, unit: .meter())
        async let glucose = fetchLatestQuantity(for: .bloodGlucose, unit: .gramUnit(with: .milli).unitDivided(by: .literUnit(with: .deci)))
        async let oxygen = fetchLatestQuantity(for: .oxygenSaturation, unit: .percent())
        async let temp = fetchLatestQuantity(for: .bodyTemperature, unit: .degreeCelsius())
        async let respRate = fetchLatestQuantity(for: .respiratoryRate, unit: .count().unitDivided(by: .minute()))
        
        do {
            healthData.heartRate = try await heartRate
            healthData.bloodPressureSystolic = try await systolic
            healthData.bloodPressureDiastolic = try await diastolic
            healthData.steps = try await steps
            healthData.weight = try await weight
            healthData.height = try await height
            healthData.bloodGlucose = try await glucose
            healthData.oxygenSaturation = try await oxygen
            healthData.bodyTemperature = try await temp
            healthData.respiratoryRate = try await respRate
        } catch {
            errorMessage = "Failed to fetch health data: \(error.localizedDescription)"
        }
    }
    
    private func fetchLatestQuantity(for identifier: HKQuantityTypeIdentifier, unit: HKUnit) async throws -> Double? {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            return nil
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
            // Query completion
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let actualQuery = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let value = sample.quantity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            
            healthStore.execute(actualQuery)
        }
    }
    
    private func fetchTodaySteps() async throws -> Double? {
        guard let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return nil
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let sum = result?.sumQuantity() else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let steps = sum.doubleValue(for: .count())
                continuation.resume(returning: steps)
            }
            
            healthStore.execute(query)
        }
    }
    
    func writeHealthData(type: HKQuantityTypeIdentifier, value: Double, unit: HKUnit) async throws {
        guard isAuthorized else {
            throw HealthKitError.notAuthorized
        }
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: type) else {
            throw HealthKitError.invalidType
        }
        
        let quantity = HKQuantity(unit: unit, doubleValue: value)
        let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: Date(), end: Date())
        
        try await healthStore.save(sample)
    }
    
    func fetchClinicalRecords() async throws -> [HKClinicalRecord] {
        guard isAuthorized else {
            throw HealthKitError.notAuthorized
        }
        
        let clinicalTypes: [HKClinicalTypeIdentifier] = [
            .allergyRecord,
            .conditionRecord,
            .immunizationRecord,
            .labResultRecord,
            .medicationRecord,
            .procedureRecord,
            .vitalSignRecord
        ]
        
        var allRecords: [HKClinicalRecord] = []
        
        for typeIdentifier in clinicalTypes {
            guard let clinicalType = HKObjectType.clinicalType(forIdentifier: typeIdentifier) else {
                continue
            }
            
            let records = try await fetchRecords(for: clinicalType)
            allRecords.append(contentsOf: records)
        }
        
        return allRecords
    }
    
    private func fetchRecords(for type: HKClinicalType) async throws -> [HKClinicalRecord] {
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let records = samples?.compactMap { $0 as? HKClinicalRecord } ?? []
                continuation.resume(returning: records)
            }
            
            healthStore.execute(query)
        }
    }
}

enum HealthKitError: LocalizedError {
    case notAuthorized
    case invalidType
    case notAvailable
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "HealthKit access not authorized. Please grant permissions in Settings."
        case .invalidType:
            return "Invalid HealthKit data type."
        case .notAvailable:
            return "HealthKit is not available on this device."
        }
    }
}
