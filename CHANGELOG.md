# Changelog

## 0.9.2 (2026-04-05)

Context Fabric release — MCP server, engineering dashboard, pattern lifecycle, Semantic Fortress, merge verification.

### Added
- **Semantic Fortress** — three-layer merge safety system:
  - **Semantic Merge Verification** — `codeledger merge-check` catches silent contract breaks: removed exports with importers, config fields accessed but missing from defaults, name collisions.
  - **Intent-Lock Registry** — cross-session collision detection. Warns when two sessions target the same directories. Stale detection via heartbeat + PID check.
  - **Hallucination Guard** — sensitive line tracking for verified bug fixes. Warns/blocks when touching regression-verified lines. Uses git blame for provenance.
- **MCP Server** — `codeledger mcp start` exposes repo memory to Claude, Cursor, and Windsurf via MCP protocol. Tools: `query_ledger`, `get_active_context`, `record_interaction`. (Team tier)
- **Engineering Dashboard** — `codeledger dashboard build` generates a static, self-contained HTML dashboard from local evidence. File:// compatible, no server needed. Feature-gated: Individual tier gets branded placeholder, Team/Enterprise gets full dashboard.
- **Prompt Coach** — automatic repo-aware prompt refinement. 4-level interaction model: auto-pass, suggest, warn, escalate. Ghost suggestion for nearly-precise tasks.
- **Pattern Distillation** — automatically identifies high-value patterns from successful sessions and promotes them for reuse.
- **Pattern Lifecycle** — patterns move through: emerging → validated → mixed → stale → retired. Confidence scoring. Anti-pattern detection from repeated failures.
- **Evidence Hash Chain** — every evidence entry includes `prevHash` (SHA-256 of previous entry). Tamper-evident append-only log.
- **Sync Commands** — `codeledger sync push/pull/hydrate` for team pattern sharing via GitHub shadow repo. Staging-only for v0.9.2.
- **Two-Loop UX** — all CLI commands show ⚡ Now (immediate value) + 💎 Next (compounding value).

### Improved
- **CI Contract** — `ci check --json` rebuilt as first-class structured API (no stdout hijacking)
- **Atomic Writes** — all evidence, episode, and pattern writes use temp→fsync→rename
- **Coordination** — explicitly labeled "advisory". Lock mechanism is age-aware (no blind force-acquire)
- **Dashboard** — signal synthesis header, contextual metric help, stale-data graceful degradation, deep-linkable evidence, full-page evidence view
- **IP Protection** — 14 crown-jewel modules, 30+ function names in binary denylist
- **Config Hardening** — memory defaults extracted into `@codeledger/types` shared constants; weight-sum validation test prevents drift

### Fixed
- ECL-Lite write path deprecated (evidence layer is canonical)
- `pruneLedger` uses atomic temp→fsync→rename
- `loadEntries` warns on malformed JSONL lines
- `setup-ci` generates vendored CLI path with npx fallback
- SQLite graceful fallback for standalone/container dashboard

## 0.7.2 (2026-03-24)

Hardening, adversarial audit remediation, and GTM polish.

### Fixed
- `activate` no-task mode now preserves existing task bundles instead of overwriting with a placeholder. Only writes a placeholder when no valid bundle exists.
- `bundle --near-misses` and `bundle --blast-radius` now correctly suppress output when arrays are empty.
- `session-cleanup` flag corrected to `--session` (was documented as `--session-id` in older guides).
- Removed duplicate public type declarations and reconciled policy resolution behavior.

### Changed
- Removed protected internal term from README architecture diagram and ContextECF mapping table.
- Removed contradictory "Confidential." label from open-source README footers.
- Corrected `CONTRIBUTING.md` license attribution from Apache 2.0 to the actual dual-license structure (MIT + proprietary core).

---

## 0.6.9 (2026-03-20)

### Added: Prompt Quality Gate

A pre-context certification layer that evaluates task prompt quality **before** context construction begins. Vague prompts are blocked or penalised before tokens are spent.

