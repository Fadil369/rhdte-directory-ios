# DoctorHub Integration Checklist

> **Status**: In Progress  
> **Last Updated**: November 27, 2025  
> **API Base URL**: `https://brainsait-doctor-hub--fadil369.github.app/api`

---

## Auth & Security

### OAuth Flow & Token Scopes
- [x] OAuth 2.0 Authorization Code Flow with PKCE
- [x] Scopes defined per feature:
  - `video:join` - Join video consultations
  - `video:create` - Create/schedule video sessions
  - `rx:read` - View prescriptions
  - `rx:write` - Request refills
  - `labs:read` - View lab results
  - `labs:download` - Download lab attachments
  - `reminders:read` - View medication reminders
  - `reminders:write` - Create/modify reminders
  - `profile:read` - Read user profile
  - `profile:write` - Update user profile

### Token Management
- [x] Access token TTL: 3600 seconds (1 hour)
- [x] Refresh token TTL: 2592000 seconds (30 days)
- [x] Grace period for refresh: 300 seconds before expiry
- [x] Background refresh: Allowed (use `BGTaskScheduler`)

```swift
// Token refresh request
POST /api/auth/token/refresh
Content-Type: application/json

{
  "refresh_token": "<refresh_token>",
  "grant_type": "refresh_token"
}

// Response
{
  "access_token": "<new_access_token>",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "<new_refresh_token>",
  "scope": "video:join rx:read labs:read reminders:write"
}
```

### Device Binding
- [x] Required for PHI actions (Rx write, lab downloads)
- [x] Binding API endpoint: `POST /api/devices/bind`

```swift
// Device binding request
POST /api/devices/bind
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "device_id": "<UUID>",
  "device_name": "iPhone 15 Pro",
  "platform": "iOS",
  "os_version": "17.1",
  "app_version": "1.0.0",
  "push_token": "<APNs_token>"
}

// Response
{
  "binding_id": "<binding_uuid>",
  "status": "active",
  "bound_at": "2025-11-27T12:00:00Z",
  "expires_at": "2026-11-27T12:00:00Z"
}
```

### TLS Security
- [x] TLS 1.3 required
- [x] Certificate pinning: SHA-256 hashes
- [x] Cert rotation policy: 90-day notice via `/api/security/cert-rotation`

### Audit Logging
- [x] All PHI access logged with:
  - `user_id`, `action`, `resource_id`, `timestamp`
  - `ip_address`, `device_id`, `session_id`
- [x] Rx/Lab access triggers HIPAA audit event

---

## Endpoints (Confirmed)

### Video Consultations

```swift
// Create video session
POST /api/video/sessions
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "appointment_id": "<appointment_uuid>",
  "doctor_id": "<doctor_uuid>",
  "patient_id": "<patient_uuid>",
  "scheduled_at": "2025-11-28T14:00:00Z",
  "duration_minutes": 30
}

// Response
{
  "session_id": "<session_uuid>",
  "join_url": "https://meet.doctorhub.app/s/<session_id>",
  "host_token": "<host_jwt>",
  "participant_token": "<participant_jwt>",
  "status": "scheduled",
  "expires_at": "2025-11-28T15:00:00Z"
}

// Join session
GET /api/video/sessions/{session_id}/join
Authorization: Bearer <access_token>

// Response
{
  "session_id": "<session_uuid>",
  "websocket_url": "wss://rtc.doctorhub.app/ws/<session_id>",
  "ice_servers": [
    {"urls": "stun:stun.doctorhub.app:3478"},
    {"urls": "turn:turn.doctorhub.app:3478", "username": "...", "credential": "..."}
  ],
  "participant_token": "<jwt>",
  "status": "ready"
}

// End-of-call webhook (server → client push)
{
  "event": "call.ended",
  "session_id": "<session_uuid>",
  "ended_at": "2025-11-28T14:28:45Z",
  "duration_seconds": 1725,
  "ended_by": "doctor",
  "reason": "completed"
}
```

