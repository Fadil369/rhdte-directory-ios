# PayLinc Integration - Unified Dashboard

## Overview

This integration adds **PayLinc**, a Saudi Digital Payment Platform, to your Unified Dashboard. PayLinc is a Shariah-compliant, SAMA-regulated payment system that specializes in healthcare payments and features:

- **Multi-gateway payment processing** (Stripe, PayPal, SARIE, Mada)
- **Healthcare-specific NPHIES integration** for Saudi medical claims
- **Murabaha BNPL** (Buy Now Pay Later) - 100% Shariah-compliant
- **Multi-currency wallets** with Islamic banking integration
- **Real-time compliance monitoring** (SAMA, Shariah, PCI DSS)
- **Automatic Zakat calculation** and tracking

## Features Integrated

### 1. PayLinc Dashboard (`/paylinc`)
**Main dashboard showing:**
- Total transaction volume across all channels
- Active payment gateway status
- Multi-currency wallet balances (SAR, USD, EUR, GBP, AED)
- Islamic deposit account with profit-sharing
- Zakat tracking and payments
- Compliance score (SAMA, Shariah, PCI DSS)

**Key Components:**
- `PayLincDashboardView.swift` - Main view
- `PayLincAPIClient.swift` - API integration layer
- `PayLincModels.swift` - Data models

### 2. Payment Channels (`/payments`)
**Track all integrated payment gateways:**
- **Stripe** - International cards, Apple Pay, Google Pay
- **PayPal** - Global wallet payments
- **SARIE** - Saudi instant payments (real-time settlement)
- **Mada** - Saudi domestic cards
- **Alipay+** - Coming 2026 for Chinese medical tourism

**Metrics per channel:**
- Transaction count
- Volume processed
- Balance available
- Status (Active/Inactive/Error/Maintenance)

### 3. Healthcare Payments (`/healthcare`)
**NPHIES-integrated medical claim processing:**
- Patient eligibility verification
- Claim submission and tracking
- Co-payment processing
- Provider settlement via SARIE
- Insurance claim status
- Digital receipts with QR codes

**Workflow:**
1. Patient visits healthcare provider
2. Provider checks eligibility via NPHIES
3. Provider submits claim
4. PayLinc calculates patient share
5. Patient pays via app
6. Provider receives instant settlement
7. Insurance processes remaining claim

### 4. Murabaha BNPL (`/murabaha`)
**Shariah-compliant Buy Now Pay Later:**
- Cost-plus sale structure (NOT interest-based)
- Full markup disclosure upfront
- Equal installment payments
- No hidden fees or penalties
- Late fees only cover administrative costs
- Excess fees donated to charity

**Example Agreement:**
```
Item: iPhone 15 Pro Max
Cost Price: SAR 4,500
Markup (10%): SAR 450
Selling Price: SAR 4,950
Installments: 6 × SAR 825
Status: Active (2/6 paid)
Outstanding: SAR 3,300
```

**Shariah Certification:** ✅ Certified by Islamic Advisory Board

## Architecture

### API Client Layer
```swift
@MainActor
class PayLincAPIClient: ObservableObject {
    - fetchTransactions()
    - fetchPaymentChannels()
    - fetchHealthcarePayments()
    - fetchMurabahaAgreements()
    - fetchWallet()
    - fetchKYCStatus()
    - fetchZakatRecords()
}
```

### Data Models

**Payment Models:**
- `PaymentChannel` - Gateway status and metrics
- `Transaction` - Individual payment records

**Healthcare Models:**
- `HealthcarePayment` - NPHIES claim with patient/provider info
- `HealthcareService` - Individual services in claim

**BNPL Models:**
- `MurabahaAgreement` - Shariah-compliant installment plan
- `Installment` - Individual payment schedule

**Wallet Models:**
- `Wallet` - Multi-currency balances
- `IslamicDeposit` - Mudarabah account details

**Compliance Models:**
- `KYCVerification` - User identity verification (Tier 1/2/3)
- `ShariahCompliance` - Certification tracking
- `ZakatRecord` - Islamic charity calculations

## Usage

### Running the App

```bash
cd /Users/fadil369/UnifiedDashboard
./run.sh
```

Or:
```bash
swift run UnifiedDashboard
```

### Configuring API Connection

Edit `PayLincAPIClient.swift`:

```swift
init(baseURL: String = "https://api.paylinc.sa", 
     apiKey: String = "your-api-key-here") {
    self.baseURL = baseURL
    self.apiKey = apiKey
}
```

### Navigation

The dashboard sidebar now includes:
- **Overview** - Summary stats across all systems
- **PayLinc Platform** - Main PayLinc dashboard
- **Payment Channels** - Gateway status
- **Healthcare Payments** - NPHIES claims
- **Murabaha BNPL** - Shariah installments
- **Workflows** - Automation pipelines
- **AI Agents** - Agent monitoring
- **A2A Integrations** - App-to-app sync
- **Tasks** - Task management
- **Apps & Services** - Service health
- **Monitoring** - Performance metrics

