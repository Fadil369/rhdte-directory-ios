//
//  KnowledgeHub.swift
//  Pillar 2: Central Knowledge + Memory System
//
//  The One Brain - RAG-powered institutional memory
//
//  Copyright © 2024 BrainSAIT. All rights reserved.
//

import Foundation

/// Pillar 2: Central Knowledge + Memory System
class KnowledgeHub {
    
    private let config: KnowledgeConfiguration
    private var vectorStore: VectorStore?
    private var documentIndex: [UUID: Document] = [:]
    
    init(config: KnowledgeConfiguration) {
        self.config = config
        print("🧠 Knowledge Hub Created")
    }
    
    func initialize() async throws {
        print("🧠 Initializing Knowledge Hub...")
        
        // Initialize vector store
        vectorStore = VectorStore(provider: config.vectorStoreProvider)
        try await vectorStore?.connect()
        
        // Load domain structure
        for domain in config.domains {
            try await createDomain(name: domain)
        }
        
        // Load existing documents
        try await loadDocumentIndex()
        
        print("🧠 Knowledge Hub Initialized with \(documentIndex.count) documents")
    }
    
    func shutdown() async {
        await vectorStore?.disconnect()
        documentIndex.removeAll()
        print("🧠 Knowledge Hub Shutdown")
    }
    
    func getHealthStatus() async -> HealthStatus {
        guard let vectorStore = vectorStore else { return .critical }
        let isConnected = await vectorStore.isConnected()
        return isConnected ? .healthy : .critical
    }
    
    // MARK: - Document Management
    
    func addDocument(_ document: Document) async throws {
        // Create embeddings
        let embeddings = try await createEmbeddings(for: document.content)
        
        // Store in vector database
        try await vectorStore?.store(
            id: document.id.uuidString,
            embeddings: embeddings,
            metadata: document.metadata
        )
        
        // Update index
        documentIndex[document.id] = document
        
        print("🧠 Document added: \(document.title)")
    }
    
    func query(_ searchQuery: String, domain: KnowledgeDomain? = nil, limit: Int = 10) async throws -> [KnowledgeResult] {
        // Create query embeddings
        let queryEmbeddings = try await createEmbeddings(for: searchQuery)
        
        // Search vector store
        guard let results = try await vectorStore?.search(
            embeddings: queryEmbeddings,
            limit: limit,
            filter: domain.map { ["domain": $0.rawValue] }
        ) else {
            return []
        }
        
        // Map to knowledge results
        return results.compactMap { result in
            guard let docId = UUID(uuidString: result.id),
                  let document = documentIndex[docId] else { return nil }
            
            return KnowledgeResult(
                document: document,
                relevanceScore: result.score,
                snippet: extractSnippet(from: document.content, query: searchQuery)
            )
        }
    }
    
    func updateDocument(_ documentId: UUID, content: String) async throws {
        guard var document = documentIndex[documentId] else {
            throw KnowledgeHubError.documentNotFound
        }
        
        document.content = content
        document.updatedAt = Date()
        
        try await addDocument(document)
    }
    
    func deleteDocument(_ documentId: UUID) async throws {
        guard documentIndex[documentId] != nil else {
            throw KnowledgeHubError.documentNotFound
        }
        
        try await vectorStore?.delete(id: documentId.uuidString)
        documentIndex.removeValue(forKey: documentId)
    }
    
    // MARK: - Domain Management
    
    private func createDomain(name: String) async throws {
        // Create domain structure in vector store
        print("🧠 Created domain: \(name)")
    }
    
    // MARK: - Private Methods
    
    private func loadDocumentIndex() async throws {
        // Load existing documents from storage
        // For now, create some demo documents
        let demoDocuments = createDemoDocuments()
        for doc in demoDocuments {
            documentIndex[doc.id] = doc
        }
    }
    
    private func createEmbeddings(for text: String) async throws -> [Float] {
        // Create embeddings using configured model
        // This would call OpenAI or local embedding service
        // For now, return mock embeddings
        return Array(repeating: Float.random(in: 0...1), count: 1536)
    }
    
    private func extractSnippet(from content: String, query: String, length: Int = 200) -> String {
        // Extract relevant snippet from content
        let words = query.lowercased().split(separator: " ")
        if let range = content.lowercased().range(of: words.first?.description ?? "") {
            let start = content.index(range.lowerBound, offsetBy: -50, limitedBy: content.startIndex) ?? content.startIndex
            let end = content.index(range.upperBound, offsetBy: length, limitedBy: content.endIndex) ?? content.endIndex
            return String(content[start..<end]) + "..."
        }
        return String(content.prefix(length)) + "..."
    }
    
    private func createDemoDocuments() -> [Document] {
        [
            Document(
                title: "PDPL Compliance Guide",
                content: "Saudi Arabia Personal Data Protection Law compliance requirements...",
                domain: .healthcare,
                tags: ["compliance", "PDPL", "privacy"],
                author: "BrainSAIT Legal"
            ),
            Document(
                title: "NPHIES Integration Guide",
                content: "National Platform for Healthcare Information Exchange integration steps...",
                domain: .healthcare,
                tags: ["NPHIES", "healthcare", "integration"],
                author: "BrainSAIT Tech"
            ),
            Document(
                title: "ClaimLinc User Manual",
                content: "Complete guide to using ClaimLinc for healthcare claims automation...",
                domain: .healthcare,
                tags: ["ClaimLinc", "claims", "automation"],
                author: "BrainSAIT"
            )
        ]
    }
}

// MARK: - Vector Store

class VectorStore {
    private let provider: String
    private var isConnectedState: Bool = false
    
    init(provider: String) {
        self.provider = provider
    }
    
    func connect() async throws {
        print("🔗 Connecting to \(provider)...")
        try await Task.sleep(for: .seconds(1))
        isConnectedState = true
    }
    
    func disconnect() async {
        isConnectedState = false
    }
    
    func isConnected() async -> Bool {
        return isConnectedState
    }
    
    func store(id: String, embeddings: [Float], metadata: [String: String]) async throws {
        // Store embeddings in vector database
    }
    
    func search(embeddings: [Float], limit: Int, filter: [String: String]?) async throws -> [VectorSearchResult] {
        // Search vector database
        return []
    }
    
    func delete(id: String) async throws {
        // Delete from vector database
    }
}

struct VectorSearchResult {
    let id: String
    let score: Float
}

// MARK: - Knowledge Hub Error

enum KnowledgeHubError: LocalizedError {
    case documentNotFound
    case embeddingFailed
    case vectorStoreUnavailable
    
    var errorDescription: String? {
        switch self {
        case .documentNotFound: return "Document not found"
        case .embeddingFailed: return "Failed to create embeddings"
        case .vectorStoreUnavailable: return "Vector store unavailable"
        }
    }
}