#### Prompt quality scoring
- Deterministic scoring with no ML or external calls
- Multi-factor analysis of task specificity
- Three decision tiers: SUFFICIENT / WEAK / INSUFFICIENT

#### CLI: `codeledger intent check "<task>" [--json]`
- Prints per-factor breakdown with human-readable issues and recommendations
- `--json` for machine-readable output; exits 1 on INSUFFICIENT

#### `codeledger context validate` upgrade
- Prompt quality check now runs as the first gate before structural validation
- `--force` bypasses blocking; `--json` output includes quality tier

#### Tests
- Coverage added for decision paths, JSON contract, edge cases, and determinism verification

---

## 0.6.8 (2026-03-20)

### Added: Outcome-Aware Hardening — DCOL v2.1

Closes the feedback loop: every execution cycle now informs future context selection.

#### ECL-Lite — Local Context Ledger
- Persistent append-only JSONL ledger at `.codeledger/ecl-lite.jsonl`
- Tracks outcomes, context signals, and bounded historical summaries

#### Context Confidence Score
- Pre-execution certification: deterministic `[0,1]` score from multiple weighted factors
- Three tiers: HIGH (proceed), MEDIUM (advisory), LOW (block)

#### Intent Decomposition
- Converts task strings into structured intent objects for downstream matching

#### Execution Path Signals
- Failure pattern detection from history boosts discovery of relevant files

#### CLI: `codeledger ledger`
- `ledger status` — ledger health: entry count, pass rates, top 10 failure hotspots with bar chart
- `ledger inspect [--intent <sig>] [--limit N]` — browse recent entries
- `ledger prune [--max N]` — trim to most recent N entries (default 2000)

#### `codeledger context validate` upgrade
- Computes and displays CCS alongside structural validation
- `--task`, `--expansion-level` flags added
- JSON output now includes `{ validation, ccs }` object

#### New types
- Added typed support for ledger entries, hotspot signals, confidence scoring, and structured intent

---

## 0.6.7 (2026-03-17)

Enterprise infrastructure, Review Intelligence, Shadow Files, and deployment flexibility.

### Added

#### Review Intelligence
- **Architectural verification in `codeledger verify`** — 5 invariant modules detect missing runtime validation (P1), unguarded outbound HTTP calls (P1), helper bypass (P2), build/runtime drift, and test integrity issues. Zero configuration required.
- **Baseline management** — `--update-baseline` accepts current findings into `.codeledger/review-baseline.json`. Baselined findings are hidden on subsequent runs.
- **Inline suppressions** — `// codeledger: ignore <rule|category|*> -- reason` comments suppress individual findings at the source.
- **Dispositions** — Every finding classified as `new`, `baselined`, or `suppressed`. CI blocks only on new P0/P1 findings.
- **Flags** — `--explain` (richer reasoning), `--json` (machine-readable for AI repair loops), `--debug-review` (internals), `--invariant <name>` (filter), `--show-triaged` (show hidden findings).

#### Shadow Files (Historical Co-Change Expansion)
- **Git history mining** — Identifies files frequently changed together, with time-weighted scoring.
- **Bundle expansion** — High-affinity neighbors (types ↔ tests, schema ↔ migration) are added to bundles automatically. No keyword or import edge needed.
- **Configurable** — tunable thresholds in `.codeledger/config.json` under `selector.shadow_files`.

#### Enterprise Infrastructure
- **Multi-CI provider support** — `setup-ci --provider github|gitlab|circleci|azure` generates workflows for GitHub Actions, GitLab CI, CircleCI, and Azure Pipelines.
- **API server** — `codeledger serve [--port 7400]` exposes GET /health, POST /verify, POST /bundle for toolchain integration.
- **Audit export** — `codeledger audit-export --format json|csv|jsonl` exports the event ledger for SIEM/compliance integration.
- **Container deployment** — Dockerfile, docker-compose.yml, and Kubernetes Helm chart for containerized deployments.
- **Cloud IaC templates** — AWS CloudFormation and Terraform templates for cloud infrastructure.
- **Standalone CLI bundle** — `codeledger vendor` produces a zero-dependency standalone CLI for cloud/web environments.