### Prescriptions

```swift
// List prescriptions
GET /api/prescriptions?patient_id={id}&status=active
Authorization: Bearer <access_token>

// Response
{
  "prescriptions": [
    {
      "id": "<rx_uuid>",
      "medication_name": "Metformin 500mg",
      "medication_name_ar": "ميتفورمين 500 مجم",
      "dosage": "1 tablet twice daily",
      "doctor_id": "<doctor_uuid>",
      "doctor_name": "Dr. Ahmed Hassan",
      "facility_id": "<facility_uuid>",
      "issued_at": "2025-11-25T10:00:00Z",
      "expires_at": "2026-05-25T10:00:00Z",
      "refills_remaining": 5,
      "status": "active",
      "attachments": [
        {
          "id": "<attachment_uuid>",
          "type": "pdf",
          "url": "/api/prescriptions/<rx_uuid>/attachments/<attachment_uuid>",
          "checksum": "sha256:abc123..."
        }
      ]
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 5
  }
}

// Get prescription detail
GET /api/prescriptions/{rx_id}
Authorization: Bearer <access_token>

// Request refill
POST /api/prescriptions/{rx_id}/refill
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "pharmacy_id": "<pharmacy_uuid>",
  "delivery_method": "pickup",
  "notes": "Please have ready by 3pm"
}

// Response
{
  "refill_id": "<refill_uuid>",
  "prescription_id": "<rx_uuid>",
  "status": "pending",
  "estimated_ready_at": "2025-11-27T15:00:00Z"
}

// Download attachment
GET /api/prescriptions/{rx_id}/attachments/{attachment_id}
Authorization: Bearer <access_token>

// Response: Binary PDF/Image with headers
Content-Type: application/pdf
X-Checksum: sha256:abc123...
Content-Disposition: attachment; filename="prescription_rx123.pdf"
```

### Lab Results

```swift
// List lab results
GET /api/labs?patient_id={id}&from_date=2025-01-01
Authorization: Bearer <access_token>

// Response
{
  "results": [
    {
      "id": "<lab_uuid>",
      "test_name": "Complete Blood Count",
      "test_name_ar": "فحص الدم الشامل",
      "ordered_by": "<doctor_uuid>",
      "doctor_name": "Dr. Sara Al-Rashid",
      "facility_id": "<facility_uuid>",
      "facility_name": "King Faisal Specialist Hospital",
      "collected_at": "2025-11-20T09:00:00Z",
      "reported_at": "2025-11-21T14:00:00Z",
      "status": "completed",
      "has_critical_values": false,
      "attachments": [
        {
          "id": "<attachment_uuid>",
          "type": "pdf",
          "url": "/api/labs/<lab_uuid>/attachments/<attachment_uuid>",
          "checksum": "sha256:def456...",
          "signature": "<digital_signature>"
        }
      ]
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 12
  }
}

// Get lab result detail
GET /api/labs/{lab_id}
Authorization: Bearer <access_token>

// Response
{
  "id": "<lab_uuid>",
  "test_name": "Complete Blood Count",
  "values": [
    {
      "name": "Hemoglobin",
      "value": "14.2",
      "unit": "g/dL",
      "reference_range": "12.0-17.5",
      "status": "normal"
    },
    {
      "name": "White Blood Cell",
      "value": "11.2",
      "unit": "K/uL",
      "reference_range": "4.5-11.0",
      "status": "high",
      "is_critical": false
    }
  ],
  "interpretation": "Slight elevation in WBC, likely due to recent infection.",
  "attachments": [...]
}

// Download attachment (with integrity verification)
GET /api/labs/{lab_id}/attachments/{attachment_id}
Authorization: Bearer <access_token>

// Response headers
Content-Type: application/pdf
X-Checksum: sha256:def456...
X-Digital-Signature: <base64_signature>
X-Certificate-Chain: <base64_cert_chain>
```

### Reminders

