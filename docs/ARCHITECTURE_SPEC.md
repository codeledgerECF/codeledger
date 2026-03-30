# CODELEDGER — UNIFIED SYSTEM ARCHITECTURE SPEC

> Canonical architecture document for CodeLedger's Architecture Governance Control Plane.

---

## 1. System Purpose

CodeLedger is an **Architecture Governance Control Plane** for AI-assisted software development.

It ensures that:

- AI agents use the right context
- New code aligns with existing architecture
- Duplicate systems are prevented
- Architectural integrity is observable
- Governance is configurable via policy
- Teams are guided toward correct interventions

---

## 2. Core Architectural Layers

The system is composed of 6 tightly integrated layers:

| Layer | Name |
|-------|------|
| 1 | Discovery Layer |
| 2 | Session Enforcement Layer |
| 3 | CI / PR Enforcement Layer |
| 4 | Architecture Health Layer |
| 5 | Intervention Engine |
| 6 | Policy Control Plane |

Each layer feeds the next.

---

## 3. System Control Loop

This is the core flywheel:

```
DISCOVER -> ENFORCE -> OBSERVE -> INTERVENE -> CONFIGURE -> (repeat)
```

### Step-by-step

1. **Discover** — Analyze the repo before coding. Identify source of truth. Detect overlap and duplication risk.
2. **Enforce** — Block bad architecture before it's written. Constrain implementation to correct zones.
3. **Observe** — Aggregate signals across the repo. Detect hotspots and drift.
4. **Intervene** — Recommend actions (docs, refactor, platformize). Prioritize based on evidence.
5. **Configure** — Adjust policy. Tune thresholds and strictness.

---

## 4. Data Model (Shared Artifacts)

All layers communicate via immutable artifacts.

### Core Artifacts

#### 1. Discovery Artifact

**Path:** `.codeledger/discovery/latest.json`

Contains:

- Overlap analysis
- Source of truth
- Gap analysis
- Insertion points
- Prohibited files
- Verdict (`GO_GENUINELY_NEW` | `GO_EXTENSION_ONLY` | `NO_GO_ALREADY_EXISTS`)

#### 2. Enforcement Report

**Path:** `.codeledger/reports/enforcement-<hash>.json`

Contains:

- Diff compliance results
- Violations
- Symbol growth analysis
- Duplicate detection results
- Final pass/warn/fail status

#### 3. Override Artifact

**Path:** `.codeledger/discovery/override.json`

Contains:

- Human approval
- Reason
- Scope
- Linked discovery artifact

#### 4. Architecture Health Records

**Path:** `.codeledger/reports/<hash>.json`

Append-only records containing:

- Verdicts
- Overlap signals
- Drift indicators
- Zone/system metadata

#### 5. Intervention Report

**Path:** `.codeledger/reports/interventions-<timestamp>.json`

Contains:

- Recommendations
- Severity
- Triggering signals
- Suggested actions

#### 6. Policy Files

**Path:** `.codeledger/policies/*.json`

Defines:

- Governance rules
- Thresholds
- Ownership
- Enforcement behavior

---

## 5. Layer 1 — Discovery

**Purpose:** Understand the repo before any code is written.

**Key command:**

```bash
codeledger discover --task "<task>"
```

**8-stage pipeline:**

1. Intent Decomposition — extract domain, operation, layer, entities from task
2. Keyword Expansion — synonyms, domain terms, entity terms
3. File Scanning + Reversed Scoring — discovery-adapted file scoring (routes/services/models weighted higher)
4. Standards Discovery — find related repo-wide helper patterns
5. Source-of-Truth Detection — identify canonical owner system
6. Blast Radius Analysis — compute dependency impact for top systems
7. Gap Analysis — coverage estimate, missing capabilities, extension targets
8. Verdict Synthesis — overlap classification, posture, guardrails

**Outputs:**

- Source of truth
- Duplication risk
- Gap analysis
- Insertion points
- Prohibited files

**Key concept:** *Do not build before understanding.*

---

## 6. Layer 2 — Session Enforcement

**Purpose:** Prevent bad architecture at the start of coding.

**Mechanism:**

- `UserPromptSubmit` hook detects implementation tasks (build, implement, create, add, develop, write, introduce, scaffold, generate, construct, make, design, architect, setup, wire up, integrate, connect, extend, refactor)
- Auto-runs discovery for matching tasks
- Injects constraints into agent context

**Behavior:**

- Blocks strong overlap
- Enforces extension mode when `GO_EXTENSION_ONLY`
- Skips non-implementation prompts (questions, affirmatives, short inputs)
- Deduplicates by task hash to avoid re-running discovery for the same task

**Key concept:** *No coding before discovery.*

---

## 7. Layer 3 — CI / PR Enforcement

**Purpose:** Prevent architectural drift from reaching main.

**Key command:**

```bash
codeledger discover-check
```

**Mechanism:**

- PR diff analysis
- Discovery artifact validation

**Key checks:**

1. **Insertion-point alignment** — changes stay within declared insertion points
2. **Prohibited file violations** — no edits to files marked off-limits
3. **Symbol growth** — classifies new exports as expected/suspicious/unrelated vs gap analysis
4. **Duplicate detection** — token-level Jaccard similarity against source-of-truth files
5. **Override validation** — human-only (rejects bots), 7-day expiry, task matching

**Key concept:** *Trust but verify — and block if necessary.*

---

## 8. Layer 4 — Architecture Health Dashboard

