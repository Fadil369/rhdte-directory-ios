import SwiftUI

import SwiftUI

struct AgentsView: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320))], spacing: 16) {
            AgentCard(name: "Customer Support Agent", type: "Chat AI", status: .active, requests: "234", uptime: "99.8%")
            AgentCard(name: "Data Analysis Agent", type: "Analytics", status: .active, requests: "89", uptime: "100%")
            AgentCard(name: "Content Generator", type: "Creative AI", status: .active, requests: "156", uptime: "98.5%")
            AgentCard(name: "Code Review Bot", type: "Development", status: .idle, requests: "12", uptime: "95.2%")
            AgentCard(name: "Email Classifier", type: "NLP", status: .active, requests: "567", uptime: "99.9%")
            AgentCard(name: "Image Processor", type: "Vision AI", status: .error, requests: "0", uptime: "0%")
        }
    }
}

struct AgentCard: View {
    let name: String
    let type: String
    let status: AgentStatus
    let requests: String
    let uptime: String
    
    enum AgentStatus {
        case active, idle, error
        
        var color: Color {
            switch self {
            case .active: return .green
            case .idle: return .orange
            case .error: return .red
            }
        }
        
        var text: String {
            switch self {
            case .active: return "Active"
            case .idle: return "Idle"
            case .error: return "Error"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundStyle(.purple)
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(status.color)
                        .frame(width: 8, height: 8)
                    Text(status.text)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text(type)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Requests")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(requests)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Uptime")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(uptime)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}