```swift
// List reminders
GET /api/reminders?patient_id={id}
Authorization: Bearer <access_token>

// Response
{
  "reminders": [
    {
      "id": "<reminder_uuid>",
      "prescription_id": "<rx_uuid>",
      "medication_name": "Metformin 500mg",
      "dosage": "1 tablet",
      "schedule": {
        "type": "daily",
        "times": ["08:00", "20:00"],
        "days_of_week": null,
        "start_date": "2025-11-25",
        "end_date": null
      },
      "status": "active",
      "next_reminder_at": "2025-11-27T08:00:00Z",
      "snooze_duration_minutes": 10,
      "created_at": "2025-11-25T10:00:00Z"
    }
  ]
}

// Create reminder
POST /api/reminders
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "prescription_id": "<rx_uuid>",
  "medication_name": "Metformin 500mg",
  "dosage": "1 tablet",
  "schedule": {
    "type": "daily",
    "times": ["08:00", "20:00"],
    "start_date": "2025-11-25"
  },
  "snooze_duration_minutes": 10
}

// Response
{
  "id": "<reminder_uuid>",
  "status": "active",
  "next_reminder_at": "2025-11-27T08:00:00Z"
}

// Update reminder
PUT /api/reminders/{reminder_id}
Authorization: Bearer <access_token>

// Delete reminder
DELETE /api/reminders/{reminder_id}
Authorization: Bearer <access_token>

// Mark as taken
POST /api/reminders/{reminder_id}/taken
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "taken_at": "2025-11-27T08:05:00Z",
  "notes": null
}

// Snooze reminder
POST /api/reminders/{reminder_id}/snooze
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "snooze_until": "2025-11-27T08:15:00Z"
}
```

### Common Endpoints

```swift
// Get user profile/eligibility
GET /api/users/me
Authorization: Bearer <access_token>

// Response
{
  "id": "<user_uuid>",
  "name_en": "Mohammed Al-Ahmadi",
  "name_ar": "محمد الأحمدي",
  "email": "m.alahmadi@email.com",
  "phone": "+966501234567",
  "date_of_birth": "1985-03-15",
  "eligibility": {
    "video_consultations": true,
    "prescription_refills": true,
    "lab_access": true,
    "reminders": true
  },
  "insurance": {
    "provider": "Bupa Arabia",
    "policy_number": "POL123456",
    "status": "active"
  }
}

// Get provider roster for facility
GET /api/facilities/{facility_id}/providers
Authorization: Bearer <access_token>

// Appointment → Session handoff
POST /api/appointments/{appointment_id}/start-session
Authorization: Bearer <access_token>

// Response: Same as video session creation
```

---

## Push/Real-Time Payloads

### Video Push Notifications

```json
// Incoming call / Session ready
{
  "aps": {
    "alert": {
      "title": "Video Consultation",
      "body": "Dr. Ahmed Hassan is ready for your appointment"
    },
    "sound": "ringtone.caf",
    "badge": 1,
    "category": "VIDEO_CALL"
  },
  "doctorhub": {
    "type": "video.session_ready",
    "session_id": "<session_uuid>",
    "appointment_id": "<appointment_uuid>",
    "doctor_name": "Dr. Ahmed Hassan",
    "join_url": "doctorhub://video/join/<session_id>",
    "expires_at": "2025-11-28T14:05:00Z",
    "ttl": 300
  }
}
```

### Reminder Push Notifications

```json
// Medication reminder
{
  "aps": {
    "alert": {
      "title": "Medication Reminder",
      "title-loc-key": "REMINDER_TITLE",
      "body": "Time to take Metformin 500mg",
      "body-loc-key": "REMINDER_BODY",
      "body-loc-args": ["Metformin 500mg"]
    },
    "sound": "reminder.caf",
    "badge": 1,
    "category": "MEDICATION_REMINDER",
    "mutable-content": 1
  },
  "doctorhub": {
    "type": "reminder.due",
    "reminder_id": "<reminder_uuid>",
    "medication_name": "Metformin 500mg",
    "dosage": "1 tablet",
    "dedupe_key": "reminder_<reminder_uuid>_<scheduled_time>",
    "actions": [
      {"id": "TAKEN", "title": "Mark as Taken"},
      {"id": "SNOOZE", "title": "Snooze 10 min"}
    ]
  }
}

// Action identifiers
- TAKEN: Mark medication as taken
- SNOOZE: Snooze for configured duration
- SKIP: Skip this dose
```

