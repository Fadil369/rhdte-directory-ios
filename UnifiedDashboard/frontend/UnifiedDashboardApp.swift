//
//  UnifiedDashboardApp.swift
//  BrainSAIT Unified Dashboard
//
//  SwiftUI native macOS app for unified observability
//

import SwiftUI

@main
struct UnifiedDashboardApp: App {
    @StateObject private var dashboardViewModel = DashboardViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dashboardViewModel)
                .frame(minWidth: 1400, minHeight: 900)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @EnvironmentObject var viewModel: DashboardViewModel
    @State private var selectedSection: DashboardSection = .overview
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            SidebarView(selectedSection: $selectedSection)
                .frame(minWidth: 200)
        } detail: {
            // Main content area
            ScrollView {
                VStack(spacing: 20) {
                    switch selectedSection {
                    case .overview:
                        OverviewDashboard()
                    case .payments:
                        PaymentsDashboard()
                    case .agents:
                        AgentsDashboard()
                    case .workflows:
                        WorkflowsDashboard()
                    case .paylinc:
                        PayLincDashboard()
                    case .analytics:
                        AnalyticsDashboard()
                    }
                }
                .padding()
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

// MARK: - Dashboard Section Enum
enum DashboardSection: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case payments = "Payments"
    case agents = "Agents"
    case workflows = "Workflows"
    case paylinc = "PayLinc"
    case analytics = "Analytics"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .overview: return "chart.bar.fill"
        case .payments: return "creditcard.fill"
        case .agents: return "cpu.fill"
        case .workflows: return "arrow.triangle.branch"
        case .paylinc: return "dollarsign.circle.fill"
        case .analytics: return "chart.line.uptrend.xyaxis"
        }
    }
}

// MARK: - Sidebar View
struct SidebarView: View {
    @Binding var selectedSection: DashboardSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("BrainSAIT")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Unified Dashboard")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            
            Divider()
            
            // Navigation items
            List(DashboardSection.allCases, selection: $selectedSection) { section in
                Label(section.rawValue, systemImage: section.icon)
                    .tag(section)
            }
            .listStyle(.sidebar)
            
            Spacer()
            
            // Status indicator
            HStack {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                Text("All Systems Operational")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}

// MARK: - Overview Dashboard
struct OverviewDashboard: View {
    @EnvironmentObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Dashboard Overview")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Real-time monitoring of all systems")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
                // Refresh button
                Button(action: { viewModel.refresh() }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
            }
            
