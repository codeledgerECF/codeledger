# CodeLedger Feature Tiers

---

> **What problem are we solving?**
>
> **The Problem** — AI coding agents waste 40–60% of their context window on irrelevant files. Every session starts cold. Institutional knowledge lives in people's heads and disappears when they leave. There is no risk signal before a merge.
>
> **The Solution** — CodeLedger is a deterministic context control plane for software development. It scores every file in a repository, selects only what the current task requires, captures outcomes, and promotes successful patterns into reusable institutional memory.
>
> **The Intelligence Layer** — The Task Intelligence Engine does not start from zero. It is seeded from day one with a curated ontology pack of golden patterns — distilled from peer organizations and leading engineering teams at organizations including Google, SAP, and Salesforce. As your team uses CodeLedger, your own earned patterns layer on top, making the system progressively more tailored to your codebase, your conventions, and your standards.
>
> **The Principle** — No cloud. No training pipeline. No behavior change required. Engineering management installs it once. Every developer and every AI agent benefits automatically — from collective intelligence on day one, and from your own institutional memory from day two onward.
>
> *Logs are history. Ledger is intelligence.*

---


## Tier Matrix

| Feature | Individual (Free) | Team | Enterprise |
|---------|:-:|:-:|:-:|
| **Context Selection** | | | |
| activate — deterministic context selection (12 signals) | ✅ | ✅ | ✅ |
| bundle — task-specific file scoring | ✅ | ✅ | ✅ |
| refine — mid-session re-scoring | ✅ | ✅ | ✅ |
| Shadow file expansion (co-commit graph) | ✅ | ✅ | ✅ |
| **Task Intelligence Engine** | | | |
| Prompt Coach (4-level interaction) | ✅ | ✅ | ✅ |
| ISC scoring (Intent Sufficiency Check) | ✅ | ✅ | ✅ |
| Prompt lift reporting | ✅ | ✅ | ✅ |
| Task type classification | ✅ | ✅ | ✅ |
| Activation confidence gate (ambient/assisted/intercept) | ✅ | ✅ | ✅ |
| **Verification & CI** | | | |
| verify — architectural verification | ✅ | ✅ | ✅ |
| Review Intelligence (6 invariant modules) | ✅ | ✅ | ✅ |
| complete-check — completion integrity verification | ✅ | ✅ | ✅ |
| ci check --json — stable CI contract | ✅ | ✅ | ✅ |
| setup-ci — generate CI workflows | ✅ | ✅ | ✅ |
| fix — auto-fix architectural violations | ✅ | ✅ | ✅ |
| pre-pr — 10-check integrity stack | ✅ | ✅ | ✅ |
| **Discovery & Architecture** | | | |
| discover — pre-build duplicate detection | ✅ | ✅ | ✅ |
| discover-check — PR diff compliance | ✅ | ✅ | ✅ |
| Architecture Health Dashboard (AHS) | 🔒 | ✅ | ✅ |
| Intervention Engine | 🔒 | ✅ | ✅ |
| Architecture Policy (4-level governance) | 🔒 | ✅ | ✅ |
| **Local Memory** | | | |
| Evidence capture (session outcomes) | ✅ | ✅ | ✅ |
| Episode generation (session summaries) | ✅ | ✅ | ✅ |
| Pattern promotion (harvest) | ✅ | ✅ | ✅ |
| Pattern lifecycle (scoring, retirement) | ✅ | ✅ | ✅ |
| Pattern distillation from successful sessions | ✅ | ✅ | ✅ |
| Golden patterns (cold-start memory) | ✅ | ✅ | ✅ |
| 5-ledger memory system (truth, validation, ontology, structure, evidence) | ✅ | ✅ | ✅ |
| **Insight System** | | | |
| explain — structured run narrative | ✅ | ✅ | ✅ |
| learnings — recurring patterns and hotspots | ✅ | ✅ | ✅ |
| next — ranked action recommendations | ✅ | ✅ | ✅ |
| Value dashboard (prevented issues, work avoided) | ✅ | ✅ | ✅ |
| Insight Packs (tiered knowledge packs) | ✅ | ✅ | ✅ |
| **Dashboard** | | | |
| Dashboard placeholder (teaser stats) | ✅ | ✅ | ✅ |
| Full Engineering Intelligence Dashboard | 🔒 | ✅ | ✅ |
| Outcome Truth Engine | 🔒 | ✅ | ✅ |
| Agent Scorecards | 🔒 | ✅ | ✅ |
| Destabilization Metrics | 🔒 | ✅ | ✅ |
| Value Compound (hours saved, dollar savings) | 🔒 | ✅ | ✅ |
| Proof of Capability layer | 🔒 | ✅ | ✅ |
| Static dashboard build (file:// compatible) | 🔒 | ✅ | ✅ |
| **AI Agent Integration** | | | |
| MCP server (Claude/Cursor/Windsurf) | 🔒 | ✅ | ✅ |
| ActivationGate enforcement (unified) | ✅ | ✅ | ✅ |
| Broker context API (refresh, current, timeline) | ✅ | ✅ | ✅ |
| Skill manifest (.codeledger/skill.md) | ✅ | ✅ | ✅ |
| **Team Coordination** | | | |
| Claims + leases (advisory) | 🔒 | ✅ | ✅ |
| Preflight-edit (conflict detection) | 🔒 | ✅ | ✅ |
| Shared session summary | 🔒 | ✅ | ✅ |
| Team ledger (git-backed) | 🔒 | ✅ | ✅ |
| Team metrics (composite KPI) | 🔒 | ✅ | ✅ |
| Detect-secrets (credential scanning) | 🔒 | ✅ | ✅ |
| **Sync & Portability** | | | |
| Sync staging (preview) | ✅ | ✅ | ✅ |
| Sync push/pull (GitHub shadow repo) | 🔒 | ✅ | ✅ |
| Pattern hydration (new team members) | 🔒 | ✅ | ✅ |
| **Enterprise Governance** | | | |
| Provenance (causal traceability) | 🔒 | 🔒 | ✅ |
| Audit export (SIEM-ready JSON/CSV) | 🔒 | 🔒 | ✅ |
| Multi-agent orchestration | 🔒 | 🔒 | ✅ |
| Policy simulation | 🔒 | 🔒 | ✅ |
| Fleet aggregation (cross-repo) | 🔒 | 🔒 | ✅ |

## Gating Implementation

All feature gates use `isTierUnlocked(cwd, tier)` from `packages/cli/src/commands/license.ts`.

- `'individual'` → always returns true
- `'team'` → requires Pro license (`.codeledger/license.json`)
- `'enterprise'` → requires Pro license (same gate as team currently)

License activation: `codeledger license activate <key>`
Tier enablement: `codeledger enable team` or `codeledger enable enterprise`
Feature listing: `codeledger features`
