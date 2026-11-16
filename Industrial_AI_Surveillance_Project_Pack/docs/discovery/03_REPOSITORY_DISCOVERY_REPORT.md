> ⚠️ SUPERSEDED / REFERENCE-ONLY (2026-11-16). Do NOT use as a source of truth. Authoritative: 00_READ_ME_FIRST.md and docs/governance/CTO_AMENDMENTS.md. Known stale content: counts of requirements, banned stack (YOLOv8/TensorRT/DeepStream/MinIO), capacity sizing, "VERIFIED_BY_EXECUTION" labels, Docker Desktop/Go 1.22 LTS claims.

# 03 — Repository & Workspace Discovery Report

**Document ID:** DISC-03-REPO-DISCOVERY  
**Version:** 1.0.0-baseline  
**Status:** DISCOVERY COMPLETE  
**Classification:** STRICTLY NON-MOCK / EVIDENCE-BASED  
**Inspection Date:** 2026-11-11  

---

## 1. Executive Inspection Summary

An exhaustive, non-destructive filesystem and environment discovery was conducted across the workspace root `D:\Project-CRM` and the project directory `D:\Project-CRM\Industrial_AI_Surveillance_Project_Pack`.

### Key Discovery Findings:
1. **Repository Type:** **Greenfield Project** for the Industrial AI Surveillance Platform. There is currently **zero application code**, zero build manifests (`pom.xml`, `package.json`, `pubspec.yaml`, `go.mod`, `Cargo.toml`, `.csproj`), and zero container configurations (`Dockerfile`, `docker-compose.yml`) for the surveillance platform.
2. **Git Version Control Status:** Neither `D:\Project-CRM` nor `D:\Project-CRM\Industrial_AI_Surveillance_Project_Pack` is initialized as a Git repository (`fatal: not a git repository`). No commit history, remote origins, or branch definitions exist.
3. **Workspace Co-habitation:** The root folder `D:\Project-CRM` contains unrelated legacy assets, third-party cloned repositories, and general documentation. These must remain completely isolated from the Industrial AI Surveillance Platform.

---

## 2. Evidence of Commands Executed & Outputs

### Command 1: Root Git Repository Check
```powershell
PS D:\Project-CRM> git status
fatal: not a git repository (or any of the parent directories): .git
```
**Conclusion:** No Git repository exists at the workspace root.

### Command 2: Project Pack Git Check
```powershell
PS D:\Project-CRM\Industrial_AI_Surveillance_Project_Pack> git status
fatal: not a git repository (or any of the parent directories): .git
```
**Conclusion:** No Git repository exists within the Project Pack folder.

### Command 3: Root Workspace Directory Listing
```powershell
PS D:\Project-CRM> cmd /c dir /b "d:\Project-CRM"
.agents
.vscode
flutter-brain
flutter_app_specs
higs
Industrial_AI_Surveillance_Project_Pack
repos
skills
```
**Output Analysis:**
- `.agents/`: Agent system configuration, rules (`caveman.md`, `charcter.md`, `cenamatic.md`, `auto_skills.md`, `rules.md`), and workflows (`security-part1.md`, etc.).
- `.vscode/`: IDE editor settings.
- `flutter-brain/`: Obsidian vault, design skill documents, and architecture reference PDFs.
- `flutter_app_specs/`: High-level specifications for unrelated mobile CRM concepts.
- `higs/`: Higgsfield ComfyUI generative media plugins (unrelated to surveillance).
- `Industrial_AI_Surveillance_Project_Pack/`: The canonical baseline documentation for the BNF/RNF surveillance platform.
- `repos/`: Cloned open-source trading and algorithmic repos (Alpaca, OpenAlgo, QuantConnect Lean, etc.) — completely unrelated to this project.
- `skills/`: Local skill definitions for Flutter engineering and architectural design.

### Command 4: Industrial AI Surveillance Project Pack Contents
```powershell
PS D:\Project-CRM> cmd /c dir /s /b "d:\Project-CRM\Industrial_AI_Surveillance_Project_Pack"
00_PROJECT_CHARTER.md
PACK_VERSION.txt
README_AR.md
ai\04_VIDEO_AI_SPEC.md
antigravity\09_MASTER_OPERATING_PROMPT.md
antigravity\10_PHASE_0_DISCOVERY_PROMPT.md
antigravity\11_PHASE_PROMPTS.md
architecture\02_TARGET_ARCHITECTURE.md
integrations\03_INTEGRATION_AND_DATA_SPEC.md
planning\06_ROADMAP_AND_GATES.md
planning\07_TEST_STRATEGY_AND_ACCEPTANCE.md
planning\08_ADR_AND_OPEN_QUESTIONS.md
planning\09_REQUIREMENTS_TRACEABILITY.csv
requirements\01_SRS.md
security\05_SECURITY_PRIVACY_AND_ACCESS.md
```
**Output Analysis:**
The project pack represents a high-quality, comprehensive requirements and architecture baseline, establishing the mission, constraints, and non-negotiables for the BNF and RNF deployment.

---

## 3. Classification of Existing Functionality

