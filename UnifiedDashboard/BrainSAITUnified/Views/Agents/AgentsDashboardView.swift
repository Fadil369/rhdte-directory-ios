//
//  AgentsDashboardView.swift
//  Agents Dashboard View
//
//  Copyright © 2024 BrainSAIT. All rights reserved.
//

import SwiftUI

struct AgentsDashboardView: View {
    let isArabic: Bool
    @EnvironmentObject var viewModel: DashboardViewModel
    @State private var selectedAgent: AgentType?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: isArabic ? .trailing : .leading) {
                        Text(isArabic ? "الوكلاء الأساسيون الخمسة" : "The Core Five Agents")
                            .font(.largeTitle.bold())
                        Text(isArabic ? "وكلاء متخصصون يعملون معاً" : "Specialized agents working together")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding()
                
                // Agent Grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 20) {
                    ForEach(AgentType.allCases, id: \.self) { agent in
                        AgentCard(agent: agent, isArabic: isArabic)
                            .onTapGesture {
                                selectedAgent = agent
                            }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .sheet(item: $selectedAgent) { agent in
            AgentDetailView(agent: agent, isArabic: isArabic)
        }
    }
}

struct AgentCard: View {
    let agent: AgentType
    let isArabic: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: agent.icon)
                    .font(.title)
                    .foregroundStyle(.blue.gradient)
                Spacer()
                Circle()
                    .fill(.green)
                    .frame(width: 12, height: 12)
            }
            
            Text(agent.rawValue)
                .font(.headline)
            
            Text(agent.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AgentDetailView: View {
    let agent: AgentType
    let isArabic: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Icon and name
                    HStack {
                        Image(systemName: agent.icon)
                            .font(.system(size: 60))
                            .foregroundStyle(.blue.gradient)
                        
                        VStack(alignment: .leading) {
                            Text(agent.rawValue)
                                .font(.title.bold())
                            Text(agent.description)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    // Capabilities
                    VStack(alignment: .leading, spacing: 12) {
                        Text(isArabic ? "القدرات" : "Capabilities")
                            .font(.headline)
                        
                        ForEach(getCapabilities(for: agent), id: \.self) { capability in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                Text(capability)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(agent.rawValue)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    func getCapabilities(for agent: AgentType) -> [String] {
        switch agent {
        case .masterLinc:
            return ["Orchestrates all agents", "Coordinates workflows", "Manages tasks", "Monitors system health"]
        case .docsLinc:
            return ["Document processing", "Knowledge queries", "Vector search", "Content indexing"]
        case .claimLinc:
            return ["Healthcare claims automation", "NPHIES integration", "Claim validation", "Status tracking"]
        case .voiceLinc:
            return ["Voice interactions", "Speech-to-text", "Text-to-speech", "Voice commands"]
        case .mapLinc:
            return ["Business intelligence", "Data mapping", "Lead generation", "Analytics"]
        }
    }
}
