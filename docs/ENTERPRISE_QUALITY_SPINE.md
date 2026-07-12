# CodeLedger Enterprise Quality Spine

The Enterprise Quality Spine connects five local-first artifacts into one evidence loop:

Intent -> Activation -> Context Bundle -> Execution -> Verification -> Review -> Outcome -> Learning -> Value Attribution.

## Artifacts

- Coding Session Capsule (`codeledger/coding-session-capsule/v1`) records what happened during a coding session, including activation, context, execution, verification, review, learning, and value refs.
- Review Context Pack (`codeledger/review-context-pack/v2`) gives reviewers the selected files, excluded files, rationale, validation plan, and refs to capsule, coordinator judgment, and value receipt.
- Coordinator Judgment (`codeledger/coordinator-judgment/v1`) maps legacy review verdicts to `SHIP`, `HOLD`, `ESCALATE`, or `BLOCK`, with deduped findings, suppressions, missing evidence, and policy basis.
- Negative-Space Learning (`codeledger/negative-space-feedback/v1`, `codeledger/negative-space-rule/v1`, `codeledger/negative-space-promotion/v1`) records reviewed noise without creating uncontrolled auto-suppression.
- Value Receipt (`codeledger/value-receipt/v1`) separates observed, inferred, and estimated CodeLedger contribution and lists what is not claimed.

## Persistence

Repo-persistent files are source code, tests, schema types, docs, and safe fixtures.

Generated local artifacts live under `.codeledger/artifacts/**` and `.codeledger/evidence/**`. Negative-space feedback events are stored as individual files under `.codeledger/evidence/negative-space/events/<event_id>.json` to avoid concurrent CLI write contention. The legacy `.codeledger/evidence/negative-space.jsonl` reader remains supported.

## CLI Flow

```bash
codeledger context pack --task "..." --json
codeledger session capsule --session <id> --json
codeledger review coordinator --task "..." --json
codeledger negative-space record --finding <id> --disposition false_positive --reason "Reviewed as noise"
codeledger negative-space candidates --json
codeledger negative-space promote --candidate <id> --reason "Repeated reviewed false positive"
codeledger value receipt --session <id> --json
```

`codeledger session-summary --session <id> --agent-addendum` also best-effort emits a Coding Session Capsule and Value Receipt, then includes their IDs in the addendum.

## Privacy And Security

Artifact writers use centralized secret redaction before writing JSON artifacts. Prompt excerpts, command observations, and generated refs should be stored as hashes or sanitized summaries rather than raw private payloads.

Missing upstream evidence is represented as `status: "degraded"` plus explicit `missing_evidence` entries. Artifact writers should not fail a session because validation, CI, review, or value evidence is absent.

Negative-space rules never suppress critical or security findings by default. Any future exception must be backed by explicit policy and audit evidence.

