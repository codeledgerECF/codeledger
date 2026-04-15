# Changelog

## 0.10.10 (Unreleased)

### Added
- **Shadow: Parallel Truth Evaluation** (`codeledger shadow`) — compare legacy and candidate implementations side by side before rollout. 5 commands (run, report, gate, list, inspect), 5 comparators (output, sufficiency, ranking, normalization, latency), severity classification, CI-grade gate with configurable thresholds (exit 0/10). V2 adds `--last N` input convenience and auto-discovery. V3 adds activate integration (shadow suggestion for refactor tasks) and CI-ready JSON output.
- **Doctrine-Aware Prompt Intelligence** — detects prompts that risk creating parallel systems, duplicate truth, or second workflows. Progressive intervention via 4 levels (none → light_cue → guided_refinement → two_phase_stop). 5 doctrine concepts seeded into ontology on init. 5 new signals in the prompt coach pack (71 total). Telemetry via DOCTRINE_INTERVENTION events.
- **Unified TaskContext** — single context object that flows through the entire activate → execute → verify → learn lifecycle. Replaces the pattern of each stage independently reading from disk.
- **ActivationGate middleware** — single chokepoint for activation enforcement across CLI, MCP, and Broker surfaces. Feature-flagged (`CODELEDGER_ACTIVATION_GATE`), enabled by default.
- **TIE visibility** — `activate` and `broker refresh` now show a "Task Intelligence" block with ISC scores, prompt lift percentage, task type, and refinement mode.
- **StorageAdapter + EventBus** — unified persistence interface for lifecycle events. `WorkspaceStorageAdapter` backs onto existing JSONL files. `EventBus` provides synchronous event routing for downstream consumers.
- **Cross-platform verification** — Docker audit battery tests across 4 Linux distros (Debian 12, Alpine 3.23, Node 18/20/22). Windows CI workflow enhanced with MCP enforcement and auto-refresh tests.
- **MCP activation enforcement tests** — 6 new handler-level tests verifying degraded mode, task type classification, and prompt lift in MCP tool calls.

### Changed
- **Task type persists through lifecycle** — `transitionLifecyclePhase` records now carry `task_type`, `task_type_confidence`, `activation_source`, and `activation_state` (previously only activation records had these).
- **Prompt lift in session summary** — ISC delta now shown in the receipt block (`Prompt lift: +50% (ISC 0.25 -> 0.75)`).
- **Broker deduplication** — broker refresh skips its own activation when ambient pre-refresh already refreshed context for the same task. Provisional activation writes are deferred to avoid duplicate lifecycle records.
- **Drift-aware confidence gate** — auto-refresh bypasses the ISC confidence gate when drift detection already validated the intent shift (MAJOR/CRITICAL drift from an existing task).

### Fixed
- **`buildMissingActivationQuality` crash** — no longer throws when called without optional `task`/`reason` args. Added null-coalescing guards for `finalPrompt`/`originalPrompt`.
- **`session-summary` crash on bare config** — gracefully handles missing `config.workspace.artifacts_dir` and `cache_dir` with defaults.
- **ESM `require` crash in `hydrateFromTaskHistory`** — restored proper ESM `import` for `node:fs` (the `require` call broke in ESM modules).
- **Auto-refresh imperative follow-on rejection** — prompts like "Please make sure we have this happening in all environments" are no longer rejected when they follow an existing task with meaningful drift.

## 0.10.7 (Unreleased)

### Added
- **`codeledger refresh`** — explicit in-session alias for `scan` when you want to force the repo index and graph current before continuing work.
- **`codeledger init` initial scan** — init now warms the repo index automatically so new repos do not need a separate first `scan` step. Use `--no-scan` to skip that work.

