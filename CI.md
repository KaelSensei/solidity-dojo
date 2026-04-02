# CI / Quality Gates

This document describes the automated quality infrastructure set up for this repository.

---

## Overview

Three GitHub Actions workflows run on every push and pull request:

| Workflow | File | Purpose | Blocks PRs? |
|----------|------|---------|-------------|
| **Forge Tests** | `forge-tests.yml` | Run all 922 Foundry tests | ✅ Yes |
| **Slither Analysis** | `slither.yml` | Static analysis → SARIF / Code Scanning | ✅ Yes — if Slither or `forge install` fails |
| **Coverage** | `coverage.yml` | Test coverage report → Codecov | ❌ No (informational) |

---

## Forge Tests

**File:** `.github/workflows/forge-tests.yml`

Runs the full test suite using the Foundry toolchain:

```bash
forge test -vv
```

All 3 test categories are covered:
- **Unit tests** — deterministic inputs, specific scenarios
- **Fuzz tests** — randomized inputs (256 runs default, configurable via `--fuzz-runs`)
- **Invariant tests** — stateful properties that must always hold (64 runs, depth 32)

The test report is uploaded as a GitHub Actions artifact (retained 1 day).

---

## Slither Static Analysis

**File:** `.github/workflows/slither.yml`

[Slither](https://github.com/crytic/slither) is Trail of Bits' static analysis framework for Solidity. It detects vulnerabilities such as reentrancy, unchecked return values, access control issues, oracle manipulation, and more.

### Why two jobs?

This repository has a `hacks/` folder containing **intentionally vulnerable contracts** — they exist to demonstrate attack vectors. Running a single Slither scan would produce hundreds of expected findings, making the report useless.

Two jobs solve this cleanly:

### Job 1 — `slither-clean` (SARIF → Code Scanning)

Scans all production-quality contracts (excludes `src/hacks/`, `lib/`, `test/`, `script/` via `--filter-paths`):

- `src/basic/`, `src/applications/`, `src/defi/`, `src/evm/`

Uses **`fail-on: none`** so Slither findings do not fail the step; reviewers use **GitHub Advanced Security** comments and the Security tab. The **job** still fails if compilation/analysis breaks (e.g. bad Solidity, `forge install` failure).

SARIF upload follows [crytic/slither-action](https://github.com/crytic/slither-action): use the action’s **`outputs.sarif`** path with `github/codeql-action/upload-sarif`, and **do not** combine `continue-on-error` on the Slither step with an unconditional upload — that can yield a failed **Code scanning results / Slither** check (e.g. missing or invalid upload).

Results appear under **GitHub → Security → Code Scanning** (category `slither-clean`).

### Job 2 — `slither-hacks` (artifact only, non-blocking)

Scans roughly `src/hacks/` by filtering out the other `src/*` trees. Uses `continue-on-error: true` and `fail-on: none` so intentional vulnerable demos do not break CI.

The SARIF file is attached as a **workflow artifact** (`slither-hacks-sarif`) for inspection — it is **not** uploaded to Code Scanning (keeps hacks findings out of the main alert stream).

### Troubleshooting: “Code scanning results / Slither” / configuration issues

1. Open the **Slither — clean contracts** job log: confirm Slither finished and `slither-clean.sarif` exists.
2. Under **Settings → Code security and analysis → Code scanning**, ensure you do not have a **stale** third-party configuration pointing at a deleted workflow; use the [tool status](https://docs.github.com/en/code-security/code-scanning/managing-code-scanning-for-your-repository/about-the-tool-status-page) page if available.
3. For **fork PRs**, `security-events: write` may be restricted; uploads only run reliably for PRs from the same repository unless you adopt a [fork-safe pattern](https://docs.github.com/en/code-security/code-scanning/troubleshooting-code-scanning/resource-not-accessible).

### Viewing results

→ **GitHub Security → Code Scanning alerts**  
`https://github.com/KaelSensei/solidity-dojo/security/code-scanning`

---

## Coverage

**File:** `.github/workflows/coverage.yml`

Generates a test coverage report using Foundry's built-in coverage tool and uploads it to [Codecov](https://codecov.io/gh/KaelSensei/solidity-dojo).

### How it works

```bash
# Generate lcov report
forge coverage --report lcov --lcov-version 2

# Strip test/ and lib/ from report (only src/ matters)
lcov --remove lcov.info 'test/*' 'lib/*' --output-file lcov.info

# Upload to Codecov
codecov-action → codecov.io
```

### What you get

- **Coverage badge** in the README (updates after each merge to `main`)
- **PR annotations** — Codecov comments on PRs showing coverage diff
- **Dashboard** at https://codecov.io/gh/KaelSensei/solidity-dojo with per-file breakdown

### Codecov GitHub App (recommended)

Codecov shows warnings such as *“install the Codecov app … to ensure uploads and comments are reliably processed”* when the repo is not linked via the official integration.

1. Install the app for this org or repo: **[Codecov on GitHub Marketplace](https://github.com/marketplace/codecov)** (or **GitHub → Settings → Integrations → Applications → Codecov**).
2. In **[codecov.io](https://codecov.io)** open this repository and confirm it is connected to **GitHub** (not “token only”).
3. Re-run the **Coverage** workflow on a PR; uploads and PR comments should then be processed consistently.

Repository YAML: root **`codecov.yml`** configures non-blocking status checks and PR comment layout.

### Required secret

`CODECOV_TOKEN` must be set in **GitHub → Settings → Secrets and variables → Actions** (still required for uploads from Actions unless you switch to [OIDC](https://docs.codecov.com/docs/github-oidc)).

The coverage report is non-blocking — a drop in coverage does not fail the CI.

---

## Artifact Retention

All workflow artifacts (test reports, coverage summaries) are retained for **1 day** to avoid accumulating GitHub Actions storage usage.

SARIF results uploaded to GitHub Code Scanning are managed separately by GitHub (not counted against artifact storage).

---

## Triggers

All three workflows run on:

```
push:
  branches: [main, fix/**, feature/**, ci/**]
pull_request:
  branches: [main]
```

---

## Adding a New Contract

When adding a new contract to `src/basic/`, `src/applications/`, `src/defi/`, or `src/evm/`:

1. Write the contract with NatSpec documentation
2. Write tests in the mirrored `test/` path
3. Open a PR — Slither will automatically scan it and fail if any high-severity vulnerability is introduced
4. Coverage will update to reflect the new tests

When adding a contract to `src/hacks/`:

1. The contract is expected to be vulnerable — Slither will flag it
2. This is intentional and will **not** block the PR
3. Document the vulnerability in the contract's NatSpec (`@notice`, `@dev`)
