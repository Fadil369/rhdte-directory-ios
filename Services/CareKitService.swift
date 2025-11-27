import Foundation
import CareKit
import CareKitStore
import HealthKit

/// CareKitService manages the CareKit store and provides methods for care plan management,
/// task tracking, contact management, and HealthKit synchronization.
class CareKitService: ObservableObject {
    static let shared = CareKitService()
    
    @Published var tasks: [OCKTask] = []
    @Published var events: [OCKEvent<OCKTask, OCKOutcome>] = []
    @Published var contacts: [OCKContact] = []
    @Published var carePlans: [OCKCarePlan] = []
    @Published var errorMessage: String?
    @Published var isInitialized = false
    
    private let store: OCKStore
    
    private init() {
        // Initialize CareKit store with data protection
        store = OCKStore(name: "BrainSAIT-CareKit", type: .onDisk(protection: .complete))
        
        setupDefaultCarePlan()
    }
    
    private func setupDefaultCarePlan() {
        Task {
            do {
                // Check if default care plan exists
                let query = OCKCarePlanQuery()
                let plans = try await store.fetchCarePlans(query: query)
                
                if plans.isEmpty {
                    // Create default care plan
                    let plan = OCKCarePlan(
                        id: "default-care-plan",
                        title: "Health & Wellness Plan",
                        patientUUID: nil
                    )
                    try await store.addCarePlan(plan)
                    
                    // Add default tasks
                    await createDefaultTasks(carePlanID: plan.id)
                }
                
                await MainActor.run {
                    isInitialized = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to setup care plan: \(error.localizedDescription)"
                    isInitialized = true // Still mark as initialized to allow app to continue
                }
            }
        }
    }
    
    private func createDefaultTasks(carePlanID: String) async {
        // Medication reminder task - morning and evening doses
        let morningSchedule = OCKSchedule.dailyAtTime(
            hour: 9, minutes: 0, start: Date(), end: nil,
            text: "Morning dose"
        )
        let eveningElement = OCKScheduleElement(
            start: Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date()) ?? Date(),
            end: nil,
            interval: DateComponents(day: 1),
            text: "Evening dose",
            targetValues: [],
            duration: .hours(1)
        )
        var medicationSchedule = morningSchedule
        medicationSchedule = medicationSchedule.inserting(element: eveningElement)
        
        let medicationTask = OCKTask(
            id: "medication-task",
            title: "Take Medication",
            carePlanUUID: nil,
            schedule: medicationSchedule
        )
        
        // Blood pressure check task
        let bpSchedule = OCKSchedule.dailyAtTime(
            hour: 8, minutes: 0, start: Date(), end: nil,
            text: "Morning BP check"
        )
        let bpTask = OCKTask(
            id: "blood-pressure-task",
            title: "Check Blood Pressure",
            carePlanUUID: nil,
            schedule: bpSchedule
        )
        
        // Exercise task
        let exerciseSchedule = OCKSchedule.dailyAtTime(
            hour: 17, minutes: 0, start: Date(), end: nil,
            text: "30 min exercise"
        )
        let exerciseTask = OCKTask(
            id: "exercise-task",
            title: "Exercise",
            carePlanUUID: nil,
            schedule: exerciseSchedule
        )
        
        // Water intake task - track throughout the day
        let waterSchedule = OCKSchedule.dailyAtTime(
            hour: 8, minutes: 0, start: Date(), end: nil,
            text: "8 glasses of water",
            duration: .allDay
        )
        let waterTask = OCKTask(
            id: "water-intake-task",
            title: "Drink Water",
            carePlanUUID: nil,
            schedule: waterSchedule
        )
        
