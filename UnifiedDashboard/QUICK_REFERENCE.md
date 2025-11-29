# PayLinc Integration - Quick Reference Card

## 🚀 Launch App
```bash
cd /Users/fadil369/UnifiedDashboard
./run.sh
```

## 📱 Navigation

| Section | What You'll See |
|---------|----------------|
| **Overview** | PayLinc stats + existing metrics |
| **PayLinc Platform** | Full dashboard with wallet & channels |
| **Payment Channels** | Stripe, PayPal, SARIE, Mada status |
| **Healthcare Payments** | NPHIES claims tracking |
| **Murabaha BNPL** | Shariah-compliant installments |

## 💰 Key Metrics (Mock Data)

| Metric | Value |
|--------|-------|
| Total Volume | SAR 450,780 |
| Active Channels | 4 gateways |
| Healthcare Claims | 12 pending |
| BNPL Agreements | 3 active |
| Wallet Balance | SAR 15,780 |
| Zakat Due | SAR 2,125 |

## 🏦 Payment Channels

| Gateway | Balance | Transactions | Use Case |
|---------|---------|--------------|----------|
| **Stripe** | SAR 12,450 | 156 | International cards |
| **PayPal** | SAR 8,230 | 89 | Global wallets |
| **SARIE** | SAR 23,890 | 34 | Saudi instant pay |
| **Mada** | SAR 5,670 | 45 | Domestic cards |

## 🏥 Healthcare (NPHIES)

**Sample Claim: NPHIES-2024-001**
- Provider: King Faisal Specialist Hospital
- Total: SAR 5,000
- Patient Share: SAR 500 ✅ Paid
- Insurance: SAR 4,500 ✅ Settled
- Status: Completed

## 🌙 Murabaha BNPL

**Sample Agreement:**
- Item: iPhone 15 Pro Max
- Cost Price: SAR 4,500
- Markup (10%): SAR 450
- Selling Price: SAR 4,950
- Installments: 6 months × SAR 825
- Progress: 2/6 paid
- Outstanding: SAR 3,300
- Shariah Certified: ✅

## 💱 Multi-Currency Wallet

| Currency | Balance | Flag |
|----------|---------|------|
| SAR | 15,780.50 | 🇸🇦 |
| USD | 1,234.00 | 🇺🇸 |
| EUR | 850.00 | 🇪🇺 |
| GBP | 620.00 | 🇬🇧 |
| AED | 3,200.00 | 🇦🇪 |

## 🕌 Islamic Banking

**Al Rajhi Bank Integration:**
- Account Type: Mudarabah (Profit-Sharing)
- Customer Share: 60%
- Actual Profit: SAR 152.30
- Zakat Enabled: ✅
- Total Zakat Paid: SAR 395.00

## 🎨 Status Colors

| Color | Meaning |
|-------|---------|
| 🟢 **Green** | Active, Paid, Completed, Halal |
| 🔵 **Blue** | Processing, In Progress |
| 🟠 **Orange** | Pending, Warning, Due Soon |
| 🔴 **Red** | Error, Failed, Rejected |
| ⚪ **Gray** | Inactive, Cancelled |

## 📋 Files to Know

| File | Purpose |
|------|---------|
| `PayLincModels.swift` | Data structures |
| `PayLincAPIClient.swift` | API integration |
| `PayLincDashboardView.swift` | Main view |
| `HealthcarePaymentsView.swift` | NPHIES claims |
| `MurabahaBNPLView.swift` | Shariah BNPL |

## 🔧 Customize

**Change API URL:**
```swift
// In PayLincAPIClient.swift
init(baseURL: String = "https://your-api.com",
     apiKey: String = "your-key")
```

**Add Mock Data:**
```swift
// In PayLincAPIClient.swift
func fetchTransactions() -> [Transaction] {
    return [
        Transaction(id: "tx-001", ...)
    ]
}
```

## 📚 Documentation

1. **INTEGRATION_SUMMARY.md** - Complete overview
2. **PAYLINC_INTEGRATION.md** - Technical details
3. **RUN_PAYLINC.md** - Quick start
4. **QUICK_REFERENCE.md** - This file

## ✅ Checklist

- [x] Build successful
- [x] All views created
- [x] Navigation working
- [x] Mock data displaying
- [ ] Connect to live API
- [ ] Test real transactions
- [ ] SAMA compliance review
- [ ] Shariah certification

## 🆘 Troubleshooting

**App won't build?**
```bash
cd /Users/fadil369/UnifiedDashboard
swift package clean
swift build
```

**Views not showing?**
- Check ContentView.swift has all cases
- Verify imports in each view file

**Mock data not appearing?**
- Views load async - give it a moment
- Check console for errors: `swift run 2>&1 | grep error`

## 🎯 Next Actions

1. **Test App:** `./run.sh` and explore all sections
2. **Review Code:** Check PayLinc files for understanding
3. **Plan API:** Get credentials for live integration
4. **Extend:** Add new features or payment methods

---

**Built with ❤️ for Saudi digital transformation** 🇸🇦
