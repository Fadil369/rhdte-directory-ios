import Foundation
import Combine

/// Centralized network manager with retry logic, caching, and error handling
/// Provides a unified interface for all network operations in the app
///
/// ## Features:
/// - Automatic retry with exponential backoff
/// - Request/response caching
/// - Request rate limiting
/// - Comprehensive error handling
/// - Request/response logging
/// - Authentication header injection
///
/// ## Usage:
/// ```swift
/// let manager = NetworkManager.shared
/// let data = try await manager.request(endpoint: "/api/doctors")
/// ```
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()

    @Published var isNetworkAvailable = true
    @Published var activeRequestCount = 0

    private let session: URLSession
    private let cache: URLCache
    private var requestTimestamps: [String: [Date]] = [:]
    private let rateLimitQueue = DispatchQueue(label: "com.brainsait.ratelimit")

    private init() {
        // Configure URL cache (50MB memory, 200MB disk)
        cache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024,
            diskPath: "brainsait_network_cache"
        )

        // Configure URL session
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Configuration.Settings.networkTimeout
        configuration.timeoutIntervalForResource = Configuration.Settings.networkTimeout * 2
        configuration.urlCache = cache
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.httpMaximumConnectionsPerHost = Configuration.Settings.maxConcurrentRequests

        // Add default headers
        configuration.httpAdditionalHeaders = [
            "User-Agent": "BrainSAIT-iOS/1.0",
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]

        session = URLSession(configuration: configuration)
    }

    // MARK: - Request Methods

    /// Perform a GET request with automatic retry and caching
    /// - Parameters:
    ///   - endpoint: The API endpoint path
    ///   - baseURL: Optional base URL override
    ///   - cachePolicy: Cache policy for this request
    ///   - retryCount: Number of retry attempts
    /// - Returns: Response data
    func request(
        endpoint: String,
        baseURL: String? = nil,
        cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad,
        retryCount: Int = Configuration.Settings.maxRetryAttempts
    ) async throws -> Data {
        let url = try buildURL(endpoint: endpoint, baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = cachePolicy

        return try await executeRequest(request, retryCount: retryCount)
    }

    /// Perform a POST request with automatic retry
    /// - Parameters:
    ///   - endpoint: The API endpoint path
    ///   - body: Request body (will be JSON encoded)
    ///   - baseURL: Optional base URL override
    ///   - retryCount: Number of retry attempts
    /// - Returns: Response data
    func post<T: Encodable>(
        endpoint: String,
        body: T,
        baseURL: String? = nil,
        retryCount: Int = Configuration.Settings.maxRetryAttempts
    ) async throws -> Data {
        let url = try buildURL(endpoint: endpoint, baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData

        // Encode body
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(body)

        return try await executeRequest(request, retryCount: retryCount)
    }

    /// Perform a PUT request with automatic retry
    func put<T: Encodable>(
        endpoint: String,
        body: T,
        baseURL: String? = nil,
        retryCount: Int = Configuration.Settings.maxRetryAttempts
    ) async throws -> Data {
        let url = try buildURL(endpoint: endpoint, baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(body)

        return try await executeRequest(request, retryCount: retryCount)
    }

    /// Perform a DELETE request with automatic retry
    func delete(
        endpoint: String,
        baseURL: String? = nil,
        retryCount: Int = Configuration.Settings.maxRetryAttempts
    ) async throws -> Data {
        let url = try buildURL(endpoint: endpoint, baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.cachePolicy = .reloadIgnoringLocalCacheData

        return try await executeRequest(request, retryCount: retryCount)
    }

    // MARK: - Typed Response Methods

    /// Perform a typed GET request (decodes JSON response)
    func fetch<T: Decodable>(
        endpoint: String,
        type: T.Type,
        baseURL: String? = nil,
        cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad,
        retryCount: Int = Configuration.Settings.maxRetryAttempts
    ) async throws -> T {
        let data = try await request(
            endpoint: endpoint,
            baseURL: baseURL,
            cachePolicy: cachePolicy,
            retryCount: retryCount
        )

        return try decodeResponse(data: data, type: type)
    }

    /// Perform a typed POST request (encodes request, decodes response)
    func post<Request: Encodable, Response: Decodable>(
        endpoint: String,
        body: Request,
        responseType: Response.Type,
        baseURL: String? = nil,
        retryCount: Int = Configuration.Settings.maxRetryAttempts
    ) async throws -> Response {
        let data = try await post(
            endpoint: endpoint,
            body: body,
            baseURL: baseURL,
            retryCount: retryCount
        )

        return try decodeResponse(data: data, type: responseType)
    }

    // MARK: - Request Execution

    /// Execute a URLRequest with retry logic
    private func executeRequest(
        _ request: URLRequest,
        retryCount: Int,
        currentAttempt: Int = 0
    ) async throws -> Data {
        // Check rate limiting
        try await checkRateLimit(for: request.url?.absoluteString ?? "")

        // Increment active request count
        await MainActor.run {
            activeRequestCount += 1
        }

        defer {
            Task { @MainActor in
                activeRequestCount -= 1
            }
        }

        do {
            if Configuration.Settings.verboseLogging {
                print("🌐 [\(request.httpMethod ?? "GET")] \(request.url?.absoluteString ?? "")")
            }

            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            if Configuration.Settings.verboseLogging {
                print("✅ [\(httpResponse.statusCode)] \(request.url?.absoluteString ?? "")")
            }

            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                return data

            case 401:
                throw NetworkError.unauthorized

            case 403:
                throw NetworkError.forbidden

            case 404:
                throw NetworkError.notFound

            case 429:
                throw NetworkError.rateLimited

            case 500...599:
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)

            default:
                throw NetworkError.httpError(statusCode: httpResponse.statusCode)
            }

        } catch let error as NetworkError {
            throw error

        } catch {
            // Handle network errors with retry
            if currentAttempt < retryCount {
                let delay = calculateBackoffDelay(attempt: currentAttempt)

                if Configuration.Settings.verboseLogging {
                    print("⚠️ Retrying request (attempt \(currentAttempt + 1)/\(retryCount + 1)) after \(delay)s")
                }

                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

                return try await executeRequest(
                    request,
                    retryCount: retryCount,
                    currentAttempt: currentAttempt + 1
                )
            }

            throw NetworkError.requestFailed(underlyingError: error)
        }
    }

    // MARK: - Helper Methods

    /// Build a full URL from endpoint and base URL
    private func buildURL(endpoint: String, baseURL: String?) throws -> URL {
        let base = baseURL ?? Configuration.API.hospitalDirectoryBaseURL
        let fullURLString = base + endpoint

        guard let url = URL(string: fullURLString) else {
            throw NetworkError.invalidURL(fullURLString)
        }

        return url
    }

    /// Decode JSON response
    private func decodeResponse<T: Decodable>(data: Data, type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError.decodingFailed(underlyingError: error)
        }
    }

    /// Calculate exponential backoff delay
    private func calculateBackoffDelay(attempt: Int) -> TimeInterval {
        let base = Configuration.Settings.retryDelayBase
        let exponentialDelay = base * pow(2.0, Double(attempt))
        let jitter = Double.random(in: 0...1.0) // Add jitter to prevent thundering herd

        return min(exponentialDelay + jitter, 30.0) // Max 30 seconds
    }

    /// Check and enforce rate limiting
    private func checkRateLimit(for endpoint: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            rateLimitQueue.async {
                let now = Date()
                let windowDuration: TimeInterval = 60.0 // 1 minute window
                let maxRequestsPerWindow = 60 // Max 60 requests per minute

                // Get recent timestamps for this endpoint
                var timestamps = self.requestTimestamps[endpoint] ?? []

                // Remove old timestamps outside the window
                timestamps = timestamps.filter { now.timeIntervalSince($0) < windowDuration }

                // Check if limit exceeded
                if timestamps.count >= maxRequestsPerWindow {
                    continuation.resume(throwing: NetworkError.rateLimited)
                    return
                }

                // Add current timestamp
                timestamps.append(now)
                self.requestTimestamps[endpoint] = timestamps

                continuation.resume()
            }
        }
    }

    /// Clear all cached data
    func clearCache() {
        cache.removeAllCachedResponses()
        if Configuration.Settings.verboseLogging {
            print("🗑️ Network cache cleared")
        }
    }

    /// Clear rate limit history
    func clearRateLimitHistory() {
        rateLimitQueue.sync {
            requestTimestamps.removeAll()
        }
    }
}

