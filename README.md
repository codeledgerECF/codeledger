# CodeLedger

CodeLedger turns every coding action into a persistent, compounding asset.

Without CodeLedger:
- Context is lost between agents
- Every task starts from scratch
- Failures repeat

With CodeLedger:
- Context persists across sessions and agents
- Success patterns compound
- Engineering becomes measurable and auditable

This is not another AI tool. This is a **Context Control Plane** for your repo.

Works with: **Claude Code** | **Cursor** | **Codex** | **GitHub Copilot** | **Gemini CLI** | Any CLI-based agent

---

## What happens when you use CodeLedger?

1. You run a task
2. CodeLedger selects context deterministically
3. The outcome is recorded
4. Future tasks improve automatically

Over time, your repo builds its own intelligence layer.

---

## The Two-Loop Model

CodeLedger helps in two ways:

**⚡ Now** — Assembles the minimal context needed for your current task. Fewer irrelevant files, fewer retries, faster execution.

**💎 Next** — Captures what worked and builds reusable memory so future tasks start smarter. Successful patterns compound into institutional knowledge.

```
⚡ Now                          💎 Next
Select context → Execute →      Record evidence → Promote patterns →
                                Future tasks start smarter
```

---

## AI Agent Integration (MCP)

CodeLedger includes an MCP server that gives Claude, Cursor, and Windsurf direct access to your repo's memory:

```bash
codeledger mcp start     # Launch MCP server (stdio transport)
codeledger mcp status    # Check readiness + connection instructions
```

**Tools available to agents:**
- `query_ledger` — Search for verified patterns before coding
- `get_active_context` — Get the task-specific context bundle
- `record_interaction` — Report outcomes for memory compounding

