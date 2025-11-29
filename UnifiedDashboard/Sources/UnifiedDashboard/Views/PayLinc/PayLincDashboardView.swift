import SwiftUI

struct PayLincDashboardView: View {
    @StateObject private var apiClient = PayLincAPIClient()
    @State private var stats: PayLincStats?
    @State private var paymentChannels: [PaymentChannel] = []
    @State private var wallet: Wallet?
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("PayLinc Platform")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Saudi Digital Payment System")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if apiClient.isConnected {
                        Label("Connected", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                
                // Stats Grid
                if let stats = stats {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 16) {
                        StatCard(
                            title: "Total Volume",
                            value: formatCurrency(stats.totalVolume, currency: "SAR"),
                            icon: "chart.line.uptrend.xyaxis",
                            color: .blue
                        )
                        StatCard(
                            title: "Transactions",
                            value: "\(stats.totalTransactions)",
                            icon: "list.bullet.rectangle",
                            color: .purple
                        )
                        StatCard(
                            title: "Payment Channels",
                            value: "\(stats.activePaymentChannels)",
                            icon: "creditcard.circle",
                            color: .green
                        )
                        StatCard(
                            title: "Compliance Score",
                            value: "\(stats.complianceScore)%",
                            icon: "checkmark.shield",
                            color: .orange
                        )
                    }
                }
                
                // Wallet Section
                if let wallet = wallet {
                    WalletSectionView(wallet: wallet)
                }
                
                // Payment Channels
                if !paymentChannels.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Payment Channels")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ForEach(paymentChannels) { channel in
                            PaymentChannelRow(channel: channel)
                        }
                    }
                }
            }
            .padding()
        }
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        isLoading = true
        
        do {
            async let statsTask = apiClient.fetchDashboardStats()
            async let channelsTask = apiClient.fetchPaymentChannels()
            async let walletTask = apiClient.fetchWallet()
            
            stats = try await statsTask
            paymentChannels = try await channelsTask
            wallet = try await walletTask
        } catch {
            print("Error loading PayLinc data: \(error)")
        }
        
        isLoading = false
    }
    
    private func formatCurrency(_ amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }
}

struct WalletSectionView: View {
    let wallet: Wallet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Multi-Currency Wallet")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))], spacing: 12) {
                CurrencyCard(currency: "SAR", balance: wallet.sarBalance, icon: "🇸🇦")
                CurrencyCard(currency: "USD", balance: wallet.usdBalance, icon: "🇺🇸")
                CurrencyCard(currency: "EUR", balance: wallet.eurBalance, icon: "🇪🇺")
                CurrencyCard(currency: "GBP", balance: wallet.gbpBalance, icon: "🇬🇧")
                CurrencyCard(currency: "AED", balance: wallet.aedBalance, icon: "🇦🇪")
            }
            
            // Islamic Deposit Info
            if let islamic = wallet.islamicDepositAccount {
                HStack {
                    Image(systemName: "crescent.fill")
                        .foregroundStyle(.green)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Islamic Deposit Account")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(islamic.bankName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Profit Sharing: \(String(format: "%.1f%%", Double(truncating: islamic.profitSharingRatio as NSNumber) * 100))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Actual Profit")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatCurrency(islamic.actualProfit, currency: "SAR"))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Zakat Info
            if wallet.zakatEnabled {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.purple)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Zakat Tracking")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Total Paid: \(formatCurrency(wallet.totalZakatPaid, currency: "SAR"))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private func formatCurrency(_ amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }
}

struct CurrencyCard: View {
    let currency: String
    let balance: Decimal
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(icon)
                    .font(.title2)
                Text(currency)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(formatCurrency(balance, currency: currency))
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .cornerRadius(8)
    }
    
    private func formatCurrency(_ amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.maximumFractionDigits = 2
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }
}

struct PaymentChannelRow: View {
    let channel: PaymentChannel
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: channel.type.icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(channel.name)
                    .font(.headline)
                HStack {
                    Text("\(channel.transactions) transactions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text(formatCurrency(channel.balance, currency: channel.currency))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            statusIndicator(for: channel.status)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func statusIndicator(for status: PaymentChannel.ChannelStatus) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor(for: status))
                .frame(width: 8, height: 8)
            Text(statusText(for: status))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private func statusColor(for status: PaymentChannel.ChannelStatus) -> Color {
        switch status {
        case .active: return .green
        case .inactive: return .gray
        case .error: return .red
        case .maintenance: return .orange
        }
    }
    
    private func statusText(for status: PaymentChannel.ChannelStatus) -> String {
        switch status {
        case .active: return "Active"
        case .inactive: return "Inactive"
        case .error: return "Error"
        case .maintenance: return "Maintenance"
        }
    }
    
    private func formatCurrency(_ amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }
}
