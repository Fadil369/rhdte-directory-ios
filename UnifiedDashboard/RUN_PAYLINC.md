# Quick Start - PayLinc Unified Dashboard

## Run the App

```bash
cd /Users/fadil369/UnifiedDashboard
./run.sh
```

## What You'll See

### 1. Overview Tab
- PayLinc payment volume: **SAR 450K**
- Active payment channels: **5 gateways**
- Healthcare claims pending: **12 claims**
- Murabaha BNPL agreements: **3 active**

### 2. PayLinc Platform Tab
**Payment Channels:**
- ✅ Stripe - SAR 12,450 (156 transactions)
- ✅ PayPal - SAR 8,230 (89 transactions)
- ✅ SARIE - SAR 23,890 (34 transactions)
- ✅ Mada - SAR 5,670 (45 transactions)

**Multi-Currency Wallet:**
- 🇸🇦 SAR: 15,780.50
- 🇺🇸 USD: 1,234.00
- ��🇺 EUR: 850.00
- 🇬🇧 GBP: 620.00
- 🇦🇪 AED: 3,200.00

**Islamic Banking:**
- Bank: Al Rajhi Bank
- Profit Sharing: 60% to customer
- Actual Profit: SAR 152.30

**Zakat Tracking:**
- Total Paid: SAR 395.00
- Current Due: SAR 2,125.00

### 3. Healthcare Payments Tab
**Sample Claim:**
- Reference: NPHIES-2024-001
- Provider: King Faisal Specialist Hospital
- Patient: Ahmed Al-Zahrani
- Total: SAR 5,000
- Patient Share: SAR 500 (paid ✅)
- Insurance: SAR 4,500 (settled ✅)

### 4. Murabaha BNPL Tab
**Active Agreement:**
- Item: iPhone 15 Pro Max
- Merchant: Extra Electronics
- Cost Price: SAR 4,500
- Markup (10%): SAR 450
- Selling Price: SAR 4,950
- Progress: 2/6 installments paid
- Next Payment: SAR 825 (in 1 month)
- Shariah Certified: ✅

## Navigation Tips

- Use sidebar to switch between sections
- All views are real-time (async/await)
- Click on cards for detailed information
- Payment status indicators:
  - 🟢 Green = Active/Completed
  - 🟡 Orange = Pending/Processing
  - 🔴 Red = Error/Failed

## Mock vs Live Data

Currently showing **mock data** for demonstration.

To connect to live PayLinc API:
1. Get API key from PayLinc admin
2. Edit `PayLincAPIClient.swift`
3. Update `baseURL` and `apiKey`
4. Rebuild: `swift build`

## Keyboard Shortcuts

- `⌘R` - Refresh data
- `⌘W` - Close window
- `⌘Q` - Quit app

## Features Demonstrated

✅ Payment gateway integration (4 providers)  
✅ Healthcare claim processing (NPHIES)  
✅ Shariah-compliant BNPL  
✅ Multi-currency wallets  
✅ Islamic banking integration  
✅ Zakat calculation  
✅ Real-time compliance monitoring  
✅ Native macOS design (SwiftUI)

Enjoy exploring the integrated PayLinc platform! 🚀
