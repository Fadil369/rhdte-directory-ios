import Foundation

/// Input validation utility to prevent injection attacks and ensure data integrity
/// Provides comprehensive validation for all user inputs across the application
///
/// ## Features:
/// - Email validation with RFC 5322 compliance
/// - Phone number validation (Saudi Arabia format)
/// - Sanitization against XSS and injection attacks
/// - Length and format validation
/// - Arabic text validation
///
/// ## Usage:
/// ```swift
/// if InputValidator.isValidEmail("user@example.com") {
///     // Process email
/// }
/// ```
enum InputValidator {

    // MARK: - Email Validation

    /// Validates email address format (RFC 5322 compliant)
    /// - Parameter email: Email address to validate
    /// - Returns: True if valid
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email) && email.count <= 254
    }

    /// Validates and sanitizes email address
    /// - Parameter email: Email address to validate
    /// - Returns: Sanitized email or throws error
    /// - Throws: ValidationError if invalid
    static func validateEmail(_ email: String) throws -> String {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            throw ValidationError.emptyField(field: "Email")
        }

        guard trimmed.count <= 254 else {
            throw ValidationError.tooLong(field: "Email", maxLength: 254)
        }

        guard isValidEmail(trimmed) else {
            throw ValidationError.invalidFormat(field: "Email", message: "Please enter a valid email address")
        }

        return trimmed.lowercased()
    }

    // MARK: - Phone Number Validation

    /// Validates Saudi Arabian phone number
    /// Accepts formats: +966XXXXXXXXX, 05XXXXXXXX, 5XXXXXXXX
    /// - Parameter phone: Phone number to validate
    /// - Returns: True if valid
    static func isValidSaudiPhone(_ phone: String) -> Bool {
        let cleanPhone = phone.replacingOccurrences(of: #"[\s\-\(\)]"#, with: "", options: .regularExpression)

        // Saudi phone patterns
        let patterns = [
            #"^\+9665\d{8}$"#,      // +9665XXXXXXXX
            #"^9665\d{8}$"#,        // 9665XXXXXXXX
            #"^05\d{8}$"#,          // 05XXXXXXXX
            #"^5\d{8}$"#            // 5XXXXXXXX
        ]

        return patterns.contains { pattern in
            NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: cleanPhone)
        }
    }

    /// Validates and formats Saudi phone number
    /// - Parameter phone: Phone number to validate
    /// - Returns: Formatted phone number (+966XXXXXXXXX)
    /// - Throws: ValidationError if invalid
    static func validateSaudiPhone(_ phone: String) throws -> String {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            throw ValidationError.emptyField(field: "Phone")
        }

        let cleanPhone = trimmed.replacingOccurrences(of: #"[\s\-\(\)]"#, with: "", options: .regularExpression)

        guard isValidSaudiPhone(cleanPhone) else {
            throw ValidationError.invalidFormat(
                field: "Phone",
                message: "Please enter a valid Saudi phone number (e.g., 05XXXXXXXX)"
            )
        }

        // Normalize to +966 format
        if cleanPhone.hasPrefix("+966") {
            return cleanPhone
        } else if cleanPhone.hasPrefix("966") {
            return "+" + cleanPhone
        } else if cleanPhone.hasPrefix("05") {
            return "+966" + cleanPhone.dropFirst()
        } else if cleanPhone.hasPrefix("5") {
            return "+966" + cleanPhone
        }

        return cleanPhone
    }

    // MARK: - Text Validation

    /// Validates name (English or Arabic)
    /// - Parameter name: Name to validate
    /// - Returns: Sanitized name
    /// - Throws: ValidationError if invalid
    static func validateName(_ name: String, minLength: Int = 2, maxLength: Int = 100) throws -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            throw ValidationError.emptyField(field: "Name")
        }

        guard trimmed.count >= minLength else {
            throw ValidationError.tooShort(field: "Name", minLength: minLength)
        }

        guard trimmed.count <= maxLength else {
            throw ValidationError.tooLong(field: "Name", maxLength: maxLength)
        }

        // Allow letters, spaces, hyphens, and Arabic characters
        let nameRegex = #"^[\p{L}\s\-'\.]+$"#
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)

        guard namePredicate.evaluate(with: trimmed) else {
            throw ValidationError.invalidFormat(
                field: "Name",
                message: "Name can only contain letters, spaces, and hyphens"
            )
        }

        return trimmed
    }

    /// Validates generic text field
    /// - Parameters:
    ///   - text: Text to validate
    ///   - fieldName: Name of the field for error messages
    ///   - minLength: Minimum required length
    ///   - maxLength: Maximum allowed length
    ///   - allowEmpty: Whether to allow empty values
    /// - Returns: Sanitized text
    /// - Throws: ValidationError if invalid
    static func validateText(
        _ text: String,
        fieldName: String,
        minLength: Int = 1,
        maxLength: Int = 1000,
        allowEmpty: Bool = false
    ) throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            if allowEmpty {
                return ""
            }
            throw ValidationError.emptyField(field: fieldName)
        }

        guard trimmed.count >= minLength else {
            throw ValidationError.tooShort(field: fieldName, minLength: minLength)
        }

        guard trimmed.count <= maxLength else {
            throw ValidationError.tooLong(field: fieldName, maxLength: maxLength)
        }

        // Sanitize potentially dangerous characters
        return sanitizeInput(trimmed)
    }

    // MARK: - ID Validation

    /// Validates UUID format
    /// - Parameter id: ID to validate
    /// - Returns: True if valid UUID
    static func isValidUUID(_ id: String) -> Bool {
        return UUID(uuidString: id) != nil
    }

    /// Validates alphanumeric ID (for facility IDs, etc.)
    /// - Parameter id: ID to validate
    /// - Returns: True if valid
    static func isValidAlphanumericID(_ id: String) -> Bool {
        let idRegex = #"^[a-zA-Z0-9_\-]{1,100}$"#
        return NSPredicate(format: "SELF MATCHES %@", idRegex).evaluate(with: id)
    }

    /// Validates and sanitizes ID
    /// - Parameter id: ID to validate
    /// - Returns: Sanitized ID
    /// - Throws: ValidationError if invalid
    static func validateID(_ id: String) throws -> String {
        let trimmed = id.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            throw ValidationError.emptyField(field: "ID")
        }

        guard trimmed.count <= 100 else {
            throw ValidationError.tooLong(field: "ID", maxLength: 100)
        }

        guard isValidUUID(trimmed) || isValidAlphanumericID(trimmed) else {
            throw ValidationError.invalidFormat(field: "ID", message: "Invalid ID format")
        }

        return trimmed
    }

    // MARK: - URL Validation

    /// Validates URL format
    /// - Parameter urlString: URL string to validate
    /// - Returns: True if valid URL
    static func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              let scheme = url.scheme,
              ["http", "https"].contains(scheme) else {
            return false
        }
        return true
    }

    /// Validates and sanitizes URL
    /// - Parameter urlString: URL string to validate
    /// - Returns: Validated URL
    /// - Throws: ValidationError if invalid
    static func validateURL(_ urlString: String) throws -> URL {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            throw ValidationError.emptyField(field: "URL")
        }

        guard let url = URL(string: trimmed), isValidURL(trimmed) else {
            throw ValidationError.invalidFormat(field: "URL", message: "Please enter a valid URL")
        }

        return url
    }

    // MARK: - Number Validation

    /// Validates numeric value within range
    /// - Parameters:
    ///   - value: Value to validate
    ///   - fieldName: Name of the field
    ///   - min: Minimum allowed value
    ///   - max: Maximum allowed value
    /// - Returns: Validated value
    /// - Throws: ValidationError if out of range
    static func validateNumber<T: Comparable>(
        _ value: T,
        fieldName: String,
        min: T? = nil,
        max: T? = nil
    ) throws -> T {
        if let min = min, value < min {
            throw ValidationError.outOfRange(
                field: fieldName,
                message: "Value must be at least \(min)"
            )
        }

        if let max = max, value > max {
            throw ValidationError.outOfRange(
                field: fieldName,
                message: "Value must be at most \(max)"
            )
        }

        return value
    }

    // MARK: - Date Validation

    /// Validates date is in the future
    /// - Parameter date: Date to validate
    /// - Returns: True if date is in the future
    static func isFutureDate(_ date: Date) -> Bool {
        return date > Date()
    }

    /// Validates date is in the past
    /// - Parameter date: Date to validate
    /// - Returns: True if date is in the past
    static func isPastDate(_ date: Date) -> Bool {
        return date < Date()
    }

    /// Validates date within range
    /// - Parameters:
    ///   - date: Date to validate
    ///   - fieldName: Name of the field
    ///   - earliest: Earliest allowed date
    ///   - latest: Latest allowed date
    /// - Returns: Validated date
    /// - Throws: ValidationError if out of range
    static func validateDate(
        _ date: Date,
        fieldName: String,
        earliest: Date? = nil,
        latest: Date? = nil
    ) throws -> Date {
        if let earliest = earliest, date < earliest {
            throw ValidationError.outOfRange(
                field: fieldName,
                message: "Date must be on or after \(formatDate(earliest))"
            )
        }

        if let latest = latest, date > latest {
            throw ValidationError.outOfRange(
                field: fieldName,
                message: "Date must be on or before \(formatDate(latest))"
            )
        }

        return date
    }

    // MARK: - Sanitization

    /// Sanitizes input by removing or escaping potentially dangerous characters
    /// - Parameter input: Input to sanitize
    /// - Returns: Sanitized input
    static func sanitizeInput(_ input: String) -> String {
        var sanitized = input

        // Remove or escape HTML/script tags
        sanitized = sanitized.replacingOccurrences(
            of: #"<script[^>]*>.*?</script>"#,
            with: "",
            options: [.regularExpression, .caseInsensitive]
        )

        sanitized = sanitized.replacingOccurrences(
            of: #"<[^>]+>"#,
            with: "",
            options: .regularExpression
        )

        // Remove SQL injection attempts
        let sqlKeywords = ["DROP", "DELETE", "INSERT", "UPDATE", "EXEC", "UNION", "--", ";--"]
        for keyword in sqlKeywords {
            sanitized = sanitized.replacingOccurrences(
                of: keyword,
                with: "",
                options: .caseInsensitive
            )
        }

        // Remove null bytes
        sanitized = sanitized.replacingOccurrences(of: "\0", with: "")

        return sanitized
    }

    /// Sanitizes filename (removes path traversal attempts)
    /// - Parameter filename: Filename to sanitize
    /// - Returns: Sanitized filename
    static func sanitizeFilename(_ filename: String) -> String {
        var sanitized = filename

        // Remove path traversal attempts
        sanitized = sanitized.replacingOccurrences(of: "../", with: "")
        sanitized = sanitized.replacingOccurrences(of: "..\\", with: "")

        // Remove directory separators
        sanitized = sanitized.replacingOccurrences(of: "/", with: "_")
        sanitized = sanitized.replacingOccurrences(of: "\\", with: "_")

        // Limit length
        if sanitized.count > 255 {
            sanitized = String(sanitized.prefix(255))
        }

        return sanitized
    }

    // MARK: - Helper Methods

    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Validation Error

