# ContextECF CodeLedger Look Book

Release candidate: v0.10.67

This look book explains the CodeLedger user experience in a two-column format:

| What the developer does | What CodeLedger does ambiently |
|-------------------------|--------------------------------|
| Runs a command, asks an agent to do work, opens a PR, or prepares a release. | Selects context, checks activation freshness, writes receipts, verifies claims, and reports release readiness. |

The core idea is simple: CodeLedger works in the developer flow. It only becomes visible when
the user expands command output, checks a receipt, opens the dashboard, or needs remediation.

## The Happy Path

```bash
npm install -g @codeledger/cli
cd your-repo
codeledger ready
codeledger activate --task "your task"
codeledger session-summary
```

## What Users Get

- Safer first-run behavior: CodeLedger stops before scanning non-git folders by default.
- Task-scoped context: agents get the files that matter for the current task.
- Ambient activation checks: stale, missing, or mismatched activation is visible.
- Worktree honesty: linked worktrees get direct guidance instead of misleading recall metrics.
- Session value: recall, precision, context narrowed, and an estimated savings proxy.
- Portable runtime: local CLI, vendored runtime, cloud, browser, Docker, and CI paths stay aligned.
- Release evidence: `codeledger release-check --json` reports whether the repo is ready.

## Suite Context

CodeLedger is the developer-facing entry point. Two optional suite layers can join the same
evidence trail:

| Suite layer | Value |
|-------------|-------|
| CodeLedger | Developer context, activation freshness, verification, receipts, and release readiness. |
| FabricLedgerSDK | Prompt pruning, bad-command filtering, and prompt/runtime evidence for agent wrappers. |
| CFA | Enterprise policy, approvals, gateway decisions, and organization-level audit. |

The products remain separately versioned internally, but the customer gets one install story,
one evidence trail, and one suite posture view.

## Webinar Practice Exercise

Use a public repo so the audience can follow along:

```bash
npm install -g @codeledger/cli
git clone https://github.com/<public>/<repo>.git
cd <repo>
codeledger ready
codeledger activate --task "explain the test structure"
codeledger session-summary
```

The presenter should show the actual bundle, the session summary, and `codeledger doctor`.
For enterprise webinars, also show `contextecf status --json` to explain where FabricLedgerSDK
and CFA add optional value.
