# BrainSAIT Healthcare Platform - Architecture Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     iOS Application (SwiftUI)                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────┐│
│  │   Map    │  │Directory │  │AI Triage │  │  Saved   │  │Profile││
│  │   Tab    │  │   Tab    │  │   Tab    │  │   Tab    │  │ Tab  ││
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘  └──┬───┘│
│       │             │              │             │            │    │
│       └─────────────┴──────────────┴─────────────┴────────────┘    │
│                              │                                      │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │              State Management Layer                         │  │
│  │  ┌──────────────────┐    ┌────────────────────────┐        │  │
│  │  │   AppState       │    │ FacilityDataManager    │        │  │
│  │  │ - User profile   │    │ - Facilities           │        │  │
│  │  │ - Auth status    │    │ - Search results       │        │  │
│  │  │ - Selected items │    │ - Dashboard stats      │        │  │
│  │  └──────────────────┘    └────────────────────────┘        │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                              │                                      │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                  Service Layer                              │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │  │
│  │  │  APIService  │  │VoiceTriage   │  │ DoctorHub    │      │  │
│  │  │              │  │  Service     │  │ Integration  │      │  │
│  │  │ - Facilities │  │ - WebSocket  │  │ - Doctors    │      │  │
│  │  │ - Search     │  │ - Audio I/O  │  │ - Booking    │      │  │
│  │  │ - Analytics  │  │ - Speech     │  │ - Insurance  │      │  │
│  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │  │
│  └─────────┼──────────────────┼──────────────────┼─────────────┘  │
│            │                  │                  │                 │
└────────────┼──────────────────┼──────────────────┼─────────────────┘
             │                  │                  │
             │                  │                  │
    ┌────────▼────────┐  ┌──────▼──────┐  ┌───────▼────────┐
    │ Hospital        │  │  CallLinc   │  │  Doctor Hub    │
    │ Directory API   │  │  Voice AI   │  │    Portal      │
    │                 │  │             │  │                │
    │ localhost:8000  │  │ GCP Run     │  │  GitHub App    │
    └────────┬────────┘  └──────┬──────┘  └───────┬────────┘
             │                  │                  │
             │                  │                  │
    ┌────────▼────────────────────▼──────────────────▼────────┐
    │              External Services                           │
    │                                                          │
    │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
    │  │   Google    │  │   Gemini    │  │   NPHIES    │    │
    │  │    Maps     │  │   2.5 Live  │  │ Insurance   │    │
    │  │     API     │  │     API     │  │     API     │    │
    │  └─────────────┘  └─────────────┘  └─────────────┘    │
    │                                                          │
    │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
    │  │  Firebase   │  │    Apple    │  │  Analytics  │    │
    │  │   Auth      │  │   Speech    │  │   Service   │    │
    │  └─────────────┘  └─────────────┘  └─────────────┘    │
    └──────────────────────────────────────────────────────────┘
