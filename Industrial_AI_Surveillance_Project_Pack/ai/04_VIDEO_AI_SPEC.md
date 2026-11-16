# Video AI and Analytics Specification

**Document ID:** AI-001  
**Status:** Functional scope confirmed; algorithms, model vendors, thresholds, and measured accuracy are TBD.  

## 1. Core rule

AI produces observations and confidence estimates. The application turns validated observations into events using versioned business rules. An event is not automatically proof of wrongdoing or a verified employee identity.

## 2. Detection catalogue

| ID | Capability | Expected output | Main dependencies / limitations |
|---|---|---|---|
| AI-PPE | PPE compliance by zone | Person track, PPE items detected/missing, zone, confidence, evidence | Camera view, PPE classes, site/zone rules, PPE dataset |
| AI-RESTRICTED | Restricted-area entry | Person/object track entering configured polygon, dwell/time, zone, evidence | Camera calibration, zone polygons, occlusion, direction logic |
| AI-FALL | Fall/accident indicators | Person track, suspected fall posture/event time, confidence, clip | View angle, occlusion, floor visibility, per-site validation |
| AI-PHONE | Phone-use behavior | Person track, phone/person association, confidence, evidence | Resolution, hand visibility, camera angle; avoid inferring use when phone is merely present |
| AI-FIRE | Fire/smoke | Suspected fire/smoke event, camera, confidence, evidence, urgent severity | Visual ambiguity, lighting, steam/dust, urgent dispatch resilience |
| AI-OBJECT | Product/material/package classes | Object class, track ID, location, movement | Site-specific object taxonomy and labeled data |
| AI-MOVEMENT | Suspicious object movement | Object entering/exiting configured boundary, direction, time, associated people | Camera coverage, area boundary, object tracking continuity |
| AI-HANDOFF | Possible transfer between people | Object track plus person tracks and handoff candidate, confidence | Both people/object visible, temporal continuity, high uncertainty |
| AI-PERSON-TRACK | Person sightings across cameras | Track segments, camera/time/location, association confidence | Camera topology, overlap, clock synchronization, appearance changes |
| AI-FACE-ID | Face-to-employee association | Candidate Employee ID, confidence, source image reference, status | Valid conventional photos, legal approval, pose/lighting/quality, evaluation set |

## 3. Zone configuration

Each site must maintain camera-to-zone mapping. A zone may define:

- Physical location name and floor/area reference.
- Camera coverage and polygon/ROI definitions.
- Zone type: office, production, warehouse, restricted, loading, corridor, or approved custom type.
- PPE policy: required item classes and applicable shifts/conditions.
- Restricted-entry policy: authorized roles/schedules where applicable.
- Object movement policy: allowed boundary directions and object classes.
- Alert severity and recipients according to the approved routing matrix.

PPE rules must be policy-driven. A rule requiring hair covering and gloves in a production zone must not accidentally apply to an office zone. The actual PPE matrix must be supplied by the factory's safety owner.

## 4. Person and employee identity

Separate these concepts:

1. **Person detection:** a human-shaped object was detected.
2. **Person tracking:** detections were linked into a track within a camera.
3. **Cross-camera association:** tracks may belong to the same physical person.
4. **Face-to-employee match:** a track/face may match a known employee image.

These are not interchangeable. A successful person detector does not prove identity. Re-identification across cameras can be wrong when uniforms are similar, lighting changes, people cross, or cameras do not overlap.

Every association must record:

- Candidate employee or unknown state.
- Confidence and calibrated threshold version.
- Source image/embedding reference and its provenance.
- Model/version and camera/time context.
- Whether the identity is provisional, accepted by policy, or unresolved.

Do not create a continuous employee route when the system has only disconnected sightings. Show gaps explicitly. Never fabricate the path between cameras.

## 5. Face image acquisition gate

The stakeholder wants to reuse photos already stored in the biometric/attendance system. The system must first prove that a normal face photo can be retrieved for each supported device family through ZKBioTime or an officially supported export path.

Required pilot outcomes per device family:

- Image retrieval success rate and failure reason distribution.
- Image format, dimensions, face visibility, quality, and duplicate handling.
- Correct Employee ID association.
- Refresh behavior when the photo changes.
- Behavior for employees with no usable photo.
- Security of transport, temporary storage, and deletion.

Do not export, reverse engineer, or treat proprietary biometric templates as ordinary photos. Do not use hidden or unsupported access methods as a production dependency.

**Gate:** AI-FACE-ID remains disabled in production until image retrieval, employee linkage, evaluation accuracy, access policy, and privacy/legal approval are documented.

## 6. Theft and object movement semantics

The platform can detect a **suspected unauthorized movement pattern**, not establish theft as a fact. The system should distinguish:

- Object detected.
- Object class candidate.
- Object crossed configured boundary.
- Object associated with one or more person tracks.
- Possible handoff/transfer.
- Movement matched or not matched to an approved process, if such process data becomes available.

The product/material classes must be defined with factory stakeholders. Examples named in the conversation include cartons, raw-material sacks, and containers/packages. The initial model taxonomy must not assume these are the only classes.

For a handoff event, store the observed sequence and uncertainty. If object/person association breaks due to occlusion, mark the event incomplete rather than filling gaps with guesses.

## 7. Fire alert behavior

- Fire/smoke candidate detection produces an urgent event.
- Dispatch does not wait for a person to confirm or reject it.
- Fire routing targets responsible recipients at the affected factory only, as defined by the approved recipient registry.
- Ordinary alert batching/rate limits must not delay urgent fire dispatch.
- Delivery failures must be retried and surfaced through an operational health channel.
- UI wording should say “Suspected fire/smoke detected” unless a human/verified sensor confirms it.

A separate fire alarm/sensor integration may improve reliability but is not confirmed in the baseline; do not silently assume it exists.

## 8. Evaluation requirements

For every event class, maintain a labeled validation dataset representative of both factories, including:

- Day/night, indoor/outdoor, lighting variations.
- Relevant camera resolutions, angles, distances, and compression.
- Occlusion and crowding.
- Normal behavior that resembles a violation.
- Positive and negative examples.
- Site-specific zones and uniforms/PPE.

Report precision, recall, false-positive rate, false-negative rate, latency, and coverage with dataset size, class definitions, and confidence intervals where appropriate. Threshold targets are **TBD** and must be approved by the business/safety owner after pilot measurements. Never invent accuracy such as “99%”.

## 9. Model governance

Every deployed model needs:

- Model ID, version, source/license, checksum, runtime dependencies.
- Supported classes and known limitations.
- Training/evaluation dataset provenance and approval.
- Performance report by site/camera conditions.
- Rollback version and compatibility contract.
- Change approval and audit record.

Model upgrades must be evaluated offline and in shadow mode before generating operational alerts. Use canary rollout by site/camera group. Keep thresholds and model versions associated with each event so historical reports remain interpretable.

## 10. Privacy and human review

Employee movement and face matching are high-impact processing. Restrict access, minimize display of identity, log access, and complete legal/privacy review before production. AI events may support investigation but shall not automatically trigger disciplinary action. Human investigative decisions remain outside the AI inference engine.