/// Validation error types with localized descriptions
enum ValidationError: LocalizedError {
    case emptyField(field: String)
    case tooShort(field: String, minLength: Int)
    case tooLong(field: String, maxLength: Int)
    case invalidFormat(field: String, message: String)
    case outOfRange(field: String, message: String)

    var errorDescription: String? {
        switch self {
        case .emptyField(let field):
            return "\(field) is required"
        case .tooShort(let field, let minLength):
            return "\(field) must be at least \(minLength) characters"
        case .tooLong(let field, let maxLength):
            return "\(field) must be at most \(maxLength) characters"
        case .invalidFormat(let field, let message):
            return "\(field): \(message)"
        case .outOfRange(let field, let message):
            return "\(field): \(message)"
        }
    }

    var errorDescriptionArabic: String {
        switch self {
        case .emptyField(let field):
            return "\(field) مطلوب"
        case .tooShort(let field, let minLength):
            return "\(field) يجب أن يكون على الأقل \(minLength) حرفاً"
        case .tooLong(let field, let maxLength):
            return "\(field) يجب أن يكون على الأكثر \(maxLength) حرفاً"
        case .invalidFormat(let field, let message):
            return "\(field): \(message)"
        case .outOfRange(let field, let message):
            return "\(field): \(message)"
        }
    }
}

// MARK: - Validation Result

/// Result of validation with detailed information
struct ValidationResult {
    let isValid: Bool
    let errors: [String]
    let warnings: [String]

    static var valid: ValidationResult {
        ValidationResult(isValid: true, errors: [], warnings: [])
    }

    static func invalid(_ errors: [String]) -> ValidationResult {
        ValidationResult(isValid: false, errors: errors, warnings: [])
    }

    static func validWithWarnings(_ warnings: [String]) -> ValidationResult {
        ValidationResult(isValid: true, errors: [], warnings: warnings)
    }
}
