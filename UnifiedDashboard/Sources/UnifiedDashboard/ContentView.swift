import SwiftUI

struct ContentView: View {
    @State private var selectedSection: DashboardSection = .overview
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedSection: $selectedSection)
        } detail: {
            DetailView(section: selectedSection)
        }
        .frame(minWidth: 1200, minHeight: 800)
    }
}

enum DashboardSection: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case paylinc = "PayLinc Platform"
    case payments = "Payment Channels"
    case healthcare = "Healthcare Payments"
    case murabaha = "Murabaha BNPL"
    case mcpServer = "MCP Server"
    case workflows = "Workflows"
    case agents = "AI Agents"
    case a2a = "A2A Integrations"
    case tasks = "Tasks"
    case apps = "Apps & Services"
    case monitoring = "Monitoring"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .overview: return "chart.bar.doc.horizontal"
        case .paylinc: return "banknote.fill"
        case .payments: return "creditcard"
        case .healthcare: return "cross.case.fill"
        case .murabaha: return "crescent.fill"
        case .mcpServer: return "brain.head.profile"
        case .workflows: return "arrow.triangle.branch"
        case .agents: return "sparkles"
        case .a2a: return "arrow.left.arrow.right"
        case .tasks: return "checklist"
        case .apps: return "app.badge"
        case .monitoring: return "chart.xyaxis.line"
        }
    }
}

struct SidebarView: View {
    @Binding var selectedSection: DashboardSection
    
    var body: some View {
        List(DashboardSection.allCases, selection: $selectedSection) { section in
            NavigationLink(value: section) {
                Label(section.rawValue, systemImage: section.icon)
            }
        }
        .navigationTitle("Dashboard")
        .frame(minWidth: 200)
    }
}

struct DetailView: View {
    let section: DashboardSection
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                
                switch section {
                case .overview:
                    OverviewView()
                case .paylinc:
                    PayLincDashboardView()
                case .payments:
                    PaymentChannelsView()
                case .healthcare:
                    HealthcarePaymentsView()
                case .murabaha:
                    MurabahaBNPLView()
                case .mcpServer:
                    MCPDashboardView()
                case .workflows:
                    WorkflowsView()
                case .agents:
                    AgentsView()
                case .a2a:
                    A2AView()
                case .tasks:
                    TasksView()
                case .apps:
                    AppsServicesView()
                case .monitoring:
                    MonitoringView()
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: section.icon)
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
                Text(section.rawValue)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Text(Date.now.formatted(date: .abbreviated, time: .shortened))
                    .foregroundStyle(.secondary)
            }
            Divider()
        }
    }
}
