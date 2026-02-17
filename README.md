# CodeLedger

**Deterministic context selection for AI coding agents.**

Works with: **Claude Code** | **Cursor** | **Codex** | **Gemini CLI** | Any CLI-based agent

---

## What is this?

AI coding agents are powerful, but on real codebases they read 40 files before finding the 5 they need. CodeLedger fixes that.

It scans your repo, scores every file across 9 weighted signals (keywords, dependency centrality, git churn, recency, test relevance, error infrastructure, and more), and delivers a minimal context bundle — the right files, ranked by relevance — before your agent runs.

**No embeddings. No cloud. No telemetry. Fully local. Fully deterministic.**

## Download

**[Download the latest release](https://github.com/codeledgerECF/codeledger/releases/latest)** or visit [codeledger.dev](https://codeledgerECF.github.io/codeledger/) for the landing page.

### Quick Install

```bash
# From the zip (recommended)
unzip codeledger-*.zip
cd codeledger-*
./install.sh

# Or install via npm (when published to registry)
npm install -g @codeledger/cli

# Or from source
pnpm install && pnpm build
node packages/cli/dist/index.js --version
```

### Getting Started

```bash
cd your-project
codeledger init
codeledger activate --task "Fix null handling in user service"
# Your agent now has .codeledger/active-bundle.md
```

See **[GETTING-STARTED.md](GETTING-STARTED.md)** for the full 5-step guide, configuration options, and troubleshooting.

## Best For

| Repo Profile | Source Files | Impact |
|-------------|-------------|--------|
| Large monolith or service | 500 - 5,000 | **Highest.** Cuts straight to the 10-25 files that matter. |
| Mid-size application | 100 - 500 | **High.** Sweet spot for tight-budget precision. |
| Multi-package monorepo | 1,000 - 50,000+ | **High** - run per-package. |
| Small project | 20 - 100 | **Moderate.** Still useful for churn-based prioritization. |

**Rule of thumb:** If your agent regularly reads more than 25 files before making its first edit, CodeLedger will help.

## How It Works

1. **Scans** your repo (dependency graph, git churn, test mappings, content index)
2. **Scores** every file across 9 weighted signals
3. **Selects** the most relevant files within a token budget
4. **Delivers** a context bundle your agent reads immediately

Same task + same repo state = same file rankings and content. Every time.

## Agent Integration

### Claude Code (Zero Setup)

CodeLedger ships with Claude Code hooks. Just run `codeledger init` and start Claude Code — the SessionStart hook handles activation automatically.

### Cursor / Codex / Other Agents

After `codeledger init`, your agent reads the `CLAUDE.md` instructions and `.codeledger/active-bundle.md` for context. Refresh the bundle when switching tasks:

```bash
codeledger activate --task "your new task"
```

## Privacy

- Runs entirely on your local machine
- Makes zero network calls
- Collects zero telemetry
- Your source code never leaves your machine
- No account required

## Links

- [Getting Started Guide](GETTING-STARTED.md)
- [Landing Page](https://codeledgerECF.github.io/codeledger/)
- [Enterprise](https://contextecf.com)

## License

MIT (plugin layer) + CodeLedger Core License (scoring engine). See [LICENSE](LICENSE) and [LICENSE-CORE](LICENSE-CORE).
