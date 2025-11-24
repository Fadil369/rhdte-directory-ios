// Brainsait Maplinc - Enhanced Map View
// Interactive map with healthcare facility markers for Riyadh

import SwiftUI
import MapKit

struct EnhancedMapView: View {
    @EnvironmentObject var dataService: RiyadhHealthcareDataService
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    )
    @State private var selectedFacility: EnhancedFacility?
    @State private var showFilters = false
    @State private var searchText = ""

    // Filters
    @State private var selectedCategory: HealthcareCategory?
    @State private var selectedDistrict: RiyadhDistrict?
    @State private var filter24Hours = false
    @State private var filterEmergency = false
    @State private var filterOnlineBooking = false
    @State private var minRating: Double = 0

    var filteredFacilities: [EnhancedFacility] {
        dataService.filterFacilities(
            category: selectedCategory,
            district: selectedDistrict,
            minRating: minRating > 0 ? minRating : nil,
            is24Hours: filter24Hours ? true : nil,
            hasEmergency: filterEmergency ? true : nil,
            hasOnlineBooking: filterOnlineBooking ? true : nil,
            searchQuery: searchText.isEmpty ? nil : searchText
        )
    }

    var body: some View {
        ZStack {
            // Map
            Map(coordinateRegion: $region, annotationItems: filteredFacilities) { facility in
                MapAnnotation(coordinate: facility.coordinate) {
                    FacilityMapMarker(facility: facility) {
                        selectedFacility = facility
                    }
                }
            }
            .ignoresSafeArea(edges: .top)

            // Search and Filter Overlay
            VStack {
                // Search Bar
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)

                        TextField("Search facilities...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(12)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.1), radius: 5)

                    Button {
                        showFilters = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title3)
                            .padding(12)
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.1), radius: 5)
                    }
                }
                .padding()

                // Category Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(
                            title: "All",
                            icon: "square.grid.2x2",
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }

                        ForEach(HealthcareCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                title: category.rawValue,
                                icon: category.icon,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()

                // Bottom Stats Bar
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(filteredFacilities.count) facilities")
                            .font(.headline)

                        Text("in Riyadh")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button {
                        // Reset to Riyadh center
                        withAnimation {
                            region = MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
                                span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
                            )
                        }
                    } label: {
                        Image(systemName: "location.fill")
                            .padding(12)
                            .background(Color("BrainSAITGreen"))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .padding()
                .background(
                    Color(.systemBackground)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
                )
            }
        }
        .sheet(item: $selectedFacility) { facility in
            EnhancedFacilityDetailSheet(facility: facility)
        }
        .sheet(isPresented: $showFilters) {
            FilterSheet(
                selectedCategory: $selectedCategory,
                selectedDistrict: $selectedDistrict,
                filter24Hours: $filter24Hours,
                filterEmergency: $filterEmergency,
                filterOnlineBooking: $filterOnlineBooking,
                minRating: $minRating
            )
        }
    }
}

// MARK: - Facility Map Marker

struct FacilityMapMarker: View {
    let facility: EnhancedFacility
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(markerColor)
                        .frame(width: 36, height: 36)

                    Image(systemName: facility.category.icon)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }

                // Triangle pointer
                Triangle()
                    .fill(markerColor)
                    .frame(width: 12, height: 8)
                    .offset(y: -2)
            }
        }
    }

    private var markerColor: Color {
        switch facility.category {
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

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color("BrainSAITGreen") : Color(.systemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 3)
        }
    }
}

// MARK: - Filter Sheet

