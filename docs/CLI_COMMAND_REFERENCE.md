# CodeLedger CLI Command Reference

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


This document is an educational reference for the current user-facing `codeledger` command surface.

- Scope: commands shown by `codeledger --help`
- Style: examples are representative and abridged
- Goal: help a new user understand what each command does and what to expect back

If you're in a browser/cloud environment, use the standalone binary instead of `npx`:

```bash
node .codeledger/bin/codeledger-standalone.cjs <command>
```

## Core Setup and Task Flow

### `init`

Initializes `.codeledger/` in the current repository and warms the initial repo index. Behaves in three modes:

- **fresh** — no `.codeledger/` present; full first-time setup.
- **upgrade** — `.codeledger/` exists with an *older* version than the running
  CLI. Auto-refreshes runtime artifacts (vendored CLI, hooks, ambient
  wrappers, CLAUDE.md section, `harness/pack.json` version stamp) while
  preserving user state (`config.json`, `memory/`, `cache/`, `sessions/`,
  `team-ledger/`, `runs/`, `insight/`, narrative). No `--force` needed.
- **force** (`--force`) — destructive: wipes the entire `.codeledger/`
  directory (including memory ledgers and team state) and starts over. Only
  use when you intentionally want a clean slate.

If the running CLI is *older* than the vendored copy, `init` refuses to
silently downgrade and tells you to upgrade your global install instead.

```bash
npx codeledger init
```

Example output (auto-upgrade — no `--force` required):

```text
CodeLedger vX.Y.Z

  ⬆️  Upgrading repo-local install: vA.B.C → vX.Y.Z
     Refreshing: vendored CLI, hooks, ambient wrappers, CLAUDE.md section, version stamp.
     Preserving: config.json, memory/, cache/, sessions/, team-ledger/, runs/, insight/.
  ↻ Refreshed harness/pack.json version stamp.
  ✅ Updated CodeLedger section in CLAUDE.md
  ✅ Updated .claude/hooks.json (auto-summary on commit, session hooks)
  ✅ Memory ledgers preserved (.codeledger/memory/)
  ✅ Vendored standalone CLI → .codeledger/bin/

  CodeLedger upgraded: vA.B.C → vX.Y.Z
  Refreshed: vendored CLI, hooks, ambient wrappers, CLAUDE.md section.
  Preserved: config, memory, cache, sessions, team-ledger, narrative, runs.
```

### `scan`

Builds the repository index used for deterministic file selection.

```bash
npx codeledger scan
```

Example output:

```text
Scanning repository...

Executive summary
  Repo size: 4,963 files · 434 modules · 3,142 entrypoints
  Key risks: 27 high-impact zones · 4 auth-critical areas · 513 low-test modules
  Policy posture: observe by default with 27 block overrides and 101 warn overrides
  Recommended next step: Review critical zones with `codeledger policy review`, then apply the recommendation in observe mode.

Recommended policy
  Block: auth-critical and security-sensitive
    Why: These paths hold authentication or security-critical logic where mistakes turn into incidents quickly.
    - src/auth/** → block
      Why this path matters: contains auth-sensitive logic.

Suggested next commands
  - codeledger apply-policy
  - codeledger policy review
  - codeledger policy review --json
```

### `refresh` (deprecated)

Deprecated alias for `scan`. Use `codeledger scan` instead.

### `memory status`

Shows HOT/WARM/COLD/ARCHIVED counts for relevance-managed policy memory.

```bash
npx codeledger memory status
```

Example output:

```text
CodeLedger Memory — Policy Relevance Status

Task clock: 12
HOT: 3  WARM: 5  COLD: 2  ARCHIVED: 1

Top retained artifacts:
  - [HOT] path_policy_record 3b6f2f0a  drs=0.88
    Frequently useful, high-blast-radius policy memory retained in HOT tier.
```

### `memory explain --id <artifact-id>`

Shows the factor breakdown for one policy memory artifact.

```bash
npx codeledger memory explain --id 3b6f2f0a --json
```

Example output:

```json
{
  "artifact_id": "3b6f2f0a",
  "score": 0.78,
  "tier": "HOT",
  "retention_reason": "Frequently useful policy memory retained in HOT tier.",
  "archive_eligible": false
}
```

### `bundle --task "..."`

Generates a deterministic context bundle for a task.

```bash
npx codeledger bundle --task "Fix null handling in getUserById"
```

Example output:

```text
Bundle generated
Files selected: 12
Estimated tokens: 4,380
Top files:
  1. src/services/user-service.ts
  2. src/api/users.ts
  3. tests/user-service.test.ts
```

### `activate --task "..."`

Creates or refreshes `.codeledger/active-bundle.md`. Runs the Task Intelligence Engine to evaluate prompt quality and optionally refine vague tasks.

```bash
codeledger activate --task "Fix auth middleware to handle expired JWT tokens"
```

Example output:

```text
Generating context bundle for: "Fix auth middleware to handle expired JWT tokens"
Bundle: 11 files, ~8508 tokens | Confidence: HIGH
Task bundle created.
Written to .codeledger/active-bundle.md

  Task Intelligence
    ISC: 0.97 [##########] sufficient
    Type: auth_change (confidence: 0.50)

   Top files:
     0.492  packages/cli/src/guardrails/workspace-validation.ts
     0.489  packages/cli/src/memory/validation-ledger.ts
     ... and 9 more
```

The Task Intelligence block shows:
- **ISC score**: Intent Sufficiency Check (0.00-1.00). Scores below 0.50 trigger interactive clarification.
- **Prompt lift**: when the Prompt Coach refines a vague prompt, shows the ISC improvement (e.g., "+50% prompt lift")
- **Task type**: classified task type (bug_fix, feature, refactor, auth_change, etc.)
- **Refinement mode**: silent (auto-refined), assisted (user-confirmed), or none
- **Doctrine**: if the task risks creating parallel systems or duplicate truth, a progressive intervention is triggered (light cue → guided refinement → two-phase stop)
- **Shadow suggestion**: for refactor/migration tasks, a one-liner is shown to run parallel truth evaluation

### `task --task "..."`

Runs the full ambient task flow: scan-if-stale, bundle, preflight, and agent launch/prep.

```bash
npx codeledger task --agent codex --task "Refactor order placement flow"
```

