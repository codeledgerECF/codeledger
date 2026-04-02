# Security

## Overview

CodeLedger is a **local-first CLI tool** that runs on your machine, against your git repositories. It makes no network requests, has no cloud services, no accounts, and no telemetry. Your code never leaves your machine.

This document describes CodeLedger's security posture, threat model, and the mechanisms it uses to protect your codebase.

---

## Threat Model

### Trust Boundaries

| Boundary | Source | Mitigation |
|----------|--------|-----------|
| **CLI arguments** | User-provided (`--task`, `--scenario`, `--agentCmd`) | Validated before use; treated as trusted input from the machine operator |
| **Configuration files** | `.codeledger/config.json`, scenario JSON — could be committed by other contributors | Schema-validated before use |
| **Repository files** | Scanned and read from the target repo — maliciously crafted files could attempt resource exhaustion | File size limits enforced (10 MB max) |
| **Git operations** | CodeLedger calls `git` via `child_process` | All interpolated values (refs, paths) validated against allowlists before shell interpolation |
| **Agent commands** | `--agentCmd` deliberately executes shell commands | Path placeholders are shell-escaped to prevent injection |

### What CodeLedger Does NOT Do

- **No network requests** — no telemetry, no API calls, no cloud sync, no phone-home
- **No elevated privileges** — runs as the current user, no `sudo` required
- **No system file modification** — writes only to `.codeledger/` and temporary worktrees
- **No arbitrary code execution** from config files
- **No dynamic `eval()`** or `Function()` calls
- **No secrets in logs** — matched credentials are redacted (first/last 4 chars visible, middle masked)

---

## Cryptographic Security

### License Verification (Ed25519)

Pro licenses are cryptographically signed and verified locally — no network call needed.

- **Algorithm:** Ed25519 digital signatures via Node.js `node:crypto`
- **Format:** `CL-PRO.<base64url-payload>.<base64url-signature>`
- **Verification:** Payload verified locally against trusted public keys with rotation support
- **Claims validation:** Enforces plan, feature set, license ID, and expiry date
- **Expired licenses** return null immediately and are never honored
- **Fully offline** — verification is local and deterministic

### Manifest Signing (HMAC-SHA256 + JCS)

Context manifests can be cryptographically signed for tamper evidence.

- **Algorithm:** HMAC-SHA256 via Node.js `node:crypto`
- **Canonicalization:** RFC 8785 (JSON Canonicalization Scheme)
- **Key management:** Signing material is supplied locally at runtime and is never committed
- **Output:** Signed manifest metadata with algorithm identifier and key ID
- **File digests:** SHA-256 hashes computed for each file in the manifest

### Provenance Graph (Append-Only Audit Trail)

For regulated industries, CodeLedger maintains a tamper-evident causal chain from task to outcome.

- **Storage:** local append-only records
- **Graph structure:** timestamped task, context, change, and validation lineage
- **Tracing:** reconstructs a causal chain from task to outcome for audit use
- **Export:** Full graph exportable for compliance audits via `codeledger audit-export`

---

## Injection Prevention

### Shell Injection

All shell command construction follows these rules:

- **Git refs** validated against `^[a-zA-Z0-9._\-/~^@{}]+$` before interpolation
- **Paths** in git commands are double-quoted
- **Agent command placeholders** (`{promptFile}`, `{repoRoot}`, `{bundlePath}`) are shell-escaped using single-quote wrapping with embedded quote escaping
- **Numeric parameters** (e.g., `sinceDays` for churn analysis) validated as finite positive integers
- **Scenario IDs** validated against `^[a-zA-Z0-9_-]+$` before use in file paths

### SQL Injection

All database operations use parameterized queries. No string concatenation is used in SQL construction.

### Path Traversal

- Scenario IDs are validated to prevent directory traversal in report output paths
- Worktree paths are constructed from validated components only
- All file operations are scoped to the repository root

---

## Secret & Credential Detection

CodeLedger includes a built-in credential scanner (`codeledger detect-secrets`) with 14 detection rules:

| Severity | What It Detects |
|----------|----------------|
| **High** | AWS access keys (`AKIA` prefix), GitHub tokens (`ghp_`, `gho_`, `ghu_`, `ghs_`, `ghr_`), private keys (`-----BEGIN PRIVATE KEY-----`), Slack tokens (`xox*`), Stripe keys (`sk_live_`, `rk_live_`) |
| **Medium** | Generic API keys, secrets, passwords, auth tokens, database connection strings |
| **Low** | JWT tokens, high-entropy strings in secret context (optional Shannon entropy analysis, threshold: 4.0 bits/char) |

**Controls:**
- **Inline suppression:** `// codeledger: allow-secret <rule-id>` on the line
- **Allowlist:** `.codeledger/secrets-allowlist.json` for global path skips, global rule skips, or per-file rule skips
- **Baseline comparison:** Filter to new findings only (fingerprinted by file + rule, line-independent)
- **Redaction:** Matched secrets are always redacted in output (first/last 4 chars visible, middle masked)
- **Output formats:** Human-readable, JSON (`--json`), or SARIF for GitHub code scanning (`--sarif`, exit code 2 on high-severity findings)
- **Auto-skip:** Binary and asset files (.png, .mp4, .zip, .lock, .db), node_modules, .git, dist, coverage

---

## Resource Exhaustion Prevention

