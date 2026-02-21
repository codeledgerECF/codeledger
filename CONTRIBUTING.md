# Contributing to CodeLedger

Thank you for your interest in contributing to CodeLedger! The scoring engine is closed-source, but there are many valuable ways to contribute.

## How to Contribute

### Bug Reports

Open an [issue](https://github.com/codeledgerECF/codeledger/issues/new?template=bug_report.md) with:

- What you expected to happen
- What actually happened
- Steps to reproduce
- Your environment (Node.js version, OS, git version)
- CodeLedger version (`codeledger --version`)

### Feature Requests

Open an [issue](https://github.com/codeledgerECF/codeledger/issues/new?template=feature_request.md) describing:

- The problem you're trying to solve
- Your proposed solution
- Alternative approaches you've considered

### Documentation

Improvements to guides, examples, and troubleshooting are always welcome. Submit a pull request with your changes.

### Benchmark Scenarios

Help us test CodeLedger against more real-world patterns:

- Propose new task/repo combinations
- Share anonymized results from your projects
- Suggest edge cases for the selector quality tests

### Agent Integrations

If you use an AI coding tool that CodeLedger doesn't support well, we'd love to hear about it:

- Describe the agent's context injection model
- Suggest how CodeLedger bundles could be delivered
- Open an issue tagged `agent-integration`

## What We Implement

Community feedback directly shapes the scoring engine. When you report that certain files should have been selected (or shouldn't have been), we use that signal to improve the algorithm. The process:

1. You file an issue describing the selection behavior
2. We reproduce it internally against the scoring engine source
3. We implement and test the fix
4. The improvement ships in the next release

## Code of Conduct

Be respectful, constructive, and kind. We're all here to make AI coding agents work better.

## Questions?

- Open a [discussion](https://github.com/codeledgerECF/codeledger/discussions) for general questions
- Visit [timetocontext.co](https://timetocontext.co) for enterprise inquiries

---

<sub>**ContextECF™** — Enterprise Context Infrastructure. Customer-Controlled Data · Tenant-Isolated · Read-Only v1 · Full Provenance · Governance-First Architecture. [timetocontext.co](https://timetocontext.co) · [codeledger.dev](https://codeledger.dev)</sub>
