//
//  MCPDashboardView.swift
//  BrainSAIT Unified Platform
//
//  Created by BrainSAIT on 2024-11-29.
//

import SwiftUI

struct SimpleMCPDashboardView: View {
    @State private var isConnected = false
    @State private var serverStatus: MCPServerStatus = .disconnected
    
    enum MCPServerStatus {
        case connected
        case connecting
        case disconnected
        case error(String)
        
        var description: String {
            switch self {
            case .connected: return "Connected"
            case .connecting: return "Connecting..."
            case .disconnected: return "Disconnected"
            case .error(let message): return "Error: \(message)"
            }
        }
        
        var color: Color {
            switch self {
            case .connected: return .green
            case .connecting: return .orange
            case .disconnected: return .gray
            case .error: return .red
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.largeTitle)
                        .foregroundStyle(.purple)
                    VStack(alignment: .leading) {
                        Text("BrainSAIT MCP Server")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Model Context Protocol Integration")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    serverStatusBadge
                }
                
                // Server Controls
                serverControls
                
                // Tools Placeholder
                if isConnected {
                    toolsPlaceholder
                } else {
                    disconnectedState
                }
            }
            .padding()
        }
    }
    
    private var serverStatusBadge: some View {
        HStack {
            Circle()
                .fill(serverStatus.color)
                .frame(width: 8, height: 8)
            Text(serverStatus.description)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.regularMaterial)
        .cornerRadius(12)
    }
    
    private var serverControls: some View {
        HStack(spacing: 12) {
            Button(action: {
                startServer()
            }) {
                Label("Start Server", systemImage: "play.fill")
            }
            .buttonStyle(.borderedProminent)
            .disabled(isConnected)
            
            Button(action: {
                stopServer()
            }) {
                Label("Stop Server", systemImage: "stop.fill")
            }
            .buttonStyle(.bordered)
            .disabled(!isConnected)
            
            Spacer()
            
            Text(isConnected ? "6 tools available" : "No tools available")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var toolsPlaceholder: some View {
        VStack(spacing: 16) {
            Text("MCP Tools")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 12) {
                MCPToolCard(name: "File System", icon: "folder.fill", status: "Ready")
                MCPToolCard(name: "Database Query", icon: "database.fill", status: "Ready")
                MCPToolCard(name: "API Client", icon: "network", status: "Ready")
                MCPToolCard(name: "Text Processing", icon: "text.alignleft", status: "Ready")
                MCPToolCard(name: "Image Analysis", icon: "photo.fill", status: "Ready")
                MCPToolCard(name: "Code Generation", icon: "curlybraces", status: "Ready")
            }
        }
    }
    
    private var disconnectedState: some View {
        VStack(spacing: 12) {
            Image(systemName: "server.rack")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("MCP Server Disconnected")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start the server to access MCP tools and capabilities")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private func startServer() {
        serverStatus = .connecting
        isConnected = false
        
        // Simulate server startup
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            serverStatus = .connected
            isConnected = true
        }
    }
    
    private func stopServer() {
        serverStatus = .disconnected
        isConnected = false
    }
}

struct MCPToolCard: View {
    let name: String
    let icon: String
    let status: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.blue)
                Spacer()
                Text(status)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.2))
                    .foregroundStyle(.green)
                    .cornerRadius(4)
            }
            
            Text(name)
                .font(.headline)
            
            Text("Tool description here")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

#Preview {
    SimpleMCPDashboardView()
}