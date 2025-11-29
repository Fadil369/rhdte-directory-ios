//
//  DOS.swift
//  BrainSAIT Digital Operating System
//
//  The Core Orchestrator - "One Brain, Many Agents"
//
//  Copyright © 2024 BrainSAIT. All rights reserved.
//

import Foundation
import SwiftUI

/// The Digital Operating System - Central intelligence coordinating all pillars
@MainActor
class DOS: ObservableObject {
    
    // MARK: - Singleton Instance
    static let shared = DOS()
    
    // MARK: - The Five Pillars
    
    /// Pillar 1: Unified Identity & Access Layer
    let identityManager: IdentityManager
    
    /// Pillar 2: Central Knowledge + Memory System
    let knowledgeHub: KnowledgeHub
    
    /// Pillar 3: Workflow Automation Spine
    let automationSpine: AutomationSpine
    
    /// Pillar 4: Agent-Oriented Architecture
    let agentOrchestrator: AgentOrchestrator
    
    /// Pillar 5: Delivery & Monetization Layer
    let monetizationEngine: MonetizationEngine
    
    // MARK: - System State
    @Published var systemStatus: SystemStatus = .initializing
    @Published var activeAgents: [AgentType] = []
    @Published var systemHealth: SystemHealth
    
    // MARK: - Configuration
    private let configuration: DOSConfiguration
    
    // MARK: - Initialization
    private init() {
        self.configuration = DOSConfiguration.load()
        
        // Initialize the five pillars in order
        self.identityManager = IdentityManager(config: configuration.identity)
        self.knowledgeHub = KnowledgeHub(config: configuration.knowledge)
        self.automationSpine = AutomationSpine(config: configuration.automation)
        self.agentOrchestrator = AgentOrchestrator(config: configuration.agents)
        self.monetizationEngine = MonetizationEngine(config: configuration.monetization)
        
        self.systemHealth = SystemHealth()
        
        print("🧠 DOS Initialized - One Brain, Many Agents")
    }
    
    // MARK: - System Lifecycle
    
    /// Start the Digital Operating System
    func start() async throws {
        systemStatus = .starting
        
        print("🚀 Starting BrainSAIT Digital Operating System...")
        
        // Phase 1: Authenticate and establish identity
        try await identityManager.initialize()
        print("✅ Pillar 1: Identity Layer Online")
        
        // Phase 2: Load knowledge base
        try await knowledgeHub.initialize()
        print("✅ Pillar 2: Knowledge Hub Online")
        
        // Phase 3: Connect automation spine
        try await automationSpine.initialize()
        print("✅ Pillar 3: Automation Spine Online")
        
        // Phase 4: Activate agents
        try await agentOrchestrator.initialize()
        activeAgents = agentOrchestrator.getActiveAgents()
        print("✅ Pillar 4: Agents Online (\(activeAgents.count) active)")
        
        // Phase 5: Enable monetization
        try await monetizationEngine.initialize()
        print("✅ Pillar 5: Monetization Engine Online")
        
        // Start health monitoring
        startHealthMonitoring()
        
        systemStatus = .running
        print("🎉 DOS is now RUNNING - All systems operational")
    }
    
    /// Stop the Digital Operating System
    func stop() async {
        systemStatus = .stopping
        
        await monetizationEngine.shutdown()
        await agentOrchestrator.shutdown()
        await automationSpine.shutdown()
        await knowledgeHub.shutdown()
        await identityManager.shutdown()
        
        systemStatus = .stopped
        activeAgents = []
        print("⏹️ DOS Stopped")
    }
    
    // MARK: - Health Monitoring
    
    private func startHealthMonitoring() {
        Task {
            while systemStatus == .running {
                await updateSystemHealth()
                try? await Task.sleep(for: .seconds(30))
            }
        }
    }
    
    private func updateSystemHealth() async {
        systemHealth.identity = await identityManager.getHealthStatus()
        systemHealth.knowledge = await knowledgeHub.getHealthStatus()
        systemHealth.automation = await automationSpine.getHealthStatus()
        systemHealth.agents = await agentOrchestrator.getHealthStatus()
        systemHealth.monetization = await monetizationEngine.getHealthStatus()
        
        systemHealth.lastCheck = Date()
        
        // Update system status based on health
        if systemHealth.overall == .critical {
            systemStatus = .error
        } else if systemHealth.overall == .degraded {
            systemStatus = .degraded
        }
    }
}

// MARK: - System Status

enum SystemStatus: String {
    case initializing = "Initializing"
    case starting = "Starting"
    case running = "Running"
    case degraded = "Degraded"
    case stopping = "Stopping"
    case stopped = "Stopped"
    case error = "Error"
    
    var color: Color {
        switch self {
        case .running: return .green
        case .degraded: return .yellow
        case .error: return .red
        default: return .gray
        }
    }
}

// MARK: - System Health

struct SystemHealth {
    var identity: HealthStatus = .unknown
    var knowledge: HealthStatus = .unknown
    var automation: HealthStatus = .unknown
    var agents: HealthStatus = .unknown
    var monetization: HealthStatus = .unknown
    var lastCheck: Date = Date()
    
    var overall: HealthStatus {
        let statuses = [identity, knowledge, automation, agents, monetization]
        if statuses.contains(.critical) { return .critical }
        if statuses.contains(.degraded) { return .degraded }
        if statuses.allSatisfy({ $0 == .healthy }) { return .healthy }
        return .unknown
    }
}

enum HealthStatus: String {
    case healthy = "Healthy"
    case degraded = "Degraded"
    case critical = "Critical"
    case unknown = "Unknown"
    
    var color: Color {
        switch self {
        case .healthy: return .green
        case .degraded: return .yellow
        case .critical: return .red
        case .unknown: return .gray
        }
    }
}

// MARK: - DOS Configuration

struct DOSConfiguration: Codable {
    let identity: IdentityConfiguration
    let knowledge: KnowledgeConfiguration
    let automation: AutomationConfiguration
    let agents: AgentConfiguration
    let monetization: MonetizationConfiguration
    let environment: Environment
    
    enum Environment: String, Codable {
        case development
        case staging
        case production
    }
    
    static func load() -> DOSConfiguration {
        // Load from configuration file or use defaults
        return DOSConfiguration(
            identity: IdentityConfiguration(),
            knowledge: KnowledgeConfiguration(),
            automation: AutomationConfiguration(),
            agents: AgentConfiguration(),
            monetization: MonetizationConfiguration(),
            environment: .development
        )
    }
}

// MARK: - Pillar Configurations

struct IdentityConfiguration: Codable {
    let cloudflareZeroTrustEnabled: Bool = true
    let ssoProvider: String = "cloudflare"
    let sessionTimeout: Int = 3600
}

struct KnowledgeConfiguration: Codable {
    let vectorStoreProvider: String = "pinecone"
    let embeddingModel: String = "openai-ada-002"
    let domains: [String] = ["Healthcare", "Business", "Tech", "Content"]
}

struct AutomationConfiguration: Codable {
    let n8nBaseURL: String = "http://localhost:5678"
    let apiGatewayEnabled: Bool = true
    let maxConcurrentWorkflows: Int = 10
}

struct AgentConfiguration: Codable {
    let coreAgents: [String] = ["MasterLinc", "DocsLinc", "ClaimLinc", "VoiceLinc", "MapLinc"]
    let enableExperimentalAgents: Bool = false
}

struct MonetizationConfiguration: Codable {
    let funnelURL: String = "https://brainsait.com/solutions"
    let primaryProduct: String = "ClaimLinc"
    let pricingModel: String = "usage-based"
}
