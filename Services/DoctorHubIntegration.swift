import Foundation

/// DoctorHubService manages doctor appointments, availability, and bookings
/// Integrates with the BrainSAIT Doctor Hub API for real-time scheduling
///
/// ## Features:
/// - Doctor profile management
/// - Real-time availability checking
/// - Appointment booking and management
/// - Insurance claim submission
/// - NPHIES integration for Saudi health insurance
class DoctorHubService: ObservableObject {
    static let shared = DoctorHubService()

    @Published var appointments: [Appointment] = []
    @Published var doctors: [Doctor] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = Configuration.Settings.networkTimeout
        config.timeoutIntervalForResource = Configuration.Settings.networkTimeout * 2
        config.requestCachePolicy = .reloadIgnoringLocalCacheData // Always fetch fresh appointment data

        // 🔒 SECURITY: Add authentication headers
        if let apiKey = Configuration.Secrets.doctorHubAPIKey {
            config.httpAdditionalHeaders = [
                "Authorization": "Bearer \(apiKey)",
                "User-Agent": "BrainSAIT-iOS/1.0"
            ]
        }

        session = URLSession(configuration: config)
    }
    
    @MainActor
    func fetchDoctors(facilityId: String) async throws -> [Doctor] {
        isLoading = true
        defer { isLoading = false }

        // 🔧 FIX: Use Configuration for base URL
        let baseURL = Configuration.API.doctorHubBaseURL

        // 🔒 SECURITY: Validate and sanitize facility ID
        guard !facilityId.isEmpty, facilityId.count < 100 else {
            throw DoctorHubError.invalidInput("Invalid facility ID")
        }

        guard let encodedFacilityId = facilityId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/doctors?facility_id=\(encodedFacilityId)") else {
            throw DoctorHubError.invalidURL
        }

        // ✅ ENHANCEMENT: Add response validation
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DoctorHubError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw DoctorHubError.httpError(statusCode: httpResponse.statusCode)
        }

        doctors = try JSONDecoder().decode([Doctor].self, from: data)
        return doctors
    }
    
    @MainActor
    func fetchAvailableSlots(doctorId: String, date: Date) async throws -> [TimeSlot] {
        isLoading = true
        defer { isLoading = false }
        
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: date)
        
        let url = URL(string: "\(doctorHubBaseURL)/availability?doctor_id=\(doctorId)&date=\(dateString)")!
        let (data, _) = try await session.data(from: url)
        
        return try JSONDecoder().decode([TimeSlot].self, from: data)
    }
    
    @MainActor
    func bookAppointment(_ request: AppointmentRequest) async throws -> Appointment {
        isLoading = true
        defer { isLoading = false }
        
        let url = URL(string: "\(doctorHubBaseURL)/appointments")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw DoctorHubError.bookingFailed
        }
        
        let appointment = try JSONDecoder().decode(Appointment.self, from: data)
        appointments.append(appointment)
        return appointment
    }
    
    @MainActor
    func fetchAppointments(patientId: String) async throws -> [Appointment] {
        isLoading = true
        defer { isLoading = false }
        
        let url = URL(string: "\(doctorHubBaseURL)/appointments?patient_id=\(patientId)")!
        let (data, _) = try await session.data(from: url)
        
        appointments = try JSONDecoder().decode([Appointment].self, from: data)
        return appointments
    }
    
    @MainActor
    func cancelAppointment(appointmentId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let url = URL(string: "\(doctorHubBaseURL)/appointments/\(appointmentId)/cancel")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw DoctorHubError.cancellationFailed
        }
        
        appointments.removeAll { $0.id == appointmentId }
    }
    
    @MainActor
    func submitInsuranceClaim(_ claim: InsuranceClaim) async throws -> ClaimResponse {
        isLoading = true
        defer { isLoading = false }
        
        let url = URL(string: "\(doctorHubBaseURL)/insurance/claims")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(claim)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw DoctorHubError.claimSubmissionFailed
        }
        
        return try JSONDecoder().decode(ClaimResponse.self, from: data)
    }
}

// MARK: - Error Types

/// Comprehensive error handling for DoctorHub operations
enum DoctorHubError: LocalizedError {
    case bookingFailed
    case cancellationFailed
    case claimSubmissionFailed
    case networkError
    case invalidURL
    case invalidResponse
    case invalidInput(String)
    case httpError(statusCode: Int)
    case decodingError(Error)
    case timeout

