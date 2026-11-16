# Project Charter — Industrial Smart Surveillance Platform

**Version:** 1.0.0-baseline  
**Status:** Requirements baseline derived from stakeholder conversation; technical discovery still required.  
**Sites:** BNF and RNF  
**Client application:** Android  
**Primary language for code and identifiers:** English  

## 1. Mission

Build a maintainable, secure, scalable industrial surveillance and safety platform for two factories, BNF and RNF. The platform combines existing CCTV/NVR infrastructure, ZKTeco attendance and biometric devices, AI video analytics, incident/event management, manager-facing Android workflows, and in-app operational reporting.

The platform must improve visibility and response. It must not turn an AI prediction into an automatic disciplinary decision or present an uncertain identity/object match as a fact.

## 2. Confirmed operating baseline

| Area | Confirmed stakeholder input |
|---|---|
| Sites | BNF and RNF are to be treated as independent factories in their operational systems and data |
| Attendance | Same ZKBioTime product/system family is used at both sites; each site has its own independent installation/environment |
| Databases | SQL Server is separate per factory |
| Cameras | Approximately 200+ cameras at BNF and approximately 200+ at RNF; counts may increase |
| Recording | Multiple NVRs of different types/models exist; many cameras connect through network switches |
| Fingerprint/face terminals | Approximately 18+ devices per factory; device models are mixed and may increase |
| Employee key | A stable Employee ID exists in the attendance system and SQL Server records |
| Face source | Employee face images currently exist only inside biometric/attendance devices; no separate employee photo repository was identified |
| Existing server | Current server has no GPU; CPU/RAM/storage and suitability are unknown |
| Site connectivity | A stable network connection between factories exists, but independence remains a design requirement |
| Video retention | 30 days |
| Detection scope | PPE violations, restricted-area entry, falls/accidents, phone use, fire, theft/suspicious movement |
| Theft/object scope | Classify relevant products/materials/packaging and track other moving objects; detect movement from production/storage areas and transfers between people |
| Employee tracking | Maintain a time-ordered record of employee appearances between cameras with location and timestamp |
| Alerts | In-app notifications; ordinary alerts routed to the relevant factory manager, company management, and security managers |
| Fire alerts | Immediate alert for responsible people at the affected factory; no human confirmation gate before dispatch |
| Factory visibility | Managers can switch between BNF and RNF |
| Video permissions | Live and recorded video access restricted to security managers and senior management |
| App audience | Managers only |
| App features | Live camera viewing, recording playback, alerts, incident follow-up, dashboards and reports |
| Reports | Built inside the application; charts and percentages; automatic daily, weekly and monthly reporting; no Power BI subscription and no email delivery requested |
| Client platform | Android |

## 3. Business objectives

1. Detect and surface safety, security, and operational events from the installed camera estate.
2. Route alerts to the correct recipients without leaking one factory's operational events to the other factory's ordinary users.
3. Give authorized managers cross-factory operational visibility while maintaining site-level data boundaries.
4. Link camera observations to employee identities only where the source data and confidence support the match.
5. Provide usable investigation context: camera, time, location, clip reference, detection type, confidence, model version, and related sightings.
6. Produce scheduled in-app reports without relying on Power BI or an external reporting subscription.
7. Preserve maintainability and controlled expansion as camera/device counts and AI use cases increase.

## 4. Scope

### In scope

- Two-site operation: BNF and RNF.
- Separate site data planes and separate SQL Server integrations.
- ZKBioTime integration per site.
- Device and camera/NVR inventory and adapters.
- Face-image acquisition feasibility from existing biometric devices/ZKBioTime.
- AI detection for the six event groups listed in the baseline.
- Zone-based PPE and restricted-area policies.
- Person tracking and cross-camera identity association with confidence/provenance.
- Object classification/tracking and suspicious movement events.
- Immediate fire alert pipeline.
- Android manager application.
- Role-based access, video authorization, dashboards, incident/event records.
- In-app daily/weekly/monthly reporting.
- 30-day video retention policy, subject to a separately approved incident-evidence exception policy.

### Out of scope unless separately approved

- Replacing the existing NVR recording platform.
- Replacing ZKBioTime or biometric terminals.
- Automatic disciplinary decisions, employee scoring, or punitive actions based only on AI output.
- Automatic law-enforcement reporting.
- iOS application.
- Power BI, email, SMS, or WhatsApp reporting/notification channels.
- Cross-factory sharing of raw video or full operational databases by default.
- Guaranteed recognition of every employee in every camera condition.

## 5. Guiding engineering principles

Correctness, reliability, security, and data isolation take priority over speed, novelty, and premature optimization. Prefer a modular architecture with explicit boundaries over a fleet of microservices introduced before operational need is proven. Use design patterns only when they solve a visible problem. Keep vendor-specific behavior behind adapters. Every AI detection is an observation with evidence and confidence, not an unquestionable fact.

## 6. Success definition

The system is accepted only when each approved requirement is implemented, traced to tests, and verified in a representative pilot at both factories. A UI mockup, placeholder response, hard-coded sample, disconnected button, simulated alert, or unverified integration does not count as completion.
