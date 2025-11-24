# BrainSAIT RHDTE Directory App

A native SwiftUI healthcare directory app for Saudi Arabia with lead magnet integration.

## Features

### Map View
- Interactive map showing healthcare facilities across Riyadh
- Custom map pins by facility type (color-coded)
- Search and filter facilities
- Location-based services
- Cluster support for dense areas

### Directory View
- Comprehensive list of all healthcare facilities
- Search by name, address, or district
- Filter by facility type, features (24h, emergency, online booking)
- Sort by rating, name, distance, or reviews
- Save favorites

### Facility Details
- Complete facility information
- Ratings and reviews
- Services and insurance accepted
- Operating hours
- Quick actions (call, directions, website)
- Digital maturity score (premium feature)
- Online booking integration

### Lead Magnet System
- Email subscription form
- Multiple subscription tiers (Free, Basic, Premium, Enterprise)
- Marketing consent collection
- PDPL compliant

### Dashboard
- Analytics overview (total facilities, districts, ratings)
- Facility type breakdown charts
- Top districts
- Recent activity tracking
- Premium upsell for free users

## Project Structure

```
rhdte-directory-ios/
├── App/
│   └── RHDTEDirectoryApp.swift      # Main app entry point
├── Models/
│   └── Facility.swift               # Data models
├── Views/
│   ├── Map/
│   │   └── MapTabView.swift         # Map with facility pins
│   ├── Directory/
│   │   ├── DirectoryView.swift      # List view
│   │   └── FacilityDetailSheet.swift # Detail bottom sheet
│   ├── Dashboard/
│   │   └── DashboardView.swift      # Analytics dashboard
│   └── Auth/
│       └── LeadMagnetView.swift     # Subscription form
├── ViewModels/
│   └── (View models)
├── Services/
│   └── APIService.swift             # Backend API integration
└── Components/
    └── (Reusable UI components)
```

## Setup

### Requirements
- Xcode 15+
- iOS 17+
- Swift 5.9+

### Installation

1. Open the project in Xcode
2. Update the API base URL in `Services/APIService.swift`
3. Add BrainSAIT colors to Asset Catalog:
   - `BrainSAITGreen`: #2E7D32 (primary brand color)
4. Build and run

### API Integration

The app connects to the RHDTE backend at `http://localhost:8000/api`. Ensure the backend is running:

```bash
cd ../rhdte-backend
pip install -r requirements.txt
uvicorn main:app --reload
```

## Subscription Tiers

| Tier | Price (SAR/mo) | Features |
|------|----------------|----------|
| Free | 0 | View facilities, basic search, 5 saves/month |
| Basic | 49 | Unlimited saves, contact info, ratings |
| Premium | 149 | Digital scores, direct booking, priority support |
| Enterprise | 499 | API access, custom reports, dedicated manager |

## Tech Stack

- **SwiftUI** - Modern declarative UI
- **MapKit** - Native Apple Maps integration
- **Charts** - Data visualization
- **Async/Await** - Modern concurrency
- **Combine** - Reactive programming

## Integration Points

- **RHDTE Backend** - FastAPI backend for facility data
- **Google Places API** - Facility discovery (via backend)
- **SendGrid** - Email notifications
- **Twilio** - WhatsApp integration

## License

Proprietary - BrainSAIT Healthcare Solutions