### Changed
- **Smarter activation refresh** — `codeledger activate` still rescans when the index is time-stale and now also rescans when structural repo changes are detected, such as added/deleted/renamed source files or important config/workspace files.
- **Automatic runtime pattern promotion** — `session-summary --final` now records deterministic promotion decisions, skips duplicate silent promotions, and exposes the current promoted patterns plus recent decisions via `codeledger memory patterns`.
- **Pattern retrieval trust ordering** — close pattern matches now break ties using conservative trust signals such as lifecycle status, reuse, confidence, and merge history instead of relying on topical relevance alone.
- **Human-readable trust output** — `broker refresh`, `broker current`, and `memory patterns` now explain pattern strength directly in CLI output instead of requiring `--json`.

### Fixed
- **Claude hook auto-refresh reliability** — fixed the generated `UserPromptSubmit` hook so meaningful-task refresh runs correctly in hook-aware Claude sessions instead of failing on malformed shell.

## 0.10.2 (2026-04-08)

Critical hotfix for v0.10.0 and v0.10.1.

### Fixed
- **`@codeledger/engine` missing runtime dependency on `typescript`** — the symbol-level graph parser added in v0.10.0 imports the TypeScript compiler API at runtime, but `typescript` was declared as a devDependency. The bug only manifested on fresh npm installs (monorepo users were unaffected because pnpm hoists dependencies). Symptom: `ERR_MODULE_NOT_FOUND: Cannot find package 'typescript'` when running `codeledger --version` after `npm install -g @codeledger/cli@0.10.0` or `@0.10.1`. Fixed by promoting `typescript ^5.4.0` to a runtime dependency of `@codeledger/engine`.

**Users on v0.10.0 or v0.10.1 should upgrade immediately:**
```bash
npm install -g @codeledger/cli@0.10.2
```

## 0.10.1 (2026-04-08)

Security patch on top of 0.10.0. No behavior changes.

### Security
- **GHSA-vvjj-xcjg-gr5g** — nodemailer SMTP command injection via CRLF in the transport `name` option. Fixed by bumping nodemailer to 8.0.5 in the license-issuer scaffold.

---

## 0.10.0 (2026-04-08)

Cross-layer intelligence release — Coach, Symbol Graph, Institutional Memory, and cross-repo Fleet insights with deterministic risk-spike alerts. No LLM in the scoring path.

### Added

- **Cross-Layer Coach** — `codeledger coach --intent "<goal>"` produces a deterministic guided implementation plan by fusing structural context (symbol graph), behavioral context (local outcomes), and institutional context (team lessons). Every advice item cites a verifiable evidence string. The coach refuses to give structural advice when the graph is stale relative to HEAD.
- **Symbol-Level Graph** — `codeledger graph index` builds a symbol-level structural snapshot of the repo using the TypeScript compiler API. Extracts top-level exported functions, classes, interfaces, types, enums, and import edges. Writes to `.codeledger/graph/` with a HEAD pointer the Coach reads for freshness. Auto-prunes to the most recent snapshots.
- **Institutional Memory (Tier 3 ECL)** — `codeledger ecl sync --seed | --from <dir>` and `codeledger ecl status`. A schema for cross-project "lessons learned" lives under `.codeledger/ecl/remote/`. The current transport is committed JSON files (offline, no network); the schema is ready for future GitHub-based transports.
- **Golden Pattern Extraction** — `codeledger memory seed-patterns [--from ecl|lessons|all] [--dry-run] [--json]` extracts "Institutional North Star" patterns from successful task history. The Prompt Coach surfaces matched patterns inline when a new task arrives: *"Looks like you're doing this; typically we follow [pattern]."* Cold-start onboarding for new team members gets the benefit of every successful execution that came before them.
- **Change Capsule "block" recommendation** — the `recommended_action` union on `ChangeCapsule` now includes `"block"` for cases of very low fused confidence or critical risk. Named thresholds are exposed via `CodeLedgerConfig` for projects that want to tune the gating to their own policy. Every boundary is unit-tested.
- **Fleet (Enterprise tier)** — cross-repo enterprise insights for the "one trust boundary, many repos" case. Subcommands:
  - `fleet sync --from-github <owner>/<repo>` — pull a fleet manifest from a GitHub source of truth (recommended: `<your-org>/.github/codeledger-fleet.json`) via the operator's existing `gh` CLI auth
  - `fleet status` — per-repo health line for the whole fleet
  - `fleet aggregate` — roll up per-team totals, first-pass success, golden pattern counts, prevented issues, and fleet-wide hotspots
  - `fleet compare --team-a A --team-b B` — side-by-side team comparison with a deterministic delta column and headline insights on meaningful gaps
  - `fleet hotspots --top N` — top failing files unioned across every repo, tagged by repo
  - `fleet dashboard` — self-contained dark-theme HTML dashboard
  - `fleet insights [--window 24h|7d|30d]` — time-windowed release-truth fleet rollup
  - `fleet alerts` — deterministic risk-spike + concentration detection that persists `RISK_ALERT` events back into each affected repo
  - Help (`fleet help` / `fleet --help`) is free; running the feature requires an Enterprise license.
