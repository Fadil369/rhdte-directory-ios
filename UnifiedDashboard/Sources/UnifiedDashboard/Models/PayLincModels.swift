import Foundation

// MARK: - Payment Models

struct PaymentChannel: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: PaymentChannelType
    let status: ChannelStatus
    let balance: Decimal
    let transactions: Int
    let currency: String
    
    enum PaymentChannelType: String, Codable {
        case stripe, paypal, sarie, mada, alipayPlus
        
        var icon: String {
            switch self {
            case .stripe: return "creditcard.fill"
            case .paypal: return "dollarsign.circle.fill"
            case .sarie: return "arrow.left.arrow.right.circle.fill"
            case .mada: return "creditcard.circle.fill"
            case .alipayPlus: return "qrcode"
            }
        }
    }
    
    enum ChannelStatus: String, Codable {
        case active, inactive, error, maintenance
    }
}

struct Transaction: Identifiable, Codable {
    let id: String
    let paymentId: String
    let amount: Decimal
    let currency: String
    let paymentMethod: String
    let gateway: String
    let status: TransactionStatus
    let createdAt: Date
    let completedAt: Date?
    let description: String
    let metadata: [String: String]
    
    enum TransactionStatus: String, Codable {
        case pending, processing, completed, failed, cancelled, refunded
    }
}

// MARK: - Healthcare Models

struct HealthcarePayment: Identifiable, Codable {
    let id = UUID()
    let claimReference: String
    let nphiesClaimId: String?
    let patient: PatientInfo
    let provider: ProviderInfo
    let totalAmount: Decimal
    let patientShare: Decimal
    let insuranceShare: Decimal
    let approvedAmount: Decimal?
    let status: ClaimStatus
    let services: [HealthcareService]
    let paymentStatus: PaymentStatus
    let settlementStatus: SettlementStatus
    
    struct PatientInfo: Codable {
        let nationalId: String
        let nphiesId: String?
        let name: String
    }
    
    struct ProviderInfo: Codable {
        let license: String
        let nphiesId: String?
        let name: String
        let iban: String?
    }
    
    enum ClaimStatus: String, Codable {
        case submitted, approved, rejected, partial, paid
    }
    
    enum PaymentStatus: String, Codable {
        case pending, paid, failed
    }
    
    enum SettlementStatus: String, Codable {
        case pending, processing, settled, failed
    }
}

struct HealthcareService: Identifiable, Codable {
    let id = UUID()
    let code: String
    let description: String
    let amount: Decimal
    let patientShare: Decimal
    let insuranceShare: Decimal
    let approvalStatus: String
}

// MARK: - Murabaha BNPL Models

struct MurabahaAgreement: Identifiable {
    let id: String
    let userId: String
    let merchantName: String
    let itemDescription: String
    let costPrice: Decimal
    let sellingPrice: Decimal
    let markup: Decimal
    let markupRatio: Decimal
    let installmentCount: Int
    let installmentAmount: Decimal
    let paidInstallments: Int
    let totalPaid: Decimal
    let outstandingBalance: Decimal
    let status: AgreementStatus
    let nextPaymentDate: Date?
    let createdAt: Date
    let shariahCertified: Bool
    
    enum AgreementStatus: String {
        case pending, active, completed, defaulted, cancelled
    }
}

struct Installment: Identifiable {
    let id = UUID()
    let agreementId: String
    let installmentNumber: Int
    let amount: Decimal
    let dueDate: Date
    let status: InstallmentStatus
    let paidAt: Date?
    let daysLate: Int
    
    enum InstallmentStatus: String {
        case pending, paid, overdue, waived
    }
}

// MARK: - Wallet Models

struct Wallet: Identifiable {
    let id: String
    let userId: String
    let sarBalance: Decimal
    let usdBalance: Decimal
    let eurBalance: Decimal
    let gbpBalance: Decimal
    let aedBalance: Decimal
    let iban: String?
    let islamicDepositAccount: IslamicDeposit?
    let zakatEnabled: Bool
    let totalZakatPaid: Decimal
    let status: WalletStatus
    
    struct IslamicDeposit {
        let accountNumber: String
        let bankName: String
        let profitSharingRatio: Decimal
        let expectedProfit: Decimal
        let actualProfit: Decimal
    }
    
    enum WalletStatus: String {
        case active, frozen, closed
    }
}

// MARK: - Compliance Models

struct KYCVerification: Identifiable {
    let id = UUID()
    let userId: String
    let tier: KYCTier
    let nationalId: KYCDocument
    let biometric: BiometricVerification
    let address: AddressVerification?
    let riskScore: Int
    let accountLimits: AccountLimits
    
    enum KYCTier: Int {
        case basic = 1
        case standard = 2
        case premium = 3
        
        var description: String {
            switch self {
            case .basic: return "Basic (SAR 5,000/month)"
            case .standard: return "Standard (SAR 50,000/month)"
            case .premium: return "Premium (Unlimited)"
            }
        }
    }
    
    struct KYCDocument {
        let number: String
        let verified: Bool
        let expiryDate: Date
    }
    
    struct BiometricVerification {
        let selfieVerified: Bool
        let livenessCheck: Bool
    }
    
    struct AddressVerification {
        let verified: Bool
        let documentPath: String
    }
    
    struct AccountLimits {
        let dailyLimit: Decimal
        let monthlyLimit: Decimal
        let singleTransactionLimit: Decimal
    }
}

struct ShariahCompliance: Identifiable {
    let id = UUID()
    let entityType: String
    let entityId: String
    let compliant: Bool
    let certificationBoard: String
    let certificateNumber: String?
    let certificationDate: Date
    let expiryDate: Date?
    let violations: [String]
}

struct ZakatRecord: Identifiable {
    let id = UUID()
    let userId: String
    let hijriYear: Int
    let zakatableWealth: Decimal
    let nisabThreshold: Decimal
    let zakatDue: Decimal
    let paymentStatus: PaymentStatus
    let paidAt: Date?
    let charities: [CharityDisbursement]
    
    enum PaymentStatus: String {
        case pending, paid, exempted
    }
    
    struct CharityDisbursement {
        let name: String
        let amount: Decimal
    }
}

// MARK: - Dashboard Stats

struct PayLincStats {
    let totalTransactions: Int
    let totalVolume: Decimal
    let activePaymentChannels: Int
    let healthcareClaimsPending: Int
    let murabahaAgreementsActive: Int
    let walletBalance: Decimal
    let zakatDue: Decimal
    let complianceScore: Int
}
