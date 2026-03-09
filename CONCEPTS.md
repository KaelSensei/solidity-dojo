# Solidity Concepts — By Example

> A guided reference for every Solidity concept in this dojo.
> Each entry explains what the concept is, why it matters, shows a code snippet from our repo, and links to the contract + its tests.
>
> Inspired by [solidity-by-example.org](https://solidity-by-example.org).

**Solidity version:** `^0.8.26` · **Tooling:** Foundry (Forge)

**Last updated:** 2026-03-09

---

## Table of Contents

### Basic

| # | Concept | Contract | Tests |
|---|---------|----------|-------|
| 1 | [Hello World](#1-hello-world) | `src/basic/HelloWorld.sol` | `test/basic/HelloWorld.t.sol` |
| 2 | [First App (Counter)](#2-first-app-counter) | `src/basic/Counter.sol` | `test/basic/Counter.t.sol` |
| 3 | [Primitive Data Types](#3-primitive-data-types) | `src/basic/Primitives.sol` | `test/basic/Primitives.t.sol` |
| 4 | [Variables](#4-variables) | `src/basic/Variables.sol` | `test/basic/Variables.t.sol` |
| 5 | [Constants](#5-constants) | `src/basic/Constants.sol` | `test/basic/Constants.t.sol` |
| 6 | [Immutable](#6-immutable) | `src/basic/Immutable.sol` | `test/basic/Immutable.t.sol` |
| 7 | [Reading and Writing State](#7-reading-and-writing-state) | `src/basic/SimpleStorage.sol` | `test/basic/SimpleStorage.t.sol` |
| 8 | [Ether and Wei](#8-ether-and-wei) | `src/basic/EtherUnits.sol` | `test/basic/EtherUnits.t.sol` |
| 9 | [Gas and Gas Price](#9-gas-and-gas-price) | `src/basic/Gas.sol` | `test/basic/Gas.t.sol` |
| 10 | [If / Else](#10-if--else) | `src/basic/IfElse.sol` | `test/basic/IfElse.t.sol` |
| 11 | [For and While Loop](#11-for-and-while-loop) | `src/basic/Loop.sol` | `test/basic/Loop.t.sol` |
| 12 | [Mapping](#12-mapping) | `src/basic/Mapping.sol` | `test/basic/Mapping.t.sol` |
| 13 | [Array](#13-array) | `src/basic/Array.sol` | `test/basic/Array.t.sol` |
| 14 | [Enum](#14-enum) | `src/basic/Enum.sol` | `test/basic/Enum.t.sol` |
| 15 | [User Defined Value Types](#15-user-defined-value-types) | `src/basic/UserDefinedValueTypes.sol` | `test/basic/UserDefinedValueTypes.t.sol` |
| 16 | [Structs](#16-structs) | `src/basic/Structs.sol` | `test/basic/Structs.t.sol` |
| 17 | [Data Locations](#17-data-locations) | `src/basic/DataLocations.sol` | `test/basic/DataLocations.t.sol` |
| 18 | [Transient Storage](#18-transient-storage) | `src/basic/TransientStorage.sol` | `test/basic/TransientStorage.t.sol` |
| 19 | [Function Types](#19-function-types) | `src/basic/FunctionTypes.sol` | `test/basic/FunctionTypes.t.sol` |
| 20 | [View and Pure Functions](#20-view-and-pure-functions) | `src/basic/ViewAndPure.sol` | `test/basic/ViewAndPure.t.sol` |
| 21 | [Custom Errors](#21-custom-errors) | `src/basic/CustomError.sol` | `test/basic/CustomError.t.sol` |
| 22 | [Function Modifier](#22-function-modifier) | `src/basic/FunctionModifier.sol` | `test/basic/FunctionModifier.t.sol` |
| 23 | [Events](#23-events) | `src/basic/Events.sol` | `test/basic/Events.t.sol` |
| 24 | [Constructor](#24-constructor) | `src/basic/Constructor.sol` | `test/basic/Constructor.t.sol` |
| 25 | [Inheritance](#25-inheritance) | `src/basic/Inheritance.sol` | `test/basic/Inheritance.t.sol` |
| 26 | [Shadowing Inherited State Variables](#26-shadowing-inherited-state-variables) | `src/basic/Shadowing.sol` | `test/basic/Shadowing.t.sol` |
| 27 | [Calling Parent Contracts](#27-calling-parent-contracts) | `src/basic/CallingParent.sol` | `test/basic/CallingParent.t.sol` |
| 28 | [Visibility](#28-visibility) | `src/basic/Visibility.sol` | `test/basic/Visibility.t.sol` |
| 29 | [Interface](#29-interface) | `src/basic/Interface.sol` | `test/basic/Interface.t.sol` |
| 30 | [Payable](#30-payable) | `src/basic/Payable.sol` | `test/basic/Payable.t.sol` |
| 31 | [Sending Ether](#31-sending-ether) | `src/basic/SendingEther.sol` | `test/basic/SendingEther.t.sol` |
| 32 | [Fallback](#32-fallback) | `src/basic/Fallback.sol` | `test/basic/Fallback.t.sol` |
| 33 | [Delegatecall](#33-delegatecall) | `src/basic/Delegatecall.sol` | `test/basic/Delegatecall.t.sol` |
| 34 | [Function Selector](#34-function-selector) | `src/basic/FunctionSelector.sol` | `test/basic/FunctionSelector.t.sol` |
| 35 | [Contract Factory](#35-contract-factory) | `src/basic/ContractFactory.sol` | `test/basic/ContractFactory.t.sol` |
| 36 | [Try / Catch](#36-try--catch) | `src/basic/TryCatch.sol` | `test/basic/TryCatch.t.sol` |
| 37 | [Import](#37-import) | `src/basic/Import.sol` | `test/basic/Import.t.sol` |
| 38 | [Library](#38-library) | `src/basic/Library.sol` | `test/basic/Library.t.sol` |
| 39 | [ABI Encode and Decode](#39-abi-encode-and-decode) | `src/basic/AbiEncode.sol` | `test/basic/AbiEncode.t.sol` |
| 40 | [Keccak256](#40-keccak256) | `src/basic/Keccak256.sol` | `test/basic/Keccak256.t.sol` |
| 41 | [Verify Signature](#41-verify-signature) | `src/basic/VerifySignature.sol` | `test/basic/VerifySignature.t.sol` |
| 42 | [Accessing Private Data](#42-accessing-private-data) | `src/basic/PrivateData.sol` | `test/basic/PrivateData.t.sol` |

### Applications

| # | Concept | Contract | Tests |
|---|---------|----------|-------|
| 43 | [Ether Wallet](#43-ether-wallet) | `src/applications/EtherWallet.sol` | `test/applications/EtherWallet.t.sol` |
| 44 | [Multi-Sig Wallet](#44-multi-sig-wallet) | `src/applications/MultiSigWallet.sol` | `test/applications/MultiSigWallet.t.sol` |
| 45 | [Merkle Tree](#45-merkle-tree) | `src/applications/MerkleTree.sol` | `test/applications/MerkleTree.t.sol` |
| 46 | [Iterable Mapping](#46-iterable-mapping) | `src/applications/IterableMapping.sol` | `test/applications/IterableMapping.t.sol` |
| 47 | [CREATE2](#47-create2) | `src/applications/Create2.sol` | `test/applications/Create2.t.sol` |
| 48 | [Minimal Proxy (EIP-1167)](#48-minimal-proxy-eip-1167) | `src/applications/MinimalProxy.sol` | `test/applications/MinimalProxy.t.sol` |
| 49 | [Deploy Any Contract](#49-deploy-any-contract) | `src/applications/Deployer.sol` | `test/applications/Deployer.t.sol` |

### DeFi

| # | Concept | Contract | Tests |
|---|---------|----------|-------|
| 50 | [Uniswap V2 Swap](#50-uniswap-v2-swap) | `src/defi/UniswapV2Swap.sol` | `test/defi/UniswapV2Swap.t.sol` |
| 51 | [Uniswap V3 Swap](#51-uniswap-v3-swap) | `src/defi/UniswapV3Swap.sol` | `test/defi/UniswapV3Swap.t.sol` |
| 52 | [Uniswap V4 Swap](#52-uniswap-v4-swap) | `src/defi/UniswapV4Swap.sol` | `test/defi/UniswapV4Swap.t.sol` |
| 53 | [Uniswap V4 Flash Loan](#53-uniswap-v4-flash-loan) | `src/defi/UniswapV4FlashLoan.sol` | `test/defi/UniswapV4FlashLoan.t.sol` |
| 54 | [Uniswap V4 Limit Order](#54-uniswap-v4-limit-order) | `src/defi/UniswapV4LimitOrder.sol` | `test/defi/UniswapV4LimitOrder.t.sol` |
| 55 | [Chainlink Price Feed](#55-chainlink-price-feed) | `src/defi/ChainlinkPriceFeed.sol` | `test/defi/ChainlinkPriceFeed.t.sol` |
| 56 | [Staking Rewards](#56-staking-rewards) | `src/defi/StakingRewards.sol` | `test/defi/StakingRewards.t.sol` |
| 57 | [Dutch Auction](#57-dutch-auction) | `src/defi/DutchAuction.sol` | `test/defi/DutchAuction.t.sol` |
| 58 | [English Auction](#58-english-auction) | `src/defi/EnglishAuction.sol` | `test/defi/EnglishAuction.t.sol` |
| 59 | [Crowd Fund](#59-crowd-fund) | `src/defi/CrowdFund.sol` | `test/defi/CrowdFund.t.sol` |

### Hacks & Security

| # | Concept | Contract | Tests |
|---|---------|----------|-------|
| 60 | [Reentrancy Attack](#60-reentrancy-attack) | `src/hacks/ReentrancyVulnerable.sol` | `test/hacks/DelegatecallAttack.t.sol` |
| 61 | [Reentrancy — Secure](#61-reentrancy--secure) | `src/hacks/ReentrancySecure.sol` | — |
| 62 | [Delegatecall Attack](#62-delegatecall-attack) | `src/hacks/DelegatecallAttack.sol` | `test/hacks/DelegatecallAttack.t.sol` |
| 63 | [Self Destruct Attack](#63-self-destruct-attack) | `src/hacks/SelfDestructAttack.sol` | `test/hacks/SelfDestructAttack.t.sol` |
| 64 | [Force Ether](#64-force-ether) | `src/hacks/ForceEther.sol` | `test/hacks/ForceEther.t.sol` |
| 65 | [tx.origin Phishing](#65-txorigin-phishing) | `src/hacks/TxOriginAttack.sol` | `test/hacks/TxOriginAttack.t.sol` |
| 66 | [Oracle Manipulation](#66-oracle-manipulation) | `src/hacks/OracleManipulation.sol` | `test/hacks/OracleManipulation.t.sol` |
| 67 | [Signature Replay](#67-signature-replay) | `src/hacks/SignatureReplay.sol` | `test/hacks/SignatureReplay.t.sol` |
| 68 | [Timestamp Manipulation](#68-timestamp-manipulation) | `src/hacks/TimestampManipulation.sol` | `test/hacks/TimestampManipulation.t.sol` |
| 69 | [Predictable Randomness](#69-predictable-randomness) | `src/hacks/PredictableRandomness.sol` | `test/hacks/PredictableRandomness.t.sol` |
| 70 | [Denial of Service (DoS)](#70-denial-of-service-dos) | `src/hacks/DoSAttack.sol` | `test/hacks/DoSAttack.t.sol` |
| 71 | [Vault Inflation Attack](#71-vault-inflation-attack) | `src/hacks/VaultInflation.sol` | `test/hacks/VaultInflation.t.sol` |

### EVM / Assembly (Yul)

| # | Concept | Contract | Tests |
|---|---------|----------|-------|
| 72 | [Assembly Variables](#72-assembly-variables) | `src/evm/AssemblyVariable.sol` | `test/evm/AssemblyVariable.t.sol` |
| 73 | [Assembly Math](#73-assembly-math) | `src/evm/AssemblyMath.sol` | `test/evm/AssemblyMath.t.sol` |
| 74 | [Assembly Conditionals](#74-assembly-conditionals) | `src/evm/AssemblyConditionals.sol` | `test/evm/AssemblyConditionals.t.sol` |
| 75 | [Assembly Loops](#75-assembly-loops) | `src/evm/AssemblyLoop.sol` | `test/evm/AssemblyLoop.t.sol` |
| 76 | [Assembly Math Exercise](#76-assembly-math-exercise) | `src/evm/AssemblyMathExercise.sol` | `test/evm/AssemblyMathExercise.t.sol` |
| 77 | [Assembly Binary Exponentiation](#77-assembly-binary-exponentiation) | `src/evm/AssemblyBinaryExponentiation.sol` | `test/evm/AssemblyBinaryExponentiation.t.sol` |
| 78 | [Assembly Arrays](#78-assembly-arrays) | `src/evm/AssemblyArray.sol` | `test/evm/AssemblyArray.t.sol` |
| 79 | [Bitwise Operators](#79-bitwise-operators) | `src/evm/BitwiseOperators.sol` | `test/evm/BitwiseOperators.t.sol` |

---

## Basic

---

### 1. Hello World

**What you learn:** SPDX license identifier, `pragma solidity`, contract declaration, `public` state variable with auto-generated getter.

Solidity requires an **SPDX license identifier** at the top of every file. The `pragma` line pins the compiler version. A `public` state variable automatically generates a getter function.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract HelloWorld {
    string public greet = "Hello World";
}
```

**Why it matters:** The `public` keyword auto-generates a getter, saving you from writing one manually. Pinning the compiler version prevents unexpected behavior from future compiler changes.

| Source | Tests |
|--------|-------|
| [`src/basic/HelloWorld.sol`](src/basic/HelloWorld.sol) | [`test/basic/HelloWorld.t.sol`](test/basic/HelloWorld.t.sol) |

---

### 2. First App (Counter)

**What you learn:** Reading and writing state variables, increment/decrement, underflow protection.

A simple counter with `inc()` and `dec()`. In Solidity 0.8+, arithmetic operations **automatically revert on overflow/underflow**.

```solidity
contract Counter {
    uint256 public count;

    function inc() external { ++count; }
    function dec() external { --count; } // reverts if count == 0
    function get() external view returns (uint256) { return count; }
}
```

**Why it matters:** Solidity 0.8+ includes built-in overflow/underflow protection. Calling `dec()` when `count == 0` will revert with a panic code — no more silent wrapping.

| Source | Tests |
|--------|-------|
| [`src/basic/Counter.sol`](src/basic/Counter.sol) | [`test/basic/Counter.t.sol`](test/basic/Counter.t.sol) |

---

### 3. Primitive Data Types

**What you learn:** `bool`, `uint`, `int`, `address`, `bytes32`, and their default values.

Every variable in Solidity has a **default value** when uninitialized.

```solidity
contract Primitives {
    bool public boo = false;           // default: false
    uint256 public u256 = 0;           // default: 0
    int256 public i256 = 0;            // default: 0
    address public addr = address(0);  // default: 0x0000...0000
    bytes32 public b32 = bytes32(0);   // default: 32 zero bytes
}
```

**Why it matters:** Understanding default values prevents bugs. Checking `addr != address(0)` is a common pattern to verify a variable was set. `address` is 20 bytes (from truncated Keccak-256 hash).

| Source | Tests |
|--------|-------|
| [`src/basic/Primitives.sol`](src/basic/Primitives.sol) | [`test/basic/Primitives.t.sol`](test/basic/Primitives.t.sol) |

---

### 4. Variables

**What you learn:** Three types of variables — **local** (stack/memory), **state** (storage), and **global** (EVM-provided: `msg.sender`, `block.timestamp`, etc.).

```solidity
contract Variables {
    uint256 public stateVar = 123;      // state: stored on-chain

    function getGlobalVars() external view returns (
        address sender, uint256 timestamp, uint256 blockNum, uint256 chainId
    ) {
        uint256 localVar = 456;         // local: exists only during execution
        sender    = msg.sender;         // global: who called this function
        timestamp = block.timestamp;    // global: current block time
        blockNum  = block.number;       // global: current block number
        chainId   = block.chainid;      // global: network chain ID
    }
}
```

**Why it matters:** State variables cost gas to read (~2100 gas cold SLOAD) and write (~5000+ gas SSTORE). Local variables are cheap (stack). Global variables are EVM builtins available everywhere.

| Source | Tests |
|--------|-------|
| [`src/basic/Variables.sol`](src/basic/Variables.sol) | [`test/basic/Variables.t.sol`](test/basic/Variables.t.sol) |

---

### 5. Constants

**What you learn:** The `constant` keyword, compile-time values embedded in bytecode, gas savings vs storage reads.

```solidity
contract Constants {
    address public constant MY_ADDRESS = 0x777788889999AaAAbBbbCcccddDdeeeEfFFfCcCc;
    uint256 public constant MY_UINT = 123;
    uint256 public constant BASIS_POINTS = 10000;

    function getConstant() external pure returns (uint256) {
        return MY_UINT; // ~3 gas (PUSH32) vs ~2100 gas (cold SLOAD)
    }
}
```

**Why it matters:** Constants are replaced by their value at compile time. Reading a constant costs **~3 gas** vs **~2100 gas** for a cold storage read. Use `constant` for values that never change.

| Source | Tests |
|--------|-------|
| [`src/basic/Constants.sol`](src/basic/Constants.sol) | [`test/basic/Constants.t.sol`](test/basic/Constants.t.sol) |

---

### 6. Immutable

**What you learn:** The `immutable` keyword — set once in the constructor, stored in bytecode, cheaper than storage.

```solidity
contract Immutable {
    uint256 public immutable MY_UINT;

    constructor(uint256 _myUint) {
        MY_UINT = _myUint; // set once, stored in bytecode
    }
}
```

**Why it matters:** Like constants, `immutable` variables are stored in bytecode (~3 gas to read). Unlike constants, the value is set at **deploy time**, not compile time. Perfect for constructor-configured values like `owner` or `token`.

| Source | Tests |
|--------|-------|
| [`src/basic/Immutable.sol`](src/basic/Immutable.sol) | [`test/basic/Immutable.t.sol`](test/basic/Immutable.t.sol) |

---

### 7. Reading and Writing State

**What you learn:** SSTORE (write) vs SLOAD (read), setter/getter patterns.

```solidity
contract SimpleStorage {
    uint256 public num;

    function set(uint256 _num) external { num = _num; }     // SSTORE
    function get() external view returns (uint256) { return num; } // SLOAD
}
```

**Why it matters:** SSTORE costs 5000–20000 gas. SLOAD costs 2100 gas (cold) or 100 gas (warm). Minimizing storage writes is one of the biggest gas optimizations.

| Source | Tests |
|--------|-------|
| [`src/basic/SimpleStorage.sol`](src/basic/SimpleStorage.sol) | [`test/basic/SimpleStorage.t.sol`](test/basic/SimpleStorage.t.sol) |

---

### 8. Ether and Wei

**What you learn:** `ether`, `gwei`, and `wei` denominations. `1 ether == 1e18 wei`.

```solidity
contract EtherUnits {
    function oneWei() external pure returns (uint256)   { return 1 wei; }
    function oneGwei() external pure returns (uint256)  { return 1 gwei; }   // 1e9 wei
    function oneEther() external pure returns (uint256) { return 1 ether; }  // 1e18 wei
}
```

**Why it matters:** ETH is always stored in **wei** internally. Literals like `1 ether` are syntactic sugar for `1000000000000000000`. Getting the unit wrong can lead to catastrophic bugs.

| Source | Tests |
|--------|-------|
| [`src/basic/EtherUnits.sol`](src/basic/EtherUnits.sol) | [`test/basic/EtherUnits.t.sol`](test/basic/EtherUnits.t.sol) |

---

### 9. Gas and Gas Price

**What you learn:** `gasleft()`, `tx.gasprice`, `block.basefee`, and EIP-1559 basics.

```solidity
contract Gas {
    function measureGas() external view returns (uint256 gasBefore, uint256 gasAfter) {
        gasBefore = gasleft();
        // ... some operation ...
        gasAfter = gasleft();
        // Gas consumed = gasBefore - gasAfter
    }
}
```

**Why it matters:** Every opcode costs gas. Out-of-gas reverts the entire transaction. With EIP-1559: base fee is burned, priority fee goes to validators. Understanding gas is essential for writing cost-efficient contracts.

| Source | Tests |
|--------|-------|
| [`src/basic/Gas.sol`](src/basic/Gas.sol) | [`test/basic/Gas.t.sol`](test/basic/Gas.t.sol) |

---

### 10. If / Else

**What you learn:** Conditional branching with `if`, `else if`, `else`, and the ternary operator `? :`.

```solidity
contract IfElse {
    function ifElse(uint256 x) external pure returns (uint256) {
        if (x < 10) {
            return 0;
        } else if (x < 20) {
            return 1;
        } else {
            return 2;
        }
    }

    function ternary(uint256 x) external pure returns (uint256) {
        return x < 10 ? 0 : (x < 20 ? 1 : 2);
    }
}
```

**Why it matters:** The ternary operator is a shorthand for simple conditions. Both forms compile to the same EVM bytecode — choose the more readable one.

| Source | Tests |
|--------|-------|
| [`src/basic/IfElse.sol`](src/basic/IfElse.sol) | [`test/basic/IfElse.t.sol`](test/basic/IfElse.t.sol) |

---

### 11. For and While Loop

**What you learn:** `for`, `while`, `break`, `continue`, and why unbounded loops are dangerous.

```solidity
contract Loop {
    function sumFor(uint256 n) external pure returns (uint256 sum) {
        for (uint256 i = 1; i <= n; i++) { sum += i; }
    }

    function sumWhile(uint256 n) external pure returns (uint256 sum) {
        uint256 i = 1;
        while (i <= n) { sum += i; i++; }
    }

    function sumOnlyEven(uint256[] calldata arr) external pure returns (uint256 sum) {
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] % 2 != 0) continue; // skip odd
            sum += arr[i];
        }
    }
}
```

**Why it matters:** Every loop iteration costs gas. Unbounded loops can exceed the block gas limit and make functions uncallable. Always set a maximum iteration count.

| Source | Tests |
|--------|-------|
| [`src/basic/Loop.sol`](src/basic/Loop.sol) | [`test/basic/Loop.t.sol`](test/basic/Loop.t.sol) |

---

### 12. Mapping

**What you learn:** `mapping(K => V)`, nested mappings, default values, and the fact that mappings cannot be iterated.

```solidity
contract Mapping {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => bool)) public nested;

    function set(address _addr, uint256 _val) external { balances[_addr] = _val; }
    function get(address _addr) external view returns (uint256) { return balances[_addr]; }
    function remove(address _addr) external { delete balances[_addr]; }
}
```

**Why it matters:** Mappings have no length, no iteration, no list of keys. Unset keys return the default value (`0`, `false`, `address(0)`). If you need to iterate, combine with an array (see [Iterable Mapping](#46-iterable-mapping)).

| Source | Tests |
|--------|-------|
| [`src/basic/Mapping.sol`](src/basic/Mapping.sol) | [`test/basic/Mapping.t.sol`](test/basic/Mapping.t.sol) |

---

### 13. Array

**What you learn:** Dynamic and fixed-size arrays, `push`, `pop`, `length`, `delete`, swap-and-pop vs shift-delete.

```solidity
contract Array {
    uint256[] public arr;

    function push(uint256 x) external { arr.push(x); }
    function pop() external { arr.pop(); }
    function getLength() external view returns (uint256) { return arr.length; }

    // O(1) removal by swapping with last element
    function removeSwap(uint256 index) external {
        arr[index] = arr[arr.length - 1];
        arr.pop();
    }
}
```

**Why it matters:** Swap-and-pop is O(1) but changes order. Shift-delete preserves order but is O(n). Choose based on whether ordering matters for your use case.

| Source | Tests |
|--------|-------|
| [`src/basic/Array.sol`](src/basic/Array.sol) | [`test/basic/Array.t.sol`](test/basic/Array.t.sol) |

---

### 14. Enum

**What you learn:** Enum types, default value (first member = 0), casting to/from `uint8`.

```solidity
contract EnumExample {
    enum Status { Pending, Active, Inactive }  // 0, 1, 2
    Status public status;                       // default: Pending (0)

    function setActive() external { status = Status.Active; }
    function reset() external { delete status; }              // resets to 0
    function getAsUint() external view returns (uint8) { return uint8(status); }
}
```

**Why it matters:** Enums make state machines explicit and type-safe. The default value is always the first member. `delete` resets to the first member.

| Source | Tests |
|--------|-------|
| [`src/basic/Enum.sol`](src/basic/Enum.sol) | [`test/basic/Enum.t.sol`](test/basic/Enum.t.sol) |

---

### 15. User Defined Value Types

**What you learn:** `type X is Y` for zero-cost type safety. `.wrap()` and `.unwrap()` for conversion.

```solidity
type Price is uint256;

function addPrice(Price a, Price b) pure returns (Price) {
    return Price.wrap(Price.unwrap(a) + Price.unwrap(b));
}
```

**Why it matters:** Prevents accidentally mixing incompatible values (e.g., Price and TokenAmount) at the type level. Zero runtime cost — the compiler enforces it.

| Source | Tests |
|--------|-------|
| [`src/basic/UserDefinedValueTypes.sol`](src/basic/UserDefinedValueTypes.sol) | [`test/basic/UserDefinedValueTypes.t.sol`](test/basic/UserDefinedValueTypes.t.sol) |

---

### 16. Structs

**What you learn:** Struct declaration, storage vs memory initialization, struct arrays.

```solidity
contract Structs {
    struct Todo { string text; bool completed; }
    Todo[] public todos;

    function create(string calldata _text) external {
        todos.push(Todo({text: _text, completed: false}));
    }

    function toggleCompleted(uint256 _index) external {
        Todo storage todo = todos[_index]; // storage reference — changes persist
        todo.completed = !todo.completed;
    }
}
```

**Why it matters:** Using `storage` references modifies the original data. Using `memory` creates a copy that is discarded after the function returns. Confusing the two is a common bug.

| Source | Tests |
|--------|-------|
| [`src/basic/Structs.sol`](src/basic/Structs.sol) | [`test/basic/Structs.t.sol`](test/basic/Structs.t.sol) |

---

### 17. Data Locations

**What you learn:** `storage` (persistent, expensive), `memory` (temporary copy), `calldata` (read-only input, cheapest).

```solidity
contract DataLocations {
    uint256[] public arr;

    function modifyStorage() external {
        uint256[] storage s = arr; // reference to storage — changes persist
        s.push(42);
    }

    function readOnly(uint256[] calldata data) external pure returns (uint256) {
        return data[0]; // calldata: no copy made, read-only
    }
}
```

**Why it matters:** Use `calldata` for external function parameters you don't modify — it avoids an expensive memory copy. Use `storage` references to modify state in-place.

| Source | Tests |
|--------|-------|
| [`src/basic/DataLocations.sol`](src/basic/DataLocations.sol) | [`test/basic/DataLocations.t.sol`](test/basic/DataLocations.t.sol) |

---

### 18. Transient Storage

**What you learn:** EIP-1153 `tstore`/`tload` opcodes — storage that is cleared at the end of every transaction.

```solidity
contract TransientStorage {
    bytes32 constant LOCK_SLOT = keccak256("LOCK");

    modifier nonReentrant() {
        assembly { if tload(LOCK_SLOT) { revert(0, 0) } tstore(LOCK_SLOT, 1) }
        _;
        assembly { tstore(LOCK_SLOT, 0) }
    }
}
```

**Why it matters:** Transient storage costs ~100 gas per operation vs ~5000+ for regular SSTORE. Perfect for reentrancy locks and flash loan callbacks because the value is automatically cleared after the transaction.

| Source | Tests |
|--------|-------|
| [`src/basic/TransientStorage.sol`](src/basic/TransientStorage.sol) | [`test/basic/TransientStorage.t.sol`](test/basic/TransientStorage.t.sol) |

---

### 19. Function Types

**What you learn:** Visibility (`external`, `public`, `internal`, `private`) and mutability (`pure`, `view`, `payable`).

```solidity
contract FunctionTypes {
    function externalFunc() external pure returns (uint256) { return 1; }
    function publicFunc() public pure returns (uint256) { return 2; }
    function internalFunc() internal pure returns (uint256) { return 3; }
    function privateFunc() private pure returns (uint256) { return 4; }
}
```

**Why it matters:** `external` is cheaper than `public` for external calls (args read directly from calldata). `pure`/`view` enable static calls and save gas by preventing state modification.

| Source | Tests |
|--------|-------|
| [`src/basic/FunctionTypes.sol`](src/basic/FunctionTypes.sol) | [`test/basic/FunctionTypes.t.sol`](test/basic/FunctionTypes.t.sol) |

---

### 20. View and Pure Functions

**What you learn:** `view` reads state but doesn't modify; `pure` doesn't read or modify state.

```solidity
contract ViewAndPure {
    uint256 public x = 1;

    function readState() external view returns (uint256) { return x; }
    function pureAdd(uint256 a, uint256 b) external pure returns (uint256) { return a + b; }
}
```

**Why it matters:** Marking functions correctly allows the compiler to enforce constraints and lets callers use `staticcall` instead of `call`, saving gas and preventing side effects.

| Source | Tests |
|--------|-------|
| [`src/basic/ViewAndPure.sol`](src/basic/ViewAndPure.sol) | [`test/basic/ViewAndPure.t.sol`](test/basic/ViewAndPure.t.sol) |

---

### 21. Custom Errors

**What you learn:** `error` keyword for gas-efficient reverts, replacing `require()` with string messages.

```solidity
error Unauthorized(address caller);
error InsufficientBalance(uint256 available, uint256 required);

contract CustomError {
    function withdraw(uint256 amount) external {
        if (msg.sender != owner) revert Unauthorized(msg.sender);
        if (balance < amount) revert InsufficientBalance(balance, amount);
    }
}
```

**Why it matters:** Custom errors use a 4-byte selector + ABI-encoded params instead of storing full error strings in bytecode. Significantly cheaper for common revert paths.

| Source | Tests |
|--------|-------|
| [`src/basic/CustomError.sol`](src/basic/CustomError.sol) | [`test/basic/CustomError.t.sol`](test/basic/CustomError.t.sol) |

---

### 22. Function Modifier

**What you learn:** Reusable validation with `modifier`, the `_` placeholder, chaining multiple modifiers.

```solidity
contract FunctionModifier {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _; // execute the modified function body here
    }

    modifier validAddress(address _addr) {
        require(_addr != address(0), "Zero address");
        _;
    }

    function changeOwner(address newOwner) external onlyOwner validAddress(newOwner) {
        owner = newOwner;
    }
}
```

**Why it matters:** Modifiers reduce code duplication for access control, input validation, and reentrancy guards. The `_` placeholder marks where the function body executes.

| Source | Tests |
|--------|-------|
| [`src/basic/FunctionModifier.sol`](src/basic/FunctionModifier.sol) | [`test/basic/FunctionModifier.t.sol`](test/basic/FunctionModifier.t.sol) |

---

### 23. Events

**What you learn:** `event` declaration, `emit`, `indexed` parameters (max 3 per event), gas cost of logs.

```solidity
contract Events {
    event Transfer(address indexed from, address indexed to, uint256 value);

    function transfer(address to, uint256 value) external {
        emit Transfer(msg.sender, to, value);
    }
}
```

**Why it matters:** Events are the cheapest form of on-chain "storage" (~375 gas per topic + 8 gas per data byte). `indexed` params become searchable log topics. Unindexed params go in data (cheaper but not searchable).

| Source | Tests |
|--------|-------|
| [`src/basic/Events.sol`](src/basic/Events.sol) | [`test/basic/Events.t.sol`](test/basic/Events.t.sol) |

---

### 24. Constructor

**What you learn:** `constructor` runs once at deployment, takes arguments, sets initial state.

```solidity
contract Constructor {
    address public immutable owner;
    uint256 public immutable value;

    constructor(address _owner, uint256 _value) {
        owner = _owner;
        value = _value;
    }
}
```

**Why it matters:** Constructors are the only place to set `immutable` variables. Constructor code is not stored on-chain — only the runtime bytecode is deployed.

| Source | Tests |
|--------|-------|
| [`src/basic/Constructor.sol`](src/basic/Constructor.sol) | [`test/basic/Constructor.t.sol`](test/basic/Constructor.t.sol) |

---

### 25. Inheritance

**What you learn:** `is` keyword, `virtual`/`override`, `super`, C3 linearization for multiple inheritance.

```solidity
contract Base {
    function greet() public pure virtual returns (string memory) { return "Base"; }
}

contract Child is Base {
    function greet() public pure override returns (string memory) { return "Child"; }
}
```

**Why it matters:** Solidity uses C3 linearization to resolve conflicts in multiple inheritance. Understand the order: the most derived contract wins.

| Source | Tests |
|--------|-------|
| [`src/basic/Inheritance.sol`](src/basic/Inheritance.sol) | [`test/basic/Inheritance.t.sol`](test/basic/Inheritance.t.sol) |

---

### 26. Shadowing Inherited State Variables

**What you learn:** What happens when a child contract declares a variable with the same name as a parent.

```solidity
contract Parent {
    uint256 public value = 1;
}

contract Child is Parent {
    uint256 public value = 2; // shadows Parent.value — separate slot!
}
```

**Why it matters:** Shadowing creates a **separate** storage variable. It does not override the parent's. This is confusing — avoid it. Override functions instead.

| Source | Tests |
|--------|-------|
| [`src/basic/Shadowing.sol`](src/basic/Shadowing.sol) | [`test/basic/Shadowing.t.sol`](test/basic/Shadowing.t.sol) |

---

### 27. Calling Parent Contracts

**What you learn:** Direct parent call vs `super`, C3 linearization with `super`.

```solidity
contract A { function foo() public virtual { /* ... */ } }
contract B is A { function foo() public virtual override { super.foo(); } }
```

**Why it matters:** `super.foo()` calls parents in C3 linearization order, not just the immediate parent. Direct calls (`A.foo()`) skip the chain.

| Source | Tests |
|--------|-------|
| [`src/basic/CallingParent.sol`](src/basic/CallingParent.sol) | [`test/basic/CallingParent.t.sol`](test/basic/CallingParent.t.sol) |

---

### 28. Visibility

**What you learn:** `private` (this contract only), `internal` (this + derived), `external` (outside only), `public` (anywhere).

| Visibility | External call | Internal call | Derived contract |
|------------|:---:|:---:|:---:|
| `private`  | — | yes | — |
| `internal` | — | yes | yes |
| `external` | yes | — | yes (external) |
| `public`   | yes | yes | yes |

**Why it matters:** Default to `external` when possible — it's cheaper because arguments are read directly from calldata.

| Source | Tests |
|--------|-------|
| [`src/basic/Visibility.sol`](src/basic/Visibility.sol) | [`test/basic/Visibility.t.sol`](test/basic/Visibility.t.sol) |

---

### 29. Interface

**What you learn:** `interface` keyword — all functions must be `external`, no implementation, used to call other contracts.

```solidity
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}
```

**Why it matters:** Interfaces enable type-safe interaction with deployed contracts. They enforce that the target contract implements the expected function signatures.

| Source | Tests |
|--------|-------|
| [`src/basic/Interface.sol`](src/basic/Interface.sol) | [`test/basic/Interface.t.sol`](test/basic/Interface.t.sol) |

---

### 30. Payable

**What you learn:** `payable` keyword, `msg.value`, `receive()`, depositing and withdrawing ether.

```solidity
contract Payable {
    function deposit() external payable {
        // msg.value contains the ether sent
    }

    receive() external payable {}  // called on plain ether transfers
}
```

**Why it matters:** Functions must be marked `payable` to accept ether. Without it, sending ether will revert. The `receive()` function handles plain transfers with no calldata.

| Source | Tests |
|--------|-------|
| [`src/basic/Payable.sol`](src/basic/Payable.sol) | [`test/basic/Payable.t.sol`](test/basic/Payable.t.sol) |

---

### 31. Sending Ether

**What you learn:** Three ways to send ether — `transfer`, `send`, `call` — and why `call` is recommended.

| Method | Gas forwarded | On failure | Recommended |
|--------|:---:|:---:|:---:|
| `transfer` | 2300 | reverts | No |
| `send` | 2300 | returns `false` | No |
| `call` | all remaining | returns `(bool, bytes)` | **Yes** |

```solidity
(bool success, ) = recipient.call{value: amount}("");
require(success, "Transfer failed");
```

**Why it matters:** `transfer` and `send` forward only 2300 gas, which can fail with smart contract recipients. Use `call` with a reentrancy guard.

| Source | Tests |
|--------|-------|
| [`src/basic/SendingEther.sol`](src/basic/SendingEther.sol) | [`test/basic/SendingEther.t.sol`](test/basic/SendingEther.t.sol) |

---

### 32. Fallback

**What you learn:** `fallback()` and `receive()` — how Solidity dispatches calls with no matching function selector.

```
Ether sent to contract
    |
    msg.data is empty?
    / \
  yes   no
  |       |
receive() exists?   fallback()
  / \
yes   no
 |      |
receive()  fallback()
```

**Why it matters:** `fallback` is called when no function matches the calldata. It's used in proxy patterns. `receive` handles plain ether transfers.

| Source | Tests |
|--------|-------|
| [`src/basic/Fallback.sol`](src/basic/Fallback.sol) | [`test/basic/Fallback.t.sol`](test/basic/Fallback.t.sol) |

---

### 33. Delegatecall

**What you learn:** `delegatecall` executes code in the **caller's context** — preserves `msg.sender`, `msg.value`, and modifies the caller's storage.

```solidity
// Implementation contract
contract Logic { uint256 public num; function setNum(uint256 _n) external { num = _n; } }

// Proxy contract
contract Proxy {
    uint256 public num; // MUST match storage layout of Logic
    function setNum(address _logic, uint256 _n) external {
        (bool ok,) = _logic.delegatecall(abi.encodeWithSignature("setNum(uint256)", _n));
        require(ok);
    }
}
```

**Why it matters:** Delegatecall is the foundation of proxy/upgrade patterns. Storage layout **must** match between proxy and implementation, or data corruption occurs.

| Source | Tests |
|--------|-------|
| [`src/basic/Delegatecall.sol`](src/basic/Delegatecall.sol) | [`test/basic/Delegatecall.t.sol`](test/basic/Delegatecall.t.sol) |

---

### 34. Function Selector

**What you learn:** The first 4 bytes of `keccak256("functionName(paramTypes)")` identify which function to call.

```solidity
contract FunctionSelector {
    function getSelector(string calldata _func) external pure returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
    }
    // "transfer(address,uint256)" → 0xa9059cbb
}
```

**Why it matters:** When you make a low-level `call`, the first 4 bytes of calldata must match the target function's selector. This is how the EVM dispatches function calls.

| Source | Tests |
|--------|-------|
| [`src/basic/FunctionSelector.sol`](src/basic/FunctionSelector.sol) | [`test/basic/FunctionSelector.t.sol`](test/basic/FunctionSelector.t.sol) |

---

### 35. Contract Factory

**What you learn:** Creating contracts with `new`, passing ether and constructor args, tracking deployed addresses.

```solidity
contract Factory {
    address[] public contracts;

    function create(uint256 _value) external {
        Child child = new Child(_value);
        contracts.push(address(child));
    }
}
```

**Why it matters:** Factories are a common pattern for deploying multiple instances of the same contract (e.g., pairs in a DEX, clones for users). The address is deterministic based on deployer nonce.

| Source | Tests |
|--------|-------|
| [`src/basic/ContractFactory.sol`](src/basic/ContractFactory.sol) | [`test/basic/ContractFactory.t.sol`](test/basic/ContractFactory.t.sol) |

---

### 36. Try / Catch

**What you learn:** Error handling for external calls — catching reverts, panics, and custom errors.

```solidity
contract TryCatch {
    function trySomething(address target) external returns (uint256) {
        try ITarget(target).doSomething() returns (uint256 result) {
            return result;
        } catch Error(string memory reason) {
            // require/revert with string
        } catch Panic(uint256 code) {
            // division by zero, overflow, etc.
        } catch (bytes memory) {
            // custom errors or low-level reverts
        }
    }
}
```

**Why it matters:** `try/catch` only works for **external** calls and contract creation. It lets you handle failures gracefully instead of reverting the entire transaction.

| Source | Tests |
|--------|-------|
| [`src/basic/TryCatch.sol`](src/basic/TryCatch.sol) | [`test/basic/TryCatch.t.sol`](test/basic/TryCatch.t.sol) |

---

### 37. Import

**What you learn:** `import` statements — local files, npm packages, named imports.

```solidity
// Import everything
import "./Foo.sol";

// Named import (preferred)
import {Foo, Bar} from "./Foo.sol";

// OpenZeppelin import
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
```

**Why it matters:** Named imports are preferred because they make dependencies explicit and avoid polluting the namespace with unused symbols.

| Source | Tests |
|--------|-------|
| [`src/basic/Import.sol`](src/basic/Import.sol) | [`test/basic/Import.t.sol`](test/basic/Import.t.sol) |

---

### 38. Library

**What you learn:** `library` keyword — `internal` functions are inlined at compile time; `external` functions are deployed separately and called via DELEGATECALL.

```solidity
library MathLib {
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }
}

contract UsesLib {
    using MathLib for uint256;
    function biggest(uint256 a, uint256 b) external pure returns (uint256) {
        return a.max(b);
    }
}
```

**Why it matters:** Internal library functions are copied into the calling contract (no extra call). External ones save bytecode but cost extra gas per call. `using X for Y` enables method-like syntax.

| Source | Tests |
|--------|-------|
| [`src/basic/Library.sol`](src/basic/Library.sol) | [`test/basic/Library.t.sol`](test/basic/Library.t.sol) |

---

### 39. ABI Encode and Decode

**What you learn:** `abi.encode`, `abi.encodePacked`, `abi.decode` — how Solidity serializes data.

| Function | Padding | Use case |
|----------|---------|----------|
| `abi.encode` | 32-byte padded | Function calls, standard ABI |
| `abi.encodePacked` | Tightly packed | Hashing, signatures, Merkle proofs |
| `abi.decode` | — | Unpacking returned bytes |

**Why it matters:** `abi.encodePacked` can cause hash collisions when concatenating dynamic types (e.g., `("ab","c")` == `("a","bc")`). Use `abi.encode` when uniqueness matters.

| Source | Tests |
|--------|-------|
| [`src/basic/AbiEncode.sol`](src/basic/AbiEncode.sol) | [`test/basic/AbiEncode.t.sol`](test/basic/AbiEncode.t.sol) |

---

### 40. Keccak256

**What you learn:** The `keccak256` hash function — used for unique IDs, commitment schemes, and Merkle trees.

```solidity
contract Keccak256Example {
    function hash(string memory _text) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_text));
    }
}
```

**Why it matters:** Keccak-256 is the native hash function of the EVM. It's used everywhere: storage slot computation, event topics, CREATE2 addresses, signatures, Merkle proofs.

| Source | Tests |
|--------|-------|
| [`src/basic/Keccak256.sol`](src/basic/Keccak256.sol) | [`test/basic/Keccak256.t.sol`](test/basic/Keccak256.t.sol) |

---

### 41. Verify Signature

**What you learn:** ECDSA signature verification with `ecrecover`, Ethereum message prefix, signature malleability.

```solidity
function verify(address signer, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s)
    external pure returns (bool)
{
    bytes32 ethSignedHash = keccak256(
        abi.encodePacked("\x19Ethereum Signed Message:\n32", msgHash)
    );
    return ecrecover(ethSignedHash, v, r, s) == signer;
}
```

**Why it matters:** Always prefix with `"\x19Ethereum Signed Message:\n32"` to prevent cross-domain replay. Check for signature malleability (s must be in the lower half of secp256k1). Consider using OpenZeppelin's ECDSA library.

| Source | Tests |
|--------|-------|
| [`src/basic/VerifySignature.sol`](src/basic/VerifySignature.sol) | [`test/basic/VerifySignature.t.sol`](test/basic/VerifySignature.t.sol) |

---

### 42. Accessing Private Data

**What you learn:** `private` only means private from other contracts — **all blockchain data is publicly readable** via storage slots.

```solidity
contract PrivateData {
    uint256 private secret = 42;
    // Anyone can read slot 0 via eth_getStorageAt or vm.load
}
```

**Why it matters:** Never store secrets, passwords, or sensitive data on-chain. `private` visibility only prevents other contracts from calling the getter — it does not hide the data from the world.

| Source | Tests |
|--------|-------|
| [`src/basic/PrivateData.sol`](src/basic/PrivateData.sol) | [`test/basic/PrivateData.t.sol`](test/basic/PrivateData.t.sol) |

---

## Applications

---

### 43. Ether Wallet

**What you learn:** A simple vault with `receive()`, access-controlled `withdraw()`, and balance tracking.

```solidity
contract EtherWallet {
    address payable public owner;

    receive() external payable {}

    function withdraw(uint256 _amount) external {
        require(msg.sender == owner, "Not owner");
        (bool ok,) = owner.call{value: _amount}("");
        require(ok, "Failed");
    }
}
```

**Why it matters:** Combines `payable`, `receive()`, access control, and secure ether transfer into a practical pattern.

| Source | Tests |
|--------|-------|
| [`src/applications/EtherWallet.sol`](src/applications/EtherWallet.sol) | [`test/applications/EtherWallet.t.sol`](test/applications/EtherWallet.t.sol) |

---

### 44. Multi-Sig Wallet

**What you learn:** N-of-M approval pattern, transaction submission/confirmation/execution, replay protection.

A multi-sig wallet requires multiple owners to approve a transaction before it can be executed. This is the standard pattern used by Gnosis Safe and similar wallets.

| Source | Tests |
|--------|-------|
| [`src/applications/MultiSigWallet.sol`](src/applications/MultiSigWallet.sol) | [`test/applications/MultiSigWallet.t.sol`](test/applications/MultiSigWallet.t.sol) |

---

### 45. Merkle Tree

**What you learn:** Merkle proofs for gas-efficient verification — used in airdrops, whitelists, and rollups.

Instead of storing every eligible address on-chain (expensive), store a single Merkle root and let users prove membership with a proof.

| Source | Tests |
|--------|-------|
| [`src/applications/MerkleTree.sol`](src/applications/MerkleTree.sol) | [`test/applications/MerkleTree.t.sol`](test/applications/MerkleTree.t.sol) |

---

### 46. Iterable Mapping

**What you learn:** Combining a `mapping` with an array to enable iteration — solving the "mappings can't be iterated" limitation.

```solidity
library IterableMapping {
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => bool) inserted;
    }
}
```

**Why it matters:** Standard mappings have no way to enumerate keys. This pattern adds iteration at the cost of extra storage writes on insert/remove.

| Source | Tests |
|--------|-------|
| [`src/applications/IterableMapping.sol`](src/applications/IterableMapping.sol) | [`test/applications/IterableMapping.t.sol`](test/applications/IterableMapping.t.sol) |

---

### 47. CREATE2

**What you learn:** Deterministic contract addresses using `CREATE2` — address is computed from `deployer + salt + bytecode`.

```solidity
address predicted = address(uint160(uint256(keccak256(
    abi.encodePacked(bytes1(0xff), deployer, salt, keccak256(bytecode))
))));
```

**Why it matters:** With CREATE2, you can know a contract's address **before** deploying it. Essential for counterfactual deployments, Layer 2 solutions, and gasless wallets.

| Source | Tests |
|--------|-------|
| [`src/applications/Create2.sol`](src/applications/Create2.sol) | [`test/applications/Create2.t.sol`](test/applications/Create2.t.sol) |

---

### 48. Minimal Proxy (EIP-1167)

**What you learn:** Clone pattern — deploy identical contracts for ~10x cheaper by delegating all calls to a single implementation.

```solidity
// All clones share the same logic, but have separate storage
address clone = Clones.clone(implementation);
```

**Why it matters:** Creating full contract copies is expensive (~32k gas per byte of bytecode). Minimal proxies deploy a tiny 45-byte contract that delegates everything to a shared implementation.

| Source | Tests |
|--------|-------|
| [`src/applications/MinimalProxy.sol`](src/applications/MinimalProxy.sol) | [`test/applications/MinimalProxy.t.sol`](test/applications/MinimalProxy.t.sol) |

---

### 49. Deploy Any Contract

**What you learn:** Generic deployer that deploys any contract given its creation bytecode.

```solidity
function deploy(bytes memory bytecode) external returns (address addr) {
    assembly { addr := create(0, add(bytecode, 0x20), mload(bytecode)) }
    require(addr != address(0), "Deploy failed");
}
```

**Why it matters:** Useful for meta-factories and contract deployment systems that need to deploy arbitrary contracts without knowing their type at compile time.

| Source | Tests |
|--------|-------|
| [`src/applications/Deployer.sol`](src/applications/Deployer.sol) | [`test/applications/Deployer.t.sol`](test/applications/Deployer.t.sol) |

---

## DeFi

---

### 50. Uniswap V2 Swap

**What you learn:** Uniswap V2 architecture — constant product formula (x * y = k), flash swaps, DEX integration.

Uniswap V2 uses the constant product AMM: `reserveA * reserveB = k`. Swappers pay a 0.3% fee that accrues to liquidity providers.

| Source | Tests |
|--------|-------|
| [`src/defi/UniswapV2Swap.sol`](src/defi/UniswapV2Swap.sol) | [`test/defi/UniswapV2Swap.t.sol`](test/defi/UniswapV2Swap.t.sol) |

---

### 51. Uniswap V3 Swap

**What you learn:** Concentrated liquidity, tick-based pricing, single-hop and multi-hop swaps, exact input vs exact output.

V3 lets LPs concentrate liquidity in specific price ranges, dramatically improving capital efficiency.

| Source | Tests |
|--------|-------|
| [`src/defi/UniswapV3Swap.sol`](src/defi/UniswapV3Swap.sol) | [`test/defi/UniswapV3Swap.t.sol`](test/defi/UniswapV3Swap.t.sol) |

---

### 52. Uniswap V4 Swap

**What you learn:** V4 singleton PoolManager, hooks, flash accounting, Permit2, Universal Router.

V4 moves all pools into a single contract (singleton), uses hooks for customizable pool behavior, and flash accounting for gas-efficient multi-step operations.

| Source | Tests |
|--------|-------|
| [`src/defi/UniswapV4Swap.sol`](src/defi/UniswapV4Swap.sol) | [`test/defi/UniswapV4Swap.t.sol`](test/defi/UniswapV4Swap.t.sol) |

---

### 53. Uniswap V4 Flash Loan

**What you learn:** V4 flash loans using the pool callback — borrow and repay within a single transaction.

```solidity
// V4 flash loans use flash accounting:
// 1. "Take" tokens from the pool (creates a debt)
// 2. Use the tokens (arbitrage, liquidation, etc.)
// 3. "Settle" the debt by paying back
```

| Source | Tests |
|--------|-------|
| [`src/defi/UniswapV4FlashLoan.sol`](src/defi/UniswapV4FlashLoan.sol) | [`test/defi/UniswapV4FlashLoan.t.sol`](test/defi/UniswapV4FlashLoan.t.sol) |

---

### 54. Uniswap V4 Limit Order

**What you learn:** Implementing limit orders as a V4 hook — orders fill when the pool price crosses the target tick.

| Source | Tests |
|--------|-------|
| [`src/defi/UniswapV4LimitOrder.sol`](src/defi/UniswapV4LimitOrder.sol) | [`test/defi/UniswapV4LimitOrder.t.sol`](test/defi/UniswapV4LimitOrder.t.sol) |

---

### 55. Chainlink Price Feed

**What you learn:** Integrating Chainlink oracles for reliable price data, handling staleness, and decimal normalization.

```solidity
(, int256 price,, uint256 updatedAt,) = priceFeed.latestRoundData();
require(block.timestamp - updatedAt < STALENESS_THRESHOLD, "Stale price");
```

**Why it matters:** Never use spot prices from DEXs for critical decisions (borrowing, liquidations). Chainlink provides time-weighted, tamper-resistant price feeds.

| Source | Tests |
|--------|-------|
| [`src/defi/ChainlinkPriceFeed.sol`](src/defi/ChainlinkPriceFeed.sol) | [`test/defi/ChainlinkPriceFeed.t.sol`](test/defi/ChainlinkPriceFeed.t.sol) |

---

### 56. Staking Rewards

**What you learn:** Synthetix-style staking — reward-per-token accumulation, staking/unstaking, and proportional distribution.

The reward accrual formula: `rewardPerToken += (rewardRate * elapsed * 1e18) / totalStaked`. Each user's reward is calculated based on the difference since their last claim.

| Source | Tests |
|--------|-------|
| [`src/defi/StakingRewards.sol`](src/defi/StakingRewards.sol) | [`test/defi/StakingRewards.t.sol`](test/defi/StakingRewards.t.sol) |

---

### 57. Dutch Auction

**What you learn:** Price starts high and decreases linearly over time — first buyer wins at the current price.

```
Price
  |
  |\
  | \
  |  \
  |   \___
  |__________ Time
  start       end
```

**Why it matters:** Dutch auctions provide fair price discovery: the price keeps dropping until someone is willing to buy. Used for NFT launches and token sales.

| Source | Tests |
|--------|-------|
| [`src/defi/DutchAuction.sol`](src/defi/DutchAuction.sol) | [`test/defi/DutchAuction.t.sol`](test/defi/DutchAuction.t.sol) |

---

### 58. English Auction

**What you learn:** Classic bidding auction — highest bidder wins after the deadline. Minimum bid increments and withdrawal pattern.

| Source | Tests |
|--------|-------|
| [`src/defi/EnglishAuction.sol`](src/defi/EnglishAuction.sol) | [`test/defi/EnglishAuction.t.sol`](test/defi/EnglishAuction.t.sol) |

---

### 59. Crowd Fund

**What you learn:** Goal-based crowdfunding with deadline — refund if goal not met, creator claims if goal met.

| Source | Tests |
|--------|-------|
| [`src/defi/CrowdFund.sol`](src/defi/CrowdFund.sol) | [`test/defi/CrowdFund.t.sol`](test/defi/CrowdFund.t.sol) |

---

## Hacks & Security

---

### 60. Reentrancy Attack

**What you learn:** The classic reentrancy vulnerability — an external call before a state update lets an attacker re-enter the function.

```solidity
// VULNERABLE: external call before state update
function withdraw() external {
    uint256 bal = balances[msg.sender];
    (bool ok,) = msg.sender.call{value: bal}(""); // attacker re-enters here
    balances[msg.sender] = 0; // too late!
}
```

**Attack flow:** Deposit → Withdraw → Attacker's `receive()` calls `withdraw()` again → Balance not yet zeroed → Drains vault.

| Source | Tests |
|--------|-------|
| [`src/hacks/ReentrancyVulnerable.sol`](src/hacks/ReentrancyVulnerable.sol) | [`test/hacks/DelegatecallAttack.t.sol`](test/hacks/DelegatecallAttack.t.sol) |

---

### 61. Reentrancy — Secure

**What you learn:** The fix: Checks-Effects-Interactions (CEI) pattern and/or a reentrancy guard.

```solidity
// SECURE: update state BEFORE external call
function withdraw() external nonReentrant {
    uint256 bal = balances[msg.sender];
    balances[msg.sender] = 0;           // Effect first
    (bool ok,) = msg.sender.call{value: bal}(""); // Interaction last
    require(ok);
}
```

| Source | Tests |
|--------|-------|
| [`src/hacks/ReentrancySecure.sol`](src/hacks/ReentrancySecure.sol) | — |

---

### 62. Delegatecall Attack

**What you learn:** Storage collision via `delegatecall` — attacker overwrites owner by exploiting mismatched storage layout.

**Fix:** Use EIP-1967 proxy standard with randomized storage slots, or OpenZeppelin's proxy libraries.

| Source | Tests |
|--------|-------|
| [`src/hacks/DelegatecallAttack.sol`](src/hacks/DelegatecallAttack.sol) | [`test/hacks/DelegatecallAttack.t.sol`](test/hacks/DelegatecallAttack.t.sol) |

---

### 63. Self Destruct Attack

**What you learn:** `selfdestruct` can force-send ether to any contract, bypassing `receive()` and `payable` checks.

**Fix:** Never rely on `address(this).balance` for logic. Track deposits with an internal accounting variable instead.

| Source | Tests |
|--------|-------|
| [`src/hacks/SelfDestructAttack.sol`](src/hacks/SelfDestructAttack.sol) | [`test/hacks/SelfDestructAttack.t.sol`](test/hacks/SelfDestructAttack.t.sol) |

---

### 64. Force Ether

**What you learn:** Multiple ways ether can arrive in a contract without triggering `receive()` — `selfdestruct`, `coinbase` rewards, pre-deployed address.

| Source | Tests |
|--------|-------|
| [`src/hacks/ForceEther.sol`](src/hacks/ForceEther.sol) | [`test/hacks/ForceEther.t.sol`](test/hacks/ForceEther.t.sol) |

---

### 65. tx.origin Phishing

**What you learn:** Using `tx.origin` for authentication allows phishing attacks — an attacker can trick the real owner into calling a malicious contract.

**Fix:** Always use `msg.sender` for authentication. `tx.origin` is the original external account that initiated the transaction chain.

| Source | Tests |
|--------|-------|
| [`src/hacks/TxOriginAttack.sol`](src/hacks/TxOriginAttack.sol) | [`test/hacks/TxOriginAttack.t.sol`](test/hacks/TxOriginAttack.t.sol) |

---

### 66. Oracle Manipulation

**What you learn:** Spot price manipulation on DEXs — why lending protocols must use TWAPs or Chainlink instead of instantaneous prices.

**Fix:** Use time-weighted average prices (TWAP) or decentralized oracle networks (Chainlink). Never use spot price from a single DEX for critical decisions.

| Source | Tests |
|--------|-------|
| [`src/hacks/OracleManipulation.sol`](src/hacks/OracleManipulation.sol) | [`test/hacks/OracleManipulation.t.sol`](test/hacks/OracleManipulation.t.sol) |

---

### 67. Signature Replay

**What you learn:** Reusing a valid signature on a different transaction or chain — missing nonces and domain separation.

**Fix:** Include a nonce (incremented per use), the contract address, and the chain ID in the signed message (EIP-712).

| Source | Tests |
|--------|-------|
| [`src/hacks/SignatureReplay.sol`](src/hacks/SignatureReplay.sol) | [`test/hacks/SignatureReplay.t.sol`](test/hacks/SignatureReplay.t.sol) |

---

### 68. Timestamp Manipulation

**What you learn:** Miners/validators can manipulate `block.timestamp` by up to ~15 seconds — don't use it for randomness or time-critical logic.

**Fix:** Use commit-reveal patterns or Chainlink VRF for randomness. Accept ±15s tolerance for time-based logic.

| Source | Tests |
|--------|-------|
| [`src/hacks/TimestampManipulation.sol`](src/hacks/TimestampManipulation.sol) | [`test/hacks/TimestampManipulation.t.sol`](test/hacks/TimestampManipulation.t.sol) |

---

### 69. Predictable Randomness

**What you learn:** `blockhash`, `block.timestamp`, `block.difficulty` are all observable — they are NOT sources of randomness.

**Fix:** Use Chainlink VRF (Verifiable Random Function) for provably fair randomness, or commit-reveal schemes.

| Source | Tests |
|--------|-------|
| [`src/hacks/PredictableRandomness.sol`](src/hacks/PredictableRandomness.sol) | [`test/hacks/PredictableRandomness.t.sol`](test/hacks/PredictableRandomness.t.sol) |

---

### 70. Denial of Service (DoS)

**What you learn:** Unbounded loops or push-based refunds can make a contract unusable when gas costs exceed block limits.

**Fix:** Use the **pull-over-push** pattern — let users withdraw their own funds instead of iterating to send to everyone.

| Source | Tests |
|--------|-------|
| [`src/hacks/DoSAttack.sol`](src/hacks/DoSAttack.sol) | [`test/hacks/DoSAttack.t.sol`](test/hacks/DoSAttack.t.sol) |

---

### 71. Vault Inflation Attack

**What you learn:** First depositor attacks on ERC-4626 vaults — an attacker can inflate the share price to steal from subsequent depositors.

**Fix:** Use virtual shares/assets offset (OpenZeppelin's ERC-4626 includes this), or require a minimum initial deposit.

| Source | Tests |
|--------|-------|
| [`src/hacks/VaultInflation.sol`](src/hacks/VaultInflation.sol) | [`test/hacks/VaultInflation.t.sol`](test/hacks/VaultInflation.t.sol) |

---

## EVM / Assembly (Yul)

---

### 72. Assembly Variables

**What you learn:** Declaring and assigning variables in Yul with `let` and `:=`.

```solidity
function asmVar() external pure returns (uint256 result) {
    assembly {
        let x := 42        // declare and assign
        let y := add(x, 8) // use EVM opcodes
        result := y         // assign to return variable
    }
}
```

| Source | Tests |
|--------|-------|
| [`src/evm/AssemblyVariable.sol`](src/evm/AssemblyVariable.sol) | [`test/evm/AssemblyVariable.t.sol`](test/evm/AssemblyVariable.t.sol) |

---

### 73. Assembly Math

**What you learn:** Arithmetic operations in Yul — `add`, `sub`, `mul`, `div`, `mod`, `exp` — with no overflow protection.

```solidity
function asmAdd(uint256 a, uint256 b) external pure returns (uint256 result) {
    assembly { result := add(a, b) }  // no overflow check!
}
```

**Why it matters:** Assembly math is unchecked — it wraps on overflow instead of reverting. This is faster but dangerous. Only use when you've proven overflow is impossible.

| Source | Tests |
|--------|-------|
| [`src/evm/AssemblyMath.sol`](src/evm/AssemblyMath.sol) | [`test/evm/AssemblyMath.t.sol`](test/evm/AssemblyMath.t.sol) |

---

### 74. Assembly Conditionals

**What you learn:** `if` and `switch` statements in Yul.

```solidity
assembly {
    // Yul 'if' has no else — use switch for multi-branch
    if iszero(x) { result := 0 }

    switch x
    case 0 { result := 0 }
    case 1 { result := 1 }
    default { result := 2 }
}
```

| Source | Tests |
|--------|-------|
| [`src/evm/AssemblyConditionals.sol`](src/evm/AssemblyConditionals.sol) | [`test/evm/AssemblyConditionals.t.sol`](test/evm/AssemblyConditionals.t.sol) |

---

### 75. Assembly Loops

**What you learn:** `for` loops in Yul — init, condition, post, body.

```solidity
assembly {
    let sum := 0
    for { let i := 0 } lt(i, n) { i := add(i, 1) } {
        sum := add(sum, i)
    }
    result := sum
}
```

| Source | Tests |
|--------|-------|
| [`src/evm/AssemblyLoop.sol`](src/evm/AssemblyLoop.sol) | [`test/evm/AssemblyLoop.t.sol`](test/evm/AssemblyLoop.t.sol) |

---

### 76. Assembly Math Exercise

**What you learn:** Practice implementing math operations (subtraction, division, modulo) in Yul.

| Source | Tests |
|--------|-------|
| [`src/evm/AssemblyMathExercise.sol`](src/evm/AssemblyMathExercise.sol) | [`test/evm/AssemblyMathExercise.t.sol`](test/evm/AssemblyMathExercise.t.sol) |

---

### 77. Assembly Binary Exponentiation

**What you learn:** Efficient `base^exp` calculation using the square-and-multiply algorithm in Yul.

Binary exponentiation computes `x^n` in O(log n) multiplications instead of O(n). This is critical for gas efficiency when computing large powers.

| Source | Tests |
|--------|-------|
| [`src/evm/AssemblyBinaryExponentiation.sol`](src/evm/AssemblyBinaryExponentiation.sol) | [`test/evm/AssemblyBinaryExponentiation.t.sol`](test/evm/AssemblyBinaryExponentiation.t.sol) |

---

### 78. Assembly Arrays

**What you learn:** Memory layout of dynamic arrays in Yul — length at first word, elements at subsequent words.

```
Memory layout:
[0x00] length
[0x20] element[0]
[0x40] element[1]
...
```

| Source | Tests |
|--------|-------|
| [`src/evm/AssemblyArray.sol`](src/evm/AssemblyArray.sol) | [`test/evm/AssemblyArray.t.sol`](test/evm/AssemblyArray.t.sol) |

---

### 79. Bitwise Operators

**What you learn:** `&` (AND), `|` (OR), `^` (XOR), `~` (NOT), `<<` (left shift), `>>` (right shift) — used for packing data, permissions, and flags.

```solidity
// Pack two uint128 into one uint256
uint256 packed = (uint256(a) << 128) | uint256(b);

// Unpack
uint128 unpacked_a = uint128(packed >> 128);
uint128 unpacked_b = uint128(packed);
```

**Why it matters:** Bit packing lets you store multiple values in a single storage slot (32 bytes), saving thousands of gas.

| Source | Tests |
|--------|-------|
| [`src/evm/BitwiseOperators.sol`](src/evm/BitwiseOperators.sol) | [`test/evm/BitwiseOperators.t.sol`](test/evm/BitwiseOperators.t.sol) |

---

## How to Run Tests

```bash
# All tests
forge test

# Specific concept
forge test --match-path test/basic/IfElse.t.sol

# With gas report
forge test --gas-report

# Verbose (shows logs)
forge test -vvv

# Fuzz with more runs
forge test --fuzz-runs 1000
```

---

## Resources

- [Solidity by Example](https://solidity-by-example.org) — Original reference
- [Solidity Documentation](https://docs.soliditylang.org)
- [Foundry Book](https://book.getfoundry.sh)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)
- [Uniswap V4 Docs](https://docs.uniswap.org/contracts/v4/overview)