```

## Data Flow Diagrams

### Voice Triage Appointment Booking Flow

```
User                   iOS App              CallLinc AI         Hospital API      Doctor Hub
  │                       │                      │                   │                │
  │  "Find dentist"       │                      │                   │                │
  ├──────────────────────>│                      │                   │                │
  │                       │  WebSocket: voice    │                   │                │
  │                       ├─────────────────────>│                   │                │
  │                       │                      │                   │                │
  │                       │  Transcription +     │                   │                │
  │                       │  Intent: "dentist"   │                   │                │
  │                       │<─────────────────────┤                   │                │
  │                       │                      │                   │                │
  │                       │  Search facilities   │                   │                │
  │                       ├──────────────────────┼──────────────────>│                │
  │                       │                      │                   │                │
  │                       │  Dental clinics      │                   │                │
  │                       │<─────────────────────┼───────────────────┤                │
  │                       │                      │                   │                │
  │  Facility cards       │  AI: "Here are 3     │                   │                │
  │  displayed            │  recommended..."     │                   │                │
  │<──────────────────────┤<─────────────────────┤                   │                │
  │                       │                      │                   │                │
  │  Tap facility card    │                      │                   │                │
  ├──────────────────────>│                      │                   │                │
  │                       │                      │                   │                │
  │                       │  Fetch doctors       │                   │                │
  │                       ├──────────────────────┼───────────────────┼───────────────>│
  │                       │                      │                   │                │
  │                       │  Doctor list         │                   │                │
  │                       │<─────────────────────┼───────────────────┼────────────────┤
  │                       │                      │                   │                │
  │  Select doctor        │                      │                   │                │
  ├──────────────────────>│                      │                   │                │
  │                       │                      │                   │                │
  │                       │  Get availability    │                   │                │
  │                       ├──────────────────────┼───────────────────┼───────────────>│
  │                       │                      │                   │                │
  │                       │  Available slots     │                   │                │
  │                       │<─────────────────────┼───────────────────┼────────────────┤
  │                       │                      │                   │                │
  │  Choose time slot     │                      │                   │                │
  │  Enter patient info   │                      │                   │                │
  ├──────────────────────>│                      │                   │                │
  │                       │                      │                   │                │
  │                       │  Book appointment    │                   │                │
  │                       ├──────────────────────┼───────────────────┼───────────────>│
  │                       │                      │                   │                │
  │                       │  Confirmation        │                   │                │
  │                       │<─────────────────────┼───────────────────┼────────────────┤
  │                       │                      │                   │                │
  │  Confirmation screen  │                      │                   │                │
  │  + Calendar event     │                      │                   │                │
  │<──────────────────────┤                      │                   │                │
```

### Voice Recognition Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                    Voice Input Processing                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Microphone      │
                    │  AVAudioEngine   │
                    └────────┬─────────┘
                             │ Raw Audio Buffer
                             ▼
              ┌──────────────────────────────┐
              │    Audio Preprocessing       │
              │  - 16kHz sampling            │
              │  - Noise reduction           │
              │  - Echo cancellation         │
              └────────┬─────────────────────┘
                       │
          ┌────────────┴────────────┐
          │                         │
          ▼                         ▼
┌──────────────────┐      ┌──────────────────┐
│  Apple Speech    │      │  CallLinc API    │
│  Recognition     │      │  Audio Stream    │
│  (Local)         │      │  (WebSocket)     │
└────────┬─────────┘      └────────┬─────────┘
         │                         │
         │ Transcription           │ Audio Data
         ▼                         ▼
┌──────────────────┐      ┌──────────────────┐
│  Display in UI   │      │  Gemini 2.5      │
│  (Real-time)     │      │  Live API        │
└──────────────────┘      └────────┬─────────┘
                                   │
                          ┌────────┴─────────┐
                          │                  │
                          ▼                  ▼
                  ┌──────────────┐   ┌──────────────┐
                  │ NLU Intent   │   │ Function     │
                  │ Detection    │   │ Calling      │
                  └──────┬───────┘   └──────┬───────┘
                         │                  │
                         └────────┬─────────┘
                                  │
                                  ▼
                        ┌──────────────────┐
                        │  AI Response     │
                        │  Generation      │
                        └────────┬─────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                    ▼                         ▼
          ┌──────────────────┐      ┌──────────────────┐
          │  Text Response   │      │  Audio TTS       │
          │  (Display)       │      │  (Playback)      │
          └──────────────────┘      └──────────────────┘
```

## Component Dependencies

