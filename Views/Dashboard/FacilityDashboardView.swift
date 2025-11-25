// Brainsait Maplinc - Facility Dashboard View
// Individual facility dashboard with analytics and paid services

import SwiftUI
import Charts

struct FacilityDashboardView: View {
    let facility: EnhancedFacility
    @State private var selectedTimeRange: TimeRange = .month
    @State private var showPaidServicesSheet = false
    @State private var selectedService: PaidService?

    enum TimeRange: String, CaseIterable {
        case week = "7 Days"
        case month = "30 Days"
        case quarter = "90 Days"
        case year = "Year"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                facilityHeader

                // Quick Stats
                quickStatsSection

                // Analytics Charts
                analyticsSection

                // Paid Services
                paidServicesSection

                // Performance Insights
                performanceInsightsSection

                // Digital Score
                digitalScoreSection
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaidServicesSheet) {
            PaidServicesManagementView(facility: facility)
        }
        .sheet(item: $selectedService) { service in
            ServiceDetailView(service: service, facility: facility)
        }
    }

    // MARK: - Facility Header

    private var facilityHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(facility.displayName)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(facility.category.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(facility.ratingStars)
                            .fontWeight(.medium)
                        Text("(\(facility.reviewCount) reviews)")
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                }

                Spacer()

                VStack {
                    Image(systemName: facility.category.icon)
                        .font(.system(size: 40))
                        .foregroundColor(Color("BrainSAITGreen"))

                    if facility.dashboardEnabled {
                        Text("Active")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                }
            }

            // Time Range Picker
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }

    // MARK: - Quick Stats Section

    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Overview")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCard(
                    title: "Profile Views",
                    value: "\(facility.analytics?.viewCount ?? 0)",
                    icon: "eye.fill",
                    color: .blue,
                    trend: "+12%"
                )

                StatCard(
                    title: "Saved",
                    value: "\(facility.analytics?.saveCount ?? 0)",
                    icon: "heart.fill",
                    color: .red,
                    trend: "+8%"
                )

                StatCard(
                    title: "Contact Clicks",
                    value: "\(facility.analytics?.contactClicks ?? 0)",
                    icon: "phone.fill",
                    color: .green,
                    trend: "+15%"
                )

                StatCard(
                    title: "Bookings",
                    value: "\(facility.analytics?.bookingClicks ?? 0)",
                    icon: "calendar",
                    color: .orange,
                    trend: "+20%"
                )

                StatCard(
                    title: "Directions",
                    value: "\(facility.analytics?.directionClicks ?? 0)",
                    icon: "map.fill",
                    color: .purple,
                    trend: "+5%"
                )

                StatCard(
                    title: "Shares",
                    value: "\(facility.analytics?.shareCount ?? 0)",
                    icon: "square.and.arrow.up",
                    color: .teal,
                    trend: "+10%"
                )
            }
        }
    }

    // MARK: - Analytics Section

    private var analyticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Engagement Analytics")
                .font(.headline)

            // Views Chart
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Views")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Chart {
                    ForEach(generateSampleViewData(), id: \.day) { data in
                        BarMark(
                            x: .value("Day", data.day),
                            y: .value("Views", data.views)
                        )
                        .foregroundStyle(Color("BrainSAITGreen").gradient)
                    }
                }
                .frame(height: 200)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)

            // Conversion Funnel
            VStack(alignment: .leading, spacing: 8) {
                Text("Conversion Funnel")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                FunnelChart(
                    searches: facility.analytics?.searchAppearances ?? 0,
                    views: facility.analytics?.viewCount ?? 0,
                    contacts: facility.analytics?.contactClicks ?? 0,
                    bookings: facility.analytics?.bookingClicks ?? 0
                )
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }

    // MARK: - Paid Services Section

    private var paidServicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Paid Services")
                    .font(.headline)

                Spacer()

                Button("Manage") {
                    showPaidServicesSheet = true
                }
                .font(.subheadline)
                .foregroundColor(Color("BrainSAITGreen"))
            }

            // Active Services
            let enabledServices = facility.paidServices.filter { $0.isEnabled }

            if enabledServices.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)

                    Text("No active services")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("Boost your visibility with premium services")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Explore Services") {
                        showPaidServicesSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("BrainSAITGreen"))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                ForEach(enabledServices) { service in
                    ServiceRow(service: service) {
                        selectedService = service
                    }
                }
            }

            // Recommended Services
            let recommendedServices = facility.paidServices.filter { !$0.isEnabled }.prefix(2)

            if !recommendedServices.isEmpty {
                Text("Recommended for You")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                ForEach(Array(recommendedServices)) { service in
                    RecommendedServiceRow(service: service) {
                        selectedService = service
                    }
                }
            }
        }
    }

    // MARK: - Performance Insights

    private var performanceInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Insights")
                .font(.headline)

            VStack(spacing: 8) {
                InsightRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Visibility Trend",
                    description: "Your profile views increased by 12% this month",
                    type: .positive
                )

                InsightRow(
                    icon: "star.fill",
                    title: "Rating Opportunity",
                    description: "Encourage satisfied patients to leave reviews",
                    type: .suggestion
                )

                InsightRow(
                    icon: "clock.fill",
                    title: "Peak Hours",
                    description: "Most users view your profile between 9-11 AM",
                    type: .info
                )

                if !facility.hasOnlineBooking {
                    InsightRow(
                        icon: "exclamationmark.triangle.fill",
                        title: "Missing Feature",
                        description: "Enable online booking to increase conversions",
                        type: .warning
                    )
                }
            }
        }
    }

    // MARK: - Digital Score Section

    private var digitalScoreSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Digital Maturity Score")
                .font(.headline)

            VStack(spacing: 16) {
                // Score Circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)

                    Circle()
                        .trim(from: 0, to: CGFloat(facility.digitalScore ?? 0) / 100)
                        .stroke(
                            scoreColor(for: facility.digitalScore ?? 0),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    VStack {
                        Text("\(facility.digitalScore ?? 0)")
                            .font(.system(size: 36, weight: .bold))

                        Text("out of 100")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 120, height: 120)

                Text(facility.maturityLevel ?? "Intermediate")
                    .font(.headline)
                    .foregroundColor(scoreColor(for: facility.digitalScore ?? 0))

                // Score Breakdown
                VStack(spacing: 8) {
                    ScoreBreakdownRow(label: "Website", score: 85)
                    ScoreBreakdownRow(label: "Mobile", score: 70)
                    ScoreBreakdownRow(label: "Online Booking", score: facility.hasOnlineBooking ? 100 : 0)
                    ScoreBreakdownRow(label: "Social Media", score: 60)
                    ScoreBreakdownRow(label: "Reviews", score: Int((facility.rating ?? 0) * 20))
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }

    // MARK: - Helper Methods

    private func scoreColor(for score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60...79: return .orange
        default: return .red
        }
    }

    private func generateSampleViewData() -> [DayViewData] {
        let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return days.enumerated().map { index, day in
            DayViewData(day: day, views: Int.random(in: 50...200))
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)

                Spacer()

                Text(trend)
                    .font(.caption2)
                    .foregroundColor(.green)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3)
    }
}

