# Changelog

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
- **Deterministic drift scoring** — Weighted Jaccard + set distance across 7 contract fields. Thresholds: NONE (<0.10), MINOR (0.10-0.24), MAJOR (0.25-0.44), CRITICAL (>=0.45).
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