| Control | Limit | Scope |
|---------|-------|-------|
| File size cap | 10 MB | Scanning, excerpt extraction, workspace scanning |
| Git output buffer | 10 MB | `git diff`, `git log` operations |
| Agent command timeout | 1,800s (30 min) default, configurable | Benchmark execution |
| Hook timeouts | 3–30s depending on hook type | Claude Code lifecycle hooks |
| Local outcome ledger | 2,000 entries max, auto-pruned | Local outcome tracking |
| Glob regex hardening | Patterns escaped before regex conversion | Prevents ReDoS |

---

## Approval & Governance Controls

### Command Capsules (Enterprise)

Risky agent actions can be governed via formal approval workflows:

- **State machine:** draft → pending_policy → pending_approval → approved → executing → completed/failed
- **5-factor risk scoring:** scope, dependency, novelty, failure history, authority — each scored and combined
- **Self-approval prevention:** Configurable policy enforces approver ≠ creator
- **Delegation depth limit:** Default max 2 levels, prevents infinite delegation chains
- **Authority matching:** File-pattern globs matched against approval scopes (any_peer, team_lead, security, owner)

### Discovery Gate Overrides

When an agent requests to override a `NO_GO_ALREADY_EXISTS` verdict:

- **Human-only enforcement:** Bot/service accounts are rejected via pattern matching (`[bot]`, `dependabot`, `renovate`, `github-actions`, `codeledger-ci`, `automation`, `noreply`, `service-account`)
- **Two-layer verification:** Both `approved_by` field AND git commit author are checked
- **Task matching:** Override must match the original discovery task (normalized comparison)
- **Automatic expiry:** Overrides expire after 7 days (604,800,000 ms)
- **Schema validation:** Required fields enforced (task, reason, approved_by, timestamp)

---

## Review Intelligence (Architectural Verification)

CodeLedger's Review Intelligence layer detects architectural violations that linters miss:

| Module | Priority | What It Detects |
|--------|----------|----------------|
| Runtime validation | P1 | Missing runtime validation on typed routes |
| Outbound I/O | P1 | HTTP calls without timeouts |
| Architecture graph | P1/P2 | Circular dependencies, boundary violations |
| Shared helper usage | P2 | Bypass of shared helper functions |
| Test integrity | P2 | Brittle test patterns |
| Build/runtime safety | P2 | Runtime safety checks |

**Disposition system:** Every finding is classified as `new`, `baselined`, or `suppressed`. Only **new** P0/P1 findings block CI.

**Suppression options:**
- Baseline: `codeledger verify --update-baseline` accepts current findings
- Inline: `// codeledger: ignore <rule|category|*> -- reason`

---

## Hook Security

CodeLedger integrates with Claude Code via lifecycle hooks (`.claude/hooks.json`).

**Resilience guarantees:**
- Hooks are designed not to break the agent session, even when local setup is incomplete
- They resolve the local CLI safely across supported environments
- Non-fatal errors are logged but do not interrupt agent execution

**Hook behaviors:**
- **PreToolUse:** On Edit/Write, checks discovery cache — blocks writes when verdict is `NO_GO_ALREADY_EXISTS`, warns when writing outside approved insertion points
- **PostToolUse:** On git commit, shows bundle recall/precision; tracks file reads; detects out-of-bundle drift
- Hooks never execute arbitrary code — they invoke the CodeLedger CLI with specific commands only

---

## File System Security

### .gitignore Enforcement

`codeledger init` configures `.gitignore` with security-aware patterns:

| Pattern | Effect |
|---------|--------|
| `.codeledger/` | Ignored — session data, cache, artifacts stay local |
| `!.codeledger/bin/` | Un-ignored — vendored CLI committed for browser/cloud sessions |
| `!.codeledger/team-ledger/` | Un-ignored — shared team memory is committed |
| `.codeledger/license.json` | Ignored — license keys stay local only |
| `.claude/` | Ignored — Claude Code private config |
| `!.claude/hooks.json` | Un-ignored — hooks must be in git for browser sessions |

### Sensitive File Patterns

The root `.gitignore` excludes: `*.pem`, `private-key.*`, `signing-key.*`, `keys/private/`

---

## Dependencies

CodeLedger uses minimal runtime dependencies:

| Dependency | Purpose | Risk Profile |
|-----------|---------|-------------|
| Embedded SQLite runtime | Local database storage | Native addon, local-only |
| Node.js built-ins | `crypto`, `fs`, `path`, `child_process` | Part of Node.js runtime |
| `typescript` | Build-time only | No runtime risk |
| `vitest` | Test-time only | No runtime risk |

No runtime services beyond local dependencies and Node.js built-ins. No packages with network access are used at runtime.

---

## Reporting Vulnerabilities

If you discover a security vulnerability, please report it responsibly:

1. **Email:** security@codeledger.dev
2. **GitHub:** Open a [private security advisory](https://github.com/codeledgerECF/codeledger/security/advisories/new) on the repository

**Please do not** disclose vulnerabilities publicly until a fix is available. We aim to acknowledge reports within 48 hours and provide a fix timeline within 7 days.

---

## Audit History

| Date | Scope | Findings | Status |
|------|-------|----------|--------|
| 2025-01-01 | Initial security review | Shell injection in git ref interpolation, path escaping, file size limits, glob regex hardening | Fixed |
| 2026-03-24 | v0.7.2 release review | Full review of cryptographic signing, approval workflows, discovery override enforcement, secret detection, hook resilience | Verified |
