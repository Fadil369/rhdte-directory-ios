// BrainSAIT RHDTE - Dashboard View
// Analytics and statistics dashboard for subscribers

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Overview Cards
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(
                            title: "Total Facilities",
                            value: "\(viewModel.stats.totalFacilities)",
                            icon: "building.2.fill",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Districts",
                            value: "\(viewModel.stats.totalDistricts)",
                            icon: "map.fill",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Avg Rating",
                            value: String(format: "%.1f", viewModel.stats.avgRating),
                            icon: "star.fill",
                            color: .yellow
                        )
                        
                        StatCard(
                            title: "Saved",
                            value: "\(appState.savedFacilities.count)",
                            icon: "heart.fill",
                            color: .red
                        )
                    }
                    
                    // Facility Type Breakdown
                    if !viewModel.stats.facilityTypeBreakdown.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Facility Types")
                                .font(.headline)
                            
                            Chart {
                                ForEach(Array(viewModel.stats.facilityTypeBreakdown.sorted(by: { $0.value > $1.value }).prefix(5)), id: \.key) { type, count in
                                    BarMark(
                                        x: .value("Count", count),
                                        y: .value("Type", type)
                                    )
                                    .foregroundStyle(Color("BrainSAITGreen"))
                                }
                            }
                            .frame(height: 200)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Top Districts
                    if !viewModel.stats.topDistricts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top Districts")
                                .font(.headline)
                            
                            ForEach(viewModel.stats.topDistricts, id: \.self) { district in
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(Color("BrainSAITGreen"))
                                    Text(district)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                                
                                if district != viewModel.stats.topDistricts.last {
                                    Divider()
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.headline)
                        
                        ForEach(viewModel.recentActivities, id: \.id) { activity in
                            HStack {
                                Image(systemName: activity.icon)
                                    .foregroundColor(Color("BrainSAITGreen"))
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(activity.title)
                                        .font(.subheadline)
                                    Text(activity.timestamp)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Premium CTA for Free Users
                    if appState.currentUser?.subscriptionTier == .free || !appState.isAuthenticated {
                        VStack(spacing: 12) {
                            Image(systemName: "crown.fill")
                                .font(.largeTitle)
                                .foregroundColor(.yellow)
                            
                            Text("Unlock Premium Analytics")
                                .font(.headline)
                            
                            Text("Get detailed insights, digital scores, and more")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: { appState.showLeadMagnet = true }) {
                                Text("Upgrade Now")
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color("BrainSAITGreen"))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .refreshable {
                await viewModel.refresh()
            }
        }
        .onAppear {
            viewModel.loadStats()
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Activity Model
struct Activity: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let timestamp: String
}

// MARK: - Dashboard View Model
class DashboardViewModel: ObservableObject {
    @Published var stats = DashboardStats(
        totalFacilities: 0,
        totalDistricts: 0,
        avgRating: 0,
        facilityTypeBreakdown: [:],
        topDistricts: []
    )
    @Published var recentActivities: [Activity] = []
    
    func loadStats() {
        Task {
            do {
                let stats = try await APIService.shared.fetchDashboardStats()
                DispatchQueue.main.async {
                    self.stats = stats
                }
            } catch {
                // Load sample stats
                DispatchQueue.main.async {
                    self.stats = DashboardStats(
                        totalFacilities: 1247,
                        totalDistricts: 15,
                        avgRating: 4.2,
                        facilityTypeBreakdown: [
                            "Hospital": 45,
                            "Clinic": 320,
                            "Pharmacy": 512,
                            "Dental": 180,
                            "Laboratory": 190
                        ],
                        topDistricts: ["Olaya", "Al Malaz", "Al Sahafa", "Hittin", "Al Yasmin"]
                    )
                    
                    self.recentActivities = [
                        Activity(title: "Searched for dental clinics", icon: "magnifyingglass", timestamp: "2 hours ago"),
                        Activity(title: "Saved Kingdom Hospital", icon: "heart.fill", timestamp: "Yesterday"),
                        Activity(title: "Viewed Al Noor Pharmacy", icon: "eye.fill", timestamp: "2 days ago")
                    ]
                }
            }
        }
    }
    
    func refresh() async {
        loadStats()
    }
}