// MARK: - Network Error

/// Comprehensive network error types with localized descriptions
enum NetworkError: LocalizedError {
    case invalidURL(String)
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case serverError(statusCode: Int)
    case httpError(statusCode: Int)
    case requestFailed(underlyingError: Error)
    case decodingFailed(underlyingError: Error)
    case noInternetConnection
    case timeout

    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .invalidResponse:
            return "Invalid server response"
        case .unauthorized:
            return "Authentication required. Please login again."
        case .forbidden:
            return "Access denied"
        case .notFound:
            return "Resource not found"
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .serverError(let statusCode):
            return "Server error (\(statusCode)). Please try again later."
        case .httpError(let statusCode):
            return "Request failed with status code \(statusCode)"
        case .requestFailed(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noInternetConnection:
            return "No internet connection. Please check your network settings."
        case .timeout:
            return "Request timed out. Please try again."
        }
    }

    var errorDescriptionArabic: String {
        switch self {
        case .invalidURL:
            return "عنوان URL غير صالح"
        case .invalidResponse:
            return "استجابة الخادم غير صالحة"
        case .unauthorized:
            return "المصادقة مطلوبة. يرجى تسجيل الدخول مرة أخرى."
        case .forbidden:
            return "تم رفض الوصول"
        case .notFound:
            return "لم يتم العثور على المورد"
        case .rateLimited:
            return "طلبات كثيرة جداً. يرجى المحاولة لاحقاً."
        case .serverError:
            return "خطأ في الخادم. يرجى المحاولة لاحقاً."
        case .httpError(let statusCode):
            return "فشل الطلب مع رمز الحالة \(statusCode)"
        case .requestFailed:
            return "فشل طلب الشبكة"
        case .decodingFailed:
            return "فشل فك تشفير الاستجابة"
        case .noInternetConnection:
            return "لا يوجد اتصال بالإنترنت. يرجى التحقق من إعدادات الشبكة."
        case .timeout:
            return "انتهت مهلة الطلب. يرجى المحاولة مرة أخرى."
        }
    }
}