- **Release Truth (per-repo)** — `codeledger release-truth`, `release-history`, and `release-insights` expose the append-only stream of `verify` outcomes per commit. Each run emits a structured PASS / WARN / FAIL event. On the Enterprise tier these events compound into the Fleet insights/alerts rollup so that a failing release in one repo becomes a visible fleet alert the next day — and the alert then flows back into per-repo developer warnings. One closed loop at the org level.
- **`audit --run-tests` + `--test-cmd`** — the adversarial audit can now execute a configured test command (defaulting to `pnpm test`), capture its exit code and duration, render a Test Run section in the report, and flip the audit verdict on failure.

### Fixed

- **`policy validate` / `diff` / `merge`** — the CLI dispatcher now routes all three subcommands. They were previously unreachable from the CLI even though the implementations existed.
- **`memory status` ESM crash** — a `require()` call in an ESM module caused a "require is not defined" crash after the status output completed. Converted to static imports.
- **Global `--help` short-circuit** — commands like `pre-pr --help` used to execute the full pre-PR integrity stack instead of showing help. The dispatcher now short-circuits to the help banner unless the command implements its own subcommand-aware help.
- **`fleet help` tier-gate carve-out** — help text is reachable on the Free tier so prospective customers can evaluate the feature without an Enterprise license.
- **ECL path canonicalization** — the local behavioral ledger is now stored at `.codeledger/ecl.jsonl`. The legacy `.codeledger/ecl-lite.jsonl` path is still read transparently as a fallback, so existing repos keep working with no migration step.

### Security

- **vite GHSA-4w7w-66w2-5vf9** (path traversal in optimized-deps `.map` handling) — closed by bumping vitest to 3.x and forcing a patched vite resolution across the workspace. Applied to both the root workspace and the license-issuer scaffold.
- **hono family** (6 moderate CVEs — GHSA-r5rp-j6wh-rvv4, GHSA-xpcf-pg52-r92g, GHSA-26pp-8wgv-hjvm, GHSA-wmmm-f939-6g9c, GHSA-xf4j-xp2r-rqqx, GHSA-92pp-h63x-v22m) — closed by bumping hono and `@hono/node-server` to their patched versions. Both are transitive via the MCP SDK; no SDK upgrade required.

### Testing

- Test suite: **~3,076 tests**, 145 test files, ~125 seconds wall time on a developer laptop. Zero network access required for any test.
- New test coverage for the Cross-Layer Coach, institutional ECL, symbol parser, Golden Pattern matching, Change Capsule block recommendation, fleet aggregator, and policy dispatcher.

### Documentation

- Refreshed `docs/CLI_COMMAND_REFERENCE.md` with the new v0.10 commands (Coach, Fleet, ECL, Symbol Graph, Release Truth, Memory seed-patterns).

---

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
- **Sync Commands** — `codeledger sync push/pull/hydrate` for team pattern sharing via GitHub shadow repo. Staging is privacy-sanitized by default and preserves repo-relative paths when safe. Staging-only for v0.9.2.
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
