# CodeLedger CLI Command Reference

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

Initializes `.codeledger/` in the current repository.

```bash
npx codeledger init
```

Example output:

```text
CodeLedger v0.7.x

✓ Initialized .codeledger/
✓ Wrote config.json
✓ Wrote starter scenarios
✓ Vendored standalone CLI
```

### `scan`

Builds the repository index used for deterministic file selection.

```bash
npx codeledger scan
```

Example output:

```text
Scanning repository...
✓ Indexed 1,248 files
✓ Built dependency graph
✓ Built churn map
✓ Built test map
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

Creates or refreshes `.codeledger/active-bundle.md`.

```bash
npx codeledger activate --task "Add pagination to products API"
```

Example output:

```text
Repo index is fresh
Bundle written: .codeledger/active-bundle.md
Selected 14 files (5,120 tokens)
Next: read the active bundle before editing
```

### `task --task "..."`

Runs the full ambient task flow: scan-if-stale, bundle, preflight, and agent launch/prep.

```bash
npx codeledger task --agent codex --task "Refactor order placement flow"
```

Example output:

```text
Session: cl_sess_20260330_abc123
Bundle written: .codeledger/active-bundle.md
Preflight: ready
Agent run: launched (codex)
```

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

Exports ledger/audit data.

```bash
npx codeledger audit-export --format jsonl --output audit.jsonl
```

Example output:

```text
Audit export written: audit.jsonl
Format: jsonl
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
CodeLedger API listening on http://localhost:7400
GET /health
POST /verify
POST /bundle
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

Generates a memory preamble for a task.

```bash
npx codeledger memory preamble --task "Release 0.7.11"
```

Example output:

```text
Generated memory preamble
Relevant prior lessons: 3
```

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
  "top_targets": ["packages/cli/src/commands/license.ts"]
}
```

### `broker validation`

Produces validation-oriented broker output.

```bash
npx codeledger broker validation --target "packages/cli/src/commands/license.ts"
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
npx codeledger broker neighborhood --target "packages/cli/src/commands/license.ts"
```

Example output:

```text
Neighborhood
- packages/cli/src/commands/upgrade.ts
- packages/cli/src/commands/features.ts
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

### `broker current`

Returns the current active bundle, latest bundle delta, and recent timeline tail.

```bash
npx codeledger broker current --json
```

### `broker timeline`

Returns the recent truth-ledger tail without rereading the entire timeline.

```bash
npx codeledger broker timeline --limit 10 --json
```

## Licensing and Tiers

### `upgrade`

Shows what Pro unlocks and how to activate it.

```bash
npx codeledger upgrade
```

Example output:

```text
Upgrading to CodeLedger Pro...
One Pro license unlocks both Team and Enterprise.
After checkout, activate your license with one of:
  npx codeledger license activate <your-key>
  Browser/cloud: node .codeledger/bin/codeledger-standalone.cjs license activate <your-key>
```

### `license activate <key>`

Activates a Pro license key locally.

```bash
npx codeledger license activate CL-PRO-TEST-AAAA-BBBB
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
npx codeledger license status
```

Example output:

```text
CodeLedger Free
Status: Not activated
Run one of:
  npx codeledger upgrade
```

### `license deactivate --yes`

Removes the active license and returns to free mode.

```bash
npx codeledger license deactivate --yes
```

Example output:

```text
License deactivated.
CodeLedger is now in Individual (free) mode.
```

### `enable team`

Turns on Team mode after licensing.

```bash
npx codeledger enable team
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
npx codeledger enable enterprise
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
codeledger v0.7.x
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
