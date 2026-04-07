# Scoring Algorithm

## Overview

CodeLedger uses a deterministic, configurable weighted scoring approach for context selection. No LLM is involved — every decision is reproducible from the same inputs.

Same task + same repo state = same file rankings and content. Every time. (Metadata fields like `bundle_id` and `generated_at` vary between runs.)

## Candidate Generation

Before scoring, CodeLedger generates a candidate set using multiple signals including:

- **Task keyword analysis** — tokenizes the task description and matches against file paths, exported symbols, and content
- **Repository graph traversal** — walks the import/require graph to include files that keyword matches depend on, and files that depend on them. Supports JS/TS, Python, Go, and other languages
- **Test pairing** — pairs source files with their corresponding test files
- **History signals** — incorporates git history to identify files that change together or are frequently modified

**Auto-Scope Inference:** CodeLedger checks the task description for compound identifiers (e.g., `api-gateway`, `stripe_billing`) that match directory names. If found, candidate generation is automatically restricted to that scope — no `--scope` flag needed. Fallback order: CLI `--scope` > config `default_scope` > auto-inference > no scope.

## Scoring

Each candidate file is evaluated across a set of positive and negative signals, all normalized to [0, 1]. The final score is a configurable weighted combination that is sensitive to task type (e.g., test-focused tasks weight test relevance more heavily).

Weights are configurable in `.codeledger/config.json` under `selector.weights`. The defaults are tuned for general-purpose codebases; run `codeledger activate --task "..." --explain` to see how each signal contributes to a specific selection.

## Selection

After scoring, files are ranked by score descending. The selector adds files to the bundle until one of:

1. **File limit** — Bundle reaches `max_files`
2. **Token budget** — Estimated token count reaches the budget, with a soft overshoot allowance for high-value files
3. **Sufficiency threshold** — Cumulative contribution score plateaus

This prevents over-selection — once the bundle has "enough" context, it stops.

## Excerpt Policy

For large files:
- Export signatures are always included
- Relevant code windows are included
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

The ledger accumulates outcome data over time, enabling CodeLedger to improve bundle quality automatically based on past success and failure patterns.
