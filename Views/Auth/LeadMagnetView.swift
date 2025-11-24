// BrainSAIT RHDTE - Lead Magnet View
// Subscription form for capturing leads and email sign-ups

import SwiftUI

struct LeadMagnetView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var name = ""
    @State private var phone = ""
    @State private var selectedTier: SubscriptionTier = .basic
    @State private var consentMarketing = false
    @State private var isLoading = false
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "cross.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color("BrainSAITGreen"))
                        
                        Text("Join BrainSAIT Directory")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Get access to Saudi Arabia's most comprehensive healthcare facility directory")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Benefits
                    VStack(alignment: .leading, spacing: 12) {
                        BenefitRow(icon: "magnifyingglass", text: "Search 10,000+ facilities")
                        BenefitRow(icon: "star.fill", text: "Real ratings & reviews")
                        BenefitRow(icon: "heart.fill", text: "Save your favorites")
                        BenefitRow(icon: "phone.fill", text: "Direct contact info")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Form
                    VStack(spacing: 16) {
                        CustomTextField(
                            icon: "envelope.fill",
                            placeholder: "Email Address",
                            text: $email,
                            keyboardType: .emailAddress
                        )
                        
                        CustomTextField(
                            icon: "person.fill",
                            placeholder: "Full Name",
                            text: $name
                        )
                        
                        CustomTextField(
                            icon: "phone.fill",
                            placeholder: "Phone Number",
                            text: $phone,
                            keyboardType: .phonePad
                        )
                    }
                    
                    // Subscription Tiers
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose Your Plan")
                            .font(.headline)
                        
                        ForEach([SubscriptionTier.free, .basic, .premium], id: \.self) { tier in
                            SubscriptionTierCard(
                                tier: tier,
                                isSelected: selectedTier == tier
                            ) {
                                selectedTier = tier
                            }
                        }
                    }
                    
                    // Consent
                    Toggle(isOn: $consentMarketing) {
                        Text("I agree to receive marketing communications from BrainSAIT")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .toggleStyle(CheckboxToggleStyle())
                    
                    // Submit Button
                    Button(action: submitForm) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Get Started")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("BrainSAITGreen"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(email.isEmpty || isLoading)
                    
                    // Terms
                    Text("By signing up, you agree to our Terms of Service and Privacy Policy")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .navigationTitle("Subscribe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Welcome to BrainSAIT!", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your subscription is active. Enjoy full access to the healthcare directory!")
            }
        }
    }
    
    private func submitForm() {
        isLoading = true
        
        let submission = LeadMagnetSubmission(
            email: email,
            name: name.isEmpty ? nil : name,
            phone: phone.isEmpty ? nil : phone,
            facilityType: nil,
            district: nil,
            source: "ios_app",
            consentMarketing: consentMarketing,
            timestamp: Date()
        )
        
        // Submit to API
        Task {
            do {
                try await APIService.shared.submitLeadMagnet(submission)
                DispatchQueue.main.async {
                    isLoading = false
                    showSuccess = true
                    appState.isAuthenticated = true
                }
            } catch {
                print("Error submitting lead: \(error)")
                DispatchQueue.main.async {
                    isLoading = false
                    // Show error
                }
            }
        }
    }
}

// MARK: - Custom Components

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color("BrainSAITGreen"))
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct SubscriptionTierCard: View {
    let tier: SubscriptionTier
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(tier.rawValue)
                        .font(.headline)
                    
                    Spacer()
                    
                    if tier.monthlyPrice == 0 {
                        Text("Free")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("BrainSAITGreen"))
                    } else {
                        Text("SAR \(Int(tier.monthlyPrice))/mo")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? Color("BrainSAITGreen") : .secondary)
                }
                
                Text(tier.features.prefix(2).joined(separator: " • "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(isSelected ? Color("BrainSAITGreen").opacity(0.1) : Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color("BrainSAITGreen") : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? Color("BrainSAITGreen") : .secondary)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            
            configuration.label
        }
    }
}
