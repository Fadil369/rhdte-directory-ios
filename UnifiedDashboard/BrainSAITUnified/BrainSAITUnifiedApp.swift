//
//  BrainSAITUnifiedApp.swift
//  BrainSAIT Unified Platform
//
//  Created by BrainSAIT on 2024-11-29.
//

import SwiftUI

@main
struct BrainSAITUnifiedApp: App {
    @StateObject private var networkManager = NetworkManager()
    @StateObject private var dashboardViewModel = DashboardViewModel()
    @State private var selectedLanguage: Language = .english
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(networkManager)
                .environmentObject(dashboardViewModel)
                .environment(\.locale, selectedLanguage.locale)
                .preferredColorScheme(.dark)
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About BrainSAIT Unified") {
                    // Show about window
                }
            }
        }
        
        #if os(macOS)
        Settings {
            SettingsView()
                .environmentObject(networkManager)
        }
        #endif
    }
}

enum Language: String, CaseIterable {
    case english = "en"
    case arabic = "ar"
    
    var locale: Locale {
        Locale(identifier: rawValue)
    }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .arabic: return "العربية"
        }
    }
}
