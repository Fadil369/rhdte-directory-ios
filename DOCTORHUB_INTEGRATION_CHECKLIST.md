# DoctorHub Integration Checklist

## Auth & Security
- [ ] Confirm OAuth flow and token scopes per feature (video, Rx, labs, reminders).
- [ ] Refresh token timing and grace period; background refresh allowed?
- [ ] Device binding required for PHI actions? If yes, document binding API.
- [ ] TLS pinning support and cert rotation policy.
- [ ] Audit logging expectations (who/what/when) for Rx/lab access and reminder changes.

## Endpoints (to confirm)
- Video: session create/join, token exchange, end-of-call status webhook.
- Prescriptions: list, detail, refill request, attachment fetch (PDF/image).
- Lab Results: list, detail, attachment download with checksum/signature.
- Reminders: CRUD, server-side schedule, push payload format.
- Common: user profile/eligibility, provider roster, appointment → session handoff.

## Push/Real-Time Payloads
- [ ] Video: incoming call/session ready payload fields and TTL.
- [ ] Reminders: action identifiers (snooze/mark taken), dedupe keys.
- [ ] Labs/Rx: new item available payload shape, attachment URL lifetime.

## Feature Flags & Versioning
- [ ] Flag per epic (video, Rx, labs, reminders).
- [ ] Minimum app version for each endpoint; deprecation notices.

## Telemetry
- [ ] Required events and identifiers (session ID, facility ID, provider ID).
- [ ] Error taxonomy for API/SDK failures.

## Test Data
- [ ] Non-PHI sandbox users for all features.
- [ ] Sample payloads for video, Rx, labs, reminders.
