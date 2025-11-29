import SwiftUI

struct TasksView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Priority.allCases, id: \.self) { priority in
                VStack(alignment: .leading, spacing: 12) {
                    Text(priority.text)
                        .font(.headline)
                        .foregroundStyle(priority.color)
                    
                    ForEach(sampleTasks.filter { $0.priority == priority }) { task in
                        TaskRow(task: task)
                    }
                }
            }
        }
    }
    
    private var sampleTasks: [Task] {
        [
            Task(title: "Review Q4 financial reports", priority: .high, dueDate: Date().addingTimeInterval(3600), completed: false),
            Task(title: "Update API documentation", priority: .high, dueDate: Date().addingTimeInterval(7200), completed: false),
            Task(title: "Deploy new payment gateway", priority: .medium, dueDate: Date().addingTimeInterval(86400), completed: false),
            Task(title: "Team standup meeting", priority: .medium, dueDate: Date().addingTimeInterval(43200), completed: true),
            Task(title: "Review code PRs", priority: .low, dueDate: Date().addingTimeInterval(172800), completed: false),
            Task(title: "Update system dependencies", priority: .low, dueDate: Date().addingTimeInterval(259200), completed: false)
        ]
    }
}

struct Task: Identifiable {
    let id = UUID()
    let title: String
    let priority: Priority
    let dueDate: Date
    let completed: Bool
}

enum Priority: CaseIterable {
    case high, medium, low
    
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }
    
    var text: String {
        switch self {
        case .high: return "High Priority"
        case .medium: return "Medium Priority"
        case .low: return "Low Priority"
        }
    }
}

struct TaskRow: View {
    let task: Task
    @State private var isCompleted: Bool
    
    init(task: Task) {
        self.task = task
        self._isCompleted = State(initialValue: task.completed)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                isCompleted.toggle()
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isCompleted ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(isCompleted)
                    .foregroundStyle(isCompleted ? .secondary : .primary)
                Text("Due: \(task.dueDate, style: .relative)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(task.priority.text)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(task.priority.color.opacity(0.2))
                .foregroundStyle(task.priority.color)
                .cornerRadius(4)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}