`copilot` is also accepted here as an alias to the existing generic runtime path:

```bash
npx codeledger task --agent copilot --agent-bin "<copilot-compatible command>" --task "Refactor order placement flow"
```

Example output:

```text
Session: cl_sess_20260330_abc123
Bundle written: .codeledger/active-bundle.md
Preflight: ready
Agent run: launched (codex)
```

For GitHub-hosted Copilot coding agent sessions, use CodeLedger to prepare and verify context around the agent instead of trying to launch it directly.

### `codex --task "..."`

Shortcut for `task --agent codex`.

```bash
npx codeledger codex --task "Harden auth middleware"
```

Example output:

```text
Using agent: codex
Bundle written: .codeledger/active-bundle.md
Agent run: launched
```

Repo-local ambient wrapper:

```bash
./.codeledger/bin/codex "Harden auth middleware"
```

In non-hook environments this wrapper applies the same meaningful-task auto-refresh rule before launching the agent. Acknowledgement-only follow-ups like `Yes please` do not refresh context.

### `claude --task "..."`

Shortcut for `task --agent claude`.

```bash
npx codeledger claude --task "Fix webhook retry handling"
```

Example output:

```text
Using agent: claude
Bundle written: .codeledger/active-bundle.md
Agent run: launched
```

Repo-local ambient wrapper:

```bash
./.codeledger/bin/claude "Fix webhook retry handling"
```

This wrapper mirrors hook-aware auto-refresh behavior in local non-hook sessions before handing off to Claude.

### `preflight "..."`

Runs scan/bundle/preflight without launching an agent.

```bash
npx codeledger preflight "Update Stripe webhook validation"
```

Example output:

```text
Preflight summary
Bundle coverage: good
Nearby tests found: yes
Risk signals: low
Ready to proceed
```

### `runs`

Shows recent ambient runtime runs.

```bash
npx codeledger runs --limit 5
```

Example output:

```text
Recent runs
1. codex  Fix auth middleware          success
2. claude Refactor order flow          success
3. codex  Add pagination               warning
```

### `refine --learned "..."`

Re-scores the bundle after the task evolves.

```bash
npx codeledger refine --learned "The bug is in the cache invalidation path"
```

Example output:

```text
Bundle refined
Added keywords: cache, invalidation
New top file: src/cache/session-cache.ts
```

### `clean`

Removes orphaned worktrees from prior interrupted compare/task runs.

```bash
npx codeledger clean
```

Example output:

```text
Cleaning orphaned worktrees...
✓ Removed 2 stale worktrees
```

### `doctor`

Checks repo setup, hooks, config, index, and ledger health.

```bash
npx codeledger doctor
```

Example output:

```text
Doctor report
✓ Config found
✓ Hooks configured
✓ Repo index healthy
✓ Ledger writable
```

## Benchmarking and Comparison

### `run --scenario <path>`

Runs one benchmark scenario.

```bash
npx codeledger run --scenario .codeledger/harness/scenarios/null-handling.json
```

Example output:

```text
Scenario: null-handling
Agent: codex
Run complete
Score: 0.82
```

### `compare --scenario <path>`

Runs with-vs-without-CodeLedger comparison.

```bash
npx codeledger compare --scenario .codeledger/harness/scenarios/auth-rate-limit.json
```

Example output:

```text
Compare complete
With CodeLedger:    pass
Without CodeLedger: fail
Delta: +27% fewer tokens, +1.0 files recall
```

### `compare-current`

Builds a compare scenario from the most recent task/session.

```bash
npx codeledger compare-current --run
```

Example output:

```text
Scaffolded compare scenario from latest session
Running compare...
Output: .codeledger/compare/latest/
```

## Daemon and Background Warmup

### `daemon start`

Starts the local background warmer.

```bash
npx codeledger daemon start --background
```

Example output:

```text
CodeLedger daemon starting...
Port: 42637
Mode: background
```

### `daemon status`

Shows daemon status.

```bash
npx codeledger daemon status
```

Example output:

```text
Daemon status: running
Port: 42637
Recent warm bundles: 4
```

### `daemon stop`

Stops the daemon.

```bash
npx codeledger daemon stop
```

Example output:

```text
Stopping daemon...
✓ Daemon stopped
```

## Truth Control Plane

### `drift`

Projects reality drift from daemon event history.

```bash
npx codeledger drift --history --verify-integrity
```

Example output:

```text
CodeLedger Drift
Mode: history
Drift records: 3
[HIGH] PREFLIGHT_WARNING  2026-03-31T...
```

### `outcome`

Projects outcome memory from the ECL and learning signals.

```bash
npx codeledger outcome --pattern auth --verify-integrity
```

Example output:

```text
CodeLedger Outcome Memory
Entries: 4
Pass rate: 75%
Trend: improving / stable
```

### `harvest`

Turns recent truth into asset candidates for the existing lessons ledger.

```bash
npx codeledger harvest --preview --verify-integrity
```

Example output:

```text
CodeLedger Harvest
Candidates: 2
[guardrail] Capture drift guard for major intent changes
```

### `context-handoff`

Builds an agent-agnostic handoff from the latest bundle.

```bash
npx codeledger context-handoff --target codex --verify-integrity
```

Example output:

```text
# CodeLedger Context Handoff — codex
- Bundle: cl_bundle_...
- Context: SUFFICIENT
- Evidence: bundle:cl_bundle_...
```

### `snapshot`

Persists a daemon snapshot descriptor.

```bash
npx codeledger snapshot --verify-integrity
```

Example output:

```text
CodeLedger Snapshot
Snapshot: snapshot-...
Event count: 12
Branch: main
```

### `time-travel`

Reconstructs daemon state from a snapshot and replay.

```bash
npx codeledger time-travel --to snapshot-... --verify-integrity
```

Example output:

```text
CodeLedger Time Travel
Replayed events: 12
Branch: main
Recent bundles: 3
```

### `reality-check`

Reconciles drift, outcomes, completion, and release state.

```bash
npx codeledger reality-check --verify-integrity
```

Example output:

```text
CodeLedger Reality Check
Verdict: WARNING
Completion: unknown
Release: ready_conditional
```

## Session and Checkpoints

### `session-init`

Creates a new session ID.

