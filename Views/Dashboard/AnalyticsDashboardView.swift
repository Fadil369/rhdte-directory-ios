// Brainsait Maplinc - Analytics Dashboard View
// Overall analytics and statistics for Riyadh healthcare facilities

import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    @EnvironmentObject var dataService: RiyadhHealthcareDataService

    var statistics: HealthcareStatistics {
        dataService.getStatistics()
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Stats
                    headerStats

                    // Category Breakdown Chart
                    categoryChart

                    // District Distribution
                    districtStats

                    // Features Overview
                    featuresOverview

                    // Top Rated Facilities
                    topRatedSection
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .refreshable {
                dataService.loadSampleRiyadhData()
            }
        }
    }

    // MARK: - Header Stats

    private var headerStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Riyadh Healthcare Overview")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                DashboardStatCard(
                    title: "Total Facilities",
                    value: "\(statistics.totalFacilities)",
                    icon: "building.2.fill",
                    color: .blue
                )

                DashboardStatCard(
                    title: "Districts",
                    value: "\(statistics.totalDistricts)",
                    icon: "map.fill",
                    color: .purple
                )

                DashboardStatCard(
                    title: "Avg Rating",
                    value: String(format: "%.1f", statistics.averageRating),
                    icon: "star.fill",
                    color: .yellow
                )

                DashboardStatCard(
                    title: "24/7 Services",
                    value: "\(statistics.facilitiesWith24Hours)",
                    icon: "clock.fill",
                    color: .green
                )
            }
        }
    }

    // MARK: - Category Chart

    private var categoryChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Facilities by Category")
                .font(.headline)

            Chart {
                ForEach(Array(statistics.categoryBreakdown.sorted { $0.value > $1.value }), id: \.key) { category, count in
                    BarMark(
                        x: .value("Count", count),
                        y: .value("Category", category.rawValue)
                    )
                    .foregroundStyle(categoryColor(for: category).gradient)
                    .annotation(position: .trailing) {
                        Text("\(count)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .chartXAxis(.hidden)
            .frame(height: CGFloat(statistics.categoryBreakdown.count * 40))
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }

    // MARK: - District Stats

    private var districtStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Districts")
                .font(.headline)

            let sortedDistricts = statistics.districtBreakdown
                .sorted { $0.value > $1.value }
                .prefix(10)

            ForEach(Array(sortedDistricts), id: \.key) { district, count in
                HStack {
                    Text(district.rawValue)
                        .font(.subheadline)

                    Text(district.arabicName)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(count)")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    // Progress bar
                    let maxCount = statistics.districtBreakdown.values.max() ?? 1
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color("BrainSAITGreen").opacity(0.3))
                            .frame(width: geometry.size.width)
                            .overlay(
                                HStack {
                                    Rectangle()
                                        .fill(Color("BrainSAITGreen"))
                                        .frame(width: geometry.size.width * CGFloat(count) / CGFloat(maxCount))
                                    Spacer(minLength: 0)
                                }
                            )
                    }
                    .frame(width: 60, height: 8)
                    .cornerRadius(4)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - Features Overview

    private var featuresOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available Features")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                FeatureStatCard(
                    title: "Emergency",
                    count: statistics.facilitiesWithEmergency,
                    total: statistics.totalFacilities,
                    icon: "cross.circle.fill",
                    color: .red
                )

                FeatureStatCard(
                    title: "Online Booking",
                    count: statistics.facilitiesWithOnlineBooking,
                    total: statistics.totalFacilities,
                    icon: "calendar.badge.clock",
                    color: .green
                )

                FeatureStatCard(
                    title: "Telemedicine",
                    count: statistics.facilitiesWithTelemedicine,
                    total: statistics.totalFacilities,
                    icon: "video.fill",
                    color: .blue
                )

                FeatureStatCard(
                    title: "24/7 Open",
                    count: statistics.facilitiesWith24Hours,
                    total: statistics.totalFacilities,
                    icon: "clock.fill",
                    color: .orange
                )
            }
        }
    }

    // MARK: - Top Rated Section

    private var topRatedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Rated Facilities")
                .font(.headline)

            let topRated = dataService.facilities
                .sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
                .prefix(5)

            ForEach(Array(topRated)) { facility in
                HStack {
                    Image(systemName: facility.category.icon)
                        .foregroundColor(categoryColor(for: facility.category))
                        .frame(width: 30)

                    VStack(alignment: .leading) {
                        Text(facility.nameEn)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)

                        Text(facility.category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)

                        Text(String(format: "%.1f", facility.rating ?? 0))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.vertical, 6)

                if facility.id != topRated.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - Helper

    private func categoryColor(for category: HealthcareCategory) -> Color {
        switch category {
        case .tertiary: return .red
        case .secondary: return .orange
        case .primary: return .blue
        case .specialty: return .purple
        case .dental: return .cyan
        case .pharmacy: return .green
        case .laboratory: return .indigo
        case .imaging: return .teal
        case .rehabilitation: return .mint
        case .homecare: return .pink
        }
    }
}

// MARK: - Dashboard Stat Card

struct DashboardStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
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
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Feature Stat Card

struct FeatureStatCard: View {
    let title: String
    let count: Int
    let total: Int
    let icon: String
    let color: Color

    var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total) * 100
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)

                Spacer()

                Text("\(Int(percentage))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }

            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            // Progress bar
            GeometryReader { geometry in
                Rectangle()
                    .fill(color.opacity(0.2))
                    .frame(width: geometry.size.width)
                    .overlay(
                        HStack {
                            Rectangle()
                                .fill(color)
                                .frame(width: geometry.size.width * CGFloat(percentage / 100))
                            Spacer(minLength: 0)
                        }
                    )
            }
            .frame(height: 4)
            .cornerRadius(2)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}
