//
//  AutomationSpine.swift
//  Pillar 3: Workflow Automation Spine
//
//  The Central Nervous System - All automation lives here
//
//  Copyright © 2024 BrainSAIT. All rights reserved.
//

import Foundation

/// Pillar 3: Workflow Automation Spine
class AutomationSpine {
    
    private let config: AutomationConfiguration
    private var n8nClient: N8NClient?
    private var apiGateway: APIGateway?
    private var activeWorkflows: [UUID: Workflow] = [:]
    
    init(config: AutomationConfiguration) {
        self.config = config
        print("⚡ Automation Spine Created")
    }
    
    func initialize() async throws {
        print("⚡ Initializing Automation Spine...")
        
        // Initialize n8n client
        n8nClient = N8NClient(baseURL: config.n8nBaseURL)
        try await n8nClient?.connect()
        
        // Initialize API Gateway
        if config.apiGatewayEnabled {
            apiGateway = APIGateway()
            try await apiGateway?.initialize()
        }
        
        // Load workflow definitions
        try await loadWorkflows()
        
        print("⚡ Automation Spine Initialized with \(activeWorkflows.count) workflows")
    }
    
    func shutdown() async {
        await n8nClient?.disconnect()
        await apiGateway?.shutdown()
        activeWorkflows.removeAll()
        print("⚡ Automation Spine Shutdown")
    }
    
    func getHealthStatus() async -> HealthStatus {
        guard let n8nClient = n8nClient else { return .critical }
        let isConnected = await n8nClient.isHealthy()
        return isConnected ? .healthy : .degraded
    }
    
    // MARK: - Workflow Execution
    
    func executeWorkflow(name: String, parameters: [String: Any]) async throws -> WorkflowResult {
        guard let workflow = activeWorkflows.values.first(where: { $0.name == name }) else {
            throw AutomationError.workflowNotFound(name)
        }
        
        print("⚡ Executing workflow: \(name)")
        
        // Execute via n8n
        let executionId = try await n8nClient?.executeWorkflow(
            workflowId: workflow.id.uuidString,
            parameters: parameters
        )
        
        // Monitor execution
        let result = try await monitorExecution(executionId: executionId ?? "")
        
        return WorkflowResult(
            workflowId: workflow.id,
            executionId: executionId ?? "",
            status: result.success ? .completed : .failed,
            output: result.data,
            startedAt: Date(),
            completedAt: Date()
        )
    }
    
    func scheduleWorkflow(name: String, schedule: String, parameters: [String: Any]) async throws {
        // Schedule recurring workflow
        print("⚡ Scheduling workflow: \(name) with schedule: \(schedule)")
    }
    
    // MARK: - API Gateway
    
    func callExternalAPI(service: ExternalService, endpoint: String, parameters: [String: Any]) async throws -> [String: Any] {
        guard let gateway = apiGateway else {
            throw AutomationError.apiGatewayUnavailable
        }
        
        return try await gateway.call(service: service, endpoint: endpoint, parameters: parameters)
    }
    
    // MARK: - Private Methods
    
    private func loadWorkflows() async throws {
        // Load workflow definitions
        let workflows = createCoreWorkflows()
        for workflow in workflows {
            activeWorkflows[workflow.id] = workflow
        }
    }
    
    private func monitorExecution(executionId: String) async throws -> (success: Bool, data: [String: Any]?) {
        // Monitor workflow execution
        try await Task.sleep(for: .seconds(2)) // Simulate execution time
        return (true, ["result": "success"])
    }
    
    private func createCoreWorkflows() -> [Workflow] {
        [
            Workflow(
                name: "Client Onboarding",
                description: "Automated client onboarding process",
                triggers: [.manual, .webhook],
                steps: ["Collect Info", "Create Account", "Send Welcome", "Schedule Follow-up"]
            ),
            Workflow(
                name: "Claim Processing",
                description: "Healthcare claim automation via ClaimLinc",
                triggers: [.manual, .api],
                steps: ["Validate Claim", "Check Eligibility", "Submit to NPHIES", "Track Status"]
            ),
            Workflow(
                name: "Lead Generation",
                description: "Automated lead generation and qualification",
                triggers: [.scheduled, .manual],
                steps: ["Identify Leads", "Enrich Data", "Qualify", "Assign to Sales"]
            ),
            Workflow(
                name: "Document Processing",
                description: "Process and index documents via DocsLinc",
                triggers: [.fileUpload, .api],
                steps: ["Extract Text", "Create Embeddings", "Index", "Notify"]
            )
        ]
    }
}

// MARK: - N8N Client

class N8NClient {
    private let baseURL: String
    private var isHealthyState: Bool = false
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    func connect() async throws {
        print("⚡ Connecting to n8n at \(baseURL)...")
        try await Task.sleep(for: .seconds(1))
        isHealthyState = true
    }
    
    func disconnect() async {
        isHealthyState = false
    }
    
    func isHealthy() async -> Bool {
        return isHealthyState
    }
    
    func executeWorkflow(workflowId: String, parameters: [String: Any]) async throws -> String {
        // Execute workflow and return execution ID
        return UUID().uuidString
    }
}

// MARK: - API Gateway

class APIGateway {
    private var apiClients: [ExternalService: Any] = [:]
    
    func initialize() async throws {
        print("⚡ Initializing API Gateway...")
        // Initialize clients for external services
    }
    
    func shutdown() async {
        apiClients.removeAll()
    }
    
    func call(service: ExternalService, endpoint: String, parameters: [String: Any]) async throws -> [String: Any] {
        print("⚡ Calling \(service.rawValue) API: \(endpoint)")
        // Make API call
        return ["status": "success"]
    }
}

// MARK: - Supporting Types

struct Workflow {
    let id: UUID = UUID()
    let name: String
    let description: String
    let triggers: [WorkflowTrigger]
    let steps: [String]
    let isActive: Bool = true
}

enum WorkflowTrigger {
    case manual
    case scheduled
    case webhook
    case fileUpload
    case api
}

struct WorkflowResult {
    let workflowId: UUID
    let executionId: String
    let status: WorkflowStatus
    let output: [String: Any]?
    let startedAt: Date
    let completedAt: Date
}

enum WorkflowStatus {
    case running
    case completed
    case failed
    case cancelled
}

enum ExternalService: String {
    case openai = "OpenAI"
    case elevenLabs = "ElevenLabs"
    case nphies = "NPHIES"
    case stripe = "Stripe"
    case twilio = "Twilio"
    case google = "Google"
}

enum AutomationError: LocalizedError {
    case workflowNotFound(String)
    case executionFailed(String)
    case apiGatewayUnavailable
    
    var errorDescription: String? {
        switch self {
        case .workflowNotFound(let name): return "Workflow not found: \(name)"
        case .executionFailed(let reason): return "Execution failed: \(reason)"
        case .apiGatewayUnavailable: return "API Gateway unavailable"
        }
    }
}