```bash
npx codeledger session-init
```

Example output:

```text
Session initialized
ID: cl_sess_20260330_abc123
```

### `session-progress`

Writes a ground-truth progress snapshot.

```bash
npx codeledger session-progress
```

Example output:

```text
Wrote .codeledger/session-progress.md
Tracked files touched: 6
```

### `session-summary`

Shows end-of-session value metrics.

```bash
npx codeledger session-summary --final
```

On `--final`, high-density successful sessions can auto-promote into reusable runtime patterns. CodeLedger records the promotion decision either way so you can inspect why a session was promoted or skipped.

Example output:

```text
Session summary
Bundle recall: 88%
Precision: 54%
Token savings: 73%
```

### `session-cleanup`

Removes a session’s registry and state files.

```bash
npx codeledger session-cleanup --session cl_sess_20260330_abc123
```

Example output:

```text
Session cleaned up
Removed registry entry and session artifacts
```

### `sessions`

Lists active sessions and overlap.

```bash
npx codeledger sessions
```

Example output:

```text
Active sessions
1. cl_sess_a  4 overlapping files
2. cl_sess_b  0 overlapping files
```

### `checkpoint create`

Saves a checkpoint for a session.

```bash
npx codeledger checkpoint create --session cl_sess_a --id before-refactor
```

Example output:

```text
Checkpoint created
ID: before-refactor
```

### `checkpoint restore`

Restores a session checkpoint.

```bash
npx codeledger checkpoint restore --session cl_sess_a --id before-refactor
```

Example output:

```text
Checkpoint restored
ID: before-refactor
```

### `checkpoint list`

Lists available checkpoints.

```bash
npx codeledger checkpoint list --session cl_sess_a
```

Example output:

```text
Checkpoints
- before-refactor
- after-tests
```

### `shared-summary`

Shows cross-session overlap and hotspots.

```bash
npx codeledger shared-summary --all
```

Example output:

```text
Shared summary
Hot files:
  src/auth/middleware.ts
  src/api/users.ts
```

### `progress-check`

Runs a lightweight mid-session bundle coverage check.

```bash
npx codeledger progress-check --session cl_sess_a
```

Example output:

```text
Progress check
Covered edits: 5/6
Recommendation: refine bundle
```

## Sharing, Reports, and Dashboards

### `share`

Generates a shareable result snippet.

```bash
npx codeledger share --format markdown
```

Example output:

```text
Generated share snippet (markdown)
Saved to stdout
```

### `stats`

Shows cumulative value metrics.

```bash
npx codeledger stats
```

Example output:

```text
CodeLedger value summary
Total sessions: 28
Average token savings: 68%
Average recall: 84%
```

### `dashboard`

Shows architecture health dashboard output.

```bash
npx codeledger dashboard --history
```

Example output:

```text
Architecture dashboard
Complexity: stable
Drift: moderate
Trend: improving
```

## Manifests, Policy, and Verification

### `manifest`

Creates a deterministic context manifest.

```bash
npx codeledger manifest --task "Release 0.7.11"
```

Example output:

```text
Manifest generated
Output: .codeledger/artifacts/manifest.json
```

### `sign-manifest`

Signs a manifest for tamper evidence.

```bash
npx codeledger sign-manifest --in manifest.json --out signed.json
```

Example output:

```text
Manifest signed
Output: signed.json
```

### `policy --print`

Prints resolved policy.

```bash
npx codeledger policy --print
```

Example output:

```text
Resolved policy
Mode: warn
Required invariants: tests, completion, scope
```

### `policy init`

Scaffolds a new policy file.

```bash
npx codeledger policy init --scope repo
```

Example output:

```text
Policy scaffolded
File: .codeledger/policy/repo-policy.json
```

### `policy validate`

Validates a policy file.

```bash
npx codeledger policy validate --file .codeledger/policy/repo-policy.json
```

Example output:

```text
Policy valid
0 schema errors
```

### `policy diff`

Diffs two policy files.

```bash
npx codeledger policy diff --base repo.json --target strict.json
```

Example output:

```text
Policy diff
- mode: warn -> block
- required invariants: +release-check
```

### `policy merge`

Merges multiple policy files.

```bash
npx codeledger policy merge --files global.json,repo.json
```

Example output:

```text
Merged policy written to stdout
Resolution strategy: strictest-wins
```

### `verify --task "..."`

Runs CI enforcement and emits artifacts.

```bash
npx codeledger verify --task "Refactor order placement flow" --json
```

Example output:

```json
{
  "status": "pass",
  "violations": [],
  "artifacts_dir": ".codeledger/artifacts"
}
```

### `setup-ci`

Generates CI workflow and policy files.

```bash
npx codeledger setup-ci --provider github --mode warn
```

Example output:

```text
Generated CI configuration
Provider: github
Mode: warn
```

### `setup-github-action`

Prints a lightweight GitHub Actions workflow for the public PR Intelligence
Action.

```bash
npx codeledger setup-github-action --print
npx codeledger setup-github-action --print --split --mode warn
```

Example output:

```yaml
name: CodeLedger PR Intelligence

on:
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]

permissions:
  contents: read
  pull-requests: write

jobs:
  codeledger:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
        with:
          fetch-depth: 0

      - name: CodeLedger PR Intelligence
        uses: codeledgerECF/codeledger@v1
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          mode: observe
```

### `ci pr-check`

Runs bounded-scope PR validation for CI.

```bash
npx codeledger ci pr-check --json
```

Example output:

```json
{
  "status": "warn",
  "out_of_scope_files": [],
  "review_comment_ready": true
}
```

## Intent, Context, and Ledger

### `intent init`

Creates a task intent contract.

```bash
npx codeledger intent init --objective "Fix flaky webhook retries"
```

Example output:

```text
Intent initialized
Objective: Fix flaky webhook retries
```

### `intent show`

Shows current intent.

```bash
npx codeledger intent show
```

Example output:

```text
Current intent
Objective: Fix flaky webhook retries
Scope-in: src/webhook
```

### `intent set`

Updates the current intent.

```bash
npx codeledger intent set --scope-in "src/webhook,tests/webhook"
```

Example output:

```text
Intent updated
Scope-in changed
```

### `intent ack`

Acknowledge drift or set a new baseline.

