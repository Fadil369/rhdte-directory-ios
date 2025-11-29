//
//  User.swift
//  Identity Models
//
//  Copyright © 2024 BrainSAIT. All rights reserved.
//

import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    let email: String
    let name: String
    let role: UserRole
    var organizationId: UUID?
    let createdAt: Date
    var lastLoginAt: Date?
    
    init(id: UUID = UUID(), email: String, name: String, role: UserRole, organizationId: UUID? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.role = role
        self.organizationId = organizationId
        self.createdAt = Date()
        self.lastLoginAt = nil
    }
}

struct Organization: Identifiable, Codable {
    let id: UUID
    let name: String
    let domain: String
    var settings: OrganizationSettings
    let createdAt: Date
    
    init(id: UUID = UUID(), name: String, domain: String) {
        self.id = id
        self.name = name
        self.domain = domain
        self.settings = OrganizationSettings()
        self.createdAt = Date()
    }
}

struct OrganizationSettings: Codable {
    var enabledAgents: [String] = []
    var billingEmail: String?
    var maxUsers: Int = 10
    var dataRetentionDays: Int = 90
}

struct ServiceAccount: Identifiable, Codable {
    let id: UUID
    let name: String
    let agentType: AgentType
    var isActive: Bool = true
    let apiKey: String
    let createdAt: Date
    
    init(id: UUID = UUID(), name: String, agentType: AgentType) {
        self.id = id
        self.name = name
        self.agentType = agentType
        self.apiKey = UUID().uuidString
        self.createdAt = Date()
    }
}
