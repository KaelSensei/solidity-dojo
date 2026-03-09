# Solidity Dojo - Architecture

## Overview

This project is a hands-on Solidity training repository structured to teach concepts from [solidity-by-example.org](https://solidity-by-example.org) through practical implementation.

## System Design

### Directory Structure

```
solidity-dojo/
├── src/                          # Source contracts
│   ├── basic/                    # Basic Solidity concepts (40 topics)
│   ├── applications/             # Practical applications (6 contracts)
│   ├── hacks/                    # Security vulnerabilities & solutions (10+ contracts)
│   ├── evm/                      # EVM assembly & low-level (6 contracts)
│   └── defi/                     # DeFi protocols (7 contracts)
├── test/                         # Test files (mirrors src/ structure)
│   ├── basic/
│   ├── applications/
│   ├── hacks/
│   ├── evm/
│   └── defi/
├── lib/                          # Dependencies (forge-std)
├── foundry.toml                  # Foundry configuration
├── Dockerfile                    # Docker environment
└── docker-compose.yml            # Container orchestration
```

## Design Patterns

### 1. Contract Organization

Each topic follows a consistent structure:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ContractName
/// @notice Brief description for users
/// @dev Technical notes, implementation details
contract ContractName {
    // State variables with NatSpec
    /// @notice Description of variable
    /// @dev Implementation notes
    uint256 public stateVar;
    
    // Events
    /// @notice Emitted when X happens
    /// @param param Description
    event SomethingHappened(uint256 param);
    
    // Errors
    /// @notice Thrown when X condition occurs
    error InvalidCondition();
    
    // Functions with proper visibility
    /// @notice Does X
    /// @param input Input description
    /// @return result Return description
    function doSomething(uint256 input) external returns (uint256 result);
}
```

### 2. Testing Philosophy

Three types of tests for each contract:

#### Unit Tests
- Specific scenarios with deterministic inputs
- Every function has at least one test
- Edge cases and revert conditions tested

#### Fuzz Tests
- Random inputs using Foundry's fuzzer
- Test invariants across value ranges
- Use `vm.assume()` to bound inputs

```solidity
function testFuzz_deposit(uint256 amount) public {
    amount = bound(amount, 1, 1e27); // Clamp to valid range
    // Test logic
}
```

#### Invariant Tests
- Properties that must hold after any sequence of calls
- Use handler pattern for stateful contracts
- Ghost variables track expected state

```solidity
function invariant_totalSupplyMatchesBalances() public view {
    assertEq(token.totalSupply(), handler.ghost_totalMinted());
}
```

### 3. Security Patterns

#### Checks-Effects-Interactions (CEI)
```solidity
function withdraw() external {
    // 1. CHECKS
    uint256 balance = balances[msg.sender];
    require(balance > 0, "No balance");
    
    // 2. EFFECTS
    balances[msg.sender] = 0;
    
    // 3. INTERACTIONS (last)
    (bool success,) = msg.sender.call{value: balance}("");
    require(success, "Transfer failed");
}
```

#### Reentrancy Guard
```solidity
bool private locked;

modifier nonReentrant() {
    require(!locked, "Reentrant call");
    locked = true;
    _;
    locked = false;
}
```

#### Access Control
```solidity
address public owner;

modifier onlyOwner() {
    require(msg.sender == owner, "Not owner");
    _;
}
```

## Gas Optimization Patterns

### 1. Constants vs Storage
- `constant`: ~3 gas (embedded in bytecode)
- `immutable`: ~3 gas (set in constructor)
- Storage read: ~100-2100 gas

### 2. Calldata vs Memory
```solidity
// Cheaper for external functions
function process(bytes calldata data) external;

// More expensive (copy to memory)
function process(bytes memory data) public;
```

### 3. Packing Variables
```solidity
// Packed into single storage slot
uint128 public balance;
uint128 public allowance;
```

## EVM Assembly (Yul) Patterns

### Basic Arithmetic with Overflow Checks
```solidity
function addAssembly(uint256 x, uint256 y) external pure returns (uint256 result) {
    assembly {
        result := add(x, y)
        if lt(result, x) { revert(0, 0) } // Overflow check
    }
}
```

### Binary Exponentiation
```solidity
function powAssembly(uint256 base, uint256 exponent) external pure returns (uint256 result) {
    assembly {
        result := 1
        for { } gt(exponent, 0) { } {
            if and(exponent, 1) {
                result := mul(result, base)
            }
            base := mul(base, base)
            exponent := shr(1, exponent)
        }
    }
}
```

## Docker Environment

### Container Design
- Base: Ubuntu 22.04
- Tools: Foundry (forge, cast, anvil, chisel), Node.js 20
- Volume mounting for live code editing
- Persistent volume for Foundry cache

### Usage Flow
```bash
# Build and start
docker compose up -d

# Enter container
docker compose exec dojo bash

# Run tests
forge test

# Format code
forge fmt

# Check gas
forge test --gas-report
```

## Dependencies

### Foundry Standard Library (forge-std)
- Location: `lib/forge-std`
- Provides: Test utilities, cheatcodes (`vm.*`)
- Key features:
  - `vm.prank()` - impersonate addresses
  - `vm.warp()` - manipulate block.timestamp
  - `vm.roll()` - manipulate block.number
  - `vm.expectRevert()` - test revert conditions
  - `vm.expectEmit()` - test event emissions

## Configuration

### foundry.toml
```toml
[profile.default]
src     = "src"
out     = "out"
libs    = ["lib"]
solc    = "0.8.26"

[fuzz]
runs = 256

[invariant]
runs  = 64
depth = 32
```

## NatSpec Standards

All contracts must include:

```solidity
/// @title ContractName
/// @notice Plain English description for end users
/// @dev Technical notes for developers

/// @notice State variable description
/// @dev Implementation details

/// @notice Function description
/// @dev Implementation notes, security considerations
/// @param name Parameter description with units if applicable
/// @return Description of return value

/// @notice Event description
/// @param name Parameter description

/// @notice Error description
/// @param name Parameter description
```

## Security Considerations

### Known Vulnerabilities Demonstrated
1. **Reentrancy** - External call before state update
2. **Integer Overflow** - Pre-0.8.0 Solidity
3. **Access Control** - tx.origin vs msg.sender
4. **Oracle Manipulation** - Price feed attacks
5. **Front-running** - Transaction ordering attacks

### Testing for Security
- Reentrancy tests with attacker contracts
- Fuzzing to find edge cases
- Invariant tests for state consistency
- Gas profiling to prevent DoS

## Future Enhancements

### Planned Features
1. CI/CD pipeline for automated testing
2. Gas snapshot tracking
3. Coverage reports
4. Slither integration for static analysis
5. Documentation generation from NatSpec

### Scalability
- Modular contract design
- Reusable test utilities
- Clear separation of concerns
- Upgradeable proxy patterns (for applicable contracts)