```bash
npx codeledger intent ack --as-baseline
```

Example output:

```text
Intent drift acknowledged
New baseline recorded
```

### `intent check`

Checks whether a task is sufficiently aligned with the current intent.

```bash
npx codeledger intent check "Refactor webhook retries"
```

Example output:

```text
Intent Sufficiency Check: SUFFICIENT
```

### `context explain`

Explains why files or symbols were selected.

```bash
npx codeledger context explain --json
```

Example output:

```json
{
  "path": "src/webhook/retry.ts",
  "reasons": ["keyword_match", "dependency_centrality", "nearby_test"]
}
```

### `context diff`

Shows how context changed between iterations.

```bash
npx codeledger context diff --from run_001 --to run_002
```

Example output:

```text
Context diff
+ src/cache/retry-cache.ts
- src/utils/logger.ts
```

### `context graph`

Outputs a Mermaid dependency graph.

```bash
npx codeledger context graph --output bundle.mmd
```

Example output:

```text
Wrote Mermaid graph: bundle.mmd
```

### `context validate`

Validates the active context bundle.

```bash
npx codeledger context validate --task "Fix retry race" --json
```

Example output:

```json
{
  "status": "pass",
  "warnings": []
}
```

### `ledger status`

Shows local ledger health.

```bash
npx codeledger ledger status
```

Example output:

```text
Ledger status
Entries: 214
Success rate: 81%
```

### `ledger inspect`

Shows recent ledger entries.

```bash
npx codeledger ledger inspect --limit 5
```

Example output:

```text
Recent ledger entries
1. intent_sig=abc123 success
2. intent_sig=def456 warning
```

### `ledger prune`

Trims old ledger entries.

```bash
npx codeledger ledger prune --max 500
```

Example output:

```text
Ledger pruned
Retained: 500 entries
```

## PR and Completion Guardrails

### `pre-pr`

Runs the full integrity stack before opening a PR.

```bash
npx codeledger pre-pr --task "Ship 0.7.11"
```

Example output:

```text
Pre-PR report
Checks passed: 9/10
Conditional: docs alignment
```

### `complete-check`

Validates whether the claimed work is actually complete.

```bash
npx codeledger complete-check --task "Ship 0.7.11" --summary "Standalone guidance fixed"
```

Example output:

```text
Completion Integrity Check
Status: verified
Claims supported by diff: yes
```

### `audit`

Runs an adversarial audit over the current worktree.

```bash
npx codeledger audit --task "Ship 0.8.0" --summary "Updated release workflow and docs"
```

Example output:

```text
CodeLedger · Adversarial Audit
Findings: 2
Required documentation updates: changelog, public docs
```

### `review-coverage`

Shows current review coverage signals.

```bash
npx codeledger review-coverage
```

Example output:

```text
Review coverage
Touched files reviewed: 8/10
```

### `review-gate`

Runs the gatekeeper review check used by hooks.

```bash
npx codeledger review-gate
```

Example output:

```text
Review gate: pass
```

## Security, Audit, and Release

### `detect-secrets`

Scans for hardcoded credentials.

```bash
npx codeledger detect-secrets --severity high
```

Example output:

```text
Secret scan complete
Findings: 0 high severity
```

### `audit-export`

Exports ledger/audit data. Output is sanitized by default; repo-local paths stay repo-relative when possible and raw machine paths are abstracted. Use `--raw` only for privileged internal workflows.

```bash
npx codeledger audit-export --format jsonl --output audit.jsonl
npx codeledger audit-export --format json --raw
```

Example output:

```text
Audit export written: audit.jsonl
Format: jsonl
```

### `provenance`

Traces or exports provenance data. JSON output is sanitized by default; add `--raw` for privileged local access.

```bash
npx codeledger provenance trace --task "task-id" --json
npx codeledger provenance export --json --raw
```

### `release-check`

Determines whether a release is shippable.

```bash
npx codeledger release-check --why
```

Example output:

```text
Release state: ready_conditional
Top actions:
1. Resolve docs mismatch
2. Rebuild standalone artifact
3. Re-run release doctor
```

## Architecture and Discovery

### `interventions`

Shows prioritized architecture interventions.

```bash
npx codeledger interventions --top 5
```

Example output:

```text
Top interventions
1. Reduce auth middleware duplication
2. Add missing tests around retry cache
```

## API and Cloud

### `serve`

Starts the local HTTP API server.

```bash
npx codeledger serve --port 7400
```

Example output:

```text
Usage:
  codeledger serve [--port 7400]

Endpoints:
  GET  /health
  POST /verify
  POST /bundle
  GET  /drift
  GET  /outcome
  POST /harvest
  POST /context-handoff
  POST /snapshot
  POST /time-travel
  GET  /reality-check
  GET  /metrics
  GET  /provenance
  GET  /policy
  GET  /architecture-health/*
  POST /broker/resolve | /broker/validation | /broker/neighborhood
  POST /broker/evidence | /broker/completion | /broker/preamble | /broker/refresh
  GET  /broker/timeline | /broker/current
```

### `vendor`

Copies the standalone CLI into a target repo.

```bash
npx codeledger vendor
```

Example output:

```text
Vendored standalone CLI
Output: .codeledger/bin/codeledger-standalone.cjs
```

## Cowork (Knowledge Mode)

### `cowork-start`

Starts a governed cowork session.

```bash
npx codeledger cowork-start --intent "Document release workflow"
```

Example output:

```text
Cowork session started
Bundle written
Workspace: .
```

### `cowork-refresh`

Refreshes cowork context.

```bash
npx codeledger cowork-refresh --intent "Focus on GitHub Actions release flow"
```

Example output:

```text
Cowork context refreshed
Top files updated
```

### `cowork-snapshot`

Writes a cowork progress snapshot.

```bash
npx codeledger cowork-snapshot
```

Example output:

```text
Cowork snapshot saved
```

### `cowork-stop`

Finalizes the cowork session.

```bash
npx codeledger cowork-stop
```

Example output:

```text
Cowork session finalized
Summary printed
```

## Memory, Lessons, Guardrails, and Broker

### `memory init`

Seeds the memory ledgers.

```bash
npx codeledger memory init --force
```

Example output:

```text
Memory initialized
Seeded ontology, evidence gates, validation ledger
```