### Labs/Rx Push Notifications

```json
// New lab result available
{
  "aps": {
    "alert": {
      "title": "New Lab Results",
      "body": "Your Complete Blood Count results are ready"
    },
    "sound": "default",
    "badge": 1,
    "category": "NEW_LAB_RESULT"
  },
  "doctorhub": {
    "type": "labs.result_ready",
    "lab_id": "<lab_uuid>",
    "test_name": "Complete Blood Count",
    "has_critical_values": false,
    "attachment_url": "/api/labs/<lab_uuid>/attachments/<attachment_uuid>",
    "attachment_url_lifetime": 3600
  }
}

// Prescription issued/refill ready
{
  "aps": {
    "alert": {
      "title": "Prescription Ready",
      "body": "Your prescription for Metformin is ready for pickup"
    },
    "sound": "default",
    "badge": 1,
    "category": "PRESCRIPTION_READY"
  },
  "doctorhub": {
    "type": "rx.ready",
    "prescription_id": "<rx_uuid>",
    "medication_name": "Metformin 500mg",
    "pharmacy_name": "Nahdi Pharmacy - Olaya",
    "pickup_code": "RX123456"
  }
}
```

---

## Feature Flags & Versioning

### Feature Flags Configuration

```swift
// GET /api/config/feature-flags
{
  "flags": {
    "video_consultations": {
      "enabled": true,
      "min_app_version": "1.0.0",
      "rollout_percentage": 100,
      "enabled_for_users": null
    },
    "prescription_management": {
      "enabled": true,
      "min_app_version": "1.0.0",
      "rollout_percentage": 100
    },
    "lab_results": {
      "enabled": true,
      "min_app_version": "1.0.0",
      "rollout_percentage": 100
    },
    "medication_reminders": {
      "enabled": true,
      "min_app_version": "1.0.0",
      "rollout_percentage": 100
    },
    "health_vault": {
      "enabled": false,
      "min_app_version": "1.1.0",
      "rollout_percentage": 0,
      "note": "Phase 2 feature"
    }
  },
  "deprecated_endpoints": [
    {
      "endpoint": "/api/v1/appointments",
      "deprecated_at": "2025-10-01",
      "removal_date": "2026-04-01",
      "replacement": "/api/appointments"
    }
  ]
}
```

### Minimum App Versions

| Endpoint Category | Min Version | Notes |
|-------------------|-------------|-------|
| Video Sessions | 1.0.0 | WebRTC required |
| Prescriptions | 1.0.0 | - |
| Lab Results | 1.0.0 | - |
| Reminders | 1.0.0 | Push notifications required |
| Health Vault | 1.1.0 | Phase 2 |

---

## Telemetry

### Required Events

```swift
// Event structure
{
  "event_name": "video.session.started",
  "timestamp": "2025-11-27T14:00:00Z",
  "session_id": "<uuid>",
  "user_id": "<uuid>",
  "device_id": "<uuid>",
  "app_version": "1.0.0",
  "platform": "iOS",
  "properties": {
    "facility_id": "<uuid>",
    "provider_id": "<uuid>",
    "appointment_id": "<uuid>",
    "connection_type": "wifi",
    "duration_ms": null
  }
}

// Required events per feature
Video:
  - video.session.started
  - video.session.ended
  - video.connection.failed
  - video.audio.muted/unmuted
  - video.video.enabled/disabled

Prescriptions:
  - rx.list.viewed
  - rx.detail.viewed
  - rx.refill.requested
  - rx.attachment.downloaded

Lab Results:
  - labs.list.viewed
  - labs.detail.viewed
  - labs.attachment.downloaded
  - labs.share.initiated

Reminders:
  - reminder.created
  - reminder.updated
  - reminder.deleted
  - reminder.taken
  - reminder.snoozed
  - reminder.missed
```

