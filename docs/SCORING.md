# Scoring Algorithm

## Overview

CodeLedger uses a deterministic, configurable weighted scoring approach for context selection. No LLM is involved — every decision is reproducible from the same inputs.

Same task + same repo state = same file rankings and content. Every time. (Metadata fields like `bundle_id` and `generated_at` vary between runs.)

## Candidate Generation (Five-Stage Pipeline)

Before scoring, CodeLedger generates a candidate set through five stages:

1. **Keyword Matching** — Tokenizes the task description and matches against file paths, exported symbols, and content. Uses IDF weighting so common words (like "fix" or "add") don't dominate. Handles plural tolerance.

2. **Hot-Zone Inclusion** — Includes the most-churned files from git history. Files that change frequently are often central to the codebase and relevant to many tasks.

3. **Dependency Expansion** — Walks the import/require graph to include files that the keyword matches depend on, and files that depend on them. Catches indirectly relevant code. Supports JS/TS imports, Python relative/absolute imports, and Go module-local imports (v0.5.0).

4. **Fan-Out Detection** — For cross-cutting tasks (like "rename the logger everywhere"), detects when many files share a common dependency and includes the full set.

5. **Test Neighborhood Pairing** — Pairs source files with their test files (and vice versa). Supports `*.test.*`/`*.spec.*` (JS/TS), `test_*`/`*_test.py` (Python), and `*_test.go` (Go) conventions (v0.5.0).

**Auto-Scope Inference (v0.5.0):** Before candidate generation, CodeLedger checks the task description for compound identifiers (e.g., `api-gateway`, `stripe_billing`) that match directory names. If found, candidate generation is automatically restricted to that scope — no `--scope` flag needed. Fallback order: CLI `--scope` > config `default_scope` > auto-inference > no scope.

## Scoring Signals

Each candidate file is evaluated across 10 signals, all normalized to [0, 1]:

### Positive Signals (higher = more relevant)

| Signal | Description |
|--------|-------------|
| **keyword** | How well the file path and exported symbols match the task description |
| **centrality** | The file's position in the dependency graph (highly imported = more central) |
| **churn** | How frequently the file has been modified recently (time-decayed) |
| **recency** | How recently the file was last modified |
| **test_relevance** | Whether the file has a mapped test file or is a test for a candidate |
| **success_prior** | From the ledger — whether including this file correlated with past successes |
| **error_infrastructure** | Whether the file is error infrastructure (error classes, validators, middleware) |
| **branch_changed** | Whether the file has uncommitted or branch-diffed changes (auto-boosted with `--branch-aware`) |

### Negative Signals (higher = less desirable)

| Signal | Description |
|--------|-------------|
| **size_penalty** | Proportional to file size — large files consume more token budget |
| **fail_prior** | From the ledger — whether including this file correlated with past failures |

## Final Score

The final score is a configurable weighted sum:

```
Score(file) = sum(weight_i * positive_signal_i) - sum(weight_j * negative_signal_j)
```

Default weights (tuned for TypeScript projects, with task-type adjustments — e.g., test tasks boost `test_relevance` to 2.5× and reduce `centrality`/`churn` to 0.5×):

```json
{
  "keyword": 0.30,
  "centrality": 0.15,
  "churn": 0.15,
  "recent_touch": 0.10,
  "test_relevance": 0.10,
  "size_penalty": 0.10,
  "success_prior": 0.05,
  "fail_prior": 0.05
}
```

Adjust these in `.codeledger/config.json` under `selector.weights`.

## Selection (Stop Rule)

After scoring, files are ranked by score descending. The selector adds files to the bundle until one of:

1. **File limit** — Bundle reaches `max_files` (default: 25)
2. **Token budget** — Estimated token count reaches the budget (default: 8000), with a 10% soft overshoot allowance for high-value files
3. **Sufficiency threshold** — Cumulative contribution score plateaus (default: 0.85)

This prevents over-selection — once the bundle has "enough" context, it stops.

## Excerpt Policy

For files that exceed the excerpt threshold (default: 250 lines):
- Export signatures are always included
- Keyword-hit windows (surrounding lines) are included
- Everything else is omitted

This keeps large files from consuming the entire token budget while preserving the most relevant sections.

## Confidence Assessment

Each bundle gets a confidence level:

- **HIGH** — Strong keyword matches, clear dependency chain, test pairs found
- **MEDIUM** — Decent matches but some ambiguity in the task description
- **LOW** — Weak keyword overlap, broad task description, or very few candidates

More specific task descriptions produce higher confidence. Compare:
- Vague: `"fix the bug"` (low confidence)
- Specific: `"Fix null handling in getUserById when email is missing"` (high confidence)

## Inspecting Scores

Use the `--explain` flag to see the per-file scoring breakdown:

```bash
codeledger bundle --task "Fix null handling in user service" --explain
```

This shows each candidate's score, the contribution from each signal, and why it was included or excluded.

## Tuning

The best approach is empirical:

1. Run `codeledger activate --task "..." --explain` with default weights
2. Check which files the bundle selected
3. After your agent finishes, run `codeledger session-summary` to see recall and precision
4. Adjust weights in `.codeledger/config.json` if needed
5. Re-run and compare

The ledger accumulates outcome data over time, enabling the success/fail priors to improve bundle quality automatically.
