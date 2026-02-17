# Getting Started with CodeLedger

CodeLedger gives your AI coding agent the right files first — deterministically, locally, with zero cloud dependencies.

---

## Is CodeLedger Right for Your Codebase?

### Where CodeLedger has the biggest impact

CodeLedger solves the problem of **agents reading the wrong files first** in repos that are too large to fit in a single context window. The bigger the gap between "total repo size" and "what the agent actually needs for a task", the more value you get.

| Repo Profile | Source Files | Impact |
|-------------|-------------|--------|
| Large monolith or service | 500 – 5,000 | **Highest.** Agent would otherwise waste thousands of tokens exploring. CodeLedger cuts straight to the 10-25 files that matter. |
| Mid-size application | 100 – 500 | **High.** Enough files that context selection makes a clear difference. Sweet spot for tight-budget precision. |
| Multi-package monorepo | 1,000 – 50,000+ | **High — run per-package.** Point CodeLedger at the package you're working in, not the entire monorepo root. |
| Small project | 20 – 100 | **Moderate.** Still useful for churn-based prioritization and test pairing, but the agent can often read everything anyway. |
| Tiny repo / scripts | < 20 | **Low.** The agent can read the whole repo in one pass. CodeLedger adds setup overhead for little gain. |

**Rule of thumb:** If your agent regularly reads more than 25 files before making its first edit, CodeLedger will help.

### Best use cases

These are the workflows where teams see the largest improvement:

- **Feature development on a mature codebase** — "Add pagination to the products API." The agent needs the route handler, service layer, model, test file, and maybe a migration — not the 300 other files. CodeLedger hands it exactly those 8-12 files.

- **Bug fixes in unfamiliar code** — "Fix the race condition in session refresh." Even if the developer doesn't know which files are involved, CodeLedger's keyword + dependency + churn signals find them.

- **Onboarding AI agents to large projects** — First time pointing Claude Code or Cursor at a 2,000-file enterprise app? CodeLedger means the agent starts productive immediately instead of spending the first 5 minutes reading irrelevant files.

- **Reducing token waste at scale** — Enterprise teams running AI agents across many tasks per day. A 99% context reduction per task compounds into significant cost and latency savings.

- **Cross-cutting refactors** — "Replace the logger with a structured logger everywhere." CodeLedger's fan-out detection finds all dependents automatically.

- **Test-adjacent work** — "Fix the failing user-service tests." CodeLedger pairs source files with their tests and surfaces error-infrastructure files.

### Where CodeLedger adds less value

- **Greenfield projects** (< 20 files) — not enough files to warrant selection
- **One-off scripts or notebooks** — no dependency graph or churn history to leverage
- **Repos that restructure constantly** — churn and dependency signals become noisy if the file tree changes every week
- **Pure documentation repos** — CodeLedger is optimized for code, not prose

### Monorepo strategy

For large monorepos, don't run CodeLedger from the root. Instead:

```bash
cd packages/your-service
codeledger init
codeledger activate --task "your task"
```

This gives the scorer a focused file set with a meaningful dependency graph. You can initialize CodeLedger independently in each package that needs it.

---

## Prerequisites

| Requirement | Minimum | Check |
|-------------|---------|-------|
| Node.js | v20+ | `node -v` |
| npm | v9+ | `npm -v` |
| Git | v2.15+ | `git --version` |

---

## Step 1: Install

```bash
npm install -g @codeledger/cli
```

Verify it works:

```bash
codeledger --version
```

You should see something like `codeledger v0.1.0`.

> **Alternative (no global install):** Use `npx codeledger <command>` anywhere. The examples below use the global command for brevity, but `npx codeledger` works identically.

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

## Step 3: Activate a Bundle

```bash
codeledger activate --task "Fix null handling in user service"
```

This single command:
1. Scans your repo (builds dependency graph, git churn data, test mappings)
2. Scores every file across 9 weighted signals
3. Selects the most relevant files within a token budget
4. Writes the bundle to `.codeledger/active-bundle.md`

Your agent reads that file and knows exactly where to start.

---

## Step 4: Start Your Agent

### Claude Code

Just start Claude Code. The hooks handle everything:

```bash
claude
```

The SessionStart hook automatically runs `codeledger activate`, and the agent sees the bundle in `CLAUDE.md` instructions + `.codeledger/active-bundle.md`. After each `git commit`, the PostToolUse hook automatically prints a session recap with recall and precision metrics.

### Cursor / Codex / Other Agents

1. Open your project in your agent's IDE or CLI
2. The agent reads `CLAUDE.md` which contains CodeLedger instructions
3. Point the agent to `.codeledger/active-bundle.md` for context

For agents without hook support, refresh the bundle manually when switching tasks:

```bash
codeledger activate --task "your new task"
```

---

## Step 5: Verify It's Working

After your agent makes a commit, check the session metrics:

```bash
codeledger session-summary
```

You'll see:
- **Bundle recall** — what % of files you changed were in the bundle
- **Precision** — what % of bundle files you actually needed
- **Token savings** — how much context was saved vs reading the whole repo (shown when the bundle was at least partially useful)

---

## Common Commands

| Command | When to Use |
|---------|-------------|
| `codeledger activate --task "..."` | Starting a new task (scans if needed) |
| `codeledger scan` | Force rebuild the repo index |
| `codeledger bundle --task "..." --explain` | See per-file scoring breakdown |
| `codeledger session-summary` | Check recall/precision after commits |
| `codeledger session-progress` | Snapshot progress (survives compaction) |
| `codeledger init --force` | Re-initialize (updates hooks + CLAUDE.md) |

---

## Configuration

Edit `.codeledger/config.json` to tune:

### Scoring Weights

```json
{
  "selector": {
    "weights": {
      "keyword": 0.30,
      "centrality": 0.15,
      "churn": 0.15,
      "recent_touch": 0.10,
      "test_relevance": 0.10,
      "size_penalty": 0.10,
      "success_prior": 0.05,
      "fail_prior": 0.05
    }
  }
}
```

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

```json
{
  "repo": {
    "include": ["**/*.ts", "**/*.tsx", "**/*.py"],
    "exclude": ["node_modules/**", "dist/**"]
  }
}
```

Add your language's file extensions to `include`. CodeLedger ships with TypeScript/JavaScript defaults.

---

## Troubleshooting

### "No .codeledger/config.json found"

Run `codeledger init` first. This creates the config and directory structure.

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

If you see "CodeLedger: CLI not installed", run:
```bash
npm install
```
The hooks check for the CLI before running and print a clear message if it's missing.

### Bundle confidence is LOW

The bundle's confidence depends on how specific your task description is. Compare:

- Vague: `"fix the bug"` (low confidence)
- Specific: `"Fix null handling in getUserById when email is missing"` (high confidence)

More keywords = better file matching = higher confidence.

---

## Privacy

- Runs entirely on your local machine
- Makes zero network calls
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
- Run `codeledger compare --scenario "..."` to benchmark agent performance with vs without CodeLedger
- Visit [contextecf.com](https://contextecf.com) for enterprise features
