# CodeLedger Architecture Overview

CodeLedger is a local-first developer evidence layer for AI-assisted software
work. It helps coding agents start with bounded task context, records what
evidence supported the work, and produces receipts that teams can review later.

## Public Architecture

CodeLedger has four public-facing layers:

1. **CLI and agent adapters** receive developer tasks, run local checks, and
   write user-visible receipts.
2. **Local evidence stores** keep activation bundles, validation receipts,
   session summaries, and team reports on the developer machine or in the
   repository workspace.
3. **Policy and release surfaces** turn local evidence into CI/PR annotations,
   release checks, and governance reports.
4. **Optional dashboards and integrations** render the same local evidence for
   engineering teams.

## Privacy Posture

CodeLedger is designed so source code and customer content do not leave the
machine by default. Public interfaces expose evidence references, summaries,
status, and hashes rather than raw source files or unrestricted transcripts.

The npm wrapper may download a platform-specific hardened binary during
installation. Runtime analysis remains local.

## What This Document Intentionally Omits

This public overview describes product boundaries and operational guarantees.
It intentionally does not publish scoring formulas, proprietary thresholds,
internal package names, protected function identifiers, or implementation
roadmaps.

For usage details, see `README.md`, `GETTING-STARTED.md`, and the CLI command
reference.
