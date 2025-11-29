//
//  DashboardViewModel.swift
//  BrainSAIT Unified Platform
//
//  Copyright © 2024 BrainSAIT. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var activeAgentsCount: Int = 5
    @Published var todayTransactions: Int = 247
    @Published var revenue: Double = 125430.50
    @Published var payLincStatus: ServiceStatus = .healthy
    @Published var masterLincStatus: ServiceStatus = .healthy
    @Published var recentActivities: [Activity] = []
    
    var todayTransactionsFormatted: String {
        "\(todayTransactions)"
    }
    
    var revenueFormatted: String {
        String(format: "$%.2f", revenue)
    }
    
    init() {
        // Initialize with demo data
        loadDemoData()
    }
    
    private func loadDemoData() {
        recentActivities = [
            Activity(
                id: UUID(),
                title: "Payment Processed",
                description: "SAR 1,250.00 via Stripe",
                icon: "checkmark.circle.fill",
                color: .green,
                timestamp: Date().addingTimeInterval(-300)
            ),
            Activity(
                id: UUID(),
                title: "Agent Deployed",
                description: "DoctorLINC v2.1 activated",
                icon: "cpu.fill",
                color: .blue,
                timestamp: Date().addingTimeInterval(-600)
            )
        ]
    }
}

enum ServiceStatus {
    case healthy
    case degraded
    case error
    case loading
    
    var color: Color {
        switch self {
        case .healthy: return .green
        case .degraded: return .yellow
        case .error: return .red
        case .loading: return .gray
        }
    }
}

struct Activity: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let color: Color
    let timestamp: Date
}
