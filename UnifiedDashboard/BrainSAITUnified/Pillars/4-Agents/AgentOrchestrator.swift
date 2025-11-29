//
//  AgentOrchestrator.swift
//  Pillar 4: Agent-Oriented Architecture
//
//  The Specialized Limbs - Core Five Agents Only
//
//  Copyright © 2024 BrainSAIT. All rights reserved.
//

import Foundation

/// Pillar 4: Agent-Oriented Architecture
class AgentOrchestrator {
    
    private let config: AgentConfiguration
    private var agents: [AgentType: BaseAgent] = [:]
    
    init(config: AgentConfiguration) {
        self.config = config
        print("🤖 Agent Orchestrator Created")
    }
    
    func initialize() async throws {
        print("🤖 Initializing Agent Orchestrator...")
        
        // Initialize the Core Five agents only
        try await initializeCoreAgents()
        
        print("🤖 Agent Orchestrator Initialized - \(agents.count) agents active")
    }
    
    func shutdown() async {
        for agent in agents.values {
            await agent.shutdown()
        }
        agents.removeAll()
        print("🤖 Agent Orchestrator Shutdown")
    }
    
    func getHealthStatus() async -> HealthStatus {
        let healthyCount = await agents.values.filter { await $0.isHealthy() }.count
        let totalCount = agents.count
        
        if healthyCount == totalCount { return .healthy }
        if healthyCount > totalCount / 2 { return .degraded }
        return .critical
    }
    
    func getActiveAgents() -> [AgentType] {
        Array(agents.keys)
    }
    
    // MARK: - Agent Access
    
    func getAgent(_ type: AgentType) throws -> BaseAgent {
        guard let agent = agents[type] else {
            throw AgentError.agentNotFound(type)
        }
        return agent
    }
    
    // MARK: - Agent Coordination
    
    func orchestrateTask(task: String, requiredAgents: [AgentType]) async throws -> [String: Any] {
        print("🤖 Orchestrating task with agents: \(requiredAgents.map { $0.rawValue }.joined(separator: ", "))")
        
        var results: [String: Any] = [:]
        
        for agentType in requiredAgents {
            let agent = try getAgent(agentType)
            let result = try await agent.processTask(task)
            results[agentType.rawValue] = result
        }
        
        return results
    }
    
    // MARK: - Private Methods
    
    private func initializeCoreAgents() async throws {
        // MasterLinc - The Orchestrator
        let masterLinc = MasterLincAgent()
        try await masterLinc.initialize()
        agents[.masterLinc] = masterLinc
        
        // DocsLinc - Document & Knowledge Processor
        let docsLinc = DocsLincAgent()
        try await docsLinc.initialize()
        agents[.docsLinc] = docsLinc
        
        // ClaimLinc - Healthcare Claims Automation
        let claimLinc = ClaimLincAgent()
        try await claimLinc.initialize()
        agents[.claimLinc] = claimLinc
        
        // VoiceLinc - Voice & Communication
        let voiceLinc = VoiceLincAgent()
        try await voiceLinc.initialize()
        agents[.voiceLinc] = voiceLinc
        
        // MapLinc - Business Intelligence & Mapping
        let mapLinc = MapLincAgent()
        try await mapLinc.initialize()
        agents[.mapLinc] = mapLinc
    }
}

// MARK: - Agent Types

enum AgentType: String, CaseIterable, Identifiable {
    case masterLinc = "MasterLinc"
    case docsLinc = "DocsLinc"
    case claimLinc = "ClaimLinc"
    case voiceLinc = "VoiceLinc"
    case mapLinc = "MapLinc"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .masterLinc: return "Main orchestrator and coordinator"
        case .docsLinc: return "Document processing and knowledge management"
        case .claimLinc: return "Healthcare claims automation"
        case .voiceLinc: return "Voice interaction and communication"
        case .mapLinc: return "Business intelligence and mapping"
        }
    }
    
    var icon: String {
        switch self {
        case .masterLinc: return "brain.head.profile"
        case .docsLinc: return "doc.text.fill"
        case .claimLinc: return "cross.case.fill"
        case .voiceLinc: return "waveform.circle.fill"
        case .mapLinc: return "map.fill"
        }
    }
}

// MARK: - Base Agent Protocol

