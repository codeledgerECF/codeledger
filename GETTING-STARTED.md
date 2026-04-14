# Getting Started with CodeLedger

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


Need a command-by-command walkthrough with example output? See [CLI Command Reference](docs/CLI_COMMAND_REFERENCE.md).
Looking beyond developer workflow? See [Beyond CodeLedger](docs/context-ecf.md).

CodeLedger gives your AI coding agent the right files first — deterministically, locally, with zero cloud dependencies.

It works with every major AI coding agent, in every environment: desktop apps, browser-based IDEs, CLI terminals, and as a plugin.

---

## Where You Can Use CodeLedger

| Environment | Agents | Integration |
|-------------|--------|-------------|
| **Desktop CLI** | Claude Code, OpenAI Codex CLI, Gemini CLI, Aider | Lifecycle hooks (fully automatic) or manual CLI commands |
| **Desktop IDE** | Cursor, Windsurf, GitHub Copilot, Cline, Continue | Agent reads `CLAUDE.md` instructions + `.codeledger/active-bundle.md` |
| **Browser IDE** | Claude Code (web), Codespaces, Gitpod, Replit, StackBlitz | Standalone bundle (zero-dependency .cjs) — no npm install needed |
| **Plugin** | Claude Code plugin (`/codeledger:activate`) | Slash commands inside the agent conversation |
| **CI Pipeline** | GitHub Actions, GitLab CI, CircleCI, Azure Pipelines | `codeledger verify` as a merge gate |

---

## Is CodeLedger Right for Your Codebase?

CodeLedger solves the problem of **agents reading the wrong files first** in repos that are too large to fit in a single context window. The bigger the gap between "total repo size" and "what the agent actually needs for a task", the more value you get.

| Repo Profile | Source Files | Impact |
|-------------|-------------|--------|
| Large monolith or service | 500 – 5,000 | **Highest.** Agent would otherwise waste thousands of tokens exploring. CodeLedger cuts straight to the 10-25 files that matter. |
| Mid-size application | 100 – 500 | **High.** Enough files that context selection makes a clear difference. Sweet spot for tight-budget precision. |
| Multi-package monorepo | 1,000 – 50,000+ | **High — run per-package.** Point CodeLedger at the package you're working in, not the entire monorepo root. |
| Small project | 20 – 100 | **Moderate.** Still useful for churn-based prioritization and test pairing, but the agent can often read everything anyway. |
| Tiny repo / scripts | < 20 | **Low.** The agent can read the whole repo in one pass. CodeLedger adds setup overhead for little gain. |

**Rule of thumb:** If your agent regularly reads more than 25 files before making its first edit, CodeLedger will help.

---

## Prerequisites

| Requirement | Minimum | Check |
|-------------|---------|-------|
| Node.js | v20+ | `node -v` |
| npm | v9+ | `npm -v` |
| Git | v2.15+ | `git --version` |

---

## Step 1: Install

### Option A: Download the release (recommended)

