// BrainSAIT RHDTE - Facility Detail Sheet
// Bottom sheet showing comprehensive facility information

import SwiftUI
import MapKit

struct FacilityDetailSheet: View {
    let facility: Facility
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showBooking = false
    @State private var showDirections = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with image/icon
                    ZStack(alignment: .bottomLeading) {
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [Color("BrainSAITGreen"), Color("BrainSAITGreen").opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(height: 160)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(facility.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                Image(systemName: facility.type.icon)
                                Text(facility.type.rawValue)
                            }
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                    
                    VStack(spacing: 16) {
                        // Rating & Status
                        HStack {
                            // Rating
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text(String(format: "%.1f", facility.rating ?? 0))
                                    .fontWeight(.semibold)
                                Text("(\(facility.reviewCount))")
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Open Status
                            if facility.is24Hours {
                                Label("24 Hours", systemImage: "clock.fill")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green)
                                    .cornerRadius(8)
                            } else if let isOpen = facility.isOpen {
                                Label(isOpen ? "Open" : "Closed", systemImage: isOpen ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(isOpen ? Color.green : Color.red)
                                    .cornerRadius(8)
                            }
                        }
                        
                        Divider()
                        
                        // Quick Actions
                        HStack(spacing: 12) {
                            ActionButton(icon: "phone.fill", title: "Call") {
                                if let phone = facility.phone {
                                    callPhone(phone)
                                }
                            }
                            .disabled(facility.phone == nil)
                            
                            ActionButton(icon: "map.fill", title: "Directions") {
                                openMaps()
                            }
                            
                            ActionButton(icon: "globe", title: "Website") {
                                if let website = facility.website, let url = URL(string: website) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .disabled(facility.website == nil)
                            
                            ActionButton(icon: isSaved ? "heart.fill" : "heart", title: "Save") {
                                toggleSave()
                            }
                        }
                        
                        Divider()
                        
                        // Address
                        InfoRow(icon: "location.fill", title: "Address", value: facility.address)
                        
                        if let phone = facility.phone {
                            InfoRow(icon: "phone.fill", title: "Phone", value: phone)
                        }
                        
                        if let email = facility.email {
                            InfoRow(icon: "envelope.fill", title: "Email", value: email)
                        }
                        
                        Divider()
                        
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
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                    }
                                }
                            }
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
                                            .foregroundColor(.blue)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        // Digital Score (Premium Feature)
                        if let score = facility.digitalScore {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Digital Presence Score")
                                    .font(.headline)
                                
                                HStack {
                                    ProgressView(value: Double(score) / 100.0)
                                        .tint(scoreColor(score))
                                    
                                    Text("\(score)/100")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(scoreColor(score))
                                }
                                
                                if let level = facility.maturityLevel {
                                    Text("Level: \(level.capitalized)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        // Book Appointment Button
                        if facility.hasOnlineBooking {
                            Button(action: { showBooking = true }) {
                                Label("Book Appointment", systemImage: "calendar.badge.plus")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("BrainSAITGreen"))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isSaved: Bool {
        appState.savedFacilities.contains(facility.id)
    }
    
    private func toggleSave() {
        if isSaved {
            appState.removeFacility(facility.id)
        } else {
            appState.saveFacility(facility.id)
        }
    }
    
    private func callPhone(_ phone: String) {
        let cleaned = phone.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(cleaned)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openMaps() {
        let placemark = MKPlacemark(coordinate: facility.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = facility.displayName
        mapItem.openInMaps()
    }
    
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 0..<40: return .red
        case 40..<70: return .orange
        default: return .green
        }
    }
}

// MARK: - Supporting Views

struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color("BrainSAITGreen"))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
            }
            
            Spacer()
        }
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(subviews: subviews, width: proposal.width ?? 0)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(subviews: subviews, width: bounds.width)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func computeLayout(subviews: Subviews, width: CGFloat) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
        
        return (CGSize(width: width, height: currentY + lineHeight), positions)
    }
}