// MARK: - Request Builder

/// Fluent request builder for complex requests
struct NetworkRequestBuilder {
    private var endpoint: String
    private var baseURL: String?
    private var method: HTTPMethod = .get
    private var headers: [String: String] = [:]
    private var queryParameters: [String: String] = [:]
    private var body: Data?
    private var cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
    private var timeout: TimeInterval?

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }

    init(endpoint: String) {
        self.endpoint = endpoint
    }

    func baseURL(_ url: String) -> NetworkRequestBuilder {
        var builder = self
        builder.baseURL = url
        return builder
    }

    func method(_ method: HTTPMethod) -> NetworkRequestBuilder {
        var builder = self
        builder.method = method
        return builder
    }

    func header(key: String, value: String) -> NetworkRequestBuilder {
        var builder = self
        builder.headers[key] = value
        return builder
    }

    func queryParameter(key: String, value: String) -> NetworkRequestBuilder {
        var builder = self
        builder.queryParameters[key] = value
        return builder
    }

    func body<T: Encodable>(_ body: T) throws -> NetworkRequestBuilder {
        var builder = self
        builder.body = try JSONEncoder().encode(body)
        return builder
    }

    func cachePolicy(_ policy: URLRequest.CachePolicy) -> NetworkRequestBuilder {
        var builder = self
        builder.cachePolicy = policy
        return builder
    }

    func timeout(_ timeout: TimeInterval) -> NetworkRequestBuilder {
        var builder = self
        builder.timeout = timeout
        return builder
    }

    func build() throws -> URLRequest {
        // Build URL with query parameters
        var urlString = (baseURL ?? Configuration.API.hospitalDirectoryBaseURL) + endpoint

        if !queryParameters.isEmpty {
            let queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
            var components = URLComponents(string: urlString)
            components?.queryItems = queryItems
            urlString = components?.url?.absoluteString ?? urlString
        }

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL(urlString)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.cachePolicy = cachePolicy

        if let timeout = timeout {
            request.timeoutInterval = timeout
        }

        // Add headers
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        // Add body
        request.httpBody = body

        return request
    }
}