```
┌───────────────────────────────────────────────────────────────┐
│                      iOS Frameworks                           │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  SwiftUI         ◄─── All UI Components                      │
│  Combine         ◄─── Reactive state management              │
│  Foundation      ◄─── Networking, data models                │
│  CoreLocation    ◄─── Map, geolocation services              │
│  MapKit          ◄─── Interactive maps                       │
│  AVFoundation    ◄─── Audio recording/playback               │
│  Speech          ◄─── Voice recognition                      │
│  EventKit        ◄─── Calendar integration                   │
│  UserNotifications ◄─── Push notifications                   │
│                                                               │
└───────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────┐
│                    Custom Services                            │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  VoiceTriageService    ──┬─► AVAudioEngine                   │
│                          ├─► SFSpeechRecognizer              │
│                          ├─► URLSessionWebSocketTask          │
│                          └─► AVAudioPlayer                    │
│                                                               │
│  DoctorHubService      ──┬─► URLSession                       │
│                          └─► JSONDecoder/Encoder              │
│                                                               │
│  APIService            ──┬─► URLSession                       │
│                          └─► Codable models                   │
│                                                               │
│  FacilityDataManager   ──┬─► Combine (@Published)            │
│                          └─► async/await                      │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

## Database Schema (Conceptual)

```sql
-- Facilities
CREATE TABLE facilities (
    id VARCHAR(255) PRIMARY KEY,
    place_id VARCHAR(255),
    name_en VARCHAR(255),
    name_ar VARCHAR(255),
    type VARCHAR(50),
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    district VARCHAR(100),
    rating DECIMAL(2,1),
    has_emergency BOOLEAN,
    is_24_hours BOOLEAN
);

-- Doctors
CREATE TABLE doctors (
    id VARCHAR(255) PRIMARY KEY,
    facility_id VARCHAR(255),
    name_en VARCHAR(255),
    name_ar VARCHAR(255),
    specialty VARCHAR(100),
    years_experience INT,
    rating DECIMAL(2,1),
    FOREIGN KEY (facility_id) REFERENCES facilities(id)
);

-- Appointments
CREATE TABLE appointments (
    id VARCHAR(255) PRIMARY KEY,
    doctor_id VARCHAR(255),
    facility_id VARCHAR(255),
    patient_id VARCHAR(255),
    appointment_date DATE,
    start_time TIME,
    status VARCHAR(20),
    confirmation_code VARCHAR(20),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id),
    FOREIGN KEY (facility_id) REFERENCES facilities(id)
);

-- Conversations (Voice Triage)
CREATE TABLE conversations (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255),
    timestamp TIMESTAMP,
    role VARCHAR(20),
    content TEXT,
    audio_url VARCHAR(500)
);

-- Insurance Claims
CREATE TABLE insurance_claims (
    id VARCHAR(255) PRIMARY KEY,
    appointment_id VARCHAR(255),
    patient_id VARCHAR(255),
    provider VARCHAR(100),
    policy_number VARCHAR(50),
    claim_amount DECIMAL(10,2),
    status VARCHAR(20),
    FOREIGN KEY (appointment_id) REFERENCES appointments(id)
);
```

## Security Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Security Layers                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Application Layer                                          │
│  ├─ User Authentication (Firebase Auth)                    │
│  ├─ Session Management (JWT tokens)                        │
│  ├─ Biometric Auth (Face ID / Touch ID)                    │
│  └─ Keychain Storage (Sensitive data)                      │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│  Network Layer                                              │
│  ├─ HTTPS/TLS 1.3 (All API calls)                         │
│  ├─ WSS (WebSocket Secure)                                 │
│  ├─ Certificate Pinning                                    │
│  └─ API Key Rotation                                       │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                                 │
│  ├─ End-to-End Encryption (Voice data)                     │
│  ├─ AES-256 Encryption (Patient data)                      │
│  ├─ CoreData Encryption                                    │
│  └─ Secure Enclave (Keys)                                  │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│  Compliance                                                 │
│  ├─ HIPAA Compliance ✅                                     │
│  ├─ PDPL (Saudi Data Protection) ✅                        │
│  ├─ GDPR Ready ✅                                          │
│  └─ NPHIES Integration ✅                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Deployment Pipeline

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│   Dev    │───>│  Test    │───>│ Staging  │───>│   Prod   │
│  Local   │    │ TestFlt  │    │  Beta    │    │App Store │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
     │               │                │               │
     ▼               ▼                ▼               ▼
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  Unit    │    │Integration│   │   UAT    │    │  Live    │
│  Tests   │    │   Tests   │   │  Tests   │    │  Users   │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
```

---

**Legend:**
- `───>` Data flow
- `◄───` Dependency
- `├─►` Integration point
- `└─►` Component relationship

**Last Updated:** November 27, 2025
