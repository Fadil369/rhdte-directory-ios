import Foundation

@MainActor
class PayLincAPIClient: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var stats: PayLincStats?
    
    private let baseURL: String
    private let apiKey: String
    
    init(baseURL: String = "https://api.paylinc.sa", apiKey: String = "") {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
    
    // MARK: - Authentication
    
    func authenticate() async throws {
        // Implement OAuth2 or JWT authentication
        isConnected = true
    }
    
    // MARK: - Transactions
    
    func fetchTransactions(limit: Int = 50) async throws -> [Transaction] {
        let url = URL(string: "\(baseURL)/api/v1/payments")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        // Parse response
        return try decoder.decode([Transaction].self, from: data)
    }
    
    func getTransaction(paymentId: String) async throws -> Transaction {
        let url = URL(string: "\(baseURL)/api/v1/payments/\(paymentId)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(Transaction.self, from: data)
    }
    
    // MARK: - Payment Channels
    
    func fetchPaymentChannels() async throws -> [PaymentChannel] {
        // Mock data for now
        return [
            PaymentChannel(
                name: "Stripe",
                type: .stripe,
                status: .active,
                balance: 12450.00,
                transactions: 156,
                currency: "SAR"
            ),
            PaymentChannel(
                name: "PayPal",
                type: .paypal,
                status: .active,
                balance: 8230.50,
                transactions: 89,
                currency: "SAR"
            ),
            PaymentChannel(
                name: "SARIE",
                type: .sarie,
                status: .active,
                balance: 23890.00,
                transactions: 34,
                currency: "SAR"
            ),
            PaymentChannel(
                name: "Mada",
                type: .mada,
                status: .active,
                balance: 5670.25,
                transactions: 45,
                currency: "SAR"
            ),
        ]
    }
    
    // MARK: - Healthcare Payments
    
    func fetchHealthcarePayments() async throws -> [HealthcarePayment] {
        let url = URL(string: "\(baseURL)/api/v1/healthcare/claims")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Mock data
        return [
            HealthcarePayment(
                claimReference: "NPHIES-2024-001",
                nphiesClaimId: "CLM-123456",
                patient: .init(nationalId: "1234567890", nphiesId: "PAT-001", name: "Ahmed Al-Zahrani"),
                provider: .init(license: "PROV-KFSH-001", nphiesId: "PRV-001", name: "King Faisal Specialist Hospital", iban: "SA0380000000608010167519"),
                totalAmount: 5000.00,
                patientShare: 500.00,
                insuranceShare: 4500.00,
                approvedAmount: 4500.00,
                status: .approved,
                services: [
                    HealthcareService(code: "99213", description: "Office Visit", amount: 300.00, patientShare: 30.00, insuranceShare: 270.00, approvalStatus: "approved"),
                    HealthcareService(code: "85025", description: "Blood Count", amount: 200.00, patientShare: 20.00, insuranceShare: 180.00, approvalStatus: "approved"),
                ],
                paymentStatus: .paid,
                settlementStatus: .settled
            ),
        ]
    }
    
    func getClaimStatus(claimReference: String) async throws -> HealthcarePayment {
        let url = URL(string: "\(baseURL)/api/v1/healthcare/claims/\(claimReference)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(HealthcarePayment.self, from: data)
    }
    
    // MARK: - Murabaha BNPL
    
    func fetchMurabahaAgreements() async throws -> [MurabahaAgreement] {
        // Mock data
        return [
            MurabahaAgreement(
                id: "MUR-001",
                userId: "user-123",
                merchantName: "Extra Electronics",
                itemDescription: "iPhone 15 Pro Max",
                costPrice: 4500.00,
                sellingPrice: 4950.00,
                markup: 450.00,
                markupRatio: 0.10,
                installmentCount: 6,
                installmentAmount: 825.00,
                paidInstallments: 2,
                totalPaid: 1650.00,
                outstandingBalance: 3300.00,
                status: .active,
                nextPaymentDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
                createdAt: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
                shariahCertified: true
            ),
        ]
    }
    
    // MARK: - Wallet
    
    func fetchWallet() async throws -> Wallet {
        let url = URL(string: "\(baseURL)/api/v1/wallet")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Mock data
        return Wallet(
            id: "wallet-001",
            userId: "user-123",
            sarBalance: 15780.50,
            usdBalance: 1234.00,
            eurBalance: 850.00,
            gbpBalance: 620.00,
            aedBalance: 3200.00,
            iban: "SA0380000000608010167519",
            islamicDepositAccount: .init(
                accountNumber: "1234567890",
                bankName: "Al Rajhi Bank",
                profitSharingRatio: 0.60,
                expectedProfit: 145.50,
                actualProfit: 152.30
            ),
            zakatEnabled: true,
            totalZakatPaid: 395.00,
            status: .active
        )
    }
    
    // MARK: - Compliance
    
    func fetchKYCStatus() async throws -> KYCVerification {
        // Mock data
        return KYCVerification(
            userId: "user-123",
            tier: .standard,
            nationalId: .init(number: "1234567890", verified: true, expiryDate: Date().addingTimeInterval(365*24*60*60)),
            biometric: .init(selfieVerified: true, livenessCheck: true),
            address: .init(verified: true, documentPath: "kyc/address-proof.pdf"),
            riskScore: 25,
            accountLimits: .init(dailyLimit: 20000, monthlyLimit: 50000, singleTransactionLimit: 10000)
        )
    }
    
    func fetchZakatRecords() async throws -> [ZakatRecord] {
        // Mock data
        let hijriCalendar = Calendar(identifier: .islamicUmmAlQura)
        let currentYear = hijriCalendar.component(.year, from: Date())
        
        return [
            ZakatRecord(
                userId: "user-123",
                hijriYear: currentYear,
                zakatableWealth: 85000.00,
                nisabThreshold: 19550.00,
                zakatDue: 2125.00,
                paymentStatus: .pending,
                paidAt: nil,
                charities: []
            ),
        ]
    }
    
    // MARK: - Dashboard Stats
    
    func fetchDashboardStats() async throws -> PayLincStats {
        return PayLincStats(
            totalTransactions: 1247,
            totalVolume: 450780.50,
            activePaymentChannels: 4,
            healthcareClaimsPending: 12,
            murabahaAgreementsActive: 3,
            walletBalance: 15780.50,
            zakatDue: 2125.00,
            complianceScore: 98
        )
    }
}

// MARK: - Mock Data Extension

extension Transaction {
    static func mockTransactions() -> [Transaction] {
        return [
            Transaction(
                id: "tx-001",
                paymentId: "PAY-001",
                amount: 500.00,
                currency: "SAR",
                paymentMethod: "card",
                gateway: "stripe",
                status: .completed,
                createdAt: Date().addingTimeInterval(-3600),
                completedAt: Date().addingTimeInterval(-3500),
                description: "Healthcare co-payment",
                metadata: ["claim_id": "NPHIES-001"]
            ),
            Transaction(
                id: "tx-002",
                paymentId: "PAY-002",
                amount: 1250.00,
                currency: "SAR",
                paymentMethod: "sarie",
                gateway: "sarie",
                status: .completed,
                createdAt: Date().addingTimeInterval(-7200),
                completedAt: Date().addingTimeInterval(-7100),
                description: "Provider settlement",
                metadata: ["provider": "KFSH"]
            ),
        ]
    }
}
