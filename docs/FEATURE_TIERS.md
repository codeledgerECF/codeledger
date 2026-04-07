# CodeLedger Feature Tiers

## Tier Matrix

| Feature | Individual (Free) | Team | Enterprise |
|---------|:-:|:-:|:-:|
| **Context Selection** | | | |
| activate — deterministic context selection | ✅ | ✅ | ✅ |
| bundle — task-specific file scoring | ✅ | ✅ | ✅ |
| refine — mid-session re-scoring | ✅ | ✅ | ✅ |
| Prompt Coach (4-level interaction) | ✅ | ✅ | ✅ |
| **Verification & CI** | | | |
| verify — architectural verification | ✅ | ✅ | ✅ |
| ci check --json — stable CI contract | ✅ | ✅ | ✅ |
| setup-ci — generate CI workflows | ✅ | ✅ | ✅ |
| fix — auto-fix architectural violations | ✅ | ✅ | ✅ |
| **Local Memory** | | | |
| Evidence capture (session outcomes) | ✅ | ✅ | ✅ |
| Episode generation (session summaries) | ✅ | ✅ | ✅ |
| Pattern promotion (harvest) | ✅ | ✅ | ✅ |
| Pattern lifecycle (scoring, retirement) | ✅ | ✅ | ✅ |
| Pattern distillation from successful sessions | ✅ | ✅ | ✅ |
| Golden patterns (cold-start memory) | ✅ | ✅ | ✅ |
| **Dashboard** | | | |
| Dashboard placeholder (teaser stats) | ✅ | ✅ | ✅ |
| Full Engineering Dashboard | 🔒 | ✅ | ✅ |
| Static dashboard build (file:// compatible) | 🔒 | ✅ | ✅ |
| Evidence drilldowns + full-page view | 🔒 | ✅ | ✅ |
| Signal synthesis (executive TL;DR) | 🔒 | ✅ | ✅ |
| **AI Agent Integration** | | | |
| MCP server (Claude/Cursor/Windsurf) | 🔒 | ✅ | ✅ |
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

## Gating Implementation

All feature gates use `isTierUnlocked(cwd, tier)` from `packages/cli/src/commands/license.ts`.

- `'individual'` → always returns true
- `'team'` → requires Pro license (`.codeledger/license.json`)
- `'enterprise'` → requires Pro license (same gate as team currently)

License activation: `codeledger license activate <key>`
Tier enablement: `codeledger enable team` or `codeledger enable enterprise`
Feature listing: `codeledger features`