#### Architectural Contract Enforcement
- **Invariant packs** — `codeledger pack list|enable|disable` for managing built-in and generated invariant packs.
- **Convention learning** — `codeledger learn [--save] [--enable]` discovers repository conventions and generates custom invariant packs.
- **Architecture graph** — `codeledger graph [--json] [--save]` builds and displays service dependency graphs with cycle detection.
- **Auto-fix** — `codeledger fix [--rule <id>] [--dry-run]` applies auto-fixes for architectural violations.

#### Security
- **Credential scanning** — `codeledger detect:secrets` with entropy detection, baseline management, SARIF output, and allowlists.

### Test Coverage
- Full suite: 1,473 tests passing (up from 951 in v0.5.0)

## 0.5.0 (2026-02-23)

Multi-language scanning, auto-scope inference, CI governance pipeline, and onboarding improvements.

### Added

#### Language-Agnostic Scanning
- **Built-in language registry** — 42 file extensions across 15 language families. Auto-detects language from file extension with no configuration required.
- **Python deep support** — Relative and absolute import resolution, `test_`/`_test.py` test mapping, `def`/`class`/`async def` keyword extraction.
- **Go deep support** — `go.mod` module-local import resolution, `_test.go` test mapping, `func`/`type`/`var`/`const` keyword extraction.
- **`.codeledgerignore`** — New ignore file (same syntax as `.gitignore`) for excluding paths from indexing.

#### Auto-Scope Inference
- **`inferScope()`** — Automatically detects service/package names in task descriptions (e.g., `api-gateway`, `stripe_billing`) and restricts context to matching directories. No `--scope` flag needed.
- **Three-level fallback** — CLI `--scope` > config `default_scope` > auto-inference > no scope.

#### CI / Enterprise Governance (Mustang Pipeline)
- **`codeledger manifest`** — Generates a deterministic context manifest (bundle metadata + git state + policy snapshot). Evidence payload for CI gates.
- **`codeledger sign-manifest`** — Signs manifests with HMAC-SHA256 using JCS canonicalization (RFC 8785) for tamper evidence.
- **`codeledger policy`** — Cascading policy resolution (hardcoded defaults → `org/default.json` → `repos/<name>.json`). Three enforcement modes: `observe`, `warn`, `block`.
- **`codeledger verify`** — CI enforcement command. Evaluates 5 violation codes (`LOW_CONFIDENCE`, `HIGH_DRIFT`, `DENY_PATH_MATCH`, `MISSING_TESTS`, `BUNDLE_TOO_LARGE`), emits structured artifacts, returns appropriate exit code.
- **`codeledger setup-ci`** — One-command enterprise onboarding. Generates GitHub Actions workflow + policy file with configurable enforcement mode (`--mode observe|warn|block`).

#### Onboarding UX
- **Simplified `init` output** — Collapsed verbose checkmarks into a single summary line with one clear CTA and discoverable flags.
- **Readable `--explain` table** — Human-readable column headers, active weights displayed above the table, actionable tips when keyword scores are low.
- **Cleaner `activate` output** — Inline confidence tag, detailed LOW-confidence guidance, no emoji clutter.
- **`codeledger doctor`** — Integration health check (8 checks: config, hooks, index, ledger, engine, sessions, intent, policy).

### Fixed

- **Test-task scoring** — "Run tests" and similar execution-verb tasks now correctly prioritize test files.

### Test Coverage
- 167 adversarial smoke tests covering all CLI commands and edge cases
- Full suite: 915 tests passing

## 0.4.0 (2026-02-20)

Agent governance layer: Phase 2 + Phase 3 + Intent Governance.

### Added