struct ServiceRow: View {
    let service: PaidService
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.nameEn)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text("\(Int(service.monthlyPrice)) SAR/month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("Active")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(4)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
        }
    }
}

struct RecommendedServiceRow: View {
    let service: PaidService
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.nameEn)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(service.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Text("\(Int(service.monthlyPrice)) SAR")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color("BrainSAITGreen"))

                Image(systemName: "plus.circle.fill")
                    .foregroundColor(Color("BrainSAITGreen"))
            }
            .padding()
            .background(Color("BrainSAITGreen").opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct InsightRow: View {
    let icon: String
    let title: String
    let description: String
    let type: InsightType

    enum InsightType {
        case positive, warning, suggestion, info

        var color: Color {
            switch self {
            case .positive: return .green
            case .warning: return .orange
            case .suggestion: return .blue
            case .info: return .gray
            }
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(type.color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(type.color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct FunnelChart: View {
    let searches: Int
    let views: Int
    let contacts: Int
    let bookings: Int

    var body: some View {
        VStack(spacing: 8) {
            FunnelRow(label: "Searches", value: searches, percentage: 100, color: .blue)
            FunnelRow(label: "Views", value: views, percentage: Double(views) / Double(max(searches, 1)) * 100, color: .purple)
            FunnelRow(label: "Contacts", value: contacts, percentage: Double(contacts) / Double(max(searches, 1)) * 100, color: .orange)
            FunnelRow(label: "Bookings", value: bookings, percentage: Double(bookings) / Double(max(searches, 1)) * 100, color: .green)
        }
    }
}

struct FunnelRow: View {
    let label: String
    let value: Int
    let percentage: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)

                Spacer()

                Text("\(value)")
                    .font(.caption)
                    .fontWeight(.medium)
            }

            GeometryReader { geometry in
                Rectangle()
                    .fill(color.opacity(0.3))
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
            .frame(height: 8)
            .cornerRadius(4)
        }
    }
}

struct ScoreBreakdownRow: View {
    let label: String
    let score: Int

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            ProgressView(value: Double(score), total: 100)
                .frame(width: 100)
                .tint(scoreColor)

            Text("\(score)")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 30)
        }
    }

    private var scoreColor: Color {
        switch score {
        case 80...100: return .green
        case 60...79: return .orange
        default: return .red
        }
    }
}