### `memory recent`

Shows recent memory entries.

```bash
npx codeledger memory recent
```

Example output:

```text
Recent truth entries
1. retry-cache bug pattern
2. release tagging drift
```

### `memory validation`

Shows validation memory.

```bash
npx codeledger memory validation
```

Example output:

```text
Validation ledger
Recent failures: 2
Recent passes: 12
```

### `memory ontology`

Shows ontology terms.

```bash
npx codeledger memory ontology
```

Example output:

```text
Ontology terms
- release
- policy
- review coverage
```

### `memory structure`

Shows memory structure.

```bash
npx codeledger memory structure
```

Example output:

```text
Memory structure
.codeledger/memory/
  recent-truth.json
  validation-ledger.json
```

### `memory evidence`

Shows evidence gate state.

```bash
npx codeledger memory evidence
```

Example output:

```text
Evidence gates
strict_required: true
missing: none
```

### `memory preamble`

Generates a memory preamble for a task. When a task is provided, the preamble now uses the Context Injection Controller to inject only the bounded, task-relevant subset of retained policy memory.

```bash
npx codeledger memory preamble --task "Release 0.7.11"
```

Example output:

```text
Generated memory preamble
Relevant prior lessons: 3
```

### `memory inject --task "..."`

Builds the deterministic task-start injection bundle from policy memory.
Before selection, CodeLedger classifies the task into one primary task type, secondary tags, confidence, risk level, complexity, and an evidence trace. Low-confidence cases fall back to `unknown`.

```bash
npx codeledger memory inject --task "Fix auth regression" --paths "src/auth/login.ts" --json
```

Example output:

```json
{
  "bundle": {
    "task_type": "auth_change",
    "complexity": "medium",
    "bundle_confidence": 0.82,
    "repo_posture": "Default observe. 4 block overrides and 12 warn overrides shape the starting posture.",
    "relevant_constraints": [
      "BLOCK src/auth/** — contains auth-sensitive logic"
    ]
  },
  "explain": {
    "included": [],
    "excluded": [],
    "budget": {
      "soft_cutoff_applied": false,
      "hard_cutoff_applied": false
    }
  }
}
```

Supported primary task types include:
- `bug_fix`
- `feature`
- `refactor`
- `test_repair`
- `migration`
- `auth_change`
- `infra_change`
- `config_change`
- `dependency_change`
- `performance_change`
- `security_change`
- `docs_only`
- `observability_change`
- `ui_change`
- `api_change`
- `data_model_change`
- `unknown`

Representative secondary tags include:
- `high_risk`
- `shared_core`
- `auth_sensitive`
- `schema_sensitive`
- `ci_sensitive`
- `deployment_sensitive`
- `customer_visible`
- `backward_compatibility_risk`
- `incident_related`

Repo-local overrides are supported through `.codeledger/taxonomy.yaml`:

```yaml
overrides:
  paths:
    "services/legacy/**":
      boost:
        refactor: 0.5
      add_tags:
        - high_risk
  keywords:
    "decommission":
      set_type: migration
      weight: 1.5
```

This lets a repo bias deterministic classification without changing the shared classifier defaults.

### `lessons list`

Lists active lessons.

```bash
npx codeledger lessons list
```

Example output:

```text
Active lessons
- release version normalization
- standalone artifact parity
```

### `lessons relevant`

Shows lessons relevant to a task/files/concepts.

```bash
npx codeledger lessons relevant --task "Fix release workflow"
```

Example output:

```text
Relevant lessons
1. Rebuild standalone after CLI messaging changes
2. Validate tags before promotion
```

### `lessons verify`

Approves a lesson.

```bash
npx codeledger lessons verify --id lesson_123
```

Example output:

```text
Lesson verified
ID: lesson_123
```

### `lessons deprecate`

Deprecates a lesson.

```bash
npx codeledger lessons deprecate --id lesson_123
```

Example output:

```text
Lesson deprecated
ID: lesson_123
```

### `guardrails status`

Shows current guardrail results.

```bash
npx codeledger guardrails status --task "Ship 0.7.11"
```

Example output:

```text
Guardrails status
Passed: 6
Failed: 0
```

### `guardrails explain`

Shows detailed guardrail explanations.

```bash
npx codeledger guardrails explain --task "Ship 0.7.11"
```

Example output:

```text
Guardrail explanations
- completion: pass
- release alignment: pass
```

### `broker resolve`

Produces structured context resolution for a task.

```bash
npx codeledger broker resolve --task "Fix release messaging"
```

Example output:

```json
{
  "task": "Fix release messaging",
  "top_targets": ["src/billing/license.ts"]
}
```

### `broker validation`

Produces validation-oriented broker output.

```bash
npx codeledger broker validation --target "src/billing/license.ts"
```

Example output:

```text
Validation targets
- upgrade guidance
- standalone parity
```

### `broker neighborhood`

Shows nearby files and dependencies.

```bash
npx codeledger broker neighborhood --target "src/billing/license.ts"
```

Example output:

```text
Neighborhood
- src/billing/upgrade.ts
- src/billing/features.ts
```

### `broker evidence`

Returns evidence for a finding.

```bash
npx codeledger broker evidence --finding "standalone mismatch"
```

Example output:

```text
Evidence
- dist output says npx
- standalone output says codeledger
```

### `broker completion`

Produces completion-oriented structured output.

```bash
npx codeledger broker completion --task "Ship 0.7.11"
```

Example output:

```text
Completion view
Open loops: 0
```

### `broker preamble`

Generates a structured preamble for an agent or review.

```bash
npx codeledger broker preamble --task "Fix standalone release parity"
```

Example output:

```text
Broker preamble generated
Key files: 4
Key risks: 2
```

### Command-driven activation

Background activation now follows explicit command policy, not loose prompt guessing.

- CodeLedger now uses a single ambient activation policy table for task-bearing commands
- pre-refresh commands such as `codeledger context --task "..."`, `codeledger broker refresh --task "..."`, `codeledger memory inject --task "..."`, `codeledger complete-check --task "..."`, and `codeledger audit --task "..."` establish or refresh task context in the background before execution
- command-managed commands such as `codeledger task`, `codeledger codex`, `codeledger claude`, `codeledger preflight`, `codeledger bundle`, `codeledger manifest`, `codeledger verify`, and `codeledger activate` establish task context themselves, so the CLI does not trigger duplicate activation in the same invocation
- non-task commands such as help, version, and status flows do not trigger ambient activation
- `codeledger activate --task "..."` remains the explicit/manual fallback
- status/help commands like `codeledger license status`, `codeledger context --help`, and `codeledger broker timeline` do not activate in the background

