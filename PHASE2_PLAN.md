# Phase 2 Delivery Plan

## Scope
- DoctorHub-backed features: Video Consultations, Prescription Management, Lab Results Integration, Medication Reminders (server-driven where applicable)
- Health Records Vault (local/optional cloud storage) — only feature not in DoctorHub
- Multi-language Support (Urdu, Hindi, Filipino)

## Milestones
1) Foundation (week 1-2)
   - Align contracts with DoctorHub (auth scopes, endpoints, push payloads)
   - App architecture extensions: secure storage, background tasks, notifications, localization setup
   - Feature flags + analytics events
2) Video Consultations (week 2-4)
   - Integrate DoctorHub video session APIs (token/session fetch), call state machine, pre-call checks, call UI
   - Appointment → DoctorHub session handoff
3) Rx & Labs (week 3-5)
   - DoctorHub prescription list/detail/refill flows
   - DoctorHub lab results listing, secure download/view, share/export guardrails
4) Reminders & Vault (week 4-6)
   - Medication reminders: consume DoctorHub push where present, local fallback for offline
   - Personal health records storage and viewer (non-DoctorHub), surfaced inside hospital/facility directories for quick patient/provider access
5) Localization (parallel, wrap-up)
   - Add Urdu/Hindi/Filipino strings, typography, layout validation

## Priority Order (why)
1) Foundation – unblocks security, notifications, and localization needed by all epics.
2) Video Consultations – highest user impact; booking handoff already exists to extend.
3) Prescription Management – recurring engagement; lower technical risk than video.
4) Lab Results Integration – similar patterns to Rx but adds secure downloads.
5) Medication Reminders – depends on notifications; simpler once plumbing exists.
6) Health Records Vault – heaviest security work; schedule after patterns proven.
Parallel) Localization – runs alongside for strings, fonts, and layout QA.

## Cross-Cutting Requirements
- Auth: token refresh, device binding for PHI actions, per-feature scopes.
- Security: at-rest encryption (Keychain + encrypted files for downloads), TLS pinning if backend supports.
- Offline/Resilience: queue mutations (new Rx, reminders) for retry; graceful degraded views.
- Notifications: APNs for server events (new lab result, prescription issued), UNUserNotificationCenter for reminders.
- Accessibility: VoiceOver, Dynamic Type, captions/subtitles in video UI.
- Observability: analytics + breadcrumbs around calls, uploads, downloads, reminders fired.
- Feature Flags: gate each epic for controlled rollout.

## Epic Breakdown

### Video Consultations
- Client
  - Pre-call checks (camera/mic permissions, network quality)
  - Call state machine: idle → ringing → connected → on-hold → ended/failed
  - UI: waiting room, in-call controls (mute, video toggle, switch cam, end), error/quality banners
  - Background/foreground handling; call keeps running when screen locks
  - Captions/subtitles toggle (if SDK supports)
- Backend/API
  - DoctorHub session create/join endpoints; token exchange; webhook for end-of-call status
- Testing
  - Unit: state machine transitions, token refresh logic
  - Integration: appointment → create session → join call
  - UI: call controls, error surfaces, background resume

### Prescription Management
- Client
  - Rx list (active, expired), detail view (doctor, meds, instructions), refill CTA, attachment download
  - File viewer for PDF/image; share limited behind confirmation and audit event
  - Create/refill flow with dosage and schedule validation
- Backend/API
  - DoctorHub Rx list/detail, refill request, attachment fetch; audit logging hook
- Testing
  - Unit: form validation, dosage scheduling math
  - Integration: login → fetch Rx → request refill
  - UI: list states (empty/error/loading), attachment viewer

### Lab Results Integration
- Client
  - Results list grouped by provider/date; detail view with values/reference ranges
  - Secure download/open; cache encrypted on disk; purge controls
  - Share/export requires confirmation + face/biometric gate (if available)
- Backend/API
  - DoctorHub results list/detail endpoints; pre-signed URLs; checksum for file integrity
- Testing
  - Unit: file integrity check, cache purge
  - Integration: fetch → download → view
  - UI: empty/error, share guardrails

### Medication Reminders
- Client
  - Create/edit schedules (times per day, weekdays, PRN)
  - Local notifications scheduling with unique IDs; snooze/skip actions
  - Missed reminder handling + reschedule rules
  - Sync with server when online; dedupe to avoid double alerts
- Backend/API
  - DoctorHub reminder CRUD; push notification payloads for server-driven reminders
- Testing
  - Unit: schedule generator, snooze/skip state, timezone changes
  - Integration: create → receive notification → mark taken
  - UI: notification actions, badge counts

### Health Records Vault
- Client
  - Encrypted document store (Keychain key, file-level encryption)
  - Import (Files/Photos/Share Sheet), categorize, tag/search; entry point from facility detail (Directory) so providers/patients reach it in-context
  - Viewer with quick actions (share/export guarded), delete/wipe
  - Optional cloud backup toggle (depending on backend policy)
- Backend/API
  - Upload/download with end-to-end or server-side encryption; retention policy endpoints
- Testing
  - Unit: encryption/decryption, search, wipe
  - Integration: import → encrypt → view → delete
  - UI: empty states, long-running uploads

### Multi-language Support
- Client
  - Add Urdu/Hindi/Filipino localizations; ensure pluralization support
  - Typography: choose fonts that render well; adjust line heights
  - Layout QA for RTL-like constraints (even if these are LTR)
- Testing
  - Snapshot/UI tests for key screens per locale
  - String coverage checks (no hardcoded English)

## Dependencies & Decisions Needed
- Confirm DoctorHub video session/token flow and SDK expectations (native vs. embedded).
- Verify DoctorHub endpoints for Rx, labs, reminders, and push payload formats.
- Encryption approach for vault/downloads (CryptoKit + secure enclave?).
- Notification strategy: server-push (DoctorHub) vs. local-only fallbacks.
- Branding/UX assets for new flows (icons, empty states, illustrations).
- Translation pipeline (who supplies translations; glossary ownership).

## Definition of Done (per epic)
- Feature behind flag, shipped to TestFlight
- Happy-path + edge-path integration tests green
- Telemetry events emitted and verified
- Accessibility and localization validated
- Security checklist passed (encryption, auth scopes, PII minimization)
