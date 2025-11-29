import SwiftUI

struct A2AView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(sampleConnections) { connection in
                A2AConnectionCard(connection: connection)
            }
        }
    }
    
    private var sampleConnections: [A2AConnection] {
        [
            A2AConnection(name: "Salesforce ↔ HubSpot", status: .synced, lastSync: Date().addingTimeInterval(-300), recordCount: "1,234"),
            A2AConnection(name: "Stripe ↔ QuickBooks", status: .synced, lastSync: Date().addingTimeInterval(-600), recordCount: "567"),
            A2AConnection(name: "Gmail ↔ Slack", status: .active, lastSync: Date().addingTimeInterval(-120), recordCount: "89"),
            A2AConnection(name: "GitHub ↔ Jira", status: .synced, lastSync: Date().addingTimeInterval(-1800), recordCount: "234"),
            A2AConnection(name: "Shopify ↔ Inventory System", status: .error, lastSync: Date().addingTimeInterval(-3600), recordCount: "0"),
            A2AConnection(name: "Twilio ↔ CRM", status: .active, lastSync: Date().addingTimeInterval(-60), recordCount: "45")
        ]
    }
}

struct A2AConnection: Identifiable {
    let id = UUID()
    let name: String
    let status: A2AStatus
    let lastSync: Date
    let recordCount: String
}

enum A2AStatus {
    case active, synced, error, paused
    
    var color: Color {
        switch self {
        case .active: return .blue
        case .synced: return .green
        case .error: return .red
        case .paused: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .active: return "arrow.triangle.2.circlepath"
        case .synced: return "checkmark.circle.fill"
        case .error: return "exclamationmark.triangle.fill"
        case .paused: return "pause.circle.fill"
        }
    }
    
    var text: String {
        switch self {
        case .active: return "Syncing"
        case .synced: return "Synced"
        case .error: return "Error"
        case .paused: return "Paused"
        }
    }
}

struct A2AConnectionCard: View {
    let connection: A2AConnection
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: connection.status.icon)
                .font(.title)
                .foregroundStyle(connection.status.color)
                .frame(width: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(connection.name)
                    .font(.headline)
                HStack {
                    Text("Last sync: \(connection.lastSync, style: .relative)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text("\(connection.recordCount) records")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(connection.status.text)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(connection.status.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(connection.status.color.opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}
