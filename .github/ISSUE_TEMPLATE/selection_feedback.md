---
name: Selection Feedback
about: Report that CodeLedger selected the wrong files for a task
title: 'Selection: '
labels: selection-quality
assignees: ''
---

## Task description

The task you gave to `codeledger activate --task "..."`:

```
<paste your task description here>
```

## What CodeLedger selected

Files that appeared in the bundle (from `.codeledger/active-bundle.md`):

```
<list the selected files>
```

## What was actually needed

Files your agent ended up reading or modifying:

```
<list the files that were actually relevant>
```

## Missing files

Files that should have been in the bundle but weren't:

```
<list any files that were missed>
```

## Extra files

Files in the bundle that weren't needed (optional):

```
<list any irrelevant files>
```

## Environment

- **CodeLedger version:** (`codeledger --version`)
- **Approximate repo size:** (file count)
- **Budget settings:** (default, or custom if changed)
- **Language/framework:** (e.g., TypeScript/Express, Python/Django)