    var errorDescription: String? {
        switch self {
        case .bookingFailed:
            return "Failed to book appointment. Please try again."
        case .cancellationFailed:
            return "Failed to cancel appointment. Please contact support."
        case .claimSubmissionFailed:
            return "Failed to submit insurance claim. Please try again."
        case .networkError:
            return "Network error. Please check your connection."
        case .invalidURL:
            return "Invalid request URL. Please contact support."
        case .invalidResponse:
            return "Invalid server response. Please try again."
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .httpError(let statusCode):
            switch statusCode {
            case 400:
                return "Bad request. Please check your input."
            case 401:
                return "Authentication required. Please login again."
            case 403:
                return "Access denied. Please check your permissions."
            case 404:
                return "Resource not found."
            case 429:
                return "Too many requests. Please try again later."
            case 500...599:
                return "Server error. Please try again later."
            default:
                return "Request failed with status code \(statusCode)."
            }
        case .decodingError(let error):
            return "Failed to process server response: \(error.localizedDescription)"
        case .timeout:
            return "Request timed out. Please check your connection and try again."
        }
    }

    var errorDescriptionArabic: String {
        switch self {
        case .bookingFailed:
            return "فشل حجز الموعد. يرجى المحاولة مرة أخرى."
        case .cancellationFailed:
            return "فشل إلغاء الموعد. يرجى الاتصال بالدعم."
        case .claimSubmissionFailed:
            return "فشل تقديم المطالبة التأمينية. يرجى المحاولة مرة أخرى."
        case .networkError:
            return "خطأ في الشبكة. يرجى التحقق من اتصالك."
        case .invalidURL:
            return "عنوان URL غير صالح. يرجى الاتصال بالدعم."
        case .invalidResponse:
            return "استجابة الخادم غير صالحة. يرجى المحاولة مرة أخرى."
        case .invalidInput(let message):
            return "إدخال غير صالح: \(message)"
        case .httpError(let statusCode):
            switch statusCode {
            case 400:
                return "طلب غير صحيح. يرجى التحقق من إدخالك."
            case 401:
                return "المصادقة مطلوبة. يرجى تسجيل الدخول مرة أخرى."
            case 403:
                return "تم رفض الوصول. يرجى التحقق من أذوناتك."
            case 404:
                return "لم يتم العثور على المورد."
            case 429:
                return "طلبات كثيرة جداً. يرجى المحاولة لاحقاً."
            case 500...599:
                return "خطأ في الخادم. يرجى المحاولة لاحقاً."
            default:
                return "فشل الطلب مع رمز الحالة \(statusCode)."
            }
        case .decodingError:
            return "فشل معالجة استجابة الخادم."
        case .timeout:
            return "انتهت مهلة الطلب. يرجى التحقق من اتصالك والمحاولة مرة أخرى."
        }
    }
}

struct Doctor: Identifiable, Codable {
    let id: String
    let nameEn: String
    let nameAr: String
    let specialty: String
    let facilityId: String
    let rating: Double?
    let yearsOfExperience: Int
    let languages: [String]
    let photo: String?
    let bio: String?
    let consultationFee: Double?
    let acceptsInsurance: Bool
    let availableDays: [String]
    
    var displayName: String {
        Locale.current.language.languageCode?.identifier == "ar" ? nameAr : nameEn
    }
}

struct TimeSlot: Identifiable, Codable {
    let id: String
    let startTime: Date
    let endTime: Date
    let isAvailable: Bool
    let consultationType: ConsultationType
    
    enum ConsultationType: String, Codable {
        case inPerson = "in_person"
        case video = "video"
        case phone = "phone"
    }
}

struct AppointmentRequest: Codable {
    let doctorId: String
    let facilityId: String
    let patientId: String
    let patientName: String
    let patientPhone: String
    let patientEmail: String?
    let timeSlotId: String
    let appointmentDate: Date
    let consultationType: TimeSlot.ConsultationType
    let reason: String
    let insuranceProvider: String?
    let insurancePolicyNumber: String?
    let notes: String?
}

struct Appointment: Identifiable, Codable {
    let id: String
    let doctorId: String
    let doctorName: String
    let facilityId: String
    let facilityName: String
    let patientId: String
    let patientName: String
    let appointmentDate: Date
    let startTime: Date
    let endTime: Date
    let consultationType: TimeSlot.ConsultationType
    let status: AppointmentStatus
    let reason: String
    let notes: String?
    let confirmationCode: String
    
    enum AppointmentStatus: String, Codable {
        case scheduled
        case confirmed
        case inProgress = "in_progress"
        case completed
        case cancelled
        case noShow = "no_show"
    }
}

struct InsuranceClaim: Codable {
    let patientId: String
    let appointmentId: String
    let insuranceProvider: String
    let policyNumber: String
    let claimAmount: Double
    let services: [ServiceItem]
    let supportingDocuments: [String]
    
    struct ServiceItem: Codable {
        let code: String
        let description: String
        let amount: Double
    }
}

struct ClaimResponse: Codable {
    let claimId: String
    let status: ClaimStatus
    let approvedAmount: Double?
    let message: String
    let estimatedProcessingDays: Int
    
    enum ClaimStatus: String, Codable {
        case submitted
        case underReview = "under_review"
        case approved
        case partiallyApproved = "partially_approved"
        case rejected
    }
}
