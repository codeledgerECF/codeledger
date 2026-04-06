# CodeLedger MCP Server

Give your AI coding agent a memory that compounds over time.

The CodeLedger MCP server exposes your local Context Ledger as tools for Claude Desktop, Cursor, Windsurf, and any MCP-compatible client.

> Requires Team or Enterprise tier. See [Feature Tiers](FEATURE_TIERS.md).

## Quick Start

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
      "args": ["mcp", "start"]
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
  "args": ["mcp", "start"]
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

Returns the pre-assembled file context (Markdown).

### `record_interaction`

Report an execution outcome into the evidence buffer.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `intent` | string | Yes | What the agent was trying to do |
| `status` | string | Yes | `"success"`, `"failure"`, or `"partial"` |
| `filesModified` | string[] | No | Files that were changed |
| `thoughtTrace` | string | No | Brief reasoning (500 char max, no secrets) |

## How It Works

1. **Before coding** — agent calls `query_ledger` to find verified patterns
2. **During coding** — agent uses `get_active_context` to stay focused
3. **After coding** — agent calls `record_interaction` to report outcomes
4. **Next session** — patterns that worked get stronger; patterns that failed weaken

The system learns which patterns actually help, automatically.

## Privacy

- **Local-only**: The MCP server has no network access
- **No telemetry**: Nothing is sent to any external service
- Everything stays in `.codeledger/` in your repo

## Prerequisites

- Node.js >= 18
- CodeLedger initialized in repo (`codeledger init`)
- Team or Enterprise tier license activated