### Repo coordination

CodeLedger can now coordinate multiple agent windows in the same repo before edits collide.

- `codeledger claim <paths...>` records active file or directory claims with policy checks
- `codeledger leases` lists active or stale leases
- `codeledger preflight-edit <path>` checks a path before you edit it
- `codeledger release` releases claims by session, claim ID, or all
- `codeledger coordination` summarizes active sessions, overlaps, and hot surfaces

Validation records bind each preflight result to:
- current commit hash
- repo fingerprint
- session ID
- claimed scopes

Product promise:
- Git tells you after two agents collided. CodeLedger tells you before they do.

### `broker refresh`

Refreshes or reuses active context for a live task shift and returns ranked files plus bundle delta.

```bash
npx codeledger broker refresh --task "Add auth middleware tests" --json
```

Example output:

```json
{
  "decision": "refreshed",
  "fallbackPolicy": "codeledger_first_then_search",
  "relevantFiles": ["src/auth/middleware.ts", "tests/auth/middleware.test.ts"]
}
```

Without `--json`, the command also prints a `Matched patterns:` section that explains why a reusable pattern ranked highly, including lifecycle status, confidence, reuse count, promotion state, merge count, keyword/file hits, and the last promotion reason when available.

### `broker current`

Returns the current active bundle, latest bundle delta, and recent timeline tail.

```bash
npx codeledger broker current --json
```

Without `--json`, the command prints the current ranked files plus the same matched-pattern trust summary used by `broker refresh`.

### `broker timeline`

Returns the recent truth-ledger tail without rereading the entire timeline.

```bash
npx codeledger broker timeline --limit 10 --json
```

## Insight System (v0.10)

Phase 2 insight commands make the system interrogable. All deterministic, no LLMs.

### `explain`

Explain the latest run using evidence, scoring signals, and prior outcome patterns.

```bash
codeledger explain
codeledger explain --json
codeledger explain --surface ide
```

### `learnings`

Show recurring patterns, hotspots, and trend learnings from recent runs.

```bash
codeledger learnings
codeledger learnings --limit 5
codeledger learnings --surface markdown
```

### `next`

Recommend the next best actions based on current signals and historical outcomes.

```bash
codeledger next
codeledger next --limit 3 --json
```

## Shadow — Parallel Truth Evaluation (v0.10.10)

Compare legacy and candidate implementations side by side before rollout.

### `shadow run`

Run a side-by-side comparison on fixture inputs.

```bash
codeledger shadow run --legacy isc-scoring --candidate isc-scoring --input fixtures.json
codeledger shadow run --legacy isc-scoring --candidate isc-scoring --last 5
```

Flags: `--compare output,sufficiency,latency`, `--timeout-ms 5000`, `--sample-rate 1.0`, `--max-samples N`, `--fail-open`, `--format text|json`

### `shadow report`

Show aggregate summary for a run.

```bash
codeledger shadow report
codeledger shadow report <run-id> --format json
```

### `shadow gate`

Evaluate rollout thresholds. Exit 0 = pass, exit 10 = fail.

```bash
codeledger shadow gate
codeledger shadow gate --max-critical-diff-pct 3 --format json
```

Threshold flags: `--max-critical-diff-pct`, `--max-tier-mismatch-pct`, `--max-error-pct`, `--max-timeout-pct`, `--max-latency-regression-pct`

### `shadow list`

List recent shadow runs.

```bash
codeledger shadow list
```

### `shadow inspect`

Show sample-level results and diffs.

```bash
codeledger shadow inspect <run-id>
codeledger shadow inspect --only critical
codeledger shadow inspect --sample s1
```

Built-in targets: `echo`, `isc-scoring`, `delayed-echo`. Auto-discovery finds additional targets from known engine functions.

## Cross-Layer Intelligence (v0.10)

These commands fuse the structural graph, local behavioral outcomes, and institutional / team lessons into deterministic, evidence-cited guidance. No LLM in the scoring path.

### `coach --intent "<goal>"`

Cross-layer guided implementation plan. Reads the current graph snapshot, local outcome history, and any institutional lessons synced into the repo, and emits a structured plan with advice items that each cite a verifiable evidence string.

```bash
npx codeledger coach --intent "Add OIDC support to auth login"
npx codeledger coach --intent "..." --json
```

The coach refuses to give structural advice when the graph snapshot is stale relative to the current HEAD. Run `graph index` first in that case.

### `graph index`

Builds a symbol-level structural snapshot of the repository using the TypeScript compiler API. Extracts top-level exported functions, classes, interfaces, types, enums, and import edges, and writes a commit-SHA-stamped snapshot plus a HEAD pointer under `.codeledger/graph/`. Auto-prunes to the most recent snapshots.

```bash
npx codeledger graph index
npx codeledger graph index --json
```

### `graph architecture`

Explicit alias for the legacy package-level architecture graph view.

```bash
npx codeledger graph architecture
```

### `ecl sync`

Manage the institutional / remote ECL — a schema for cross-project "lessons learned" at `.codeledger/ecl/remote/`. The current transport is committed JSON files; the schema is ready for future network-based transports.

```bash
npx codeledger ecl sync --seed            # write a deterministic seed fixture
npx codeledger ecl sync --from <dir>      # copy outcomes.jsonl/lessons.jsonl from a local dir
```

### `ecl status`

Show the remote ECL manifest + record counts.

```bash
npx codeledger ecl status
npx codeledger ecl status --json
```

### `memory seed-patterns`

Extract "Institutional North Star" patterns from successful task history. Filters your outcome ledger for consistently successful, high-confidence execution groups and promotes them into the Golden Patterns ledger. The Prompt Coach then surfaces matched patterns inline when a new task arrives — the cold-start fix for new team members.

```bash
npx codeledger memory seed-patterns                  # all sources
npx codeledger memory seed-patterns --from ecl
npx codeledger memory seed-patterns --dry-run --json
```