**Purpose:** Make architectural pressure visible.

**Key command:**

```bash
codeledger health
```

**Architecture Health Score (AHS)** — composite [0-100], graded A-F:

| Metric | Name | Weight | What It Measures |
|--------|------|--------|------------------|
| DRI | Duplication Risk Index | 25% | % of discoveries with strong overlap (lower = better) |
| EDS | Extension Discipline Score | 25% | % of verify checks that passed |
| STS | Source-of-Truth Stability | 20% | Consistency of canonical system across runs |
| OFS | Override Frequency Score | 15% | Inverse of override rate on NO_GO verdicts |
| DCS | Discovery Coverage | 15% | % of implementation tasks that ran discovery |

**Grades:** A (85+), B (70-84), C (55-69), D (40-54), F (<40)

Includes trend detection, hotspot identification, and 5 named advisor rules: `PLATFORMIZATION`, `RIGID_EXTENSION_SEAM`, `DOCUMENTATION_HOTSPOT`, `OVERRIDE_ABUSE`, `SOT_CONFUSION`.

**Key concept:** *Where is the architecture under stress?*

---

## 9. Layer 5 — Intervention Engine

**Purpose:** Translate signals into actions.

**Key command:**

```bash
codeledger intervene
```

**Detects 6 categories:**

- **Duplication pressure** — multiple tasks overlapping same system
- **Drift spikes** — rapid task activation (formal Drift Velocity: `LOW` | `RISING` | `HIGH` | `CRITICAL`)
- **Governance breakdowns** — invalid/expired overrides
- **SoT instability** — source-of-truth changing across runs
- **Coverage gaps** — low discovery adoption rate
- **Extension failures** — `GO_EXTENSION_ONLY` with diff violations

**Key outputs:**

- Documentation interventions
- Platformization recommendations
- Extension seam fixes
- Consolidation suggestions
- Governance tightening
- Drift spike alerts

Each intervention includes suggested actions and agent execution templates.

**Key concept:** *What should we do now?*

---

## 10. Layer 6 — Policy Control Plane

**Purpose:** Define governance behavior.

**Key command:**

```bash
codeledger arch-policy
```

**6 policy domains:**

- `discovery` — controls discovery behavior and thresholds
- `enforcement` — controls CI/PR enforcement strictness
- `source_of_truth` — controls canonical system detection and stability rules
- `overrides` — controls override approval requirements and expiry
- `interventions` — controls intervention triggers and severity thresholds
- `dashboard` — controls health score weights and grading

**4-level scope hierarchy** (strictest wins):

1. **global** — `.codeledger/policies/global.json`
2. **repo** — `.codeledger/policies/repo.json`
3. **zone** — `.codeledger/policies/zones/*.json`
4. **system** — `.codeledger/policies/systems/*.json`

**Key capabilities:**

- Layered policies (global -> system)
- Deterministic resolution
- Strictest-wins semantics
- Simulation before activation (`arch-policy simulate`)
- Fail-safe behavior
- Enforcement modes: `block` | `warn` | `observe`
- Policy lifecycle: `draft` -> `active` -> `deprecated`

**Key concept:** *Governance is configurable.*

---

## 11. Data Flow

```
Developer Task
    |
    v
Discovery  -->  .codeledger/discovery/latest.json
    |
    v
Session Hook (enforces constraints)
    |
    v
Code changes
    |
    v
CI Enforcement  -->  enforcement report
    |
    v
Artifacts aggregated  -->  health records
    |
    v
Dashboard  -->  metrics + trends
    |
    v
Intervention Engine  -->  recommendations
    |
    v
Policy System  -->  adjusts behavior
    |
    v
(Loop continues)
```

---

## 12. Key System Capabilities

### 1. Pre-build architectural awareness

Agents cannot act blindly. Discovery runs before implementation begins.

### 2. Deterministic enforcement

No reliance on "best effort." All checks are deterministic, reproducible, and auditable.

### 3. Drift detection (with velocity)

Detects both:

- **Slow decay** — gradual architectural erosion
- **Rapid spikes** — sudden bursts of overlapping changes (measured by Drift Velocity)

### 4. Anti-duplication guarantees

Prevents:

- Parallel systems
- Renamed copies
- Hidden logic duplication

### 5. Human-in-the-loop governance

Overrides must be:

- Explicit
- Attributable (human-only, rejects bots)
- Auditable (7-day expiry, task-scoped)

### 6. Governance-as-Code

All rules are:

- Versioned
- Testable (via `arch-policy simulate`)
- Explainable

---

## 13. Implementation Principles

1. **Reuse existing primitives** — scoring engine, dependency graph, CLI structure
2. **Deterministic > probabilistic** — no LLM dependency for core logic
3. **Immutable data model** — all artifacts are append-only and replayable
4. **Explainability everywhere** — every decision must answer: *"why?"*
5. **Progressive adoption** — supports individual dev, team, and enterprise tiers

---

## 14. System Differentiation

CodeLedger is **not**:

- A linter
- A static analyzer
- A code search tool
- An AI assistant

It **is**: an Architecture Governance Control Plane for AI-native development.

---

## 15. Final State

When fully implemented, CodeLedger:

- Prevents architectural drift before it happens
- Continuously monitors system integrity
- Explains pressure and failure modes
- Recommends high-ROI interventions
- Allows governance to evolve safely

---

## 16. North Star

> *No duplicate architecture reaches main. No architectural pressure goes unseen. No intervention lacks clarity.*
