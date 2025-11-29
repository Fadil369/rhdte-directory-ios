//
//  Document.swift
//  Knowledge Models
//
//  Copyright © 2024 BrainSAIT. All rights reserved.
//

import Foundation

struct Document: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    let domain: KnowledgeDomain
    var tags: [String]
    let author: String
    var metadata: [String: String]
    let createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), title: String, content: String, domain: KnowledgeDomain, tags: [String] = [], author: String) {
        self.id = id
        self.title = title
        self.content = content
        self.domain = domain
        self.tags = tags
        self.author = author
        self.metadata = [
            "domain": domain.rawValue,
            "author": author,
            "wordCount": "\(content.split(separator: " ").count)"
        ]
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum KnowledgeDomain: String, Codable, CaseIterable {
    case healthcare = "Healthcare"
    case business = "Business"
    case tech = "Tech"
    case content = "Content"
    
    var icon: String {
        switch self {
        case .healthcare: return "cross.case.fill"
        case .business: return "briefcase.fill"
        case .tech: return "laptopcomputer"
        case .content: return "text.book.closed.fill"
        }
    }
}

struct KnowledgeResult: Identifiable {
    let id = UUID()
    let document: Document
    let relevanceScore: Float
    let snippet: String
}

struct HealthcareClaim: Codable {
    let id: UUID
    let patientId: String
    let providerId: String
    let serviceDate: Date
    let services: [ClaimService]
    let totalAmount: Double
    var status: ClaimStatus
    
    init(id: UUID = UUID(), patientId: String, providerId: String, serviceDate: Date, services: [ClaimService], totalAmount: Double) {
        self.id = id
        self.patientId = patientId
        self.providerId = providerId
        self.serviceDate = serviceDate
        self.services = services
        self.totalAmount = totalAmount
        self.status = .pending
    }
}

struct ClaimService: Codable {
    let code: String
    let description: String
    let quantity: Int
    let unitPrice: Double
}

enum ClaimStatus: String, Codable {
    case pending = "Pending"
    case submitted = "Submitted"
    case approved = "Approved"
    case rejected = "Rejected"
    case paid = "Paid"
}

struct ClaimResult {
    let claimId: UUID
    let status: ClaimStatus
    let approvedAmount: Double?
    let rejectionReason: String?
    let processedAt: Date
}