protocol BaseAgent {
    var type: AgentType { get }
    var status: AgentStatus { get }
    
    func initialize() async throws
    func shutdown() async
    func isHealthy() async -> Bool
    func processTask(_ task: String) async throws -> [String: Any]
}

enum AgentStatus {
    case offline
    case initializing
    case ready
    case busy
    case error
}

// MARK: - Agent Implementations

class MasterLincAgent: BaseAgent {
    let type: AgentType = .masterLinc
    var status: AgentStatus = .offline
    
    func initialize() async throws {
        status = .initializing
        print("🧠 MasterLinc initializing...")
        try await Task.sleep(for: .seconds(1))
        status = .ready
        print("🧠 MasterLinc ready")
    }
    
    func shutdown() async {
        status = .offline
    }
    
    func isHealthy() async -> Bool {
        status == .ready || status == .busy
    }
    
    func processTask(_ task: String) async throws -> [String: Any] {
        status = .busy
        defer { status = .ready }
        
        // MasterLinc orchestrates other agents
        return ["orchestration": "completed", "task": task]
    }
}

class DocsLincAgent: BaseAgent {
    let type: AgentType = .docsLinc
    var status: AgentStatus = .offline
    
    func initialize() async throws {
        status = .initializing
        print("📄 DocsLinc initializing...")
        try await Task.sleep(for: .seconds(1))
        status = .ready
        print("📄 DocsLinc ready")
    }
    
    func shutdown() async {
        status = .offline
    }
    
    func isHealthy() async -> Bool {
        status == .ready || status == .busy
    }
    
    func processTask(_ task: String) async throws -> [String: Any] {
        status = .busy
        defer { status = .ready }
        
        // Process documents and knowledge queries
        return ["documents": "processed", "task": task]
    }
}

class ClaimLincAgent: BaseAgent {
    let type: AgentType = .claimLinc
    var status: AgentStatus = .offline
    
    func initialize() async throws {
        status = .initializing
        print("🏥 ClaimLinc initializing...")
        try await Task.sleep(for: .seconds(1))
        status = .ready
        print("🏥 ClaimLinc ready")
    }
    
    func shutdown() async {
        status = .offline
    }
    
    func isHealthy() async -> Bool {
        status == .ready || status == .busy
    }
    
    func processTask(_ task: String) async throws -> [String: Any] {
        status = .busy
        defer { status = .ready }
        
        // Process healthcare claims
        return ["claims": "processed", "task": task]
    }
}

class VoiceLincAgent: BaseAgent {
    let type: AgentType = .voiceLinc
    var status: AgentStatus = .offline
    
    func initialize() async throws {
        status = .initializing
        print("🗣️ VoiceLinc initializing...")
        try await Task.sleep(for: .seconds(1))
        status = .ready
        print("🗣️ VoiceLinc ready")
    }
    
    func shutdown() async {
        status = .offline
    }
    
    func isHealthy() async -> Bool {
        status == .ready || status == .busy
    }
    
    func processTask(_ task: String) async throws -> [String: Any] {
        status = .busy
        defer { status = .ready }
        
        // Process voice interactions
        return ["voice": "processed", "task": task]
    }
}

class MapLincAgent: BaseAgent {
    let type: AgentType = .mapLinc
    var status: AgentStatus = .offline
    
    func initialize() async throws {
        status = .initializing
        print("🗺️ MapLinc initializing...")
        try await Task.sleep(for: .seconds(1))
        status = .ready
        print("🗺️ MapLinc ready")
    }
    
    func shutdown() async {
        status = .offline
    }
    
    func isHealthy() async -> Bool {
        status == .ready || status == .busy
    }
    
    func processTask(_ task: String) async throws -> [String: Any] {
        status = .busy
        defer { status = .ready }
        
        // Process business mapping
        return ["mapping": "completed", "task": task]
    }
}

// MARK: - Agent Error

enum AgentError: LocalizedError {
    case agentNotFound(AgentType)
    case agentUnavailable(AgentType)
    case taskFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .agentNotFound(let type): return "Agent not found: \(type.rawValue)"
        case .agentUnavailable(let type): return "Agent unavailable: \(type.rawValue)"
        case .taskFailed(let reason): return "Task failed: \(reason)"
        }
    }
}
