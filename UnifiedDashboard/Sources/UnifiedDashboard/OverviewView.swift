import SwiftUI

struct OverviewView: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 280))], spacing: 20) {
            StatCard(title: "PayLinc Volume", value: "SAR 450K", icon: "banknote.fill", color: .green)
            StatCard(title: "Active Workflows", value: "12", icon: "arrow.triangle.branch", color: .blue)
            StatCard(title: "AI Agents Running", value: "8", icon: "brain.head.profile", color: .purple)
            StatCard(title: "Payment Channels", value: "5", icon: "creditcard", color: .green)
            StatCard(title: "Healthcare Claims", value: "12", icon: "cross.case.fill", color: .red)
            StatCard(title: "Murabaha BNPL", value: "3", icon: "crescent.fill", color: .orange)
            StatCard(title: "Pending Tasks", value: "23", icon: "checklist", color: .orange)
            StatCard(title: "A2A Connections", value: "6", icon: "arrow.left.arrow.right", color: .pink)
            StatCard(title: "Active Services", value: "15", icon: "app.badge", color: .indigo)
        }
        
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top)
            
            RecentActivityList()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Spacer()
            }
            Text(value)
                .font(.system(size: 36, weight: .bold))
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct RecentActivityList: View {
    var body: some View {
        VStack(spacing: 12) {
            ActivityRow(icon: "banknote.fill", color: .green, title: "PayLinc payment received SAR 500", time: "1 min ago")
            ActivityRow(icon: "cross.case.fill", color: .red, title: "Healthcare claim approved", time: "3 min ago")
            ActivityRow(icon: "checkmark.circle.fill", color: .green, title: "Workflow 'Data Sync' completed", time: "5 min ago")
            ActivityRow(icon: "play.circle.fill", color: .blue, title: "Agent 'Customer Support' started", time: "8 min ago")
            ActivityRow(icon: "crescent.fill", color: .orange, title: "Murabaha installment paid", time: "15 min ago")
            ActivityRow(icon: "exclamationmark.triangle.fill", color: .orange, title: "Task 'Review Dashboard' due soon", time: "1 hour ago")
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}

struct ActivityRow: View {
    let icon: String
    let color: Color
    let title: String
    let time: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
                .font(.body)
            Spacer()
            Text(time)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