### Error Taxonomy

```swift
enum DoctorHubErrorCode: String {
    // Network errors (1xxx)
    case networkUnavailable = "ERR_1001"
    case connectionTimeout = "ERR_1002"
    case sslError = "ERR_1003"
    
    // Auth errors (2xxx)
    case tokenExpired = "ERR_2001"
    case tokenInvalid = "ERR_2002"
    case insufficientScope = "ERR_2003"
    case deviceNotBound = "ERR_2004"
    
    // Video errors (3xxx)
    case sessionNotFound = "ERR_3001"
    case sessionExpired = "ERR_3002"
    case webrtcFailed = "ERR_3003"
    case mediaCaptureError = "ERR_3004"
    
    // Rx errors (4xxx)
    case prescriptionNotFound = "ERR_4001"
    case refillNotAllowed = "ERR_4002"
    case pharmacyUnavailable = "ERR_4003"
    
    // Labs errors (5xxx)
    case labResultNotFound = "ERR_5001"
    case attachmentUnavailable = "ERR_5002"
    case checksumMismatch = "ERR_5003"
    
    // Reminder errors (6xxx)
    case reminderNotFound = "ERR_6001"
    case invalidSchedule = "ERR_6002"
    case pushNotificationsDisabled = "ERR_6003"
}
```

---

## Test Data

### Sandbox Users

| User Type | Email | Password | Features |
|-----------|-------|----------|----------|
| Patient (Full Access) | test.patient@sandbox.doctorhub.app | Sandbox123! | All features enabled |
| Patient (Rx Only) | rx.patient@sandbox.doctorhub.app | Sandbox123! | Rx only, no video |
| Patient (No Insurance) | cash.patient@sandbox.doctorhub.app | Sandbox123! | Cash payment only |
| Doctor | test.doctor@sandbox.doctorhub.app | Doctor123! | Provider account |

### Sample API Response Payloads

All sample payloads are documented inline in the Endpoints section above.

### Test Facilities

| Facility ID | Name | Features |
|-------------|------|----------|
| `fac_test_001` | Sandbox Hospital | Full services |
| `fac_test_002` | Sandbox Clinic | Outpatient only |
| `fac_test_003` | Sandbox Lab | Lab results only |
| `fac_test_004` | Sandbox Pharmacy | Rx pickup only |

### Test Scenarios

1. **Happy Path - Video Consultation**
   - Login as patient → Book appointment → Join video call → End call

2. **Happy Path - Prescription Refill**
   - Login as patient → View prescriptions → Request refill → Confirm pickup

3. **Happy Path - Lab Results**
   - Login as patient → View lab results → Download PDF → Verify checksum

4. **Happy Path - Medication Reminders**
   - Login as patient → Create reminder → Receive push → Mark as taken

5. **Error Handling - Token Expired**
   - Make API call with expired token → Receive 401 → Refresh token → Retry

6. **Offline Mode**
   - Enable airplane mode → View cached data → Queue actions → Sync when online

---

## Implementation Status

- [ ] OAuth flow implementation
- [ ] Token refresh logic
- [ ] Device binding
- [ ] Video session integration
- [ ] Prescription list/detail
- [ ] Refill request flow
- [ ] Lab results list/detail
- [ ] Secure attachment download
- [ ] Reminder CRUD
- [ ] Push notification handling
- [ ] Feature flags service
- [ ] Telemetry integration
- [ ] Error handling
- [ ] Offline support

---

**Next Steps:**
1. Implement `FeatureFlagsService` to gate features
2. Create stub service interfaces for Video, Rx, Labs, Reminders
3. Add navigation entry point from facility detail to Health Vault
4. Wire up push notification handlers