            // Key metrics grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                MetricCard(
                    title: "Today's Revenue",
                    value: "$\(viewModel.todayRevenue, specifier: "%.2f")",
                    change: "+12.5%",
                    trend: .up
                )
                
                MetricCard(
                    title: "Active Agents",
                    value: "\(viewModel.activeAgents)/16",
                    change: "100%",
                    trend: .stable
                )
                
                MetricCard(
                    title: "Transactions",
                    value: "\(viewModel.todayTransactions)",
                    change: "+8.3%",
                    trend: .up
                )
                
                MetricCard(
                    title: "Active Workflows",
                    value: "\(viewModel.activeWorkflows)",
                    change: "2 pending",
                    trend: .stable
                )
            }
            
            // Payment channels status
            GroupBox("Payment Channels") {
                HStack(spacing: 16) {
                    PaymentChannelIndicator(name: "PayLinc", status: .active, volume: "$15,234")
                    PaymentChannelIndicator(name: "Stripe", status: .active, volume: "$8,456")
                    PaymentChannelIndicator(name: "PayPal", status: .active, volume: "$3,211")
                    PaymentChannelIndicator(name: "SARIE", status: .active, volume: "$12,890")
                    PaymentChannelIndicator(name: "NPHIES", status: .active, volume: "$5,678")
                }
                .padding()
            }
            
            // Recent activity
            GroupBox("Recent Activity") {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.recentActivity.prefix(5)) { activity in
                        ActivityRow(activity: activity)
                        Divider()
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - PayLinc Dashboard
struct PayLincDashboard: View {
    @EnvironmentObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("PayLinc Platform")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Saudi Digital Payment Platform - OID 1.3.6.1.4.1.61026")
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            
            // PayLinc modules
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ModuleCard(
                    title: "Wallet Core",
                    icon: "wallet.pass.fill",
                    status: "Active",
                    metrics: [
                        "Balance": "SAR 45,678.90",
                        "Transactions": "1,234",
                        "Users": "5,678"
                    ]
                )
                
                ModuleCard(
                    title: "Healthcare Payments",
                    icon: "cross.case.fill",
                    status: "Active",
                    metrics: [
                        "Claims": "234",
                        "Providers": "89",
                        "Settlement": "< 24h"
                    ]
                )
                
                ModuleCard(
                    title: "BNPL (Murabaha)",
                    icon: "calendar.badge.clock",
                    status: "Active",
                    metrics: [
                        "Active": "156",
                        "Approved": "SAR 234K",
                        "Default Rate": "0.8%"
                    ]
                )
                
                ModuleCard(
                    title: "Cross-Border",
                    icon: "globe",
                    status: "Active",
                    metrics: [
                        "Corridors": "12",
                        "Volume": "$56,789",
                        "FX Rate": "3.75"
                    ]
                )
            }
            
            // NPHIES Integration Status
            GroupBox("NPHIES Healthcare Integration") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("Eligibility Checks", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Spacer()
                        Text("234 today")
                    }
                    
                    HStack {
                        Label("Claims Submitted", systemImage: "doc.text.fill")
                        Spacer()
                        Text("89 pending")
                    }
                    
                    HStack {
                        Label("Provider Settlements", systemImage: "building.columns.fill")
                        Spacer()
                        Text("45 completed")
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Supporting Views

struct MetricCard: View {
    let title: String
    let value: String
    let change: String
    let trend: Trend
    
    enum Trend {
        case up, down, stable
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            HStack {
                Image(systemName: trendIcon)
                    .foregroundStyle(trendColor)
                Text(change)
                    .font(.caption)
                    .foregroundStyle(trendColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    var trendIcon: String {
        switch trend {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }
    
    var trendColor: Color {
        switch trend {
        case .up: return .green
        case .down: return .red
        case .stable: return .blue
        }
    }
}

struct PaymentChannelIndicator: View {
    let name: String
    let status: Status
    let volume: String
    
    enum Status {
        case active, warning, error
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)
            
            Text(name)
                .font(.headline)
            
            Text(volume)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(8)
    }
    
    var statusColor: Color {
        switch status {
        case .active: return .green
        case .warning: return .orange
        case .error: return .red
        }
    }
}

struct ModuleCard: View {
    let title: String
    let icon: String
    let status: String
    let metrics: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Text(status)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green.opacity(0.2))
                    .foregroundStyle(.green)
                    .cornerRadius(4)
            }
            
            Divider()
            
            ForEach(Array(metrics.keys.sorted()), id: \.self) { key in
                HStack {
                    Text(key)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(metrics[key] ?? "")
                        .fontWeight(.semibold)
                }
                .font(.caption)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ActivityRow: View {
    let activity: Activity
    
    var body: some View {
        HStack {
            Image(systemName: activity.icon)
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading) {
                Text(activity.title)
                    .font(.subheadline)
                Text(activity.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(activity.time)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - View Model
class DashboardViewModel: ObservableObject {
    @Published var todayRevenue: Double = 45678.90
    @Published var activeAgents: Int = 16
    @Published var todayTransactions: Int = 1234
    @Published var activeWorkflows: Int = 8
    @Published var recentActivity: [Activity] = []
    
    init() {
        loadData()
        startRealtimeUpdates()
    }
    
    func loadData() {
        // Load initial data from backend
        recentActivity = [
            Activity(icon: "creditcard.fill", title: "Payment Processed", description: "PayLinc: SAR 1,234.56", time: "2 min ago"),
            Activity(icon: "cross.case.fill", title: "Healthcare Claim", description: "NPHIES approved", time: "5 min ago"),
            Activity(icon: "cpu.fill", title: "Agent Started", description: "DoctorLINC now active", time: "10 min ago"),
            Activity(icon: "arrow.triangle.branch", title: "Workflow Completed", description: "Patient registration", time: "15 min ago"),
            Activity(icon: "dollarsign.circle.fill", title: "SARIE Settlement", description: "SAR 5,678.90 settled", time: "20 min ago")
        ]
    }
    
    func startRealtimeUpdates() {
        // Connect to WebSocket for real-time updates
        Task {
            await connectWebSocket()
        }
    }
    
    func refresh() {
        loadData()
    }
    
    private func connectWebSocket() async {
        // WebSocket connection logic here
    }
}

// MARK: - Models
struct Activity: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let time: String
}

// Placeholder views for other sections
struct PaymentsDashboard: View {
    var body: some View {
        Text("Payments Dashboard")
            .font(.largeTitle)
    }
}

struct AgentsDashboard: View {
    var body: some View {
        Text("Agents Dashboard")
            .font(.largeTitle)
    }
}

struct WorkflowsDashboard: View {
    var body: some View {
        Text("Workflows Dashboard")
            .font(.largeTitle)
    }
}

struct AnalyticsDashboard: View {
    var body: some View {
        Text("Analytics Dashboard")
            .font(.largeTitle)
    }
}