1. **[Download the latest release](https://github.com/codeledgerECF/codeledger/releases/latest)** and extract the zip
2. Drag `install.sh` from the extracted folder into your terminal window
3. Press Enter

The installer uses the bundled package from the zip, so the installed wrapper version matches the release. The wrapper then fetches the matching hardened binary from the GitHub release unless your environment already provides it.

### Option B: Install from npm

```bash
npm install -g @codeledger/cli
```

> **No global install?** Use `npx codeledger <command>` anywhere. The examples below use the global command for brevity, but `npx codeledger` works identically.

### Option C: Standalone bundle (browser IDEs, sandboxed environments)

For cloud IDEs (Codespaces, Gitpod, Replit) or environments without npm:

```bash
# Vendor a zero-dependency standalone CLI into your repo
codeledger vendor
# Then run it anywhere:
node .codeledger/bin/codeledger-standalone.cjs activate --task "your task"
```

### Verify

```bash
codeledger --version
```

---

## Step 2: Initialize in Your Project

```bash
cd your-project
codeledger init
```

This creates:

| What | Where | Purpose |
|------|-------|---------|
| Config | `.codeledger/config.json` | Scoring weights, budget, file patterns |
| Agent instructions | `CLAUDE.md` (or appends to existing) | Tells your AI agent how to use CodeLedger |
| Claude Code hooks | `.claude/hooks.json` | Auto-activates bundles on session start |
| Scenarios | `.codeledger/harness/scenarios/` | Starter benchmark scenarios |

> **Already have a CLAUDE.md?** CodeLedger appends its section. It won't overwrite your existing content.

---

## Step 3: Start Your Agent

That's it — just start your agent and describe your task in plain English.

### Claude Code (Desktop CLI) — Fully Automatic

Just start Claude Code. Five lifecycle hooks handle everything:

```bash
claude
```

| Hook | What Happens |
|------|-------------|
| **SessionStart** | Scans the repo and warms the index |
| **UserPromptSubmit** | Auto-activates a bundle from your message (you never run `activate` manually) |
| **PreToolUse** | Reminds the agent to check the bundle before editing; logs file reads |
| **PostToolUse** | After `git commit`, shows recall/precision metrics and staleness warnings |
| **PreCompact** | Saves a progress snapshot before context compression |
| **Stop** | Shows final session recap with recall, precision, and token savings |

When hooks detect a failure, they now emit a diagnostic message (e.g., "CodeLedger: activate failed — working without context") instead of failing silently.

### Claude Code (Web / Browser) — Standalone Bundle

In browser-based Claude Code (or any web IDE), use the vendored standalone bundle:

```bash
# One-time: vendor the standalone CLI into .codeledger/
codeledger vendor
git add .codeledger/bin/ .gitignore
git commit -m "vendor codeledger standalone for cloud/browser environments"

# Then use it (no npm install needed at runtime):
./.codeledger/bin/codeledger activate --task "your task"
node .codeledger/bin/codeledger-standalone.cjs init
node .codeledger/bin/codeledger-standalone.cjs activate --task "your task"
```

The `CLAUDE.md` instructions tell the agent to auto-activate. No npm install required.

Packaging model:
- The standalone runtime bundled with the release is the canonical browser/cloud artifact.
- `.codeledger/bin/` is the deployed, repo-local runtime package committed for browser/cloud use.
- `codeledger init` and `codeledger vendor` keep those aligned so the checked-in runtime matches the version you tested locally.
- `./.codeledger/bin/codeledger` is the easiest interactive command inside a vendored repo.

### Claude Code Plugin — Slash Commands

If installed as a plugin, use slash commands directly in conversation:

```
/codeledger:activate Fix null handling in getUserById
```

The plugin supports two modes:
- **Standalone context selection** — `/codeledger:activate` generates a ranked bundle
- **Governed cowork session** — `/codeledger:cowork-start` for long multi-step tasks with checkpoints and drift detection

### Cursor

Cursor reads the `.cursor/rules/codeledger.mdc` rule file (created by `codeledger init`) which tells it to prioritize bundle files. For agents without lifecycle hooks, generate a bundle before you start:

```bash
codeledger activate --task "your task here"
# Then open Cursor — it reads .codeledger/active-bundle.md automatically
```

### OpenAI Codex CLI

Codex reads `CLAUDE.md` instructions and the active bundle automatically. For sandboxed mode (no network, no npm), use the vendored standalone bundle:

```bash
node .codeledger/bin/codeledger-standalone.cjs activate --task "your task"
```

### Gemini CLI / Aider / Windsurf / Copilot / Cline / Continue

These agents read `CLAUDE.md` and the active bundle. For agents without lifecycle hooks, generate a bundle before you start:

```bash
codeledger activate --task "your task here"
```

For Aider specifically, pass the bundle as a read-only file:

```bash
aider --read .codeledger/active-bundle.md
```

### Any Agent (Generic)

For any AI coding agent that accepts text instructions:

```bash
codeledger activate --task "your task"
cat .codeledger/active-bundle.md  # copy and paste into your agent's chat
```

---

## Step 4: Verify It's Working

After your agent makes a commit, check the session metrics:

```bash
codeledger session-summary
```

You'll see:
- **Bundle recall** — what % of files you changed were in the bundle
- **Edit-recall** — the meaningful metric when new files were created (bundles can't predict files that don't exist yet)
- **Precision** — what % of bundle files you actually needed
- **Token savings** — how much context was saved vs reading the whole repo

If recall is 0% but you changed tasks mid-session, that's normal — the summary will tell you "work diverged from task" instead of just "bundle wasn't useful."

Run `codeledger doctor` to verify the full integration is healthy (config, hooks, index, bundle, weights).

---

## Step 4b (Optional): CI Integration

For teams that want CI enforcement on every PR:

```bash
codeledger setup-ci --mode warn
```

This generates two files in one command:
- `.github/workflows/codeledger-verify.yml` — GitHub Actions workflow
- `.codeledger/policy/org/default.json` — policy thresholds

**Enforcement modes:** `observe` (report only) | `warn` (annotate PRs) | `block` (fail build on violations)

**Supported CI providers:** GitHub Actions, GitLab CI, CircleCI, Azure Pipelines.

---

## Common Commands

| Command | When to Use |
|---------|-------------|
| `codeledger activate --task "..."` | Starting a new task (scans if needed) |
| `codeledger activate --task "..." --branch-aware` | Boost files changed on your branch |
| `codeledger activate --task "..." --explain` | See why each file was selected |
| `codeledger activate --task "..." --expand` | Double the budget for broader coverage |
| `codeledger scan` | Force rebuild the repo index |
| `codeledger refresh` | In-session alias for `scan` |
| `codeledger refine --learned "..."` | Re-score mid-session with new context |
| `codeledger session-summary` | Check recall/precision after commits |
| `codeledger session-progress` | Snapshot progress (survives compaction) |
| `codeledger checkpoint create` | Save work-in-progress snapshot |
| `codeledger checkpoint restore --id …` | Resume from a checkpoint |
| `codeledger shared-summary` | Cross-session coordination summary |
| `codeledger intent show` | Check task drift score |
| `codeledger intent ack` | Acknowledge drift when prompted |
| `codeledger doctor` | Health check (config, hooks, index, bundle, weights) |
| `codeledger verify --task "..."` | Run architectural checks + policy evaluation |
| `codeledger fix --rule <id>` | Auto-fix architectural violations |
| `codeledger stats` | Cumulative value dashboard across all sessions |
| `codeledger setup-ci --mode warn` | Generate CI workflow + policy |
| `codeledger init --force` | Re-initialize (updates hooks + CLAUDE.md) |

---

## Configuration

Edit `.codeledger/config.json` to tune:

### Scoring Weights

CodeLedger uses configurable weights for multi-signal file scoring. The defaults are tuned for general-purpose codebases. You can adjust them in `.codeledger/config.json` under `selector.weights`.

Available signals: `keyword`, `centrality`, `churn`, `recent_touch`, `test_relevance`, `size_penalty`, `success_prior`, `fail_prior`.

Run `codeledger activate --task "..." --explain` to see how each signal contributes to file selection.

### Budget

```json
{
  "selector": {
    "default_budget": {
      "tokens": 8000,
      "max_files": 25
    }
  }
}
```

- **Tight budget** (small bundles, high precision): `tokens: 3000, max_files: 10`
- **Default** (balanced): `tokens: 8000, max_files: 25`
- **Generous** (high recall): `tokens: 15000, max_files: 40`

### File Patterns

CodeLedger auto-detects 42 file extensions across 15 language families (JS/TS, Python, Go, Rust, Ruby, Java, C#, and more). You can also create a `.codeledgerignore` file (same syntax as `.gitignore`) to exclude paths without modifying config.

---

## Troubleshooting

### "No .codeledger/config.json found"

Run `codeledger init` first. This creates the config and directory structure and warms the initial repo index.

### "Repo index is empty"

Your `include` patterns in `.codeledger/config.json` may not match any files. Check:
```bash
codeledger scan
```
If it reports 0 files, update `repo.include` to match your project's file extensions.

### Agent is ignoring the bundle

Make sure `CLAUDE.md` contains the CodeLedger section. Run:
```bash
codeledger init --force
```
This updates the CLAUDE.md instructions and hooks to the latest version.

### Hook errors on session start

If you see "CodeLedger: activate failed — working without pre-warmed context", run:
```bash
codeledger doctor
```
This checks config validity, index freshness, hook installation, bundle health, and config weight sanity.

### Bundle confidence is LOW

The bundle's confidence depends on how specific your task description is. Compare:

- Vague: `"fix the bug"` (low confidence)
- Specific: `"Fix null handling in getUserById when email is missing"` (high confidence)

If the bundle is empty, CodeLedger now tells you *why* — whether your keywords don't exist in the repo, were filtered by scope rules, or need more specific terms.

### Bundle feels stale after working for a while

After 30+ minutes and several commits, CodeLedger will nudge you to refresh. You can also refresh manually:
```bash
codeledger activate --task "your current task"
```

### "npx shows old version after upgrade"

If `npx codeledger --version` shows an older version after upgrading globally, your project has a local copy in `node_modules` that shadows the global install. Fix it:

```bash
# Option 1: Update the local copy
npm install /path/to/codeledger-cli-<version>.tgz

# Option 2: Remove the local copy (npx will use global)
rm -rf node_modules/@codeledger

# Option 3: Use the global install directly
codeledger --version  # global, not npx
```

---

## Monorepo Strategy

CodeLedger auto-detects service/package names in your task description. If you say `"Fix auth for api-gateway"`, it automatically restricts context to `services/api-gateway/` — no `--scope` flag needed.

For explicit control, use `--scope` or initialize per-package:

```bash
# Option A: auto-scope — just describe the service in your task
codeledger activate --task "Fix auth for api-gateway"

# Option B: explicit scope flag
codeledger activate --task "Fix auth" --scope "services/api-gateway/"

# Option C: initialize inside a service subdirectory
cd services/your-service
codeledger init
codeledger activate --task "your task"
```

---

## Privacy

- **Installation** requires npm access to fetch `@codeledger/*` dependencies (one-time)
- **After install**, runs entirely on your local machine
- Makes zero network calls at runtime
- Collects zero telemetry
- Your source code never leaves your machine
- No account required

---

## Uninstall

```bash
# Remove from your project
rm -rf .codeledger

# Remove the CLAUDE.md section (or delete the file if CodeLedger created it)
# Remove .claude/hooks.json (or just the CodeLedger hooks)

# Uninstall globally
npm uninstall -g @codeledger/cli
```

---

## What's Next

- Run `codeledger bundle --task "..." --explain` to see exactly why each file was selected
- Try different budget levels to find the right precision/recall tradeoff
- Use `codeledger intent show` to monitor task drift mid-session
- Use `codeledger checkpoint create` to save progress before risky operations
- Run `codeledger verify --task "..."` to catch architectural violations before merge
- Run `codeledger compare --scenario "..."` to benchmark agent performance with vs without CodeLedger
- Run `codeledger stats` to see cumulative value across all sessions

### New in v0.9.2

#### Engineering Dashboard
```bash
codeledger dashboard build    # Generate static dashboard from local evidence
codeledger dashboard open     # Open in browser (no server needed)
```
Shows system health, quality metrics, pattern reuse, and engineering value. Requires Team tier.

#### MCP Server (AI Agent Integration)
```bash
codeledger mcp start          # Launch MCP server for Claude/Cursor/Windsurf
codeledger mcp status         # Check readiness + connection instructions
```
Gives AI agents direct access to repo memory. Requires Team tier.

#### Semantic Fortress (Merge Safety)
```bash
codeledger merge-check --save-baseline    # Capture semantic contract
codeledger merge-check --verify           # Verify after merge + regression guard
codeledger merge-check                    # Quick health check
```
Three-layer merge safety: semantic merge verification (catches removed types, config drift, name collisions), Intent-Lock Registry (cross-session collision detection), and Hallucination Guard (regression watch on verified bug-fix lines). Intent-Lock and Hallucination Guard require Team tier.

#### Pattern Sync
```bash
codeledger sync push          # Stage + push patterns to GitHub mirror
codeledger sync pull          # Pull latest from team mirror
codeledger sync hydrate       # Pull golden patterns (new team members)
```
Share verified patterns across the team. Requires Team tier.

#### Feature Discovery
```bash
codeledger features           # See what's available at your tier
codeledger upgrade            # Explore Team / Enterprise
```

- Visit [codeledger.dev](https://codeledger.dev) for the latest releases
- Visit [timetocontext.co](https://timetocontext.co) for enterprise features

---

<sub>**ContextECF™** — Enterprise Context Infrastructure. Customer-Controlled Data · Tenant-Isolated · Read-Only v1 · Full Provenance · Governance-First Architecture. Confidential. ContextECF is proprietary infrastructure that augments enterprise systems with governed, role-aware contextual intelligence. The platform does not replace source systems and does not execute autonomous actions in Read-Only v1. All intelligence outputs are explainable, permission-validated, and fully auditable. Protected by pending and issued patents. [timetocontext.co](https://timetocontext.co) · [codeledger.dev](https://codeledger.dev)</sub>
