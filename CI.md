# CI / Quality Gates

This document describes the automated quality infrastructure set up for this repository.

---

## Overview

Three GitHub Actions workflows run on every push and pull request:

| Workflow | File | Purpose | Blocks PRs? |
|----------|------|---------|-------------|
| **Forge Tests** | `forge-tests.yml` | Run all 922 Foundry tests | ✅ Yes |
| **Slither Analysis** | `slither.yml` | Static analysis for vulnerabilities | ✅ Yes (clean code only) |
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

### Job 1 — `slither-clean` (blocks PRs)

Scans all production-quality contracts:
- `src/basic/`
- `src/applications/`
- `src/defi/`
- `src/evm/`

Configured with `fail-on: high` — any high-severity finding **blocks the PR**.

Results are uploaded as SARIF and visible in **GitHub → Security → Code Scanning**:
- Inline annotations on the affected lines
- Persistent alert history
- Severity filtering (high / medium / low / informational)

### Job 2 — `slither-hacks` (never blocks)

Scans only `src/hacks/` with `continue-on-error: true` and `fail-on: none`.

Purpose: document that vulnerabilities **are** intentionally present. If someone accidentally fixes a vulnerability in `hacks/`, the finding disappears from the report — a useful signal that the educational example has been compromised.

Results are uploaded to a separate SARIF category (`slither-hacks`) so they don't pollute the clean code findings.

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

### Required secret

`CODECOV_TOKEN` must be set in **GitHub → Settings → Secrets → Actions**.

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
