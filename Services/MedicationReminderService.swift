// BrainSAIT RHDTE - Medication Reminder Service
// Stub interface for DoctorHub medication reminders

import Foundation
import Combine
import UserNotifications
import os.log

private let logger = Logger(subsystem: "com.brainsait.rhdte-directory", category: "MedicationReminder")

/// Service for managing medication reminders with DoctorHub
class MedicationReminderService: ObservableObject {
    static let shared = MedicationReminderService()
    
    // MARK: - Published State
    
    @Published var reminders: [MedicationReminder] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var notificationsEnabled = false
    
    // MARK: - Configuration
    
    private let doctorHubBaseURL = "https://brainsait-doctor-hub--fadil369.github.app/api"
    private var authToken: String?
    
    // MARK: - Types
    
    struct MedicationReminder: Codable, Identifiable {
        let id: String
        let prescriptionId: String?
        let medicationName: String
        let dosage: String
        let schedule: ReminderSchedule
        let status: ReminderStatus
        let nextReminderAt: Date?
        let snoozeDurationMinutes: Int
        let createdAt: Date
        
        enum ReminderStatus: String, Codable {
            case active
            case paused
            case completed
            case cancelled
        }
        
        struct ReminderSchedule: Codable {
            let type: ScheduleType
            let times: [String]
            let daysOfWeek: [Int]?
            let startDate: String
            let endDate: String?
            
            enum ScheduleType: String, Codable {
                case daily
                case weekly
                case asNeeded = "as_needed"
                case custom
            }
            
            enum CodingKeys: String, CodingKey {
                case type, times
                case daysOfWeek = "days_of_week"
                case startDate = "start_date"
                case endDate = "end_date"
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case prescriptionId = "prescription_id"
            case medicationName = "medication_name"
            case dosage
            case schedule
            case status
            case nextReminderAt = "next_reminder_at"
            case snoozeDurationMinutes = "snooze_duration_minutes"
            case createdAt = "created_at"
        }
    }
    
    struct CreateReminderRequest: Codable {
        let prescriptionId: String?
        let medicationName: String
        let dosage: String
        let schedule: MedicationReminder.ReminderSchedule
        let snoozeDurationMinutes: Int
        
        enum CodingKeys: String, CodingKey {
            case prescriptionId = "prescription_id"
            case medicationName = "medication_name"
            case dosage
            case schedule
            case snoozeDurationMinutes = "snooze_duration_minutes"
        }
    }
    
    // MARK: - Notification Actions
    
    enum NotificationAction: String {
        case taken = "TAKEN"
        case snooze = "SNOOZE"
        case skip = "SKIP"
    }
    
    // MARK: - Private Init
    
    private init() {
        checkNotificationPermissions()
    }
    
    // MARK: - Authentication
    
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    // MARK: - Notification Permissions
    
    func requestNotificationPermissions() async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            
            await MainActor.run {
                notificationsEnabled = granted
            }
            
            if granted {
                await registerNotificationCategories()
            }
            
