// Brainsait Maplinc - Healthcare ViewModel
// ViewModel for managing healthcare facility data and user interactions

import Foundation
import Combine
import CoreLocation

@MainActor
class HealthcareViewModel: ObservableObject {
    @Published var selectedFacility: EnhancedFacility?
    @Published var isLoading = false
    @Published var error: String?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Facility Actions

    func selectFacility(_ facility: EnhancedFacility) {
        selectedFacility = facility
    }

    func clearSelection() {
        selectedFacility = nil
    }

    // MARK: - Contact Actions

    func callFacility(_ facility: EnhancedFacility) {
        guard let phone = facility.phone,
              let url = URL(string: "tel:\(phone.replacingOccurrences(of: " ", with: ""))") else {
            return
        }
        UIApplication.shared.open(url)
    }

    func openWhatsApp(_ facility: EnhancedFacility) {
        guard let whatsapp = facility.whatsapp,
              let url = URL(string: "https://wa.me/\(whatsapp)") else {
            return
        }
        UIApplication.shared.open(url)
    }

    func openDirections(_ facility: EnhancedFacility) {
        let coordinate = facility.coordinate
        if let url = URL(string: "maps://?daddr=\(coordinate.latitude),\(coordinate.longitude)") {
            UIApplication.shared.open(url)
        }
    }

    func openWebsite(_ facility: EnhancedFacility) {
        guard let website = facility.website,
              let url = URL(string: website) else {
            return
        }
        UIApplication.shared.open(url)
    }

    // MARK: - Sharing

    func shareFacility(_ facility: EnhancedFacility) -> String {
        var shareText = "Check out \(facility.nameEn)"

        if let rating = facility.rating {
            shareText += " - \(String(format: "%.1f", rating)) stars"
        }

        shareText += "\n\(facility.address)"

        if let phone = facility.phone {
            shareText += "\nPhone: \(phone)"
        }

        if let website = facility.website {
            shareText += "\n\(website)"
        }

        shareText += "\n\nFound on Brainsait Maplinc"

        return shareText
    }

    // MARK: - Analytics Tracking

    func trackView(_ facility: EnhancedFacility) {
        // Track facility view for analytics
        print("Tracked view for facility: \(facility.id)")
    }

    func trackContact(_ facility: EnhancedFacility, type: String) {
        // Track contact action for analytics
        print("Tracked \(type) contact for facility: \(facility.id)")
    }

    func trackBooking(_ facility: EnhancedFacility) {
        // Track booking attempt for analytics
        print("Tracked booking for facility: \(facility.id)")
    }
}

// MARK: - UIApplication Extension

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
