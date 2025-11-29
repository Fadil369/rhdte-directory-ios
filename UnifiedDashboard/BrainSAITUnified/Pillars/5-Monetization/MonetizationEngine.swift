//
//  MonetizationEngine.swift
//  Pillar 5: Delivery & Monetization Layer
//
//  The Economic Engine - ClaimLinc First
//
//  Copyright © 2024 BrainSAIT. All rights reserved.
//

import Foundation

/// Pillar 5: Delivery & Monetization Layer
class MonetizationEngine {
    
    private let config: MonetizationConfiguration
    private var funnelManager: FunnelManager?
    private var pricingEngine: PricingEngine?
    private var leads: [UUID: Lead] = [:]
    private var customers: [UUID: Customer] = [:]
    
    init(config: MonetizationConfiguration) {
        self.config = config
        print("💰 Monetization Engine Created")
    }
    
    func initialize() async throws {
        print("💰 Initializing Monetization Engine...")
        
        // Initialize funnel manager
        funnelManager = FunnelManager(funnelURL: config.funnelURL)
        try await funnelManager?.initialize()
        
        // Initialize pricing engine
        pricingEngine = PricingEngine(model: config.pricingModel)
        
        print("💰 Monetization Engine Initialized - Focus: \(config.primaryProduct)")
    }
    
    func shutdown() async {
        await funnelManager?.shutdown()
        leads.removeAll()
        customers.removeAll()
        print("💰 Monetization Engine Shutdown")
    }
    
    func getHealthStatus() async -> HealthStatus {
        return .healthy
    }
    
    // MARK: - Lead Management
    
    func captureLeadFromIntake(formData: [String: String]) async throws -> Lead {
        let lead = Lead(
            name: formData["name"] ?? "",
            email: formData["email"] ?? "",
            company: formData["company"],
            phone: formData["phone"],
            interest: formData["interest"] ?? "ClaimLinc",
            source: .webForm,
            status: .new
        )
        
        leads[lead.id] = lead
        
        // Trigger lead nurturing workflow
        try await nurtureLead(lead)
        
        print("💰 New lead captured: \(lead.name) - Interest: \(lead.interest)")
        return lead
    }
    
    func qualifyLead(_ leadId: UUID) async throws -> LeadQualification {
        guard let lead = leads[leadId] else {
            throw MonetizationError.leadNotFound
        }
        
        // Qualify lead based on criteria
        let qualification = LeadQualification(
            leadId: lead.id,
            score: calculateLeadScore(lead),
            qualifiedFor: determineProductFit(lead),
            recommendedPlan: suggestPlan(for: lead)
        )
        
        return qualification
    }
    
    func convertLeadToCustomer(_ leadId: UUID, plan: PricingPlan) async throws -> Customer {
        guard let lead = leads[leadId] else {
            throw MonetizationError.leadNotFound
        }
        
        let customer = Customer(
            name: lead.name,
            email: lead.email,
            company: lead.company,
            plan: plan,
            status: .active,
            convertedFrom: leadId
        )
        
        customers[customer.id] = customer
        leads[leadId]?.status = .converted
        
        print("💰 Lead converted to customer: \(customer.name) - Plan: \(plan.name)")
        return customer
    }
    
    // MARK: - Pricing & Offers
    
    func getClaimLincPricing() -> [PricingPlan] {
        guard let pricing = pricingEngine else { return [] }
        return pricing.getClaimLincPlans()
    }
    
    func getSMEDigitalEnablementPricing() -> [PricingPlan] {
        guard let pricing = pricingEngine else { return [] }
        return pricing.getSMEPlans()
    }
    
    func calculateCustomQuote(requirements: [String: Any]) async -> CustomQuote {
        // Generate custom quote based on requirements
        let basePrice = requirements["volumeEstimate"] as? Double ?? 0.0
        let features = requirements["features"] as? [String] ?? []
        
        return CustomQuote(
            basePrice: basePrice,
            features: features,
            estimatedMRR: basePrice * 1.2,
            validUntil: Date().addingTimeInterval(30 * 24 * 3600)
        )
    }
    
    // MARK: - Revenue Tracking
    
    func getMonthlyRecurringRevenue() async -> Double {
        return customers.values
            .filter { $0.status == .active }
            .reduce(0.0) { $0 + $1.plan.monthlyPrice }
    }
    
    func getAnnualRecurringRevenue() async -> Double {
        await getMonthlyRecurringRevenue() * 12
    }
    
    // MARK: - Private Methods
    
    private func nurtureLead(_ lead: Lead) async throws {
        // Trigger automated lead nurturing via Automation Spine
        print("💰 Starting lead nurturing for: \(lead.name)")
    }
    
    private func calculateLeadScore(_ lead: Lead) -> Int {
        var score = 0
        
        // Company provided
        if lead.company != nil { score += 20 }
        
        // Phone provided
        if lead.phone != nil { score += 15 }
        
        // Interest in ClaimLinc (our primary product)
        if lead.interest == "ClaimLinc" { score += 30 }
        
        // Healthcare sector
        if lead.company?.lowercased().contains("health") ?? false { score += 35 }
        
        return min(score, 100)
    }
    
