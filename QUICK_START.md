# Quick Start Guide - BrainSAIT Healthcare Platform

## 🚀 Getting Started in 5 Minutes

### Prerequisites
```bash
- Xcode 15.0 or later
- iOS 16.0+ device or simulator
- CocoaPods or Swift Package Manager
- Active internet connection
```

### Installation

#### Step 1: Clone and Setup
```bash
cd rhdte-directory-ios-new
pod install  # or use SPM
open RHDTEDirectory.xcworkspace
```

#### Step 2: Configure Info.plist
Add required privacy descriptions:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access for voice-based medical consultations</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>We use speech recognition to understand your medical inquiries</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to recommend nearby healthcare facilities</string>

<key>NSCalendarsUsageDescription</key>
<string>We need calendar access to save your appointments</string>
```

#### Step 3: Build and Run
```bash
# Select target device
# Press Cmd+R to build and run
```

## 📱 Feature Overview

### Tab 1: Map 🗺️
**What it does:** Shows all healthcare facilities on an interactive map

**Try it:**
1. Launch app → Map tab (default)
2. Pinch to zoom, tap markers to see details
3. Use search bar to find specific facilities
4. Filter by type (Hospital, Clinic, Pharmacy)

### Tab 2: Directory 📋
**What it does:** Browse facilities in list view

**Try it:**
1. Tap "Directory" tab
2. Scroll through facilities
3. Use filter button for advanced search
4. Tap facility card for details

### Tab 3: AI Triage 🤖
**What it does:** Voice/text AI assistant for medical help

**Try it:**
1. Tap "AI Triage" tab
2. Grant microphone permission
3. Tap "Connect to CallLinc"
4. Say: "I need a dentist appointment in Riyadh"
5. AI will recommend clinics and help you book

**Example Commands:**
```
Voice:
- "أريد موعد مع طبيب عام" (I need a GP appointment)
- "Find me a 24-hour pharmacy near me"
- "How do I submit an insurance claim?"

Text:
- "Show me hospitals with emergency services"
- "I have chest pain, what should I do?"
- "Check my appointment status"
```

### Tab 4: Saved ❤️
**What it does:** Your bookmarked facilities

**Try it:**
1. Save facilities from Map or Directory
2. Access quickly from Saved tab
3. Remove by swiping left

### Tab 5: Dashboard 📊
**What it does:** Healthcare insights and statistics

**Try it:**
1. View total facilities count
2. See top-rated providers
3. Analyze facility distribution

### Tab 6: Profile 👤
**What it does:** Manage your account and preferences

**Try it:**
1. Update personal information
2. Manage appointments
3. View conversation history
4. Export data

## 🎯 Use Case Scenarios

### Scenario 1: Emergency Dental Pain
```
User Action: Open AI Triage → "I have severe toothache"
AI Response: 
  1. Asks pain level and symptoms
  2. Recommends 3 nearby dental clinics
  3. Shows available emergency slots
  4. Books appointment for today
  5. Sends WhatsApp confirmation
```

### Scenario 2: Routine Checkup
```
User Action: Browse Directory → Filter by "General Practitioner"
System:
  1. Shows 15 GPs in your area
  2. Sort by rating (4.5★+)
  3. Tap facility → View doctor profiles
  4. Select preferred time slot
  5. Complete booking with insurance
```

### Scenario 3: Insurance Query
```
User Action: AI Triage (text) → "How do I use my insurance?"
AI Response:
  1. Asks for insurance provider
  2. Explains coverage details
  3. Lists accepted facilities
  4. Offers to submit pre-authorization
  5. Provides claim tracking link
```

## 🛠️ API Integration Testing

### Test CallLinc Voice Agent
```bash
# WebSocket connection test
curl -i -N -H "Connection: Upgrade" \
     -H "Upgrade: websocket" \
     -H "Sec-WebSocket-Key: test" \
     https://calllinc-healthcare-ai-agent-469357002740.us-west1.run.app/ws/voice
