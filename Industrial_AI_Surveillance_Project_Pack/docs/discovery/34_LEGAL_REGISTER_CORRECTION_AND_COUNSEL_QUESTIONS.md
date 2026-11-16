> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO/Valkey/TimescaleDB/React), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 34 — Legal Register Corrections & Corporate Counsel Inquiry Brief

**Document ID:** DISC-34-LEGAL-COUNSEL-BRIEF  
**Version:** 1.0.0  
**Date:** 2026-11-11  
**Status:** MANDATORY LEGAL AUDIT & COUNSEL INQUIRY  
**Classification:** `VERIFIED_OFFICIAL_SOURCE` (Statutory Citations) & `PROPOSED` (Questions for Counsel)  
**Statutory Authorities:** Egyptian Personal Data Protection Law No. 151 of 2020 & Executive Regulations Decree No. 816 of 2025  
**Directive Reference:** Finding P0-06 of CTO Review  

---

## 1. Executive Correction of Statutory Legal Claims

In strict accordance with Finding P0-06 of the CTO Review:
> **Initial legal assertions in Document 25 contained substantive mis-citations and overbroad legal assumptions.** 
> An engineering team must never interpret statutory law or invent legal exemptions. This document formally retracts the flawed citations and articulates the exact legal questions that **must be answered in a written legal opinion by qualified Egyptian legal counsel** before production deployment.

### Itemized Corrections Enacted:
1. **Retraction of Article 11 DPIA Citation:** Document 25 cited Article 11 of Law 151/2020 as a statutory mandate for a Data Protection Impact Assessment (DPIA). Article 11 does not establish a general DPIA mandate. **The DPIA is formally reclassified as an internal engineering best-practice risk assessment**, pending corporate counsel confirmation of specific regulatory decrees.
2. **Correction of Breach Notification Timelines (Article 7):** The claim that "affected individuals must be notified within 72 hours" was legally imprecise. Under Article 7 of Law 151/2020:
   - The data controller must notify the **Personal Data Protection Center (PDPC)** within **72 hours** of discovering a personal data breach.
   - If the breach involves sensitive biometric data or poses high operational risks, notification to **affected data subjects** must follow within **3 business days** of notifying the Center, in accordance with the specific procedures set forth in the Executive Regulations (Decree 816/2025).
3. **Retraction of Broad "Safety / Crime Prevention" Consent Exemption:** Document 25 suggested that workplace safety or crime prevention broadly exempts the enterprise from obtaining employee biometric consent under Article 12. This was an unverified legal assumption. Article 12 strictly restricts the processing of sensitive data; whether occupational safety qualifies as an independent lawful ground without explicit employee consent or statutory labor authorization requires formal legal counsel certification.
4. **Distinction Between Identifiable Video and Biometric Data:** A standard CCTV video stream capturing an identifiable worker constitutes **Personal Data** (بيانات شخصية). It only becomes **Sensitive Biometric Personal Data** (بيانات بيومترية حساسة) when specific technical processing is applied to extract unique biological/behavioral mathematical identifiers (e.g., face embeddings or gait vectors). Both categories are governed by Law 151/2020, but sensitive biometric data carries stricter criminal penalties for unauthorized processing.
5. **Retraction of Arbitrary "90% Operational Value" Claim:** The statement that the platform retains "90% of its operational value without facial recognition" is **formally retracted**. The platform supports non-biometric safety surveillance (PPE detection, perimeter geofencing, fire early warning, fall detection), but identifiable video recording remains personal data requiring statutory privacy compliance.
6. **Retraction of 30-Day Post-Termination Deletion Rule:** The rule mandating deletion of employee embeddings "30 days post-termination" is retracted. Retention schedules must balance data minimization against statutory defense against labor disputes (e.g., Egyptian Labor Law No. 12/2003 limitation periods).

---

## 2. Formal Questions for Qualified Egyptian Legal Counsel

The following 7 formal inquiries are submitted to the company's licensed legal counsel:

### Question 1: Permissibility & Licensing of On-Premise Facial Recognition
- *Inquiry:* Under Article 12 of Law 151/2020 and Executive Regulations Decree 816/2025, what exact licensing dossier or permit must BNF and RNF obtain from the Personal Data Protection Center (PDPC) prior to operating an on-premise facial recognition system for factory access control and safety monitoring?
- *Engineering Context:* The system extracts 512-dimension mathematical vector embeddings stored locally on an on-premise server with zero cloud transmission.

### Question 2: Employee Consent vs. Legitimate Employment Grounds
- *Inquiry:* Can biometric facial recognition of factory workers be legally justified under the employment contract or occupational safety regulations, or is **individual, written, informed consent** mandatory for every enrolled worker?
- *Engineering Context:* If a worker refuses biometric consent, can the factory mandate alternative manual verification (e.g., RFID badge) without disciplinary consequence?

### Question 3: Non-Biometric Industrial CCTV Compliance
- *Inquiry:* What specific legal requirements apply to the continuous recording of ~400 CCTV cameras across plant floors, warehouses, and corridors under Law 151/2020, assuming facial recognition is disabled?
- *Engineering Context:* Video is retained for 30 days on local NVRs for physical plant security. Are physical Arabic warning notices at factory gates legally sufficient?

### Question 4: Workplace Movement Profiling
- *Inquiry:* Does cross-camera tracking (generating a chronological log of an employee's sightings across factory zones during a shift) constitute unlawful behavioral profiling under Law 151/2020?
- *Engineering Context:* The feature records discrete sightings (e.g., "Worker 10425 observed at Packaging Line at 10:15, Warehouse at 10:45").

### Question 5: Statutory Retention Schedules for Biometric Embeddings
- *Inquiry:* What is the legally mandated or recommended retention period for biometric face models following the termination of an employee's labor contract under Egyptian Labor and Data Protection laws?

### Question 6: Mandatory DPO & Register Registration
- *Inquiry:* Is the enterprise legally required to register a Data Protection Officer (DPO) and submit its Register of Processing Activities to the PDPC immediately, or do grace periods apply under Decree 816/2025?

### Question 7: Cloud GPU Benchmarking Data Sovereignty
- *Inquiry:* Is the engineering team legally permitted to benchmark AI models using de-identified or synthetic factory video clips on leased cloud GPU servers located outside Egypt, or does Article 14 (Cross-Border Data Transfer) strictly prohibit this without a cross-border permit?
- *Engineering Directive:* Until counsel approves in writing, **zero factory footage may leave the on-premise physical facility.**

---

## 3. Legal Brief Sign-Off

- **Status:** CANONICAL LEGAL AUDIT & INQUIRY BRIEF.
- **Action Item:** Transmit Document 34 to Corporate Legal Counsel; freeze all facial recognition activation until written counsel opinion is returned.