## Compliance & Security

### SAMA (Saudi Arabian Monetary Authority)
- ✅ PSP License required
- ✅ KYC/AML compliance (3 tiers)
- ✅ Transaction limits enforcement
- ✅ 7-year audit log retention
- ✅ Real-time fraud detection

### Shariah Compliance
- ✅ No interest (Riba) in any transactions
- ✅ Murabaha structure for BNPL
- ✅ Islamic deposit accounts (Mudarabah)
- ✅ Automatic Zakat calculation
- ✅ Halal investment options
- ✅ Charitable excess fee donation

### PCI DSS Level 1
- ✅ No card data storage (tokenization via Stripe/PayPal)
- ✅ TLS 1.3 encryption
- ✅ AES-256-GCM at rest
- ✅ Quarterly vulnerability scans
- ✅ Annual penetration testing

### Data Privacy
- Saudi data residency (Riyadh primary, Bahrain backup)
- GDPR-compliant for international patients
- End-to-end encryption
- Device fingerprinting for fraud prevention

## Backend Integration Points

### Payment Gateways
```typescript
// Cloudflare Workers API
POST /api/v1/payments
GET  /api/v1/payments/:id
GET  /api/v1/payments/channels
```

### Healthcare (NPHIES)
```typescript
GET  /api/v1/healthcare/eligibility/:nationalId
POST /api/v1/healthcare/claims
GET  /api/v1/healthcare/claims/:reference
POST /api/v1/healthcare/payments/patient
POST /api/v1/healthcare/payments/provider-settlement
```

### Murabaha BNPL
```typescript
POST /api/v1/bnpl/murabaha
GET  /api/v1/bnpl/agreements
POST /api/v1/bnpl/installments/:id/pay
```

### Wallet
```typescript
GET  /api/v1/wallet
POST /api/v1/wallet/topup
POST /api/v1/wallet/withdraw
GET  /api/v1/wallet/transactions
```

### Compliance
```typescript
GET  /api/v1/compliance/kyc
POST /api/v1/compliance/kyc/verify
GET  /api/v1/compliance/zakat
POST /api/v1/compliance/zakat/pay
```

## Tech Stack

**Frontend (This App):**
- Swift 6.2
- SwiftUI (macOS 13+)
- Async/await concurrency
- Combine for reactive updates

**Backend (PayLinc API):**
- Cloudflare Workers (edge computing)
- Hono.js (TypeScript API framework)
- Cloudflare D1 (SQLite database)
- Cloudflare R2 (object storage)
- Durable Objects (stateful operations)

**Payment Providers:**
- Stripe SDK
- PayPal SDK  
- SARIE (Saudi instant payment)
- Mada network
- NPHIES (healthcare API)

## Sample Data

The app currently uses mock data. To connect to live PayLinc API:

1. Get API credentials from PayLinc admin
2. Update `PayLincAPIClient.init()` with:
   - Production API URL
   - Your API key
3. Remove mock data return statements
4. Enable real API calls

## Development Roadmap

### Phase 1: Foundation ✅ (Complete)
- Core wallet infrastructure
- Stripe integration
- PayPal integration
- Basic KYC (Tier 1)
- Static QR codes
- macOS dashboard

### Phase 2: Saudi Integration (In Progress)
- [ ] SARIE instant payments
- [ ] Mada network
- [ ] SADAD bill payments
- [ ] SAMA compliance module
- [ ] Absher National ID integration
- [ ] iOS mobile app

### Phase 3: Healthcare (Q1 2025)
- [ ] NPHIES API connection
- [ ] Live claim processing
- [ ] Provider portal integration
- [ ] Medical tourism packages
- [ ] FHIR R4 data exchange

### Phase 4: Advanced Features (Q2 2025)
- [ ] Live Murabaha BNPL
- [ ] Shariah board certification
- [ ] Zakat disbursement
- [ ] Dynamic QR (EMVCo)
- [ ] Cross-border remittances
- [ ] AI fraud detection

## Support & Documentation

**Official PayLinc Docs:**
- API Reference: https://docs.paylinc.sa
- Developer Portal: https://developers.paylinc.sa
- Shariah Guidelines: https://shariah.paylinc.sa

**Compliance:**
- SAMA Guidelines: https://sama.gov.sa
- NPHIES Documentation: https://nphies.sa
- Shariah Standards: AAOIFI/OIC

## License

Private use - Dr. Mohamed El Fadil  
BrainSAIT OID: 1.3.6.1.4.1.61026

## Version History

**1.0.0** (November 29, 2025)
- Initial PayLinc integration
- Payment channels dashboard
- Healthcare payments view
- Murabaha BNPL tracking
- Multi-currency wallet
- Compliance monitoring

---

**Built with ❤️ for the Saudi healthcare ecosystem**