struct FilterSheet: View {
    @Binding var selectedCategory: HealthcareCategory?
    @Binding var selectedDistrict: RiyadhDistrict?
    @Binding var filter24Hours: Bool
    @Binding var filterEmergency: Bool
    @Binding var filterOnlineBooking: Bool
    @Binding var minRating: Double
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                // Category Section
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("All Categories").tag(nil as HealthcareCategory?)
                        ForEach(HealthcareCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category as HealthcareCategory?)
                        }
                    }
                }

                // District Section
                Section("District") {
                    Picker("District", selection: $selectedDistrict) {
                        Text("All Districts").tag(nil as RiyadhDistrict?)
                        ForEach(RiyadhDistrict.allCases, id: \.self) { district in
                            Text("\(district.rawValue) (\(district.arabicName))")
                                .tag(district as RiyadhDistrict?)
                        }
                    }
                }

                // Features Section
                Section("Features") {
                    Toggle("Open 24 Hours", isOn: $filter24Hours)
                    Toggle("Has Emergency", isOn: $filterEmergency)
                    Toggle("Online Booking", isOn: $filterOnlineBooking)
                }

                // Rating Section
                Section("Minimum Rating") {
                    VStack(alignment: .leading) {
                        HStack {
                            ForEach(0..<5) { index in
                                Image(systemName: Double(index) < minRating ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                            Text(minRating > 0 ? String(format: "%.1f+", minRating) : "Any")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Slider(value: $minRating, in: 0...5, step: 0.5)
                            .tint(Color("BrainSAITGreen"))
                    }
                }

                // Reset Button
                Section {
                    Button("Reset All Filters") {
                        selectedCategory = nil
                        selectedDistrict = nil
                        filter24Hours = false
                        filterEmergency = false
                        filterOnlineBooking = false
                        minRating = 0
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Enhanced Facility Detail Sheet

struct EnhancedFacilityDetailSheet: View {
    let facility: EnhancedFacility
    @Environment(\.dismiss) var dismiss
    @State private var showFullDetails = false
    @State private var showDashboard = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header Image
                    if let primaryImage = facility.images.first(where: { $0.isPrimary }) {
                        AsyncImage(url: URL(string: primaryImage.url)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            default:
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .overlay(
                                        Image(systemName: facility.category.icon)
                                            .font(.system(size: 50))
                                            .foregroundColor(.gray)
                                    )
                            }
                        }
                        .frame(height: 200)
                        .clipped()
                    }

                    VStack(spacing: 16) {
                        // Facility Info
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(facility.displayName)
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Spacer()

                                if facility.dashboardEnabled {
                                    Button {
                                        showDashboard = true
                                    } label: {
                                        Image(systemName: "chart.bar.fill")
                                            .padding(8)
                                            .background(Color("BrainSAITGreen").opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                }
                            }

                            // Category and Type
                            HStack {
                                Label(facility.category.rawValue, systemImage: facility.category.icon)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color("BrainSAITGreen").opacity(0.2))
                                    .foregroundColor(Color("BrainSAITGreen"))
                                    .cornerRadius(4)

                                if facility.is24Hours {
                                    Label("24/7", systemImage: "clock.fill")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .cornerRadius(4)
                                }

                                if facility.hasEmergency {
                                    Label("ER", systemImage: "cross.circle.fill")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.red.opacity(0.2))
                                        .foregroundColor(.red)
                                        .cornerRadius(4)
                                }
                            }

                            // Rating
                            HStack {
                                ForEach(0..<5) { index in
                                    Image(systemName: Double(index) < (facility.rating ?? 0) ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                }
                                Text(facility.ratingStars)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("(\(facility.reviewCount) reviews)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            // Address
                            Label(facility.address, systemImage: "mappin")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)

                        Divider()

                        // Contact Actions
                        HStack(spacing: 12) {
                            if let phone = facility.phone {
                                ActionButton(icon: "phone.fill", title: "Call", color: .green) {
                                    if let url = URL(string: "tel:\(phone)") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }

                            if facility.hasWhatsApp, let whatsapp = facility.whatsapp {
                                ActionButton(icon: "message.fill", title: "WhatsApp", color: .green) {
                                    if let url = URL(string: "https://wa.me/\(whatsapp)") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }

                            ActionButton(icon: "map.fill", title: "Directions", color: .blue) {
                                let coordinate = facility.coordinate
                                if let url = URL(string: "maps://?daddr=\(coordinate.latitude),\(coordinate.longitude)") {
                                    UIApplication.shared.open(url)
                                }
                            }

                            if let website = facility.website {
                                ActionButton(icon: "globe", title: "Website", color: .purple) {
                                    if let url = URL(string: website) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)

                        Divider()

                        // Specialties
                        if !facility.specialties.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Specialties")
                                    .font(.headline)

                                FlowLayout(spacing: 8) {
                                    ForEach(facility.specialties, id: \.self) { specialty in
                                        Text(specialty)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Services
                        if !facility.services.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Services")
                                    .font(.headline)

                                FlowLayout(spacing: 8) {
                                    ForEach(facility.services, id: \.self) { service in
                                        Text(service)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color("BrainSAITGreen").opacity(0.1))
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Insurance
                        if !facility.insuranceAccepted.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Insurance Accepted")
                                    .font(.headline)

                                FlowLayout(spacing: 8) {
                                    ForEach(facility.insuranceAccepted, id: \.self) { insurance in
                                        Text(insurance)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Accreditations
                        if !facility.accreditations.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Accreditations")
                                    .font(.headline)

                                HStack {
                                    ForEach(facility.accreditations, id: \.self) { accreditation in
                                        VStack {
                                            Image(systemName: "checkmark.seal.fill")
                                                .font(.title2)
                                                .foregroundColor(Color("BrainSAITGreen"))
                                            Text(accreditation)
                                                .font(.caption2)
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Book Appointment Button
                        if facility.hasOnlineBooking {
                            Button {
                                // Handle booking
                            } label: {
                                Label("Book Appointment", systemImage: "calendar.badge.plus")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("BrainSAITGreen"))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            // Share
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }

                        Button {
                            // Save
                        } label: {
                            Image(systemName: "heart")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showDashboard) {
            NavigationView {
                FacilityDashboardView(facility: facility)
            }
        }
    }
}

// MARK: - Action Button

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(8)
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        let containerWidth = proposal.width ?? .infinity

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > containerWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxWidth = max(maxWidth, currentX)
        }

        return (CGSize(width: maxWidth, height: currentY + lineHeight), positions)
    }
}
