# CodeLedger Architecture Overview

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


> Public architecture summary for how CodeLedger fits into an AI-assisted development workflow.

---

## System Purpose

CodeLedger is a local-first verification and context system for AI-assisted software development.

It helps teams:

- start with the right context
- keep implementation aligned with existing code structure
- detect risky drift before it lands
- preserve evidence about what changed and what was verified
- apply governance consistently across local work and CI

---

## High-Level Flow

CodeLedger follows a simple product loop:

1. **Discover** relevant code for a task
2. **Guide** the agent toward the right files and constraints
3. **Verify** changes against policy and evidence
4. **Observe** outcomes and operational signals
5. **Improve** future runs using those signals

This is the public-facing mental model: start with the right context, verify the work, and keep a durable record of what happened.

---

## Task Lifecycle

Every task follows a unified lifecycle: **Activate > Execute > Verify > Learn**. A single TaskContext object flows through all four phases, ensuring no metadata is lost between stages.

| Phase | What happens | Key outputs |
|-------|-------------|-------------|
| **Activate** | Scan repo, score files, refine task prompt, generate context bundle | Context bundle, ISC score, task type classification |
| **Execute** | Agent works within bundle. Broker delivers context to any surface. Discovery Gate checks for existing code. | Evidence records, read logs, drift detection |
| **Verify** | Review Intelligence checks architecture. Completion Integrity Check verifies claims against diff. | Verification report, finding dispositions |
| **Learn** | Session summary computes recall/precision. Patterns promoted or retired. Anti-patterns detected. | Session metrics, pattern candidates, episode records |

## Core Capabilities

### Context Selection

CodeLedger scans the repository and ranks files using 12 weighted scoring signals: keyword match, dependency centrality, git churn, recent touch, test relevance, size penalty, success/failure priors, error infrastructure, branch changes, co-commit affinity, and shadow file expansion.

The result is a deterministic context bundle — same task, same repo state, same bundle.

### Task Intelligence Engine (TIE)

The TIE evaluates task prompt quality using Intent Sufficiency Check (ISC) scoring, refines vague prompts into scoped tasks, and reports prompt lift. A prompt like "fix the auth thing" (ISC 0.25) becomes "Fix authentication middleware in packages/cli to handle expired tokens" (ISC 0.75) — a 50% prompt lift that also produces a sharper, smaller bundle.

The TIE surfaces its work in CLI output:
```
Task Intelligence
  ISC: 0.25 -> 0.75 (+50% prompt lift)
  Type: bug_fix (confidence: 0.87)
  Refinement: silent (auto-scoped to packages/cli)
```

### Review Intelligence

Architectural verification that detects:
- Missing runtime validation on typed routes (P1)
- Outbound HTTP calls without timeouts (P1)
- Bypass of shared helpers (P2)
- Circular dependencies and boundary violations via architecture graph (P1/P2)
- Brittle test patterns (P2)

Supports auto-fix (`codeledger fix`), invariant packs (`codeledger pack`), and convention learning (`codeledger learn`). Runs with zero configuration.

### Discovery Gate

Pre-build intelligence that scans the repo for existing capabilities before implementation begins. 8-stage pipeline producing one of three verdicts:
- **GO_GENUINELY_NEW** — no overlap, safe to build
- **GO_EXTENSION_ONLY** — overlap detected, extend the existing system
- **NO_GO_ALREADY_EXISTS** — capability exists, use it

Runs automatically during activation for implementation tasks.

### Verification

CodeLedger checks claimed work against observable repo state, validation output, and policy. The Completion Integrity Check (CIC) verifies claims against the git diff, runs ghost file detection, and evaluates neighborhood dependencies.

### Governance

CodeLedger applies local or CI guardrails including architecture policy (4-level scope hierarchy), discovery enforcement, and zone-based access control. The intervention engine detects duplication pressure, drift spikes, and governance breakdowns.

### Session Continuity

CodeLedger keeps lightweight session artifacts so agents and humans can recover context after compaction, interruptions, or task shifts. The unified TaskContext enables fast hydration from context snapshots without JSONL scanning.

### Observability

CodeLedger tracks operational signals including drift, validation outcomes, and intervention opportunities. The Engineering Intelligence Dashboard provides outcome truth, agent scorecards, destabilization metrics, and value compounding — all grounded in deterministic evidence.

### MCP Integration

The MCP server exposes CodeLedger as tools for Claude Desktop, Cursor, and Windsurf. An ActivationGate ensures no context is delivered without task linkage — every MCP tool call either activates a task or surfaces degraded state honestly.

### Insight System

Three interrogation commands answer: Why did this happen? What patterns are emerging? What should I do next?
- `codeledger explain` — structured narrative for the latest run
- `codeledger learnings` — recurring patterns and hotspots
- `codeledger next` — ranked action recommendations

All deterministic. No LLMs.

---

## Public Artifacts

After initialization, CodeLedger stores repo-local artifacts under `.codeledger/`.

Depending on the commands you use, these artifacts can include:

- active context bundles
- repo index and cache data
- policy files
- validation reports
- session summaries
- append-only evidence records

These artifacts are local to the repository and are designed to support deterministic, auditable operation.

---

## Local and CI Use

CodeLedger is designed to work in both:

- **local sessions**, where it helps an agent choose context and stay aligned during implementation
- **CI workflows**, where it verifies outcomes, policy, and release readiness

This lets the same context and verification model span developer workflows and release workflows without relying on remote services.

---

## Design Principles

- **Local-first**: your code stays on your machine or in your CI environment
- **Deterministic**: same repo state and same task should produce stable outputs
- **Evidence-backed**: CodeLedger prefers observed repo state over agent self-reporting
- **Append-only where it matters**: session, provenance, and value records are written as durable history
- **Product-first docs**: this public document explains behavior, not internal implementation details

---

## Further Reading

- [README](../README.md)
- [Getting Started](../GETTING-STARTED.md)
- [CLI Command Reference](./CLI_COMMAND_REFERENCE.md)
- [Security](../SECURITY.md)
