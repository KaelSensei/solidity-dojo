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
- [x] Fuzz tests: 256 runs per test
- [x] Invariant tests: 64 runs, 2048 calls
- [x] All contracts have NatSpec documentation

### ✅ Phase 5: Remaining Basic Topics (29/29 COMPLETE)
- [x] DataLocations - storage, memory, calldata
- [x] TransientStorage - EIP-1153
- [x] FunctionTypes - visibility, mutability
- [x] ViewAndPure - view vs pure functions
- [x] CustomError - custom errors
- [x] FunctionModifier - modifiers
- [x] Events - logging
- [x] Constructor - initialization
- [x] Inheritance - contract inheritance
- [x] Shadowing - variable shadowing
- [x] CallingParent - calling parent contracts
- [x] Visibility - public, private, internal, external
- [x] Interface - contract interfaces
- [x] Payable - receiving ether
- [x] SendingEther - transfer, send, call
- [x] Fallback - fallback/receive functions
- [x] Call - low-level calls
- [x] Delegatecall - delegatecall pattern
- [x] FunctionSelector - function signatures
- [x] ContractFactory - creating contracts
- [x] TryCatch - error handling
- [x] Import - importing contracts
- [x] Library - Solidity libraries
- [x] AbiEncode - ABI encoding/decoding
- [x] Keccak256 - hashing
- [x] VerifySignature - ECDSA verification
- [x] PrivateData - accessing private data
- [x] **UncheckedMath** - unchecked blocks, overflow wrapping, gas-efficient loops *(NEW)*
- [x] **GasGolf** - side-by-side gas optimization comparison *(NEW)*

### ✅ Phase 6: Applications Section (11/11 COMPLETE)
- [x] MultiSigWallet - multi-signature wallet
- [x] MerkleTree - merkle proofs
- [x] IterableMapping - iterable mappings
- [x] Create2 - deterministic addresses
- [x] MinimalProxy - EIP-1167 clones
- [x] Deployer - generic contract deployer
- [x] **ERC20Token** - full ERC20 implementation from scratch *(NEW)*
- [x] **ERC721Token** - full ERC721 (NFT) implementation from scratch *(NEW)*
- [x] **MultiCall** - batch multiple calls into one transaction *(NEW)*
- [x] **TimeLock** - timelock controller for delayed execution *(NEW)*
- [x] **UpgradeableProxy** - EIP-1967 transparent upgradeable proxy *(NEW)*

### ✅ Phase 7: DeFi Section (10/10 COMPLETE)
- [x] UniswapV2Swap - Uniswap V2 integration
- [x] UniswapV3Swap - Uniswap V3 integration
- [x] UniswapV4Swap - Uniswap V4 integration
- [x] UniswapV4FlashLoan - flash loan pattern
- [x] UniswapV4LimitOrder - limit order hook
- [x] ChainlinkPriceFeed - oracle integration
- [x] StakingRewards - yield farming
- [x] DutchAuction - price decay auction
- [x] EnglishAuction - bidding auction
- [x] CrowdFund - crowdfunding
- [x] **Vault** - ERC4626-style deposit vault with inflation protection *(NEW)*
- [x] **ConstantProductAMM** - x*y=k AMM with 0.3% fee (Uniswap V1/V2 core) *(NEW)*

### ✅ Phase 8: Hacks Section (11/11 COMPLETE)
- [x] OracleManipulation - price oracle attacks
- [x] SelfDestructAttack - forced ether
- [x] TxOriginAttack - phishing
- [x] DelegatecallAttack - proxy vulnerabilities
- [x] ForceEther - selfdestruct patterns
- [x] VaultInflation - share price manipulation
- [x] SignatureReplay - replay attacks
- [x] TimestampManipulation - block.timestamp issues
- [x] PredictableRandomness - weak randomness
- [x] DoSAttack - gas limit attacks
- [x] **FrontRunning** - mempool front-running + commit-reveal protection *(NEW)*

### ✅ Phase 9: EVM Section
- [x] AssemblyVariable - Yul variables
- [x] AssemblyConditionals - Yul if/switch
- [x] AssemblyLoop - Yul loops
- [x] AssemblyBinaryExponentiation - efficient pow
- [x] AssemblyArray - Yul arrays
- [x] BitwiseOperators - bit manipulation
- [x] AssemblyMathExercise - math operations

## Test Results

Last run: 2026-03-09

```
Total: 722 tests
Passing: 655 (90.7%)
Failing: 67 (9.3%)

Failing tests breakdown:
- EVM Section: ~40 failing (Yul overflow/underflow edge cases, assembly logic)
- DeFi Section: ~27 failing (Uniswap V2/V3/V4, StakingRewards edge cases)
- All Basic, Applications, and Hacks sections: 100% passing

New contracts (Phase 10): 92/92 tests passing (100%)
```

## Documentation

- [x] **Concepts Guide**: [`CONCEPTS.md`](CONCEPTS.md) — Solidity by Example-style reference for all concepts in this dojo

## Topics Added (2026-03-09)

10 new topics were identified as missing from the curriculum compared to Solidity by Example:

| # | Topic | Section | What it teaches |
|---|-------|---------|-----------------|
| 1 | UncheckedMath | Basic | `unchecked` blocks, overflow wrapping, gas comparison |
| 2 | GasGolf | Basic | Side-by-side gas optimization (calldata, caching, unchecked) |
| 3 | ERC20Token | Applications | Full ERC20 from scratch — transfer, approve, mint, burn |
| 4 | ERC721Token | Applications | Full ERC721 from scratch — NFT, safeTransfer, ERC165 |
| 5 | MultiCall | Applications | Batch calls to save 21k gas per tx |
| 6 | TimeLock | Applications | Governance timelock — queue, delay, execute, cancel |
| 7 | UpgradeableProxy | Applications | EIP-1967 proxy, delegatecall, storage persistence |
| 8 | Vault | DeFi | ERC4626-style shares/assets math, inflation protection |
| 9 | ConstantProductAMM | DeFi | x*y=k AMM, LP shares, swap fees, sqrt |
| 10 | FrontRunning | Hacks | Mempool front-running + commit-reveal countermeasure |

## Remaining Gaps (for future phases)

Topics from Solidity by Example not yet covered:

**Applications:** ERC1155, Gasless Token Transfer (ERC20Permit), Simple Bytecode Contract, Write to Any Slot, Payment Channels, Merkle Airdrop

**DeFi:** Constant Sum AMM, Stable Swap AMM, Token Lock, Discrete Staking Rewards

**Hacks:** Arithmetic Overflow (pre-0.8), Honeypot, Hiding Malicious Code, Bypass Contract Size Check, Deploy Different Contracts at Same Address, WETH Permit, 63/64 Gas Rule

**EVM:** Storage Layout deep dive, Memory Layout deep dive

**Foundry:** Cheatcode tutorials (vm.prank, vm.warp, vm.expectRevert, vm.sign, etc.)

## Estimated Completion

- Current: 83 topics implemented
- Test coverage: 655/722 tests passing (90.7%)
- All Basic, Applications, and Hacks: 100% passing