            return granted
        } catch {
            logger.error("Failed to request notification permissions: \(error.localizedDescription)")
            return false
        }
    }
    
    private func checkNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func registerNotificationCategories() async {
        let takenAction = UNNotificationAction(
            identifier: NotificationAction.taken.rawValue,
            title: "Mark as Taken",
            options: []
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: NotificationAction.snooze.rawValue,
            title: "Snooze 10 min",
            options: []
        )
        
        let skipAction = UNNotificationAction(
            identifier: NotificationAction.skip.rawValue,
            title: "Skip",
            options: [.destructive]
        )
        
        let category = UNNotificationCategory(
            identifier: "MEDICATION_REMINDER",
            actions: [takenAction, snoozeAction, skipAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // MARK: - API Methods
    
    /// Fetch all reminders for the current user
    @MainActor
    func fetchReminders(patientId: String) async throws -> [MedicationReminder] {
        guard FeatureFlagsService.shared.isEnabled(.medicationReminders) else {
            throw ReminderError.featureDisabled
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Implement actual API call
        // For now, return stub response
        throw ReminderError.notImplemented
    }
    
    /// Create a new reminder
    @MainActor
    func createReminder(_ request: CreateReminderRequest) async throws -> MedicationReminder {
        guard FeatureFlagsService.shared.isEnabled(.medicationReminders) else {
            throw ReminderError.featureDisabled
        }
        
        guard notificationsEnabled else {
            throw ReminderError.notificationsDisabled
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Implement actual API call
        throw ReminderError.notImplemented
    }
    
    /// Update an existing reminder
    @MainActor
    func updateReminder(id: String, request: CreateReminderRequest) async throws -> MedicationReminder {
        guard FeatureFlagsService.shared.isEnabled(.medicationReminders) else {
            throw ReminderError.featureDisabled
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Implement actual API call
        throw ReminderError.notImplemented
    }
    
    /// Delete a reminder
    @MainActor
    func deleteReminder(id: String) async throws {
        guard FeatureFlagsService.shared.isEnabled(.medicationReminders) else {
            throw ReminderError.featureDisabled
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Implement actual API call
        throw ReminderError.notImplemented
    }
    
    /// Mark medication as taken
    @MainActor
    func markAsTaken(reminderId: String, takenAt: Date = Date(), notes: String? = nil) async throws {
        guard FeatureFlagsService.shared.isEnabled(.medicationReminders) else {
            throw ReminderError.featureDisabled
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Implement actual API call
        throw ReminderError.notImplemented
    }
    
    /// Snooze a reminder
    @MainActor
    func snoozeReminder(reminderId: String, until: Date) async throws {
        guard FeatureFlagsService.shared.isEnabled(.medicationReminders) else {
            throw ReminderError.featureDisabled
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Implement actual API call
        throw ReminderError.notImplemented
    }
    
    // MARK: - Local Notifications (Offline Fallback)
    
    /// Schedule a local notification for a reminder
    func scheduleLocalNotification(for reminder: MedicationReminder) async throws {
        guard notificationsEnabled else {
            throw ReminderError.notificationsDisabled
        }
        
        guard let nextReminder = reminder.nextReminderAt else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "Time to take \(reminder.medicationName) - \(reminder.dosage)"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("reminder.caf"))
        content.categoryIdentifier = "MEDICATION_REMINDER"
        content.userInfo = [
            "reminder_id": reminder.id,
            "medication_name": reminder.medicationName,
            "dosage": reminder.dosage
        ]
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextReminder)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "reminder_\(reminder.id)",
            content: content,
            trigger: trigger
        )
        
        try await UNUserNotificationCenter.current().add(request)
    }
    
    /// Cancel a scheduled local notification
    func cancelLocalNotification(for reminderId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["reminder_\(reminderId)"]
        )
    }
    
    /// Cancel all local notifications
    func cancelAllLocalNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Push Notification Handling
    
    /// Handle push notification for medication reminder
    func handlePushNotification(userInfo: [AnyHashable: Any]) {
        guard let doctorHubData = userInfo["doctorhub"] as? [String: Any],
              let type = doctorHubData["type"] as? String,
              type == "reminder.due" else {
            return
        }
        
        // Process reminder notification
        if let reminderId = doctorHubData["reminder_id"] as? String {
            logger.debug("Received reminder notification for: \(reminderId)")
            // TODO: Update local state
        }
    }
    
    /// Handle notification action response
    func handleNotificationAction(_ action: NotificationAction, reminderId: String) {
        Task {
            switch action {
            case .taken:
                try? await markAsTaken(reminderId: reminderId)
            case .snooze:
                let snoozeUntil = Date().addingTimeInterval(10 * 60) // 10 minutes
                try? await snoozeReminder(reminderId: reminderId, until: snoozeUntil)
            case .skip:
                // Just dismiss, log the skip
                logger.debug("User skipped reminder: \(reminderId)")
            }
        }
    }
}

// MARK: - Errors

enum ReminderError: LocalizedError {
    case featureDisabled
    case notificationsDisabled
    case invalidSchedule
    case notFound
    case notImplemented
    
    var errorDescription: String? {
        switch self {
        case .featureDisabled:
            return "Medication reminders are not available at this time."
        case .notificationsDisabled:
            return "Please enable notifications to use medication reminders."
        case .invalidSchedule:
            return "The reminder schedule is invalid."
        case .notFound:
            return "Reminder not found."
        case .notImplemented:
            return "This feature is coming soon."
        }
    }
}
