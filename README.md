# CodeLedger

**Deterministic context selection for AI coding agents.**

Works with: **Claude Code** | **Cursor** | **Codex** | **Gemini CLI** | Any CLI-based agent

```bash
npm install -g @codeledger/cli
cd your-project
codeledger init
codeledger activate --task "Fix null handling in user service"
# Your agent now has .codeledger/active-bundle.md with the right context
```

Your agent reads the right files first. Every time.

---

## Why CodeLedger?

AI coding agents are powerful, but on real codebases they waste time, tokens, and accuracy because they lack **targeted context**. CodeLedger fixes that — deterministically.

**No embeddings. No cloud. No telemetry. Fully local. Fully deterministic.**

| Pain Point (Without CodeLedger) | Feature (With CodeLedger) | How It Works | Benefit |
|:-|:-|:-|:-|
| Agent reads 30-50 files before finding the right ones | **Deterministic file selection** | Scores every file across 10 weighted signals (keyword, centrality, churn, recency, test relevance, size, priors, error infra, branch changes) and selects the top-ranked set within a token budget | Agent starts with the right files from the first turn |
| Irrelevant context burns tokens and degrades model accuracy | **Bounded token budgets** | Stop-rule algorithm packs files greedily until the budget is full; `--expand` doubles when you need more | 60-99% context reduction — pay only for what matters |
| Agent edits files in package A when the task is in package B | **Monorepo scope restriction** (`--scope`) | Constrains candidate generation, dependency expansion, fan-out, and test pairing to specified path prefixes | No cross-package pollution; bundles stay focused |
| Compound tasks ("fix auth and add tests") miss half the files | **Task decomposition** | Splits compound tasks into clauses, runs keyword matching per-clause, then unions results | Every clause gets its own file discovery pass |
| Agent doesn't know which tests to run after a change | **Blast radius annotation** (`--blast-radius`) | Traces direct dependents, transitive dependents, and impacted test files for each bundle file via the dependency graph | Agent knows exactly what to test and what might break |
| Hard to tell if the bundle actually covers the task | **Confidence scoring with actionable UX** | Assesses keyword coverage, score distribution, and reason diversity; suggests improvements when confidence is low | Low-confidence bundles come with specific "try this" guidance |
| No visibility into files that almost made the cut | **Near-miss explanation** (`--near-misses`) | Reports the top N excluded files with scores, ranks, budget gaps, and keyword suggestions | Refine your task description or bump budget with precision |
| "Add a new endpoint" tasks lack structural examples | **Pattern exemplars** | Detects creation-intent tasks and includes sibling files from the same directory as structural templates | Agent sees how existing endpoints are built before writing new ones |
| Bundle scores feel like a black box | **Explain mode** (`--explain`) | Dumps the full per-file feature vector (keyword, centrality, churn, etc.) for every selected file | Full transparency into why each file was chosen |
| Agent loses context after compaction or long sessions | **Session continuity** (`session-progress`, `session-summary`) | Writes ground-truth snapshots from git (commits, changed files, remaining bundle files) before compaction; session-end recall/precision metrics | Re-orient after compaction without redoing work |
| Mid-session learning can't feed back into context | **Mid-session refine** (`refine --learned "..."`) | Re-scores the bundle with new learned context, extra keywords (`--add-keywords`), and file exclusions (`--drop`); recomputes all derived metadata | Bundle evolves as the agent learns, without starting over |
| Manually figuring out which files changed on the current branch | **Branch-aware scoring** (`--branch-aware`) | Detects uncommitted and branch-diffed files and boosts their scores automatically | Work-in-progress files float to the top |
| Config files, type definitions, and contracts get missed | **Surface-aware auto-inclusion** | Automatically includes config files, type definitions, and API contracts that match task keywords | Critical context files never fall through the cracks |
| Agent reads files in random order, missing structural context | **Architectural layer ordering** (`--layer-order`) | Sorts bundle files by architectural layer (types, models, services, routes, tests) | Agent reads contracts before implementations, just like a human would |
| Token estimates are wildly inaccurate across languages | **Language-aware token calibration** | Uses per-language token/line rates (TypeScript 3.5, Python 3.2, Java 4.5, etc.) instead of a flat 4.0 | Budgets are accurate; no over- or under-packing |
| Task type doesn't influence which files are prioritized | **Task-type inference** | Auto-detects bug fix, feature add, refactor, test update, or config task and adjusts scoring weights accordingly | Bug fixes emphasize error infrastructure; features emphasize centrality |
| TODO/FIXME markers scattered across the codebase are invisible | **TODO/FIXME awareness** | Scans selected files for TODO, FIXME, HACK, XXX markers and surfaces counts in the bundle | Agent sees open work items in the files it's about to edit |
| No way to compare agent performance with vs. without context | **A/B benchmarking** (`compare`) | Runs the same task twice — once with CodeLedger context, once without — and diffs test pass rate, iterations, token usage, and time | Quantified proof that context selection works |