        do {
            try await store.addTasks([medicationTask, bpTask, exerciseTask, waterTask])
        } catch {
            await MainActor.run {
                errorMessage = "Failed to create default tasks: \(error.localizedDescription)"
            }
        }
    }
    
    @MainActor
    func fetchTasks(for date: Date = Date()) async {
        do {
            let query = OCKTaskQuery(for: date)
            tasks = try await store.fetchTasks(query: query)
        } catch {
            errorMessage = "Failed to fetch tasks: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func fetchEvents(for date: Date = Date()) async {
        do {
            let query = OCKEventQuery(for: date)
            events = try await store.fetchEvents(query: query)
        } catch {
            errorMessage = "Failed to fetch events: \(error.localizedDescription)"
        }
    }
    
    func addTask(_ task: OCKTask) async throws {
        try await store.addTask(task)
        await fetchTasks()
    }
    
    func updateTask(_ task: OCKTask) async throws {
        try await store.updateTask(task)
        await fetchTasks()
    }
    
    func deleteTask(_ task: OCKTask) async throws {
        try await store.deleteTask(task)
        await fetchTasks()
    }
    
    func completeEvent(_ event: OCKEvent<OCKTask, OCKOutcome>) async throws {
        let outcome = OCKOutcome(
            taskUUID: event.task.uuid,
            taskOccurrenceIndex: event.scheduleEvent.occurrence,
            values: []
        )
        try await store.addOutcome(outcome)
        await fetchEvents()
    }
    
    @MainActor
    func addContact(_ contact: OCKContact) async throws {
        try await store.addContact(contact)
        try await fetchContacts()
    }
    
    @MainActor
    func fetchContacts() async throws {
        let query = OCKContactQuery()
        contacts = try await store.fetchContacts(query: query)
    }
    
    func createDoctorContact(from facility: Facility, doctor: Doctor? = nil) -> OCKContact {
        var contact = OCKContact(
            id: facility.id,
            givenName: doctor?.nameEn ?? facility.nameEn,
            familyName: "",
            carePlanUUID: nil
        )
        
        contact.title = doctor?.specialty ?? facility.type.rawValue
        contact.organization = facility.nameEn
        
        if let phone = facility.phone {
            contact.phoneNumbers = [OCKLabeledValue(label: "Work", value: phone)]
        }
        
        if let email = facility.email {
            contact.emailAddresses = [OCKLabeledValue(label: "Work", value: email)]
        }
        
        contact.address = {
            var address = OCKPostalAddress()
            address.street = facility.address
            address.city = facility.city
            address.state = facility.district
            return address
        }()
        
        return contact
    }
    
    /// Synchronizes HealthKit data with CareKit outcomes
    func syncWithHealthKit() async throws {
        let healthKitService = HealthKitService.shared
        await healthKitService.fetchLatestHealthData()
        
        let healthData = healthKitService.healthData
        
        // Create blood pressure outcome if data exists
        if let systolic = healthData.bloodPressureSystolic,
           let diastolic = healthData.bloodPressureDiastolic {
            
            // Find the blood pressure task
            let taskQuery = OCKTaskQuery(id: "blood-pressure-task")
            let tasks = try await store.fetchTasks(query: taskQuery)
            
            guard let bpTask = tasks.first else {
                return
            }
            
            let systolicValue = OCKOutcomeValue(systolic, units: "mmHg")
            var systolicOutcomeValue = systolicValue
            systolicOutcomeValue.kind = "systolic"
            
            let diastolicValue = OCKOutcomeValue(diastolic, units: "mmHg")
            var diastolicOutcomeValue = diastolicValue
            diastolicOutcomeValue.kind = "diastolic"
            
            let bpOutcome = OCKOutcome(
                taskUUID: bpTask.uuid,
                taskOccurrenceIndex: 0,
                values: [systolicOutcomeValue, diastolicOutcomeValue]
            )
            
            try await store.addOutcome(bpOutcome)
        }
        
        // Sync heart rate data if available
        if let heartRate = healthData.heartRate {
            // Could create a heart rate tracking task/outcome here
            print("Heart rate from HealthKit: \(heartRate) bpm")
        }
    }
    
    /// Calculate adherence rate for a task within a date range
    func getAdherenceRate(for task: OCKTask, in dateRange: DateInterval) async -> Double {
        do {
            let query = OCKEventQuery(dateInterval: dateRange)
            let events = try await store.fetchEvents(taskID: task.id, query: query)
            
            let totalEvents = events.count
            guard totalEvents > 0 else { return 0.0 }
            
            let completedEvents = events.filter { $0.outcome != nil }.count
            return Double(completedEvents) / Double(totalEvents)
            
        } catch {
            print("Failed to calculate adherence: \(error.localizedDescription)")
            return 0.0
        }
    }
    
    /// Fetch all care plans
    @MainActor
    func fetchCarePlans() async {
        do {
            let query = OCKCarePlanQuery()
            carePlans = try await store.fetchCarePlans(query: query)
        } catch {
            errorMessage = "Failed to fetch care plans: \(error.localizedDescription)"
        }
    }
    
    /// Get the store for direct access if needed
    func getStore() -> OCKStore {
        return store
    }
}

// Extension for creating medication tasks
extension CareKitService {
    func createMedicationTask(
        name: String,
        dosage: String,
        schedule: OCKSchedule,
        instructions: String? = nil
    ) async throws -> OCKTask {
        var task = OCKTask(
            id: UUID().uuidString,
            title: name,
            carePlanUUID: nil,
            schedule: schedule
        )
        
        task.instructions = instructions ?? "Take \(dosage)"
        task.impactsAdherence = true
        
        try await store.addTask(task)
        await fetchTasks()
        
        return task
    }
    
    func createAppointmentTask(
        facility: Facility,
        doctor: Doctor,
        appointment: Appointment
    ) async throws -> OCKTask {
        let schedule = OCKSchedule(
            composing: [
                OCKScheduleElement(
                    start: appointment.appointmentDate,
                    end: appointment.endTime,
                    interval: DateComponents(),
                    text: "Appointment with Dr. \(doctor.displayName)",
                    targetValues: [],
                    duration: .hours(1)
                )
            ]
        )
        
        var task = OCKTask(
            id: appointment.id,
            title: "Doctor Appointment",
            carePlanUUID: nil,
            schedule: schedule
        )
        
        task.instructions = """
        Appointment with Dr. \(doctor.displayName)
        \(doctor.specialty)
        
        Facility: \(facility.displayName)
        Address: \(facility.address)
        
        Reason: \(appointment.reason)
        """
        
        try await store.addTask(task)
        await fetchTasks()
        
        return task
    }
}