    private func determineProductFit(_ lead: Lead) -> [String] {
        var products: [String] = []
        
        if lead.interest.contains("Claim") || lead.interest.contains("Healthcare") {
            products.append("ClaimLinc")
        }
        
        if lead.company != nil {
            products.append("Digital Enablement")
        }
        
        return products
    }
    
    private func suggestPlan(for lead: Lead) -> PricingPlan {
        // Suggest appropriate plan based on lead profile
        return getClaimLincPricing().first ?? PricingPlan.claimLincStarter()
    }
}

// MARK: - Funnel Manager

class FunnelManager {
    private let funnelURL: String
    
    init(funnelURL: String) {
        self.funnelURL = funnelURL
    }
    
    func initialize() async throws {
        print("💰 Initializing funnel at: \(funnelURL)")
    }
    
    func shutdown() async {
        print("💰 Funnel manager shutdown")
    }
}

// MARK: - Pricing Engine

class PricingEngine {
    private let model: String
    
    init(model: String) {
        self.model = model
    }
    
    func getClaimLincPlans() -> [PricingPlan] {
        [
            PricingPlan.claimLincStarter(),
            PricingPlan.claimLincProfessional(),
            PricingPlan.claimLincEnterprise()
        ]
    }
    
    func getSMEPlans() -> [PricingPlan] {
        [
            PricingPlan.smeBasic(),
            PricingPlan.smeGrowth(),
            PricingPlan.smeScale()
        ]
    }
}

// MARK: - Supporting Types

struct Lead {
    let id: UUID = UUID()
    let name: String
    let email: String
    let company: String?
    let phone: String?
    let interest: String
    let source: LeadSource
    var status: LeadStatus
    let createdAt: Date = Date()
}

enum LeadSource {
    case webForm
    case referral
    case voiceLinc
    case mapLinc
    case event
}

enum LeadStatus {
    case new
    case contacted
    case qualified
    case proposal
    case negotiation
    case converted
    case lost
}

struct LeadQualification {
    let leadId: UUID
    let score: Int
    let qualifiedFor: [String]
    let recommendedPlan: PricingPlan
}

struct Customer {
    let id: UUID = UUID()
    let name: String
    let email: String
    let company: String?
    let plan: PricingPlan
    var status: CustomerStatus
    let convertedFrom: UUID
    let createdAt: Date = Date()
}

enum CustomerStatus {
    case active
    case paused
    case churned
}

struct PricingPlan {
    let id: UUID = UUID()
    let name: String
    let description: String
    let monthlyPrice: Double
    let features: [String]
    let limits: [String: Int]
    
    // ClaimLinc Plans
    static func claimLincStarter() -> PricingPlan {
        PricingPlan(
            name: "ClaimLinc Starter",
            description: "Perfect for small clinics",
            monthlyPrice: 299.0,
            features: ["Up to 100 claims/month", "NPHIES integration", "Email support"],
            limits: ["claims": 100]
        )
    }
    
    static func claimLincProfessional() -> PricingPlan {
        PricingPlan(
            name: "ClaimLinc Professional",
            description: "For growing healthcare facilities",
            monthlyPrice: 799.0,
            features: ["Up to 500 claims/month", "NPHIES integration", "Priority support", "Analytics"],
            limits: ["claims": 500]
        )
    }
    
    static func claimLincEnterprise() -> PricingPlan {
        PricingPlan(
            name: "ClaimLinc Enterprise",
            description: "For hospitals and large facilities",
            monthlyPrice: 2499.0,
            features: ["Unlimited claims", "NPHIES integration", "24/7 support", "Advanced analytics", "Custom workflows"],
            limits: ["claims": -1]
        )
    }
    
    // SME Digital Enablement Plans
    static func smeBasic() -> PricingPlan {
        PricingPlan(
            name: "SME Basic",
            description: "Essential digital tools",
            monthlyPrice: 199.0,
            features: ["3 automated workflows", "Basic AI agents", "Email support"],
            limits: ["workflows": 3]
        )
    }
    
    static func smeGrowth() -> PricingPlan {
        PricingPlan(
            name: "SME Growth",
            description: "Scale your operations",
            monthlyPrice: 499.0,
            features: ["10 automated workflows", "All AI agents", "Priority support", "Analytics"],
            limits: ["workflows": 10]
        )
    }
    
    static func smeScale() -> PricingPlan {
        PricingPlan(
            name: "SME Scale",
            description: "Full digital transformation",
            monthlyPrice: 999.0,
            features: ["Unlimited workflows", "All AI agents", "24/7 support", "Custom integrations"],
            limits: ["workflows": -1]
        )
    }
}

struct CustomQuote {
    let basePrice: Double
    let features: [String]
    let estimatedMRR: Double
    let validUntil: Date
}

enum MonetizationError: LocalizedError {
    case leadNotFound
    case invalidPlan
    case paymentFailed
    
    var errorDescription: String? {
        switch self {
        case .leadNotFound: return "Lead not found"
        case .invalidPlan: return "Invalid pricing plan"
        case .paymentFailed: return "Payment processing failed"
        }
    }
}
