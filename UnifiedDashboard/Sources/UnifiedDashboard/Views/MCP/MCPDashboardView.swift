import SwiftUI

struct MCPDashboardView: View {
    @StateObject private var mcpClient = MCPServerClient()
    @State private var selectedTool: MCPTool?
    @State private var showToolDetail = false
    
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
                
                // Tools by Category
                if mcpClient.isConnected {
                    toolsCatalog
                }
            }
            .padding()
        }
        .sheet(isPresented: $showToolDetail) {
            if let tool = selectedTool {
                ToolDetailView(tool: tool, mcpClient: mcpClient)
            }
        }
    }
    
    private var serverStatusBadge: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(statusText)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private var statusColor: Color {
        switch mcpClient.serverStatus {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .gray
        case .error: return .red
        }
    }
    
    private var statusText: String {
        switch mcpClient.serverStatus {
        case .connected: return "Connected"
        case .connecting: return "Connecting..."
        case .disconnected: return "Disconnected"
        case .error(let message): return "Error: \(message)"
        }
    }
    
    private var serverControls: some View {
        HStack(spacing: 12) {
            Button(action: {
                Task { await mcpClient.startServer() }
            }) {
                Label("Start Server", systemImage: "play.fill")
            }
            .buttonStyle(.borderedProminent)
            .disabled(mcpClient.isConnected)
            
            Button(action: {
                mcpClient.stopServer()
            }) {
                Label("Stop Server", systemImage: "stop.fill")
            }
            .buttonStyle(.bordered)
            .disabled(!mcpClient.isConnected)
            
            Spacer()
            
            Text("\(mcpClient.availableTools.count) tools available")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private var toolsCatalog: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Tools")
                .font(.headline)
            
            let categories = Dictionary(grouping: mcpClient.availableTools, by: { $0.category })
            
            ForEach(Array(categories.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { category in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundStyle(categoryColor(category))
                        Text(category.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 12) {
                        ForEach(categories[category]!) { tool in
                            ToolCard(tool: tool)
                                .onTapGesture {
                                    selectedTool = tool
                                    showToolDetail = true
                                }
                        }
                    }
                }
                
                Divider()
            }
        }
    }
    
    private func categoryColor(_ category: MCPTool.ToolCategory) -> Color {
        switch category {
        case .fileProcessing: return .blue
        case .knowledge: return .purple
        case .automation: return .orange
        case .healthcare: return .red
        case .compliance: return .green
        case .ai: return .pink
        case .development: return .indigo
        case .testing: return Color(red: 0.0, green: 0.5, blue: 0.5)
        case .integration: return .yellow
        }
    }
}

struct ToolCard: View {
    let tool: MCPTool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: tool.category.icon)
                    .font(.title3)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(tool.name)
                .font(.headline)
            
            Text(tool.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct ToolDetailView: View {
    let tool: MCPTool
    let mcpClient: MCPServerClient
    @Environment(\.dismiss) private var dismiss
    
    @State private var inputText: String = ""
    @State private var result: String = ""
    @State private var isExecuting = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: tool.category.icon)
                    .font(.largeTitle)
                VStack(alignment: .leading) {
                    Text(tool.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(tool.category.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Close") { dismiss() }
            }
            
            Divider()
            
            // Description
            Text(tool.description)
                .font(.body)
            
            // Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Input")
                    .font(.headline)
                TextEditor(text: $inputText)
                    .frame(height: 150)
                    .border(Color.gray.opacity(0.3))
            }
            
            // Execute Button
            Button(action: executeTool) {
                if isExecuting {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("Execute Tool")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isExecuting || inputText.isEmpty)
            
            // Result
            if !result.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Result")
                        .font(.headline)
                    ScrollView {
                        Text(result)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: 200)
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 600, height: 700)
    }
    
    private func executeTool() {
        isExecuting = true
        result = ""
        
        Task {
            do {
                let toolResult = try await mcpClient.executeTool(
                    name: tool.name,
                    arguments: ["input": inputText]
                )
                result = toolResult.output
            } catch {
                result = "Error: \(error.localizedDescription)"
            }
            isExecuting = false
        }
    }
}