### `memory patterns`

Shows promoted runtime patterns plus recent automatic promotion decisions.

```bash
npx codeledger memory patterns
npx codeledger memory patterns --json
```

The human-readable view shows each pattern's lifecycle status, confidence, trust basis (`reuse` and occurrences), promotion state, and latest promotion reason.

## Release Truth

An append-only stream of `verify` outcomes per commit. Each run emits a structured PASS / WARN / FAIL event with traceable findings.

### `release-truth`

Show raw release-truth events for a commit.

```bash
npx codeledger release-truth                        # latest commit
npx codeledger release-truth --commit <sha>
npx codeledger release-truth --commit <sha> --json
```

### `release-history`

Show release-truth aggregates and recent verify history for the current repo.

```bash
npx codeledger release-history
```

### `release-insights`

Narrative + aggregate release-truth insights for the current repo over a time window.

```bash
npx codeledger release-insights
```

## Fleet — Cross-Repo Enterprise Insights (Enterprise tier)

Phase 1 cross-repo insights for enterprise customers with multiple CodeLedger-instrumented repos. Same trust boundary, many repos. The manifest is the source of truth for which repos belong to the fleet; data is read from each repo's local `.codeledger/` on the operator's filesystem.

**Manifest schema** (recommended location: `<your-org>/.github/codeledger-fleet.json`):

```json
{
  "schema_version": "codeledger/fleet/v1",
  "name": "Acme Engineering",
  "repos": [
    { "id": "payments",   "local_path": "/repos/payments-service",   "team": "fintech-alpha" },
    { "id": "checkout",   "local_path": "/repos/checkout-service",   "team": "fintech-alpha" },
    { "id": "design-sys", "local_path": "/repos/design-system",      "team": "frontend-platform" }
  ]
}
```

**Manifest resolution order:** `--manifest <path>` → `./codeledger-fleet.json` → `./.codeledger/fleet.json` → `~/.codeledger/fleet.cache.json`.

**Help is free; running the feature requires an Enterprise license.** `codeledger fleet help` and `codeledger fleet --help` always work; the other subcommands are tier-gated.

### `fleet sync`

Pull a fleet manifest into the local cache (`~/.codeledger/fleet.cache.json`).

```bash
npx codeledger fleet sync --from-github acme-corp/.github
npx codeledger fleet sync --from-github acme-corp/codeledger-config:fleet.json
npx codeledger fleet sync --from /path/to/local/codeledger-fleet.json
```

GitHub mode uses the operator's existing `gh` CLI authentication — no new auth surface.

### `fleet status`

Per-repo health line for every repo in the fleet manifest.

```bash
npx codeledger fleet status
npx codeledger fleet status --json
```

### `fleet aggregate`

Walk every repo and produce a cross-fleet report with per-team totals, first-pass success rates, golden pattern counts, prevented-issue totals, and the union of fleet-wide hotspots.
Saved and JSON reports sanitize repo-local filesystem paths by default so shareable reports do not leak operator machine structure.

```bash
npx codeledger fleet aggregate
npx codeledger fleet aggregate --json
npx codeledger fleet aggregate --out fleet-report.json
```

### `fleet compare --team-a A --team-b B`

Side-by-side metric comparison for two teams in the fleet. Surfaces deltas in outcome volume, first-pass success rate, golden pattern adoption, and prevented issues, with a deterministic delta column and a headline insight when the first-pass gap is meaningful.

```bash
npx codeledger fleet compare --team-a fintech-alpha --team-b fintech-beta
```

### `fleet hotspots`

Top failing files unioned across the entire fleet, ranked and tagged by repo so the platform team can see where tech debt is accumulating fastest across the org.

```bash
npx codeledger fleet hotspots --top 10
npx codeledger fleet hotspots --top 25 --json
```

### `fleet dashboard`

Render a self-contained HTML fleet dashboard (dark theme, no external dependencies, no JavaScript). Output defaults to `.codeledger/fleet-dashboard.html`.

```bash
npx codeledger fleet dashboard
npx codeledger fleet dashboard --out /tmp/fleet-dashboard.html
```

### `fleet insights`

Time-windowed Release Truth fleet rollup. Aggregates PASS/WARN/FAIL rates and high-risk repo count across every repo in the manifest.

```bash
npx codeledger fleet insights                    # default window: 7d
npx codeledger fleet insights --window 24h
npx codeledger fleet insights --window 30d --json
```

### `fleet alerts`

Deterministic risk-spike and concentration alerts. Compares recent vs baseline windows of release-truth data; for every detected spike, persists a `RISK_ALERT` event back into the affected repo's local release-truth log so the next developer in that repo sees the same warning that the VP saw in the fleet view.

```bash
npx codeledger fleet alerts
npx codeledger fleet alerts --json
```

This is the closed loop at the org level: a failing release in one repo becomes a visible fleet alert, and the alert then flows back into per-repo developer warnings. No human in the relay.

## Licensing and Tiers

### `upgrade`

Shows what Pro unlocks and how to activate it.

```bash
./.codeledger/bin/codeledger upgrade
```

Example output:

```text
Upgrading to CodeLedger Pro...
One Pro license unlocks both Team and Enterprise.
After checkout, activate your license with one of:
  Repo-local: ./.codeledger/bin/codeledger license activate <your-key>
  Global: codeledger license activate <your-key>
  Browser/cloud: node .codeledger/bin/codeledger-standalone.cjs license activate <your-key>
```

### `license activate <key>`

Activates a Pro license key locally.

```bash
codeledger license activate CL-PRO-TEST-AAAA-BBBB
```

Example output:

```text
✓ License activated successfully!
Status: Active
Plan: Pro
```

### `license status`

Shows current license state.

```bash
codeledger license status
```

Example output:

```text
CodeLedger Free
Status: Not activated
Run one of:
  Repo-local: ./.codeledger/bin/codeledger upgrade
  Global: codeledger upgrade
```

### `license deactivate --yes`

Removes the active license and returns to free mode.

```bash
codeledger license deactivate --yes
```

Example output:

```text
License deactivated.
CodeLedger is now in Individual (free) mode.
```

### `enable team`

Turns on Team mode after licensing.

```bash
codeledger enable team
```

Example output:

