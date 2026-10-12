# CodeLedger MCP Server

Give your AI coding agent access to CodeLedger context and evidence through MCP.

The CodeLedger MCP server exposes your local Context Ledger as tools for Claude Desktop, Cursor, Windsurf, and any MCP-compatible client.

> Requires Team or Enterprise tier. See [Feature Tiers](FEATURE_TIERS.md).

## Quick Start

Install/configuration success is not a connection test. On a supported native
host (Apple Silicon macOS or Linux x64), prepare a specific repository:

```sh
npm install -g @codeledger/cli@latest
codeledger --version
codeledger ready --cwd /absolute/path/to/repo --task "Inspect this repository"
codeledger license status --cwd /absolute/path/to/repo
codeledger mcp status --cwd /absolute/path/to/repo --json
```

Use the printed `config` object for desktop clients. It includes an explicit
`mcp start` and absolute repository target. Portable `.mcp.json` configs written
by `ready` require the client to launch from that repo; do not copy them to a
desktop client with a different working directory. `--cwd` takes precedence
over `CODELEDGER_REPO_ROOT`. Sibling roots remain outside the default approved
scope. Do not expand allowed roots to work around setup errors.

After reconnecting, verify MCP initialize, tools/list, then an actual
`get_active_context` call with `{}` returning this repository's prepared bundle.
Missing activation is degraded context, not task readiness. Verify the server
version matches the CLI and record artifact/source identity for candidates;
version strings alone are insufficient. Repeat cold and warm cache checks.
Profiles are `core` (default), `governance` and `full`; use `governance` for
acceptance tools. A directory template is not proof of a working client, and a
local stdio command alone does not connect a hosted ChatGPT integration.

Windows, Intel Mac and Linux ARM64 have no pre-built native installer asset.
Intel Macs cannot run Apple Silicon binaries through Rosetta. An already
trusted vendored runtime may work; skipping postinstall cannot bootstrap one
in a fresh repo. Use a supported host/environment or review source-build
prerequisites before attempting an unsupported host; this wrapper does not
provide a fresh source-build bootstrap.
No universal OS/client compatibility is implied. Published MCP requires an
activated Team/Enterprise license; source-only checks without credentials do
not validate the licensed hardened route. Never put license keys in configs.

```bash
codeledger mcp status    # Check readiness
codeledger mcp start     # Launch server (stdio transport)
```

## Connecting to Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "codeledger": {
      "command": "codeledger",
      "args": ["mcp", "start", "--cwd", "/absolute/path/to/repo"],
      "env": { "CODELEDGER_REPO_ROOT": "/absolute/path/to/repo" }
    }
  }
}
```

## Connecting to Cursor

In Cursor settings → MCP Servers:

```json
{
  "name": "codeledger",
  "command": "codeledger",
  "args": ["mcp", "start", "--cwd", "/absolute/path/to/repo"],
  "env": { "CODELEDGER_REPO_ROOT": "/absolute/path/to/repo" }
}
```

## Available Tools

### `query_ledger`

Search for verified engineering patterns before coding.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `intent` | string | Yes | Task description to search for |
| `maxResults` | number | No | Maximum patterns to return (default 5) |

Returns scored pattern matches with relevance %, key files, and anti-pattern warnings.

### `get_active_context`

Retrieve the current task-specific context bundle.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `intent` | string | No | Task intent — triggers activation if no bundle exists |
| `repoRoot` | string | No | Repo root path (defaults to cwd) |

Returns the pre-assembled file context (Markdown) with an activation header showing task ID, source, confidence, and degraded status.

### Session Brief Tools

Use these after activation when an agent needs continuity without replaying a
long chat transcript.

| Tool | Description |
|------|-------------|
| `codeledger_get_session_brief` | Bounded working memory for the active session |
| `codeledger_verify_session_brief` | Fresh/stale/corrupt/missing freshness report |
| `codeledger_get_session_brief_evidence` | Evidence refs and missing-evidence keys |

These tools return paths, hashes, capped summaries, freshness state, and
evidence refs. They do not return raw prompts, raw diffs, full source files,
unrestricted logs, scoring weights, or proprietary internals.

### `record_interaction`

Report an execution outcome into the evidence buffer.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `intent` | string | Yes | What the agent was trying to do |
| `status` | string | Yes | `"success"`, `"failure"`, or `"partial"` |
| `filesModified` | string[] | No | Files that were changed |
| `thoughtTrace` | string | No | Brief reasoning (500 char max, no secrets) |

### `prompt_validate`

Validate a task prompt against enterprise prompt engineering best practices.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `task` | string | Yes | The task prompt to validate |
| `category` | string | No | Filter: clarity, structure, examples, safety, enterprise_governance, software_dev |

Returns a scored report with findings, fix suggestions, and source attribution.

## Activation Enforcement

The MCP server enforces activation before delivering context. This ensures every tool call is linked to a tracked task:

- **With intent**: if no bundle exists, the server auto-activates using the provided intent
- **Without intent**: returns context with an `Activation: missing` header and a degraded-mode annotation
- **Degraded mode**: when activation quality is absent, the response clearly states "Task context was not formally established for part of this session" — it never hides degraded state

This behavior is controlled by the ActivationGate, a unified middleware that all surfaces (CLI, MCP, Broker) pass through.

## How It Works

1. **Before coding** — agent calls `query_ledger` to find verified patterns
2. **During coding** — agent uses `get_active_context` to stay focused (activation enforced)
3. **After coding** — agent calls `record_interaction` to report outcomes (linked to active task)
4. **Next session** — patterns that worked get stronger; patterns that failed weaken

The system learns which patterns actually help, automatically.

## Privacy

- **Local-only**: The MCP server has no network access
- **No source-code telemetry by default**: local MCP use does not send repository contents to CodeLedger telemetry
- Everything stays in `.codeledger/` in your repo

## Prerequisites

- Node.js >= 20 for repository-local/source CLI (Node 22 tested)
- CodeLedger initialized in repo (`codeledger init`)
- Team or Enterprise tier license activated