#### Phase 2: Agent Governance Differentiation
- **Loop Detection & Circuit-Breaker** — Deterministic stuck-agent detection from event ledger patterns (repeated test failures, file edit loops, command retries). Configurable thresholds with `stuck_signal` events.
- **Scope Contract Enforcement** — Bundle-derived scope boundaries (selected files + dependency neighbors). Enforcement levels: `warn` (default), `strict`, `off`. Tracks `scope_drift_count` in session summary.
- **Cross-Session Conflict Zones** — Detects file overlap between concurrent agent sessions. Warns when multiple sessions target the same files. Reports `conflict_zone_touches` in session summary.

#### Phase 3: Strategic Expansion
- **`codeledger checkpoint`** — Create, restore, and list incremental work-in-progress snapshots. Enables resume after interruption (rate limits, crashes). Auto-checkpoint on activate.
- **`codeledger shared-summary`** — Cross-session coordination summary with overlap matrix, per-session metrics, and hotspot detection for multi-agent orchestration.
- **Commit-Aware Bundle Invalidation** — Marks bundled files as "addressed" when committed. Suggests bundle refresh when staleness >= 75%. Prevents re-review parroting.

#### Intent Governance Layer
- **`codeledger intent init`** — Create a structured task contract (objective, deliverable, scope, constraints, acceptance criteria, risk flags).
- **`codeledger intent show`** — Display baseline vs current contract with per-field drift distances.
- **`codeledger intent set`** — Update contract fields mid-session with automatic drift event logging.
- **`codeledger intent ack`** — Acknowledge drift (accept as new baseline or as known deviation).
- **Deterministic drift scoring** — Multi-field comparison across the intent contract with graduated severity tiers (NONE, MINOR, MAJOR, CRITICAL).
- **Auto-initialization** — Intent contract created automatically on first `activate` from task text.
- **Soft-blocking** — CRITICAL drift blocks `activate`/`refine` until acknowledged.
- **Integrated** into activate, session-summary, session-progress, and bundle injection.

### Test Coverage
- 84 new tests: Phase 2 (21), Phase 3 (22), Intent Governance (41)
- Full suite: 636 tests passing

## 0.3.0 (2026-02-18)

Cowork integration and go-to-market update.

### Added
- **Cowork session lifecycle** — Full session management for long-running, multi-step tasks
- **`/codeledger:cowork-start`** — Start a Cowork session with knowledge-scored context selection
- **`/codeledger:cowork-refresh`** — Re-score the bundle mid-session when focus shifts
- **`/codeledger:cowork-snapshot`** — Write a progress snapshot for session continuity
- **PreCompact Cowork hook** — Automatically snapshots Cowork state before context compaction
- **Knowledge scoring mode** — Optimized signal weights for codebase understanding tasks

### Changed
- **README rewritten for GTM** — Quality metrics (100% recall, 62.5% precision), two-mode messaging, install quickstart, architecture diagram
- **Plugin manifest v0.3.0** — Added Cowork keywords (cowork, session-continuity, knowledge-scoring, context-governor)

## 0.2.1 (2026-02-18)

### Fixed
- Requires CLI v0.2.1 — adds early `--agentCmd`/`--guided` validation to `compare` and `run` commands so missing agent configuration is caught before execution begins

## 0.2.0 (2026-02-18)

Initial plugin release for the Claude Code Plugin Directory.

### Added
- **SessionStart hook** — Auto-initializes CodeLedger and warms the repo index on session start
- **PreToolUse hook** — Reminds the agent to check the active context bundle before editing files
- **PreCompact hook** — Writes a ground-truth session progress snapshot before context compaction
- **Stop hook** — Shows session-end recall/precision metrics and cleanup
- **`/codeledger:activate`** — Generate a context bundle for a task (scan + score + select + write)
- **`/codeledger:bundle`** — Preview a bundle without writing to disk, with JSON output support
- **`/codeledger:refine`** — Mid-session bundle refinement with learned context and keyword injection
- **`/codeledger:status`** — Check session metrics (recall, precision, token savings, progress)
- **`/codeledger:explain`** — Detailed per-file scoring breakdown with near-misses and blast radius