```text
Team mode enabled.
You now have access to:
  codeledger team-ledger
  codeledger team-metrics
```

### `enable enterprise`

Turns on Enterprise mode after licensing.

```bash
codeledger enable enterprise
```

Example output:

```text
Enterprise mode enabled.
You now have access to all Team features, plus:
  codeledger provenance
  codeledger audit-export
```

## Global Flags

### `--version` / `-v`

Shows the CLI version.

```bash
npx codeledger --version
```

Example output:

```text
codeledger vX.Y.Z
```

### `--help` / `-h`

Shows CLI help.

```bash
npx codeledger --help
```

Example output:

```text
Usage: codeledger <command> [options]
Commands:
  init
  activate
  verify
  ...
```

## Command Coverage Appendix

These terse entries keep the source-derived command inventory aligned with this
reference. Detailed examples live in the workflow sections above.

- `codeledger about` — show product, version, and license summary.
- `codeledger arch-policy` — inspect or enforce architecture policy (list, validate, simulate, init).
- `codeledger auto-refresh` — decide whether a task prompt should trigger a context refresh.
- `codeledger broker sync` — single-call broker sync: refresh + current + timeline in one subprocess.
- `codeledger capsule` — manage Command Capsules (inspect, change, approve, risk scoring).
- `codeledger capture` — capture replay or evidence input for the terminal replay engine.
- `codeledger capture-merge-memory` — append a post-merge outcome snapshot to the team ledger.
- `codeledger claims` — inspect or manage soft coordination claims.
- `codeledger classify` — classify a task or route a command to the correct subsystem.
- `codeledger commit-msg` — generate a structured commit message from staged changes.
- `codeledger config` — inspect or update local `.codeledger/config.json` settings.
- `codeledger conflicts` — report detected coordination conflicts between agents or sessions.
- `codeledger context-pointer` — derive, show, or add context-pointer entry points for scoped work.
- `codeledger delegation` — show or manage agent task delegation records.
- `codeledger digest` — generate a dense human-readable digest of the current session or bundle.
- `codeledger discover` — run architecture discovery before implementation begins.
- `codeledger discover-check` — validate a PR diff against prior discovery findings.
- `codeledger discover-gate` — gate a build or deploy on discovery verdict.
- `codeledger doctor` — verify the local installation and print fix commands; use `--fix` to auto-remediate.
- `codeledger drift-watch` — watch for structural drift in real time (continuous mode).
- `codeledger explain` — explain the scoring evidence for the latest run.
- `codeledger features` — show available features and their tier/enablement state.
- `codeledger fix` — apply supported auto-fixes found by `verify`.
- `codeledger fix-suggestions` — deprecated alias for `fix`.
- `codeledger github-check` — inspect GitHub-facing release or PR status via the API.
- `codeledger health` — report architecture health score (AHS, DRI, EDS, STS).
- `codeledger help` — show help for any command.
- `codeledger hotspots` — report historically risky or high-churn file paths.
- `codeledger improve` — suggest targeted improvements for a specific file.
- `codeledger insight-pack` — install, list, or remove Insight prompt packs.
- `codeledger intervene` — start an architecture intervention and print prioritized recommendations.
- `codeledger kg` — run knowledge-graph commands (build, query).
- `codeledger log` — inspect terminal replay logs.
- `codeledger mcp` — manage the MCP server integration (start, stop, status).
- `codeledger merge-check` — verify semantic merge safety before landing a branch.
- `codeledger next` — recommend the next best actions based on current signals.
- `codeledger onboard` — interactive first-session onboarding walkthrough.
- `codeledger orchestrate` — coordinate multi-agent work: reservations, task partitioning.
- `codeledger pack` — manage release or insight packs (install, list, remove).
- `codeledger panel` — render the portable context cockpit for IDEs and agents.
- `codeledger panel_brief` — MCP alias: emit a compact bundle brief for IDE panel injection.
- `codeledger panel_handoff` — MCP alias: emit a structured context-handoff artifact.
- `codeledger panel_snapshot` — MCP alias: take a point-in-time session snapshot for the IDE panel.
- `codeledger playbook` — generate a step-by-step playbook for a given task.
- `codeledger plg` — product-led-growth telemetry helpers (internal).
- `codeledger post-merge-outcome` — record the post-merge outcome for a completed feature.
- `codeledger pr-comment` — render a deterministic PR comment from verification output.
- `codeledger pr-summary` — generate a PR summary from the current diff and session evidence.
- `codeledger pr-truth-comment` — post a truth-verified PR comment (includes provenance).
- `codeledger proof-pack` — bundle evidence into a portable proof pack for audit or handoff.
- `codeledger prompt-template` — render prompt templates for common task types.
- `codeledger prompt-validate` — validate a task prompt quality before activation.
- `codeledger pulse` — show the recent signal pulse (ambient session activity).
- `codeledger recent` — inspect recent replay or evidence entries.
- `codeledger redux` — run architecture reduction analysis (identify removable complexity).
- `codeledger refresh` — deprecated alias for `scan`.
- `codeledger release-decision` — record or query a release decision with evidence.
- `codeledger release-verify` — verify release state across all propagation surfaces.
- `codeledger replay` — reproduce prior context or terminal state from the replay engine.
- `codeledger routing-audit` — audit command routing for orphans or misclassifications.
- `codeledger routing-log` — inspect the command routing log.
- `codeledger sast-ingest` — ingest external SAST findings into the evidence ledger.
- `codeledger system-map` — build, refresh, or show the repo system-topology map.
- `codeledger test-summary` — generate a test-coverage summary for the current task surface.
- `codeledger ticket-resolve` — resolve a task back to a ticket ID (Jira, Linear, GitHub).
- `codeledger validate-change` — deprecated alias for `capsule change`.
- `codeledger verify-surface` — verify a specific surface (e.g. `--surface mcp`).
- `codeledger version` — print the CLI version string.
- `codeledger brief` — emit a short session brief suitable for a PR description or standup.
- `codeledger delegation` — (team) inspect agent delegation assignments and task ownership.
- `codeledger orchestrate` — (enterprise) coordinate file reservations across parallel agents.
- `codeledger pulse` — show recent ambient activity from the session discovery engine.
- `codeledger conflicts` — show detected semantic or wiring conflicts across the session.