> MCP integration requires Team or Enterprise tier. See [Feature Tiers](#feature-tiers).

---

## Engineering Dashboard

Generate a repo-local engineering dashboard from your Context Ledger:

```bash
codeledger dashboard build    # Generate static HTML dashboard
codeledger dashboard open     # Open in browser (no server needed)
```

The dashboard shows: system health, integrity signals, quality metrics, pattern reuse intelligence, and estimated engineering value — all derived from real execution evidence.

> Full dashboard requires Team or Enterprise tier. Individual tier receives a placeholder with teaser stats.

---

## Semantic Merge Verification

Prevent silent merge failures where code compiles but types or config are semantically broken:

```bash
codeledger merge-check --save-baseline    # Before parallel work
codeledger merge-check --verify           # After pulling a merge
codeledger merge-check                    # Quick health check
```

Catches removed types with active importers, config fields accessed but missing from defaults, and name collisions across packages.

---

## Feature Tiers

| Feature | Individual (Free) | Team | Enterprise |
|---------|:-:|:-:|:-:|
| Context selection + scanning | ✅ | ✅ | ✅ |
| Prompt coaching (automatic) | ✅ | ✅ | ✅ |
| CI enforcement (`ci check --json`) | ✅ | ✅ | ✅ |
| Local evidence + pattern capture | ✅ | ✅ | ✅ |
| Semantic merge verification | ✅ | ✅ | ✅ |
| **Full Engineering Dashboard** | 🔒 | ✅ | ✅ |
| **MCP Server** (AI agent memory) | 🔒 | ✅ | ✅ |
| **Team coordination** (claims, leases) | 🔒 | ✅ | ✅ |
| **Pattern sync** (GitHub mirror) | 🔒 | ✅ | ✅ |
| **Provenance** (causal traceability) | 🔒 | 🔒 | ✅ |
| **Audit export** (SIEM-ready) | 🔒 | 🔒 | ✅ |

```bash
codeledger features           # See what's available at your tier
codeledger upgrade            # Explore Team / Enterprise
```

---

## Why this matters

CodeLedger is built on a local-first Context Ledger:

- Append-only memory of engineering activity
- Outcome-linked learning (what worked vs what failed)
- Cross-agent continuity
- Deterministic context selection

Your repo becomes an evolving system — not just code.

---

### Get CodeLedger

**[Download Latest Release](https://github.com/codeledgerECF/codeledger/releases/latest)** · `npm install -g @codeledger/cli` · [Getting Started Guide](GETTING-STARTED.md) · [CLI Command Reference](docs/CLI_COMMAND_REFERENCE.md)

```bash
npm install -g @codeledger/cli   # or download the zip from Releases
cd your-project
codeledger init
git add .codeledger/bin/ .gitignore
git commit -m "chore: init codeledger"
./.codeledger/bin/codeledger task --task "Fix null handling in user service"
codeledger task --task "Fix null handling in user service"
# Your agent now has .codeledger/active-bundle.md with the right context
```

Your agent reads the right files first. Every time.

For browser/cloud sessions, the committed `.codeledger/bin/` runtime package is what gets executed. `codeledger init` deploys it from the canonical standalone build so the checked-in runtime matches the version you tested locally. Inside a vendored repo, `./.codeledger/bin/codeledger <command>` is the easiest interactive entry point.

### Truth Control Plane

Once a repo is initialized, CodeLedger can reconcile reality across drift, outcomes, snapshots, handoffs, and release state:

```bash
codeledger drift --history --verify-integrity
codeledger outcome --json --verify-integrity
codeledger harvest --preview --verify-integrity
codeledger context-handoff --target codex --verify-integrity
codeledger snapshot --verify-integrity
codeledger time-travel --to <snapshot-id> --verify-integrity
codeledger reality-check --verify-integrity
```

These commands extend CodeLedger's existing verification and memory systems. They do not create a separate ledger or memory store.

### What Happens After Install

Installing CodeLedger gives you the CLI. To use it in a project, initialize that project:

```bash
codeledger init
```

That sets up CodeLedger inside the repo by creating:
- `.codeledger/` for project-local cache, bundles, sessions, and runtime data
- `.codeledger/bin/` for the vendored standalone runtime
- `.claude/hooks.json` for automatic integration
- updates to `CLAUDE.md` so agents know how to use the context bundle

Your normal flow after install is:

1. Install CodeLedger
```bash
npm install -g @codeledger/cli
```

2. Go to your project
```bash
cd your-project
```

3. Initialize CodeLedger in that repo
```bash
codeledger init
```

4. Commit the vendored runtime if you want browser/cloud support
```bash
git add .codeledger/bin/ .gitignore
git commit -m "chore: initialize codeledger"
```

5. Start using it
```bash
codeledger scan
codeledger activate --task "your task here"
```

## 🌐 Beyond CodeLedger

CodeLedger is just the beginning.

It’s built on a broader system called the **Enterprise Context Fabric (ContextECF)** — a new way to make AI systems **deterministic, auditable, and cumulative** instead of probabilistic and forgetful.

At the core is a simple idea:

> Every interaction with AI should make the system smarter, more reliable, and more accountable over time.

---

## 🧠 What This Means (In Practice)

While you’re using CodeLedger for development, the same foundation extends to:

- 🧑‍💻 Engineering → Shared memory across agents, verified execution, no rework  
- 📊 Decision-making → Faster, context-rich executive decisions  
- 🗂️ Knowledge → Institutional memory that doesn’t disappear  
- 🤖 AI agents → Coordinated, governed, and trustworthy systems  
- 💬 Communication → Smarter meetings, better alignment  
- 📈 Revenue → Relationship intelligence and proactive insights  
- 🔐 Governance → Built-in auditability and compliance  

---

## 🚀 Why It Matters

Most AI tools:
- Recompute context every time  
- Lose what they learned  
- Can’t prove what happened  

ContextECF + CodeLedger:
- Remember  
- Verify  
- Compound value over time  

What you’re building isn’t just output.

> You’re building a **long-term context asset** for yourself — and potentially your entire organization.

---

## 🤝 Share This

If CodeLedger is helping you, it’s worth a quick share with:

- CTO / VP Engineering  
- Platform / DevEx teams  
- AI / Data leaders  

---

## 🏢 About

**Intelligent Context AI Inc** is the creator of CodeLedger and the Enterprise Context Fabric.

If your team is exploring AI at scale, agent systems, or enterprise context management:

📩 customersuccess@intelligentcontext.ai  
📞 916-753-7432  

---

> CodeLedger helps you capture truth in code.  
> ContextECF helps you scale that truth across the enterprise.

Important:
- You do not need to keep a separate CodeLedger folder elsewhere on your machine.
- The long-lived project state lives inside each repo in `.codeledger/`.
- The global install is just the CLI entry point.
- For browser/cloud environments, the committed `.codeledger/bin/` runtime is what makes CodeLedger portable.

---

## Why CodeLedger?

AI coding agents are powerful, but on real codebases they waste time, tokens, and accuracy because they lack **targeted context**. CodeLedger fixes that — deterministically.

**No embeddings. No cloud. No telemetry. Fully local at runtime. Fully deterministic.**

| Pain Point (Without CodeLedger) | Feature (With CodeLedger) | How It Works | Benefit |
|:-|:-|:-|:-|
| Agent reads 30-50 files before finding the right ones | **Deterministic file selection** | Scores every file across 10 weighted signals (keyword, centrality, churn, recency, test relevance, size, priors, error infra, branch changes) and selects the top-ranked set within a token budget | Agent starts with the right files from the first turn |
| Irrelevant context burns tokens and degrades model accuracy | **Bounded token budgets** | Stop-rule algorithm packs files greedily until the budget is full; `--expand` doubles when you need more | 60-99% context reduction — pay only for what matters |
| Agent edits files in package A when the task is in package B | **Monorepo scope restriction** (`--scope`) + **Auto-scope inference** | Constrains candidate generation to specified path prefixes. Auto-detects service names in the task (e.g., "fix auth for api-gateway") and scopes automatically — no `--scope` flag needed | No cross-package pollution; bundles stay focused |
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
| Only works on TypeScript/JavaScript repos | **Language-agnostic scanning** | Built-in language registry for 42 file extensions across 15 language families. Python and Go get full deep support (import resolution, test conventions, keyword extraction). Any language works out of the box | Polyglot and multi-language monorepos just work |
| Co-changed files missing from the bundle | **Shadow Files** | Mines git history for temporal co-commit affinity. Expands bundle with high-affinity neighbors using recency-weighted scoring and commit-size penalties | Cross-cutting companions (types ↔ tests, schema ↔ migration) included automatically |
| Agent introduces architectural violations that linters miss | **Review Intelligence** | 5 invariant modules detect missing runtime validation (P1), unguarded outbound HTTP (P1), helper bypass (P2). Baselines, inline suppressions, disposition tracking | Catches architectural risks — not just syntax issues — deterministically |
| Token estimates are wildly inaccurate across languages | **Language-aware token calibration** | Uses per-language token/line rates (TypeScript 3.5, Python 3.2, Java 4.5, etc.) instead of a flat 4.0 | Budgets are accurate; no over- or under-packing |
| Task type doesn't influence which files are prioritized | **Task-type inference** | Auto-detects bug fix, feature add, refactor, test update, or config task and adjusts scoring weights accordingly | Bug fixes emphasize error infrastructure; test tasks heavily prioritize test files |
| TODO/FIXME markers scattered across the codebase are invisible | **TODO/FIXME awareness** | Scans selected files for TODO, FIXME, HACK, XXX markers and surfaces counts in the bundle | Agent sees open work items in the files it's about to edit |
| No way to compare agent performance with vs. without context | **A/B benchmarking** (`compare`) | Runs the same task twice — once with CodeLedger context, once without — and diffs test pass rate, iterations, token usage, and time | Quantified proof that context selection works |
| Agent gets stuck in test-fail-edit-retry loops | **Loop detection & circuit-breaker** | Detects repeated test failures, file edit loops, and command retries from the event ledger with configurable thresholds | Stuck agents get a clear signal to change approach |
| Agent edits files outside the task's scope | **Scope contract enforcement** | Derives allowed file paths from bundle + dependency neighbors; warns or blocks out-of-scope edits | Haphazard changes caught before they land |
| Multiple agents edit the same files concurrently | **Cross-session conflict zones** | Detects file overlap between active sessions and warns before edits begin | Merge conflicts prevented before they happen |
| Refreshed bundles re-surface already-resolved files | **Commit-aware bundle invalidation** | Marks bundled files as "addressed" when committed; suggests refresh when staleness >= 75% | No re-review parroting — agents move forward |
| Task objective drifts mid-session without detection | **Intent governance** (`intent`) | Tracks structured task contracts (objective, scope, constraints) with deterministic Jaccard-based drift scoring across 7 fields | Scope creep detected and flagged automatically |
| Rate limit or crash loses all work-in-progress | **Checkpoint bundles** (`checkpoint`) | Incremental snapshots of bundle state + git HEAD + changed files; restore to resume | Work survives interruptions |
| No visibility across concurrent agent sessions | **Multi-agent shared summary** (`shared-summary`) | Cross-session overlap matrix, per-session metrics, hotspot detection | Orchestrators see the full picture |

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
For a command-by-command walkthrough with example output, see **[docs/CLI_COMMAND_REFERENCE.md](docs/CLI_COMMAND_REFERENCE.md)**.

### Alternative: Download from GitHub Releases

**[Download the latest release](https://github.com/codeledgerECF/codeledger/releases/latest)** — extract the zip, then drag `install.sh` into your terminal and press Enter. The installer uses the bundled package from the zip, so the installed version always matches the release — no npm registry required.

## Best For

| Repo Profile | Source Files | Impact |
|-------------|-------------|--------|
| Large monolith or service | 500 – 5,000 | **Highest.** Cuts straight to the 10-25 files that matter. |
| Mid-size application | 100 – 500 | **High.** Sweet spot for tight-budget precision. |
| Multi-package monorepo | 1,000 – 50,000+ | **High.** Auto-scope inference detects service names in your task automatically. |
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
```

That's it. Start your agent and describe your task in plain English. The hooks will:
1. Extract your intent and scan the repo automatically
2. Score every file across 10 weighted signals
3. Select the most relevant files within a token budget
4. Write a context bundle for your agent to read

No commands to memorize. Context is ready when your agent starts.

Inside an initialized repo, prefer:

```bash
./.codeledger/bin/codeledger <command>
```

That repo-local wrapper prefers a newer global `codeledger` install on your machine and falls back to the vendored standalone runtime in browser, CI, and container environments.

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

After `codeledger init`, your agent reads the `CLAUDE.md` instructions and `.codeledger/active-bundle.md` for context. Hook-aware environments refresh automatically for new meaningful tasks. In local non-hook environments, the repo-local ambient wrappers now apply the same rule before handoff:

```bash
./.codeledger/bin/codex "your new task"
./.codeledger/bin/claude "your new task"
```

Acknowledgement-only follow-ups like `Yes please` do not refresh context. If you need to trigger the rule directly, use:

```bash
./.codeledger/bin/codeledger auto-refresh --prompt "your new task"
```

For plugin-first, mid-session retrieval, ask CodeLedger for refreshed context before using raw search:

```bash
./.codeledger/bin/codeledger broker refresh --task "implement the related feature" --json
```

That returns the active bundle, top-ranked files, and bundle delta for the task shift. Use `rg` or manual file search only if the broker result is insufficient.

For session-aware inspection during the same run:

```bash
./.codeledger/bin/codeledger broker current --json
./.codeledger/bin/codeledger broker timeline --limit 10 --json
```

`codeledger scan` ends with a compact executive summary, grouped policy recommendations, and suggested next commands. Use `codeledger scan --full-policy` when you want the full override list instead of the compact default view.

For relevance-managed architectural memory:

```bash
codeledger memory status
codeledger memory explain --id <artifact-id>
codeledger memory inject --task "Fix auth regression" --paths "src/auth/login.ts"
codeledger memory compact --dry-run
codeledger memory prune --dry-run
```

Policy memory is stored under `.codeledger/memory/policy-artifacts.json` and keeps HOT/WARM/COLD/ARCHIVED artifacts deterministic, compact, and auditable.
`codeledger memory inject` builds the bounded task-start injection bundle that sits on top of DRS: HOT is eligible, not automatically injected.

Task-start injection is driven by a deterministic taxonomy classifier. Before injection, CodeLedger classifies the task into one primary type such as `bug_fix`, `auth_change`, `migration`, `infra_change`, `dependency_change`, `api_change`, `ui_change`, `docs_only`, or `unknown`. It also emits secondary tags like `high_risk`, `shared_core`, `auth_sensitive`, `schema_sensitive`, `customer_visible`, and `incident_related`, plus a confidence score, risk level, complexity, and evidence trace.

If you need repo-specific tuning, add `.codeledger/taxonomy.yaml`:

```yaml
overrides:
  paths:
    "services/legacy/**":
      boost:
        refactor: 0.30
      add_tags:
        - high_risk
  keywords:
    "decommission":
      set_type: migration
      weight: 1.5
```

This lets you bias classification deterministically without changing the global defaults.

## CLI Commands

```bash
# ── Getting Started ───────────────────────────────────────────
codeledger init [--force]                # Set up .codeledger/ with config and scenarios
codeledger doctor                        # Integration health check (config, hooks, index, ledger)

# ── Context Selection (daily use) ─────────────────────────────
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

Command-driven activation is now deterministic:
- CodeLedger now uses a single ambient activation policy table for task-bearing commands
- pre-refresh commands such as `codeledger context --task "..."`, `codeledger broker refresh --task "..."`, `codeledger memory inject --task "..."`, `codeledger complete-check --task "..."`, and `codeledger audit --task "..."` establish or refresh task context in the background before they run
- command-managed commands such as `codeledger task`, `codeledger codex`, `codeledger claude`, `codeledger preflight`, `codeledger bundle`, `codeledger manifest`, `codeledger verify`, and `codeledger activate` establish task context themselves, so the CLI avoids duplicate activation in the same invocation
- help, version, and status-style commands do not trigger ambient activation
- `codeledger activate --task "..."` remains the explicit/manual fallback and power-user entrypoint

GitHub Copilot support is available through the existing generic task runtime:
- `codeledger task --agent copilot --agent-bin "<copilot-compatible command>" --task "..."`
- for GitHub-hosted Copilot coding agent sessions, use CodeLedger to prepare and verify context around the agent with `bundle` and `verify`

Multi-agent repo coordination is now repo-native:
- `codeledger claim <paths...>` records active file or directory claims before edits happen
- `codeledger preflight-edit <path>` checks a target path against active claims and policy before you modify it
- `codeledger leases`, `codeledger release`, and `codeledger coordination` expose active leases, stale claims, and overlap summaries
- validation records bind decisions to commit hash, repo fingerprint, session ID, and claimed scopes

Product promise:
- Git tells you after two agents collided. CodeLedger tells you before they do.

# ── Session Management ────────────────────────────────────────
codeledger session-init                  # Initialize a new session (returns session ID)
codeledger sessions                      # List active sessions and file overlaps
codeledger session-progress              # Write ground-truth progress snapshot
codeledger session-summary               # Show session-end recall/precision metrics
codeledger session-cleanup               # Clean up a session's state files
codeledger checkpoint create             # Save work-in-progress snapshot
codeledger checkpoint restore --id …    # Resume from a checkpoint
codeledger checkpoint list               # List available checkpoints
codeledger shared-summary                # Cross-session coordination summary

# ── Intent Governance ─────────────────────────────────────────
codeledger intent init --objective "…"   # Create a structured task contract
codeledger intent show                   # Display drift score and per-field distances
codeledger intent set --objective "…"    # Update contract fields mid-session
codeledger intent ack                    # Acknowledge drift (reset or accept)

# ── CI / Enterprise Governance ────────────────────────────────
codeledger setup-ci                      # Generate CI workflow + policy file
  --provider github|gitlab|circleci|azure #  CI provider (default: github)
  --mode observe|warn|block              #   Set enforcement level (default: warn)
  --output <dir>                         #   Custom workflow directory
codeledger manifest --task "…"           # Generate deterministic context manifest
codeledger sign-manifest --in … --out …  # Sign a manifest with HMAC-SHA256
codeledger policy --print                # Show resolved policy for current repo
codeledger verify --task "…"             # CI enforcement: evaluate policy, emit artifacts
  --explain                              #   Show richer reasoning and repo-standard examples
  --json                                 #   Machine-readable output for CI/AI agents
  --invariant <name>                     #   Narrow to one invariant module

# ── API Server & Compliance ──────────────────────────────────
codeledger serve                         # Start HTTP API server (default: port 7400)
  --port 7400                            #   GET /health, /drift, /outcome, /reality-check, /metrics, /provenance, /policy
                                         #   GET /architecture-health/*, /broker/timeline, /broker/current
                                         #   POST /verify, /bundle, /harvest, /snapshot, /time-travel, /context-handoff
                                         #   POST /broker/resolve, /broker/validation, /broker/neighborhood,
                                         #        /broker/evidence, /broker/completion, /broker/preamble, /broker/refresh
                                         #   Use `codeledger serve --help` for the full endpoint list
codeledger audit-export                  # Export ledger to JSON, CSV, or JSON Lines
  --format json|csv|jsonl                #   SIEM-compatible output
  --output <path>                        #   Write to file (default: stdout)
  --table runs|events|bundles|coverage   #   Filter to one table
  --raw                                  #   Opt into privileged raw export; default output is sanitized
codeledger provenance trace --task "…"   # Trace provenance for one task
codeledger provenance export --json      # Export provenance graph (sanitized by default)

# ── Cowork (Knowledge Mode) ──────────────────────────────────
codeledger cowork-start --intent "…"     # Scan workspace + generate context bundle
codeledger cowork-refresh --intent "…"   # Re-run selection with updated intent
codeledger cowork-snapshot               # Write progress snapshot for continuity
codeledger cowork-stop                   # Finalize session + print summary

# ── Benchmarking ──────────────────────────────────────────────
codeledger run --scenario …              # Execute a single benchmark scenario
codeledger compare --scenario …          # A/B comparison: with vs without CodeLedger
codeledger share [--format twitter]      # Generate shareable result snippet
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

**Candidate Generation (6 stages):**
1. Per-clause keyword matching (with IDF weighting and plural tolerance)
2. Hot-zone inclusion (most-churned files from git history)
3. Scope-aware dependency expansion (imports + dependents of matched files)
4. Fan-out detection (cross-cutting changes like "rename everywhere")
5. Test neighborhood pairing (source + test files together)
6. Shadow Files — temporal co-commit expansion (files frequently committed together in git history)

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
- Scope contract derivation (bundle files + dependency neighbors)
- Commit-aware invalidation (addressed files marked as stale)
- Shadow file annotations (temporal co-commit companions with boost reasons)
- Intent drift scoring (objective/scope/constraint change detection)

Run `codeledger bundle --task "…" --explain` to see the per-file scoring breakdown.

See [docs/SCORING.md](docs/SCORING.md) for the full scoring algorithm documentation.

## Review Intelligence

`codeledger verify` includes **Review Intelligence** — a repository-aware architectural verification layer that catches risks linters and SAST tools miss. Runs automatically with zero configuration:

- **Runtime validation** — catches typed routes without runtime input validation (P1)
- **Outbound I/O safety** — flags HTTP calls without timeouts (P1)
- **Repository drift** — detects bypass of sanctioned helpers/wrappers (P2)
- **Repo-standard discovery** — automatically finds and recommends helpers already used in your repo
- **AI repair loop** — structured JSON output lets AI agents patch and re-verify

Findings support baselines (`--update-baseline`), inline suppressions (`// codeledger: ignore <rule>`), and dispositions (new/baselined/suppressed). CI blocks only on **new** P0/P1 findings.

## Agent Governance

CodeLedger extends beyond context selection into **deterministic agent governance** — three containment layers that keep agents productive without requiring LLM judgment:

**Context Containment** — what the agent sees:
- Deterministic scoring, bounded budgets, intent-tracked bundles

**Execution Containment** — what the agent does:
- Scope contracts prevent out-of-scope edits
- Loop detection catches stuck agents before they waste tokens
- Cross-session conflict zones prevent concurrent agents from colliding
- Intent drift scoring flags when the task objective has changed

**Quality Containment** — what the agent produces:
- Commit-aware invalidation prevents re-review parroting
- Checkpoint bundles enable resume after interruption
- Multi-agent shared summaries give orchestrators full visibility

All governance features are **deterministic** — numeric thresholds, pattern matching, and set distance calculations. No LLM reasoning. No probabilistic language. Fully auditable.

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

- **Installation** requires npm access to fetch `@codeledger/*` dependencies (one-time)
- **After install**, runs entirely on your local machine
- Makes zero network calls at runtime
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

## Tiers

| | **Individual (Free)** | **Team** | **Organization** |
|---|---|---|---|
| **Who** | Solo devs, personal projects, OSS | Dev teams (>1 developer), commercial | Engineering orgs, enterprise, regulated |
| **Context selection** | Full (10 signals, Shadow Files, auto-scope) | Same | Same |
| **Agent governance** | Full (scope, loops, intent, checkpoints) | Same | Same |
| **Review Intelligence** | Full (5 invariant modules) | Same | Same |
| **Multi-session coordination** | — | Conflict zones, shared summary | Same |
| **CI enforcement** | — | `setup-ci` for 4 CI providers | Same |
| **Audit & compliance** | — | — | Audit export (JSON/CSV/JSONL), manifest signing |
| **Deployment** | Local CLI | Local CLI | + Docker, Helm, AWS, Terraform |
| **API server** | — | — | `codeledger serve` |
| **Policy cascading** | — | — | Org → repo policy resolution |
| **Enterprise platform** | — | — | [ContextECF](https://timetocontext.co) |
| **Price** | Free | [Contact us](mailto:team@codeledger.dev) | [Contact us](mailto:team@codeledger.dev) |

Start free. Tier up when your team — or your compliance team — needs more.

## License

- **Plugin (CLI, types, repo, harness, report):** [MIT](LICENSE)
- **Scoring engine (core-engine binary):** [CodeLedger Core License](LICENSE-CORE) — free for individuals and OSS, commercial use requires a license

## Links

- [Getting Started Guide](GETTING-STARTED.md)
- [Scoring Algorithm](docs/SCORING.md)
- [Changelog](CHANGELOG.md)
- [CodeLedger](https://codeledger.dev)
- [npm: @codeledger/cli](https://www.npmjs.com/package/@codeledger/cli)
- [ContextECF Enterprise](https://timetocontext.co)

## Philosophy

Large context windows are not the answer.

**Smarter context selection is.**

---

<sub>**ContextECF™** — Enterprise Context Infrastructure. Customer-Controlled Data · Tenant-Isolated · Read-Only v1 · Full Provenance · Governance-First Architecture. ContextECF is proprietary infrastructure that augments enterprise systems with governed, role-aware contextual intelligence. The platform does not replace source systems and does not execute autonomous actions in Read-Only v1. All intelligence outputs are explainable, permission-validated, and fully auditable. Protected by pending and issued patents. [timetocontext.co](https://timetocontext.co) · [codeledger.dev](https://codeledger.dev)</sub>
