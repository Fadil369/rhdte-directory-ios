import SwiftUI

struct AppsServicesView: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280))], spacing: 16) {
            ServiceCard(name: "BrainSAIT Platform", category: "AI Services", status: .running, uptime: "99.9%")
            ServiceCard(name: "API Gateway", category: "Infrastructure", status: .running, uptime: "100%")
            ServiceCard(name: "Database Cluster", category: "Data", status: .running, uptime: "99.8%")
            ServiceCard(name: "Authentication Service", category: "Security", status: .running, uptime: "99.95%")
            ServiceCard(name: "CDN", category: "Content Delivery", status: .running, uptime: "100%")
            ServiceCard(name: "Email Service", category: "Communication", status: .running, uptime: "99.5%")
            ServiceCard(name: "Analytics Engine", category: "Analytics", status: .running, uptime: "98.7%")
            ServiceCard(name: "Backup Service", category: "Infrastructure", status: .maintenance, uptime: "N/A")
            ServiceCard(name: "Monitoring Stack", category: "Observability", status: .running, uptime: "100%")
        }
    }
}

struct ServiceCard: View {
    let name: String
    let category: String
    let status: ServiceStatus
    let uptime: String
    
    enum ServiceStatus {
        case running, stopped, maintenance, error
        
        var color: Color {
            switch self {
            case .running: return .green
            case .stopped: return .gray
            case .maintenance: return .orange
            case .error: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .running: return "circle.fill"
            case .stopped: return "stop.circle.fill"
            case .maintenance: return "wrench.and.screwdriver.fill"
            case .error: return "exclamationmark.octagon.fill"
            }
        }
        
        var text: String {
            switch self {
            case .running: return "Running"
            case .stopped: return "Stopped"
            case .maintenance: return "Maintenance"
            case .error: return "Error"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "app.badge")
                    .foregroundStyle(.indigo)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: status.icon)
                        .font(.caption)
                        .foregroundStyle(status.color)
                    Text(status.text)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text(category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            HStack {
                Text("Uptime:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(uptime)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(status == .running ? .green : .secondary)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}