| Component / Subsystem | Current State | Evidence |
|---|---|---|
| **BNF Site Data Plane** | Not Present (0% Code) | No source directory or runtime files found. |
| **RNF Site Data Plane** | Not Present (0% Code) | No source directory or runtime files found. |
| **Management API / BFF** | Not Present (0% Code) | No source directory or runtime files found. |
| **Android Client Application** | Not Present (0% Code) | No Android / Flutter project structure found. |
| **ZKBioTime Adapter** | Not Present (0% Code) | Specification only (`INT-001`). |
| **SQL Server Adapter** | Not Present (0% Code) | Specification only (`INT-001`). |
| **NVR / Camera Video Ingestion** | Not Present (0% Code) | Specification only (`ARCH-001`). |
| **Computer Vision Models** | Not Present (0% Code) | Specification only (`AI-001`). |
| **Alert & Outbox Engine** | Not Present (0% Code) | Specification only (`ARCH-001`). |
| **In-App Reporting Module** | Not Present (0% Code) | Specification only (`SRS-001`). |
| **CI/CD Pipeline Configurations**| Not Present (0% Code) | No GitHub Actions or build scripts exist. |

---

## 4. Proposed Clean Repository Architecture (For Phase 2 Implementation)

When Phase 1 spikes are validated and Phase 2 foundation is approved by the project owner, the following isolated repository structure must be established:

```text
Industrial_AI_Surveillance_Platform/
├── .github/
│   ├── workflows/
│   │   ├── ci-backend.yml              # Linting, static analysis, unit & contract tests
│   │   ├── ci-android.yml              # Flutter / Android test & build checks
│   │   ├── security-scan.yml           # Gitleaks, Trivy, vulnerability scanning
│   │   └── pr-gatekeeper.yml           # Architecture boundary verification
│   └── pull_request_template.md
├── docs/
│   ├── discovery/                      # Phase 0 deliverables (these 20 documents)
│   ├── adr/                            # Architecture Decision Records
│   ├── architecture/                   # System diagrams & interface contracts
│   └── runbooks/                       # Deployment, incident response, disaster recovery
├── src/
│   ├── backend/                        # Modular Monolith Core
│   │   ├── Domain/                     # Zero-dependency domain models & policies
│   │   │   ├── Sites/
│   │   │   ├── Employees/
│   │   │   ├── Events/
│   │   │   ├── Alerts/
│   │   │   └── Policies/
│   │   ├── Application/                # Use cases, command handlers, ports/interfaces
│   │   │   ├── Sites/
│   │   │   ├── Employees/
│   │   │   ├── Cameras/
│   │   │   ├── Events/
│   │   │   └── Reports/
│   │   ├── Infrastructure/             # Adapters for external dependencies
│   │   │   ├── Persistence/            # SQL Server / PostgreSQL repositories
│   │   │   ├── ZkBioTime/              # ZKBioTime API & photo extraction adapters
│   │   │   ├── Nvr/                    # RTSP / ONVIF / NVR SDK adapters
│   │   │   ├── Messaging/              # Outbox, Redis / RabbitMQ queue adapters
│   │   │   ├── Storage/                # S3 / MinIO object storage adapters
│   │   │   └── Notifications/          # In-app push / WebSocket delivery adapters
│   │   └── Presentation/
│   │       ├── ManagementApi/          # Cross-site authenticated router & BFF
│   │       └── SiteApi/                # Site-scoped operational endpoints
│   ├── workers/                        # Isolated High-Performance Edge Workers
│   │   ├── video_ingestion/            # RTSP stream decoders & frame samplers
│   │   ├── inference_engine/           # TensorRT / ONNX multi-model runtime
│   │   └── tracking_engine/            # ByteTrack & cross-camera association
│   └── client/
│       └── android/                    # Production Android Manager Application
│           ├── lib/
│           │   ├── core/               # Design system, network client, token storage
│           │   ├── domain/             # Client entities and repository contracts
│           │   ├── data/               # API clients, local persistence (Hive/Isar)
│           │   ├── presentation/       # Feature screens, blocs/cubits, widgets
│           │   └── main.dart
│           └── test/
├── deploy/
│   ├── bnf/                            # BNF site-specific Docker Compose / Helm charts
│   ├── rnf/                            # RNF site-specific Docker Compose / Helm charts
│   └── management/                     # Management plane deployment manifests
├── tests/
│   ├── unit/                           # Isolated domain & application unit tests
│   ├── contract/                       # ZKBioTime, SQL Server, and NVR contract tests
│   ├── integration/                    # Site-isolated integration suites
│   ├── security/                       # Negative authorization & site-isolation tests
│   └── ai_eval/                        # Held-out dataset validation & benchmarking
└── scripts/
    ├── discovery/                      # Read-only vendor probing scripts (Phase 1)
    └── dev/                            # Local development sandbox bootstrap
```

---

## 5. Non-Destructive Integrity Confirmation

- **No source code was modified.**
- **No dependencies were installed or updated.**
- **No git commands altering state were executed.**
- **All Phase 0 deliverables are being authored cleanly in `docs/discovery/`.**

