# CodeLedger Architecture Overview

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

## Core Capabilities

### Context Selection

CodeLedger scans the repository, ranks likely files for a task, and writes a focused bundle for the agent to use first.

### Verification

CodeLedger checks claimed work against observable repo state, validation output, and policy.

### Governance

CodeLedger can apply local or CI guardrails to discourage duplicate systems, risky edits, and out-of-scope changes.

### Session Continuity

CodeLedger keeps lightweight session artifacts so agents and humans can recover context after compaction, interruptions, or task shifts.

### Observability

CodeLedger tracks operational signals such as drift, validation outcomes, and intervention opportunities so teams can see whether workflows are improving.

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
