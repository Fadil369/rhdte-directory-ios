//
//  PayLincDashboardView.swift
//  PayLinc Dashboard View
//
//  Copyright © 2024 BrainSAIT. All rights reserved.
//

import SwiftUI

struct PayLincDashboardView: View {
    let isArabic: Bool
    @EnvironmentObject var viewModel: DashboardViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text(isArabic ? "لوحة PayLinc" : "PayLinc Dashboard")
                    .font(.largeTitle.bold())
                
                // Coming soon content
                Text(isArabic ? "قريباً..." : "Coming soon...")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}
