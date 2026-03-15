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

### ✅ Phase 6: Applications Section (18/18 COMPLETE)
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
- [x] **ERC1155Token** - multi-token standard, batch transfers *(NEW)*
- [x] **ERC20Permit** - gasless approvals via EIP-2612 *(NEW)*
- [x] **WriteToAnySlot** - assembly sstore/sload to arbitrary slots *(NEW)*
- [x] **SimpleBytecodeContract** - deploy via raw bytecode (CREATE opcode) *(NEW)*
- [x] **PaymentChannel** - off-chain payment channels with signatures *(NEW)*
- [x] **MerkleAirdrop** - merkle proof-based token airdrop *(NEW)*

### ✅ Phase 7: DeFi Section (16/16 COMPLETE)
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
- [x] **ConstantSumAMM** - x+y=k AMM for same-price tokens *(NEW)*
- [x] **StableSwapAMM** - Curve-style StableSwap invariant *(NEW)*
- [x] **TokenLocker** - time-locked token vesting *(NEW)*
- [x] **DiscreteStakingRewards** - discrete per-notification reward distribution *(NEW)*

### ✅ Phase 8: Hacks Section (20/20 COMPLETE)
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
- [x] **ArithmeticOverflow** - pre-0.8 overflow behavior vs. 0.8+ safe math *(NEW)*
- [x] **Honeypot** - deceptive contracts that trap user funds *(NEW)*
- [x] **HidingMaliciousCode** - hiding malicious logic via external contracts *(NEW)*
- [x] **BypassContractSize** - bypassing extcodesize check via constructor *(NEW)*
- [x] **DeployDifferentContract** - CREATE2 + selfdestruct address swap *(NEW)*
- [x] **WETHPermitAttack** - WETH permit griefing vulnerability *(NEW)*
- [x] **SixtyThreeOver64Rule** - EIP-150 gas forwarding rule exploitation *(NEW)*

### ✅ Phase 9: EVM Section (10/10 COMPLETE)
- [x] AssemblyVariable - Yul variables
- [x] AssemblyConditionals - Yul if/switch
- [x] AssemblyLoop - Yul loops
- [x] AssemblyBinaryExponentiation - efficient pow
- [x] AssemblyArray - Yul arrays
- [x] BitwiseOperators - bit manipulation
- [x] AssemblyMathExercise - math operations
- [x] **StorageLayout** - slot packing, dynamic arrays, mappings storage locations *(NEW)*
- [x] **MemoryLayout** - memory layout, free memory pointer, ABI encoding *(NEW)*

## Test Results

Last run: 2026-03-15 (feature/missing-concepts branch)

```
New contracts: 19
New tests: 201 (all passing)
Total tests: 922 (908 passing, 14 pre-existing Uniswap integration failures)

All new contracts compile and pass tests via Docker:
  docker compose exec dojo forge test
```

## Documentation

- [x] **Concepts Guide**: [`CONCEPTS.md`](CONCEPTS.md) — Solidity by Example-style reference for all 109 concepts

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

## Topics Added (2026-03-15)

19 new topics filling the remaining gaps from Solidity by Example:

| # | Topic | Section | What it teaches |
|---|-------|---------|-----------------|
| 1 | ERC1155Token | Applications | Multi-token standard, batch transfers, balanceOfBatch |
| 2 | ERC20Permit | Applications | Gasless approvals via EIP-2612 signatures |
| 3 | WriteToAnySlot | Applications | Assembly sstore/sload to arbitrary storage slots |
| 4 | SimpleBytecodeContract | Applications | Deploy contracts via raw bytecode (CREATE opcode) |
| 5 | PaymentChannel | Applications | Off-chain payment channels with signature verification |
| 6 | MerkleAirdrop | Applications | Merkle proof-based token airdrop |
| 7 | ConstantSumAMM | DeFi | x+y=k AMM (simplest AMM, no slippage) |
| 8 | StableSwapAMM | DeFi | Curve-style StableSwap invariant |
| 9 | TokenLocker | DeFi | Time-locked token vesting |
| 10 | DiscreteStakingRewards | DeFi | Discrete (per-notification) reward distribution |
| 11 | ArithmeticOverflow | Hacks | Pre-0.8 overflow (why 0.8 defaults matter) |
| 12 | Honeypot | Hacks | Deceptive contracts that trap users |
| 13 | HidingMaliciousCode | Hacks | Hiding malicious logic via external contracts |
| 14 | BypassContractSize | Hacks | Bypassing extcodesize check via constructor |
| 15 | DeployDifferentContract | Hacks | CREATE2 + selfdestruct to swap contract at same address |
| 16 | WETHPermitAttack | Hacks | WETH permit griefing vulnerability |
| 17 | SixtyThreeOver64Rule | Hacks | EIP-150 gas forwarding rule exploitation |
| 18 | StorageLayout | EVM | Slot packing, dynamic arrays, mappings storage locations |
| 19 | MemoryLayout | EVM | Memory layout, free memory pointer, ABI encoding in memory |

## Remaining Gaps

**Foundry:** Cheatcode tutorials (vm.prank, vm.warp, vm.expectRevert, vm.sign, etc.) — these are tool docs, not Solidity concepts. Skipped intentionally.

## Estimated Completion

- Current: 109 topics implemented (up from 90)
- New test count: 201 additional tests
- Total tests: 922 (908 passing, 14 pre-existing Uniswap integration failures)
- All Basic, Applications, DeFi (non-Uniswap), Hacks, and EVM: 100% passing
