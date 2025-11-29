import SwiftUI

struct WorkflowsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(sampleWorkflows) { workflow in
                WorkflowCard(workflow: workflow)
            }
        }
    }
    
    private var sampleWorkflows: [Workflow] {
        [
            Workflow(name: "Data Sync Pipeline", status: .running, lastRun: Date().addingTimeInterval(-120), duration: "2m 15s"),
            Workflow(name: "Customer Onboarding", status: .completed, lastRun: Date().addingTimeInterval(-3600), duration: "5m 42s"),
            Workflow(name: "Invoice Generation", status: .running, lastRun: Date().addingTimeInterval(-300), duration: "1m 08s"),
            Workflow(name: "Backup Automation", status: .scheduled, lastRun: Date().addingTimeInterval(-86400), duration: "15m 30s"),
            Workflow(name: "Report Generation", status: .failed, lastRun: Date().addingTimeInterval(-7200), duration: "N/A")
        ]
    }
}

struct Workflow: Identifiable {
    let id = UUID()
    let name: String
    let status: WorkflowStatus
    let lastRun: Date
    let duration: String
}

enum WorkflowStatus {
    case running, completed, failed, scheduled
    
    var color: Color {
        switch self {
        case .running: return .blue
        case .completed: return .green
        case .failed: return .red
        case .scheduled: return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .running: return "play.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .scheduled: return "clock.fill"
        }
    }
    
    var text: String {
        switch self {
        case .running: return "Running"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .scheduled: return "Scheduled"
        }
    }
}

struct WorkflowCard: View {
    let workflow: Workflow
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: workflow.status.icon)
                .font(.title)
                .foregroundStyle(workflow.status.color)
                .frame(width: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workflow.name)
                    .font(.headline)
                HStack {
                    Text("Last run: \(workflow.lastRun, style: .relative)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text("Duration: \(workflow.duration)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(workflow.status.text)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(workflow.status.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(workflow.status.color.opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}
