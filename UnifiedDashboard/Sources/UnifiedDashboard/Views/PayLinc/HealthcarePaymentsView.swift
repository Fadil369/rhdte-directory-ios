import SwiftUI

struct HealthcarePaymentsView: View {
    @StateObject private var apiClient = PayLincAPIClient()
    @State private var claims: [HealthcarePayment] = []
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "cross.case.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.red)
                    VStack(alignment: .leading) {
                        Text("Healthcare Payments")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("NPHIES Integrated Claims")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Claims List
                if isLoading {
                    ProgressView("Loading claims...")
                } else if claims.isEmpty {
                    emptyState
                } else {
                    ForEach(claims) { claim in
                        HealthcareClaimCard(claim: claim)
                    }
                }
            }
            .padding()
        }
        .task {
            await loadClaims()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("No healthcare claims found")
                .font(.headline)
            Text("Claims will appear here once submitted")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
    
    private func loadClaims() async {
        isLoading = true
        do {
            claims = try await apiClient.fetchHealthcarePayments()
        } catch {
            print("Error loading claims: \(error)")
        }
        isLoading = false
    }
}

struct HealthcareClaimCard: View {
    let claim: HealthcarePayment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(claim.claimReference)
                        .font(.headline)
                    Text(claim.provider.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                statusBadge(for: claim.status)
            }
            
            Divider()
            
            // Patient Info
            HStack {
                Label("Patient", systemImage: "person.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(claim.patient.name)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            // Financial Breakdown
            VStack(alignment: .leading, spacing: 8) {
                Text("Financial Details")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text("Total Amount:")
                    Spacer()
                    Text(formatCurrency(claim.totalAmount))
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                
                HStack {
                    Text("Patient Share:")
                    Spacer()
                    Text(formatCurrency(claim.patientShare))
                        .foregroundStyle(.orange)
                }
                .font(.subheadline)
                
                HStack {
                    Text("Insurance Share:")
                    Spacer()
                    Text(formatCurrency(claim.insuranceShare))
                        .foregroundStyle(.green)
                }
                .font(.subheadline)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            .cornerRadius(8)
            
            // Services
            if !claim.services.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Services")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    ForEach(claim.services) { service in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(service.description)
                                    .font(.caption)
                                Text(service.code)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(formatCurrency(service.amount))
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            
            // Payment Status
            HStack {
                Label("Payment", systemImage: "creditcard")
                    .font(.caption)
                Spacer()
                paymentStatusBadge(for: claim.paymentStatus)
            }
            
            HStack {
                Label("Settlement", systemImage: "banknote")
                    .font(.caption)
                Spacer()
                settlementStatusBadge(for: claim.settlementStatus)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func statusBadge(for status: HealthcarePayment.ClaimStatus) -> some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor(for: status).opacity(0.2))
            .foregroundStyle(statusColor(for: status))
            .cornerRadius(6)
    }
    
    private func statusColor(for status: HealthcarePayment.ClaimStatus) -> Color {
        switch status {
        case .submitted: return .blue
        case .approved: return .green
        case .rejected: return .red
        case .partial: return .orange
        case .paid: return .purple
        }
    }
    
    @ViewBuilder
    private func paymentStatusBadge(for status: HealthcarePayment.PaymentStatus) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(paymentStatusColor(for: status))
                .frame(width: 6, height: 6)
            Text(status.rawValue.capitalized)
                .font(.caption2)
        }
    }
    
    private func paymentStatusColor(for status: HealthcarePayment.PaymentStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .paid: return .green
        case .failed: return .red
        }
    }
    
    @ViewBuilder
    private func settlementStatusBadge(for status: HealthcarePayment.SettlementStatus) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(settlementStatusColor(for: status))
                .frame(width: 6, height: 6)
            Text(status.rawValue.capitalized)
                .font(.caption2)
        }
    }
    
    private func settlementStatusColor(for status: HealthcarePayment.SettlementStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .processing: return .blue
        case .settled: return .green
        case .failed: return .red
        }
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "SAR"
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }
}