```

### Test Doctor Hub API
```bash
# Get doctors list
curl https://brainsait-doctor-hub--fadil369.github.app/api/doctors?facility_id=test123

# Check availability
curl https://brainsait-doctor-hub--fadil369.github.app/api/availability?doctor_id=doc123&date=2025-11-28
```

### Test Hospital Directory
```bash
# Search facilities
curl http://localhost:8000/api/facilities/search?q=dental

# Get districts
curl http://localhost:8000/api/districts
```

## 🔧 Troubleshooting

### Issue: Voice not working
**Solution:**
1. Check microphone permission in Settings → Privacy
2. Ensure internet connection (WebSocket requires connectivity)
3. Try text mode if voice fails
4. Restart app and reconnect

### Issue: No doctors showing
**Solution:**
1. Verify facility has doctors in Doctor Hub
2. Check network connectivity
3. Try different facility
4. Contact support with facility ID

### Issue: Appointment booking fails
**Solution:**
1. Ensure all required fields are filled
2. Check time slot is still available
3. Verify insurance details (if applicable)
4. Try different time slot
5. Check error message for details

### Issue: Map not loading
**Solution:**
1. Enable location services
2. Check internet connection
3. Reload GeoJSON data
4. Clear app cache

## 📝 Development Tips

### Debug Mode
Enable detailed logging:
```swift
// Add to RHDTEDirectoryApp.swift
init() {
    #if DEBUG
    UserDefaults.standard.set(true, forKey: "debug_mode")
    print("🐛 Debug mode enabled")
    #endif
}
```

### Mock Data
Test without backend:
```swift
// In VoiceTriageService.swift
private let useMockData = true  // Set to true for testing
```

### Custom Base URLs
Override API endpoints:
```swift
// In APIService.swift
private let baseURL = ProcessInfo.processInfo.environment["API_BASE_URL"] 
    ?? "http://localhost:8000/api"
```

## 🎨 Customization

### Branding
Update colors in:
```swift
// Create Theme.swift
struct AppTheme {
    static let primaryColor = Color.blue
    static let accentColor = Color.green
    static let backgroundColor = Color(.systemBackground)
}
```

### Localization
Add Arabic support:
```swift
// In Localizable.strings (ar)
"appointment_title" = "حجز موعد";
"search_placeholder" = "البحث عن المرافق الصحية";
```

## 📞 Support Resources

### Documentation
- **Full Docs:** `/INTEGRATION_DOCUMENTATION.md`
- **API Reference:** `/docs/api-reference.md`
- **Architecture:** `/docs/architecture.md`

### Community
- **GitHub Issues:** Report bugs
- **Stack Overflow:** Tag `brainsait-health`
- **Discord:** Join developer community

### Contact
- **Email:** dev-support@brainsait.com
- **Phone:** +966 11 XXX XXXX (9AM-5PM AST)
- **WhatsApp:** +966 5X XXX XXXX

## ✅ Pre-Launch Checklist

Before deploying to production:

- [ ] Update API endpoints to production URLs
- [ ] Enable analytics tracking
- [ ] Configure push notification certificates
- [ ] Test on physical iOS devices (iPhone 12+)
- [ ] Verify HIPAA/PDPL compliance
- [ ] Load test voice triage service
- [ ] Set up error monitoring (Sentry/Crashlytics)
- [ ] Create App Store assets (screenshots, description)
- [ ] Submit for TestFlight beta testing
- [ ] Train support team on features

## 🎓 Training Videos

**Coming Soon:**
1. Platform Overview (5 min)
2. Voice Triage Tutorial (10 min)
3. Appointment Booking (7 min)
4. Admin Dashboard (15 min)

## 📈 Success Metrics

**Track these after launch:**
- Daily Active Users (DAU)
- Voice session completion rate
- Appointment booking conversion
- Average response time
- User satisfaction (NPS)
- Crash-free rate

---

**Ready to build amazing healthcare experiences! 🚀**

For detailed integration guide, see `INTEGRATION_DOCUMENTATION.md`

**Version:** 1.0.0  
**Last Updated:** November 27, 2025