struct DayViewData {
    let day: String
    let views: Int
}

// MARK: - Paid Services Management View

struct PaidServicesManagementView: View {
    let facility: EnhancedFacility
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Plan
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Subscription")
                            .font(.headline)

                        let activeCount = facility.paidServices.filter { $0.isEnabled }.count
                        let totalCost = facility.paidServices.filter { $0.isEnabled }.reduce(0) { $0 + $1.monthlyPrice }

                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(activeCount) Active Services")
                                    .font(.title3)
                                    .fontWeight(.bold)

                                Text("Total: \(Int(totalCost)) SAR/month")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Button("Upgrade") {
                                // Handle upgrade
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color("BrainSAITGreen"))
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    // All Services
                    ForEach(PaidService.ServiceCategory.allCases, id: \.self) { category in
                        let services = facility.paidServices.filter { $0.category == category }

                        if !services.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(category.rawValue)
                                    .font(.headline)

                                ForEach(services) { service in
                                    PaidServiceCard(service: service)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Paid Services")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PaidServiceCard: View {
    let service: PaidService
    @State private var isEnabled: Bool

    init(service: PaidService) {
        self.service = service
        self._isEnabled = State(initialValue: service.isEnabled)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.nameEn)
                        .font(.headline)

                    Text(service.nameAr)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("\(Int(service.monthlyPrice)) SAR")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("BrainSAITGreen"))

                    Text("per month")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Text(service.description)
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Features
            VStack(alignment: .leading, spacing: 4) {
                ForEach(service.features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color("BrainSAITGreen"))
                            .font(.caption)

                        Text(feature)
                            .font(.caption)
                    }
                }
            }

            Toggle(isOn: $isEnabled) {
                Text(isEnabled ? "Active" : "Enable")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .tint(Color("BrainSAITGreen"))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Service Detail View

struct ServiceDetailView: View {
    let service: PaidService
    let facility: EnhancedFacility
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Service Info
                    VStack(spacing: 16) {
                        Image(systemName: serviceIcon)
                            .font(.system(size: 50))
                            .foregroundColor(Color("BrainSAITGreen"))

                        Text(service.nameEn)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(service.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Text("\(Int(service.monthlyPrice)) SAR/month")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color("BrainSAITGreen"))
                    }
                    .padding()

                    // Features
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Included Features")
                            .font(.headline)

                        ForEach(service.features, id: \.self) { feature in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color("BrainSAITGreen"))

                                Text(feature)
                                    .font(.body)

                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // CTA Button
                    Button {
                        // Handle subscription
                        dismiss()
                    } label: {
                        Text(service.isEnabled ? "Manage Subscription" : "Subscribe Now")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("BrainSAITGreen"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var serviceIcon: String {
        switch service.category {
        case .visibility: return "eye.fill"
        case .booking: return "calendar"
        case .analytics: return "chart.bar.fill"
        case .marketing: return "megaphone.fill"
        case .premium: return "crown.fill"
        }
    }
}

// MARK: - Extension for CaseIterable

extension PaidService.ServiceCategory: CaseIterable {
    static var allCases: [PaidService.ServiceCategory] {
        [.visibility, .booking, .analytics, .marketing, .premium]
    }
}
