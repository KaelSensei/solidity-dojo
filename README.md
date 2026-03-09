![Solidity Dojo Banner](assets/banner.png)

# Solidity Dojo

A hands-on Solidity training ground based on [solidity-by-example.org](https://solidity-by-example.org).

## Overview

This repository contains a comprehensive collection of Solidity smart contracts organized by topic, with full test coverage including unit tests, fuzz tests, and invariant tests where applicable.

## Project Structure

```
solidity-dojo/
├── src/
│   ├── basic/          # Basic Solidity concepts
│   ├── applications/   # Practical applications
│   ├── hacks/          # Common vulnerabilities and solutions
│   ├── evm/            # EVM assembly and low-level operations
│   └── defi/           # DeFi protocol examples
├── test/               # Mirror structure of src/
├── foundry.toml        # Foundry configuration
├── Dockerfile          # Docker environment setup
└── docker-compose.yml  # Docker compose configuration
```

## How to Run Tests

### Option 1: Docker (Recommended - No Local Install Needed)

**Prerequisites:** Docker Desktop installed and running

```bash
# Step 1: Build and start the container (first time only)
docker compose up -d

# Step 2: Run tests directly (no need to enter container)
docker compose exec dojo forge test

# Or enter container shell for interactive use:
docker compose exec dojo bash
# Then inside container:
forge test
```

### Option 2: Local Foundry (If you have Foundry installed)

```bash
# Install dependencies
forge install

# Run all tests
forge test
```

## Test Commands Quick Reference

```bash
# Run all tests
forge test

# Run with verbose output (shows console logs)
forge test -v

# Run specific test file
forge test --match-path test/basic/Counter.t.sol

# Run specific test function
forge test --match-test test_inc_incrementsByOne

# Run tests with gas report
forge test --gas-report

# Run only failed tests from previous run
forge test --rerun

# Increase fuzz runs (default is 256)
forge test --fuzz-runs 1000
```

## Quick Start

### Option 2: Local Foundry

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Install dependencies
forge install

# Run tests
forge test
```

## Running Tests

```bash
# Run all tests
forge test

# Run tests with verbose output
forge test -v

# Run specific test file
forge test --match-path test/basic/Counter.t.sol

# Run specific test function
forge test --match-test test_inc_incrementsByOne

# Run fuzz tests only (increased runs)
forge test --fuzz-runs 1000
```

## 📖 Concepts Guide

See **[CONCEPTS.md](CONCEPTS.md)** for a Solidity by Example-style reference covering all 79 topics in this dojo. Each entry explains the concept, shows a code snippet, and links directly to the contract and its tests.

## Implemented Contracts

### Basic Section

| Contract | Description | Tests |
|----------|-------------|-------|
| HelloWorld | SPDX, pragma, state variables | Unit |
| Counter | Increment/decrement with underflow protection | Unit, Fuzz |
| Primitives | bool, uint, int, address, bytes32 | Unit, Fuzz |
| Variables | local, state, global variables | Unit, Fuzz |
| Constants | constant keyword and gas savings | Unit, Invariant |
| Immutable | immutable variables set in constructor | Unit, Fuzz |
| SimpleStorage | SSTORE vs SLOAD demonstration | Unit, Fuzz, Invariant |
| EtherUnits | wei, gwei, ether conversions | Unit, Fuzz |
| Gas | gasleft() and EIP-1559 concepts | Unit |
| IfElse | conditional branching and ternary | Unit, Fuzz |
| Loop | for, while, break, continue | Unit, Fuzz |
| Mapping | mapping and nested mappings | Unit, Fuzz |
| Array | dynamic and fixed-size arrays | Unit, Fuzz |
| Enum | enum types with casting | Unit, Fuzz |
| UserDefinedValueTypes | type safety with wrap/unwrap | Unit, Fuzz |
| Structs | struct declaration and usage | Unit, Invariant |

### Applications Section

| Contract | Description |
|----------|-------------|
| EtherWallet | payable functions, receive/fallback, access control |

### Hacks Section

| Contract | Description |
|----------|-------------|
| ReentrancyVulnerable | Classic reentrancy vulnerability (DO NOT USE) |
| ReentrancySecure | CEI pattern and reentrancy guard |

### EVM Section

| Contract | Description |
|----------|-------------|
| AssemblyMath | Inline assembly for gas-efficient operations |

## Testing Philosophy

Each contract includes:

1. **Unit Tests** - Specific scenarios with deterministic inputs
2. **Fuzz Tests** - Random inputs to test across value ranges (where applicable)
3. **Invariant Tests** - Properties that must always hold (for stateful contracts)

## NatSpec Documentation

All contracts follow NatSpec conventions:

```solidity
/// @title ContractName
/// @notice Plain English description
/// @dev Technical implementation details
/// @param name Parameter description
/// @return Description of return value
```

## Gas Optimization Notes

Key gas-saving patterns demonstrated:

- `constant` and `immutable` for compile-time values (~3 gas vs ~2100 for storage)
- `calldata` instead of `memory` for external function parameters
- Short-circuiting in boolean expressions
- Assembly for performance-critical operations

## Security Patterns

Security best practices implemented:

- Checks-Effects-Interactions (CEI) pattern
- Reentrancy guards
- Proper error handling with custom errors
- Access control modifiers
- Input validation

## Contributing

This is a training repository. To add new contracts:

1. Create the contract in `src/<section>/ContractName.sol`
2. Create tests in `test/<section>/ContractName.t.sol`
3. Follow the NatSpec documentation standard
4. Include unit tests for all functions
5. Add fuzz tests where applicable
6. Add invariant tests for stateful contracts

## Resources

- [Solidity by Example](https://solidity-by-example.org)
- [Foundry Documentation](https://book.getfoundry.sh)
- [Solidity Documentation](https://docs.soliditylang.org)

## License

MIT
