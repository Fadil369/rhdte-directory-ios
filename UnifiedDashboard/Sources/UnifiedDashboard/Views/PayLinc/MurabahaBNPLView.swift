import SwiftUI

struct MurabahaBNPLView: View {
    @StateObject private var apiClient = PayLincAPIClient()
    @State private var agreements: [MurabahaAgreement] = []
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with Shariah Compliance Badge
                HStack {
                    Image(systemName: "crescent.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                    VStack(alignment: .leading) {
                        Text("Murabaha BNPL")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Shariah-Compliant Installments")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                }
                
                // Info Card
                shariahComplianceInfo
                
                // Agreements List
                if isLoading {
                    ProgressView("Loading agreements...")
                } else if agreements.isEmpty {
                    emptyState
                } else {
                    ForEach(agreements) { agreement in
                        MurabahaAgreementCard(agreement: agreement)
                    }
                }
            }
            .padding()
        }
        .task {
            await loadAgreements()
        }
    }
    
    private var shariahComplianceInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.blue)
                Text("How Murabaha Works")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                CompliancePoint(
                    icon: "1.circle.fill",
                    text: "PayLinc purchases item from merchant at cost price"
                )
                CompliancePoint(
                    icon: "2.circle.fill",
                    text: "PayLinc sells to you at disclosed markup (no hidden fees)"
                )
                CompliancePoint(
                    icon: "3.circle.fill",
                    text: "You pay in equal installments with NO additional charges"
                )
                CompliancePoint(
                    icon: "4.circle.fill",
                    text: "Late fees only reflect actual costs (excess goes to charity)"
                )
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard.and.123")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("No active agreements")
                .font(.headline)
            Text("Create a Shariah-compliant purchase plan")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
    
    private func loadAgreements() async {
        isLoading = true
        do {
            agreements = try await apiClient.fetchMurabahaAgreements()
        } catch {
            print("Error loading agreements: \(error)")
        }
        isLoading = false
    }
}

struct CompliancePoint: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.green)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct MurabahaAgreementCard: View {
    let agreement: MurabahaAgreement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(agreement.itemDescription)
                        .font(.headline)
                    Text(agreement.merchantName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if agreement.shariahCertified {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                }
                statusBadge(for: agreement.status)
            }
            
            Divider()
            
            // Murabaha Structure
            VStack(alignment: .leading, spacing: 12) {
                Text("Murabaha Structure")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                    GridRow {
                        Text("Cost Price:")
                            .foregroundStyle(.secondary)
                        Text(formatCurrency(agreement.costPrice))
                            .fontWeight(.medium)
                    }
                    
                    GridRow {
                        Text("Markup (\(String(format: "%.1f%%", Double(truncating: agreement.markupRatio as NSNumber) * 100))):")
                            .foregroundStyle(.secondary)
                        Text(formatCurrency(agreement.markup))
                            .fontWeight(.medium)
                            .foregroundStyle(.orange)
                    }
                    
                    GridRow {
                        Text("Selling Price:")
                            .foregroundStyle(.secondary)
                        Text(formatCurrency(agreement.sellingPrice))
                            .fontWeight(.semibold)
                    }
                }
                .font(.subheadline)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            .cornerRadius(8)
            
            // Payment Progress
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Payment Progress")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(agreement.paidInstallments)/\(agreement.installmentCount) paid")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                ProgressView(value: Double(agreement.paidInstallments), total: Double(agreement.installmentCount))
                    .tint(.green)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Paid")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(formatCurrency(agreement.totalPaid))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Outstanding")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(formatCurrency(agreement.outstandingBalance))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.orange)
                    }
                }
            }
            
            // Next Payment
            if let nextPayment = agreement.nextPaymentDate {
                HStack {
                    Label("Next Payment", systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(nextPayment, style: .date)
                        .font(.caption)
                        .fontWeight(.medium)
                    Text(formatCurrency(agreement.installmentAmount))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func statusBadge(for status: MurabahaAgreement.AgreementStatus) -> some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor(for: status).opacity(0.2))
            .foregroundStyle(statusColor(for: status))
            .cornerRadius(6)
    }
    
    private func statusColor(for status: MurabahaAgreement.AgreementStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .active: return .blue
        case .completed: return .green
        case .defaulted: return .red
        case .cancelled: return .gray
        }
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "SAR"
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }
}
