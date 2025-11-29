import SwiftUI

struct PaymentChannelsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 16) {
                PaymentChannelCard(name: "Stripe", status: .active, balance: "$12,450.00", transactions: "156")
                PaymentChannelCard(name: "PayPal", status: .active, balance: "$8,230.50", transactions: "89")
                PaymentChannelCard(name: "Square", status: .active, balance: "$5,670.25", transactions: "45")
                PaymentChannelCard(name: "Bank Transfer", status: .active, balance: "$23,890.00", transactions: "34")
                PaymentChannelCard(name: "Cryptocurrency", status: .inactive, balance: "$0.00", transactions: "0")
            }
        }
    }
}

struct PaymentChannelCard: View {
    let name: String
    let status: ChannelStatus
    let balance: String
    let transactions: String
    
    enum ChannelStatus {
        case active, inactive, error
        
        var color: Color {
            switch self {
            case .active: return .green
            case .inactive: return .gray
            case .error: return .red
            }
        }
        
        var text: String {
            switch self {
            case .active: return "Active"
            case .inactive: return "Inactive"
            case .error: return "Error"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(name)
                    .font(.headline)
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(status.color)
                        .frame(width: 8, height: 8)
                    Text(status.text)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Balance:")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(balance)
                        .fontWeight(.semibold)
                }
                HStack {
                    Text("Transactions:")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(transactions)
                        .fontWeight(.semibold)
                }
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
    }
}