## Install

```bash
# Recommended: install globally
npm install -g @codeledger/cli

# Or use without installing
npx @codeledger/cli --version

# Or install as a dev dependency
npm install --save-dev @codeledger/cli
```

Verify it works:

```bash
codeledger --version
```

See **[GETTING-STARTED.md](GETTING-STARTED.md)** for the full 5-step setup guide, configuration, and troubleshooting.

### Alternative: Download from GitHub Releases

**[Download the latest release](https://github.com/codeledgerECF/codeledger/releases/latest)** — extract the zip and run `./install.sh`.

## Best For

| Repo Profile | Source Files | Impact |
|-------------|-------------|--------|
| Large monolith or service | 500 – 5,000 | **Highest.** Cuts straight to the 10-25 files that matter. |
| Mid-size application | 100 – 500 | **High.** Sweet spot for tight-budget precision. |
| Multi-package monorepo | 1,000 – 50,000+ | **High — run per-package.** |
| Small project | 20 – 100 | **Moderate.** Still useful for churn-based prioritization. |

**Rule of thumb:** If your agent regularly reads more than 25 files before making its first edit, CodeLedger will help.

## How It Works

1. **Scans** your repo (dependency graph, git churn, test mappings, content index)
2. **Scores** every file across 10 weighted signals
3. **Selects** the most relevant files within a token budget
4. **Delivers** a context bundle your agent reads immediately

Same task + same repo state = same file rankings and content. Every time.

See [SCORING.md](docs/SCORING.md) for details on how files are scored.

## Quick Start

```bash
cd your-project
codeledger init
codeledger activate --task "Fix null handling in user service"
```

That single `activate` command:
1. Scans your repo (builds dependency graph, git churn data, test mappings)
2. Scores every file across 10 weighted signals
3. Selects the most relevant files within a token budget
4. Writes the bundle to `.codeledger/active-bundle.md`

Your agent reads that file and knows exactly where to start.

## Agent Integration

### Claude Code (Zero Setup)

CodeLedger ships with Claude Code hooks. Just run `codeledger init` and start Claude Code — the SessionStart hook handles activation automatically.

| Hook | When | What |
|------|------|------|
| **SessionStart** | Session opens | Scans repo, generates bundle |
| **PreToolUse** | Before edit/write | Reminds agent to check the bundle |
| **PreCompact** | Before compression | Saves progress snapshot to survive compaction |
| **Stop** | Session ends | Shows recall/precision metrics |

No commands to remember. Context is ready when your agent starts.

See [examples/claude-code-hooks.json](examples/claude-code-hooks.json) for the hook configuration.

### Cursor / Codex / Other Agents

After `codeledger init`, your agent reads the `CLAUDE.md` instructions and `.codeledger/active-bundle.md` for context. Refresh the bundle when switching tasks:

```bash
codeledger activate --task "your new task"
```

## CLI Commands

```bash
codeledger init                          # Set up .codeledger/ with config and scenarios
codeledger scan                          # Build repo index (dep graph, churn, test map)
codeledger bundle --task "…"             # Generate a deterministic context bundle
  --scope "src/auth/,src/api/"           #   Restrict to path prefixes (monorepo-friendly)
  --near-misses                          #   Show files that almost made the cut
  --blast-radius                         #   Annotate dependents and impacted tests
  --explain                              #   Dump per-file scoring breakdown
  --expand                               #   Double the token budget
  --layer-order                          #   Sort files by architectural layer
codeledger activate --task "…"           # Scan-if-stale + bundle + write active-bundle.md
  --scope --branch-aware                 #   Same flags as bundle, plus branch awareness
  --near-misses --blast-radius --explain #   All diagnostic flags supported
codeledger refine --learned "…"          # Re-score with new context mid-session
  --drop "file1.ts,file2.ts"             #   Remove specific files
  --add-keywords "pool,cache"            #   Inject new search terms
codeledger session-progress              # Write ground-truth progress snapshot
codeledger session-summary               # Show session-end recall/precision metrics
codeledger share [--format twitter]      # Generate shareable result snippet
codeledger run --scenario …              # Execute a single benchmark scenario
codeledger compare --scenario …          # A/B comparison: with vs without CodeLedger
codeledger clean                         # Remove orphaned worktrees
```

## Benchmark Results

| Metric | Without CodeLedger | With CodeLedger | Delta |
|--------|-------------------|-----------------|-------|
| Tests Passed | 78% | 94% | **+16%** |
| Iterations | 4 | 2 | **-50%** |
| Files Changed | 17 | 9 | **-47%** |
| Time to Finish | 6m 12s | 3m 40s | **-41%** |
| Token Usage | 28k | 18k | **-36%** |

*Example results from a mid-sized Node.js service.*

### Selector Quality (CI-Enforced)

| Budget | Avg Recall | Avg Precision |
|--------|-----------|---------------|
| **Tight** (10 files) | 100% | 62.5% |
| **Default** (25 files) | 100% | -- |

## How the Scoring Works

CodeLedger uses a multi-stage candidate pipeline and a ten-signal scorer:

**Candidate Generation (5 stages):**
1. Per-clause keyword matching (with IDF weighting and plural tolerance)
2. Hot-zone inclusion (most-churned files from git history)
3. Scope-aware dependency expansion (imports + dependents of matched files)
4. Fan-out detection (cross-cutting changes like "rename everywhere")
5. Test neighborhood pairing (source + test files together)

**Scoring Signals (10 dimensions):**
`keyword` | `centrality` | `churn` | `recency` | `test_relevance` | `size_penalty` | `success_prior` | `fail_prior` | `error_infrastructure` | `branch_changed`

**Post-Selection Enrichment:**
- Confidence assessment with actionable suggestions
- Pattern exemplars for creation-intent tasks
- Near-miss explanation with budget gap analysis
- Blast radius annotation with impacted test discovery
- Architectural layer ordering
- TODO/FIXME marker surfacing
- Task-type inference (bug fix, feature, refactor, test, config)

Run `codeledger bundle --task "…" --explain` to see the per-file scoring breakdown.

See [docs/SCORING.md](docs/SCORING.md) for the full scoring algorithm documentation.

## Architecture: Open Surface, Closed Engine

```
┌──────────────────────────────────────────────────────┐
│  PUBLIC (MIT License)                                │
│  CLI · Types · Repo Scanner · Harness · Report       │
│  Hooks · Config · Scenarios · Quality Tests          │
├──────────────────────────────────────────────────────┤
│  PROTECTED (CodeLedger Core License)                 │
│  Scoring Engine · Selection Algorithm · Confidence   │
│  Shipped as a single compiled JS binary (~19KB)      │
│  No network calls · No telemetry · Fully local       │
└──────────────────────────────────────────────────────┘
```

The CLI wrapper, benchmarking harness, types, and repo scanning are fully open — inspect them, contribute improvements, build trust. The scoring algorithm is compiled into a single binary to protect the IP while keeping everything local and transparent in behavior.

```bash
# Transparency flags — see what the engine does, not how
codeledger-core --version
codeledger-core --license
codeledger-core --explain-architecture
```

## Share Your Results

```bash
codeledger share                        # Markdown summary
codeledger share --format twitter       # Copy-pasteable tweet
codeledger share --format linkedin      # LinkedIn post
codeledger share --clipboard            # Copy to clipboard
```

## Privacy

- Runs entirely on your local machine
- Makes zero network calls
- Collects zero telemetry
- Your source code never leaves your machine
- No account required
- Uninstall at any time

## Contributing

The scoring engine is closed, but there are many ways to contribute:

- **Bug reports** — file issues with reproduction steps
- **Feature requests** — propose new CLI commands, output formats, or agent integrations
- **Documentation** — improve guides, examples, and troubleshooting
- **Benchmark scenarios** — suggest new task/repo combinations for testing
- **Agent adapters** — add support for new AI coding tools

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Prerequisites

| Requirement | Minimum | Check |
|-------------|---------|-------|
| Node.js | v20+ | `node -v` |
| npm | v9+ | `npm -v` |
| Git | v2.15+ | `git --version` |

## Enterprise

For team-scale AI workflow benchmarking and context orchestration:

**[ContextECF](https://timetocontext.co)** — Enterprise Context Infrastructure. Customer-controlled data, tenant-isolated, governance-first architecture.

## License

- **Plugin (CLI, types, repo, harness, report):** [MIT](LICENSE)
- **Scoring engine (core-engine binary):** [CodeLedger Core License](LICENSE-CORE) — free for individuals and OSS, commercial use requires a license

## Links

- [Getting Started Guide](GETTING-STARTED.md)
- [Scoring Algorithm](docs/SCORING.md)
- [CodeLedger](https://codeledger.dev)
- [npm: @codeledger/cli](https://www.npmjs.com/package/@codeledger/cli)
- [ContextECF Enterprise](https://timetocontext.co)

## Philosophy

Large context windows are not the answer.

**Smarter context selection is.**

---

<sub>**ContextECF™** — Enterprise Context Infrastructure. Customer-Controlled Data · Tenant-Isolated · Read-Only v1 · Full Provenance · Governance-First Architecture. Confidential. ContextECF is proprietary infrastructure that augments enterprise systems with governed, role-aware contextual intelligence. The platform does not replace source systems and does not execute autonomous actions in Read-Only v1. All intelligence outputs are explainable, permission-validated, and fully auditable. Protected by pending and issued patents. [timetocontext.co](https://timetocontext.co) · [codeledger.dev](https://codeledger.dev)</sub>
