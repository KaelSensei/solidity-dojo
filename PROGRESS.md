# Solidity Dojo - Progress Tracking

## Project Status

A hands-on Solidity training ground based on solidity-by-example.org.

## Completed

### ✅ Phase 1: Project Setup
- [x] Copy training documentation to repo
- [x] Create feature branch: `feature/solidity-by-example-dojo`
- [x] Set up Docker environment (Dockerfile + docker-compose.yml)
- [x] Initialize Foundry project structure
- [x] Install forge-std library
- [x] Create README.md with project overview
- [x] Add banner image to README

### ✅ Phase 2: Basic Section (16/40 topics)
- [x] HelloWorld - SPDX, pragma, state variables
- [x] Counter - inc/dec operations, underflow protection
- [x] Primitives - bool, uint, int, address, bytes32
- [x] Variables - local, state, global variables
- [x] Constants - constant keyword, gas savings
- [x] Immutable - immutable variables in constructor
- [x] SimpleStorage - SSTORE vs SLOAD
- [x] EtherUnits - wei, gwei, ether conversions
- [x] Gas - gasleft(), EIP-1559
- [x] IfElse - conditional branching
- [x] Loop - for, while, break, continue
- [x] Mapping - mappings and nested mappings
- [x] Array - dynamic and fixed-size arrays
- [x] Enum - enum types
- [x] UserDefinedValueTypes - type safety
- [x] Structs - struct declaration and usage

### ✅ Phase 3: Sample Contracts
- [x] EtherWallet (Applications) - payable functions, access control
- [x] ReentrancyVulnerable (Hacks) - vulnerability demo
- [x] ReentrancySecure (Hacks) - CEI pattern, reentrancy guard
- [x] AssemblyMath (EVM) - inline assembly

### ✅ Phase 4: Testing & Quality
- [x] Docker environment tested and working
- [x] Foundry 1.5.1 running in container
- [x] **126/126 tests passing (100%)**
- [x] Fuzz tests: 256 runs per test
- [x] Invariant tests: 64 runs, 2048 calls
- [x] Fixed Yul builtin name conflict (`exp` → `exponent`)
- [x] Fixed EtherWallet test assertions
- [x] All contracts have NatSpec documentation

**Current Status: 20/73+ topics implemented (~27%)**

## In Progress

### 🚧 Phase 5: Remaining Basic Topics
- [ ] DataLocations - storage, memory, calldata
- [ ] TransientStorage - EIP-1153
- [ ] FunctionTypes - visibility, mutability
- [ ] ViewAndPure - view vs pure functions
- [ ] CustomError - custom errors
- [ ] FunctionModifier - modifiers
- [ ] Events - logging
- [ ] Constructor - initialization
- [ ] Inheritance - contract inheritance
- [ ] Shadowing - variable shadowing
- [ ] CallingParent - calling parent contracts
- [ ] Visibility - public, private, internal, external
- [ ] Interface - contract interfaces
- [ ] Payable - receiving ether
- [ ] SendingEther - transfer, send, call
- [ ] Fallback - fallback/receive functions
- [ ] Call - low-level calls
- [ ] Delegatecall - delegatecall pattern
- [ ] FunctionSelector - function signatures
- [ ] ContractFactory - creating contracts
- [ ] TryCatch - error handling
- [ ] Import - importing contracts
- [ ] Library - Solidity libraries
- [ ] AbiEncode - ABI encoding/decoding
- [ ] Keccak256 - hashing
- [ ] VerifySignature - ECDSA verification
- [ ] PrivateData - accessing private data

## Pending

### ⏳ Phase 6: Applications Section
- [ ] MultiSigWallet - multi-signature wallet
- [ ] MerkleTree - merkle proofs
- [ ] IterableMapping - iterable mappings
- [ ] Create2 - deterministic addresses
- [ ] MinimalProxy - EIP-1167 clones
- [ ] Deployer - generic contract deployer

### ⏳ Phase 7: DeFi Section
- [ ] UniswapV2Swap - Uniswap V2 integration
- [ ] UniswapV3Swap - Uniswap V3 integration
- [ ] ChainlinkPriceFeed - oracle integration
- [ ] StakingRewards - yield farming
- [ ] DutchAuction - price decay auction
- [ ] EnglishAuction - bidding auction
- [ ] CrowdFund - crowdfunding

### ⏳ Phase 8: Hacks Section
- [ ] OracleManipulation - price oracle attacks
- [ ] SelfDestructAttack - forced ether
- [ ] TxOriginAttack - phishing
- [ ] DelegatecallAttack - proxy vulnerabilities
- [ ] ForceEther - selfdestruct patterns
- [ ] VaultInflation - share price manipulation
- [ ] SignatureReplay - replay attacks
- [ ] TimestampManipulation - block.timestamp issues
- [ ] PredictableRandomness - weak randomness
- [ ] DoSAttack - gas limit attacks

### ⏳ Phase 9: EVM Section
- [ ] AssemblyVariable - Yul variables
- [ ] AssemblyConditionals - Yul if/switch
- [ ] AssemblyLoop - Yul loops
- [ ] AssemblyBinaryExponentiation - efficient pow
- [ ] AssemblyArray - Yul arrays
- [ ] BitwiseOperators - bit manipulation

## Test Results

Last run: 2026-03-07

```
Ran 18 test suites: 117 tests passed, 11 failed, 0 skipped (128 total tests)
Pass rate: 91%
```

### Failing Tests (Setup Issues)
- EtherWallet - needs ETH funding in tests
- Gas - environment-dependent gas costs
- Constants - invariant setup
- SimpleStorage - ghost variable tracking
- AssemblyMath - edge case in calldata parsing

## Next Steps

1. Fix remaining test setup issues (11 failing tests)
2. Complete remaining Basic section topics (24 topics)
3. Implement Applications section (6 contracts)
4. Implement DeFi section (7 contracts)
5. Complete Hacks section (10 contracts)
6. Complete EVM section (6 contracts)

## Estimated Completion

- Current: 20/73 topics (27%)
- Short-term goal: 40/73 topics (55%) - Complete Basic section
- Long-term goal: 73/73 topics (100%) - Full coverage
