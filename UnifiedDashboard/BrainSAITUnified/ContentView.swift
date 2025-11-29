//
//  ContentView.swift
//  BrainSAIT Unified Platform
//
//  Created by BrainSAIT on 2024-11-29.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    @State private var selectedTab: DashboardTab = .paylinc
    @State private var showSidebar = true
    
    var body: some View {
        NavigationSplitView(columnVisibility: showSidebar ? .constant(.all) : .constant(.detailOnly)) {
            SidebarView(selectedTab: $selectedTab)
        } detail: {
            DetailView(selectedTab: selectedTab)
        }
        .navigationSplitViewStyle(.balanced)
        .task {
            await networkManager.startMonitoring()
        }
    }
}

enum DashboardTab: String, CaseIterable, Identifiable {
    case paylinc = "PayLinc"
    case agents = "LINC Agents"
    case mcp = "MCP Servers"
    case analytics = "Analytics"
    case settings = "Settings"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .paylinc: return "creditcard.fill"
        case .agents: return "brain.head.profile"
        case .mcp: return "server.rack"
        case .analytics: return "chart.xyaxis.line"
        case .settings: return "gearshape.fill"
        }
    }
}

struct SidebarView: View {
    @Binding var selectedTab: DashboardTab
    @State private var currentTime = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        List(DashboardTab.allCases, selection: $selectedTab) { tab in
            NavigationLink(value: tab) {
                Label(tab.rawValue, systemImage: tab.icon)
            }
        }
        .navigationTitle("BrainSAIT")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentTime, style: .time)
                        .font(.caption)
                    Text(currentTime, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .onReceive(timer) { _ in
                    currentTime = Date()
                }
            }
        }
    }
}

struct DetailView: View {
    let selectedTab: DashboardTab
    @EnvironmentObject var dashboardViewModel: DashboardViewModel
    @State private var isArabic: Bool = false
    
    var body: some View {
        Group {
            switch selectedTab {
            case .paylinc:
                PayLincDashboardView(isArabic: isArabic)
                    .environmentObject(dashboardViewModel)
            case .agents:
                AgentsDashboardView(isArabic: isArabic)
                    .environmentObject(dashboardViewModel)
            case .mcp:
                MCPDashboardView()
            case .analytics:
                AnalyticsView()
            case .settings:
                SettingsView()
            }
        }
        .navigationTitle(selectedTab.rawValue)
    }
}

struct AnalyticsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Analytics Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Coming Soon")
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}

struct SettingsView: View {
    @AppStorage("apiEndpoint") private var apiEndpoint = "http://localhost:8021"
    @AppStorage("refreshInterval") private var refreshInterval = 30.0
    @AppStorage("enableNotifications") private var enableNotifications = true
    @EnvironmentObject var networkManager: NetworkManager
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Connection Status")
                    Spacer()
                    Circle()
                        .fill(networkManager.isConnected ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    Text(networkManager.isConnected ? "Connected" : "Disconnected")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("System")
            }
            
            Section("API Configuration") {
                TextField("API Endpoint", text: $apiEndpoint)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    Text("Refresh Interval")
                    Spacer()
                    Text("\(Int(refreshInterval))s")
                        .foregroundStyle(.secondary)
                }
                Slider(value: $refreshInterval, in: 10...120, step: 10)
            }
            
            Section("Notifications") {
                Toggle("Enable Notifications", isOn: $enableNotifications)
            }
            
            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Build", value: "1")
                LabeledContent("Platform", value: "macOS • iOS")
                LabeledContent("Created", value: "2024-11-29")
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: 600)
    }
}

#Preview {
    NavigationSplitView {
        SidebarView(selectedTab: .constant(.paylinc))
    } detail: {
        DetailView(selectedTab: .paylinc)
            .environmentObject(DashboardViewModel())
    }
    .environmentObject(NetworkManager())
}
