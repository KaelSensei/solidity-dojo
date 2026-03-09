# solidity-by-example — Training Repo

A hands-on Solidity training ground covering every section of [solidity-by-example.org](https://solidity-by-example.org).

For each topic: a contract, a test, and where relevant a fuzz test and an invariant test.
Everything runs inside Docker — no local Foundry install needed.
NatSpec is mandatory on every contract. Inline comments explain the WHY, not the what.

This is not a reference. It is a dojo. You read, you implement, you break it, you fix it.

---

## Docker Setup

All tooling runs inside a container. You need Docker Desktop (Windows/macOS) or Docker Engine (Linux). Nothing else.

```bash
# First run — builds the image (~5-10 min)
docker compose up -d

# Every session
docker compose exec dojo bash

# Inside the container
forge --version   # should print forge 0.2.x
```

**Dockerfile** — place at repo root:

```dockerfile
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl git build-essential pkg-config libssl-dev \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://foundry.paradigm.xyz | bash
ENV PATH="/root/.foundry/bin:$PATH"
RUN foundryup

WORKDIR /workspace
```

**docker-compose.yml**:

```yaml
services:
  dojo:
    build: .
    volumes:
      - .:/workspace
      - dojo-foundry:/root/.foundry
    stdin_open: true
    tty: true

volumes:
  dojo-foundry:
```

**Project init** (run once inside the container):

```bash
forge init solidity-by-example
cd solidity-by-example
forge install OpenZeppelin/openzeppelin-contracts --no-commit
forge install transmissions11/solmate --no-commit
```

**foundry.toml**:

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

---

## How this repo is organized

```
src/
  basic/
  applications/
  hacks/
  evm/
  defi/
test/
  basic/
  applications/
  hacks/
  evm/
  defi/
```

Each topic gets one contract file and one test file.
Test files contain all three test types when applicable: unit, fuzz, invariant.

---

## Testing philosophy

**Unit test** — specific scenario, deterministic input. Every topic gets at least one.

**Fuzz test** — Foundry generates random inputs. Use when a function's behavior should hold across a range of values (math, state transitions, access control).

```solidity
function testFuzz_deposit(uint256 amount) public {
    amount = bound(amount, 1, 1e27); // clamp to valid range
    // ...
}
```

**Invariant test** — a property that must hold after ANY sequence of calls. Use for stateful contracts (vaults, AMMs, auctions, payment channels).

```solidity
function invariant_totalSupplyMatchesBalances() public view {
    assertEq(token.totalSupply(), handler.ghost_totalMinted() - handler.ghost_totalBurned());
}
```

Use the handler pattern for invariant tests — never target the contract directly.
The handler bounds inputs, tracks ghost variables, and filters out invalid calls.

---

## NatSpec standard

Every contract you write must follow this format:

```solidity
/// @title ContractName
/// @notice Plain English description for users.
/// @dev Technical notes: upgrade status, audit status, key invariants, known limitations.
contract ContractName {

    /// @notice Description of what this state variable represents.
    /// @dev Note any unit (wei, basis points, seconds) and constraints.
    uint256 public someValue;

    /// @notice Emitted when something important happens.
    /// @param user  The address that triggered the event.
    /// @param value The value associated with the event.
    event SomethingHappened(address indexed user, uint256 value);

    /// @notice Thrown when the caller provides an invalid input.
    /// @param provided What the caller sent.
    /// @param expected What was expected.
    error InvalidInput(uint256 provided, uint256 expected);

    /// @notice Does X for the caller.
    /// @dev Explain CEI pattern, reentrancy risk, or any non-obvious implementation detail.
    /// @param input Description including units and valid range.
    /// @return result Description of what is returned.
    function doSomething(uint256 input) external returns (uint256 result) {
```

Use `// SECURITY:` for security-critical lines, `// CEI:` to mark Check-Effects-Interactions steps, `// INVARIANT:` to mark enforced invariants.

---

## Sections

---

### BASIC

---

#### Hello World

**Concepts:** SPDX license, pragma, contract declaration, state variable, public getter.

**Contract:** `src/basic/HelloWorld.sol`
Declares a `string public greet` initialized to `"Hello World"`.

**Test:** `test/basic/HelloWorld.t.sol`
- Unit: assert `greet()` returns `"Hello World"`

**Fuzz:** no — no inputs.
**Invariant:** no — no state transitions.

**Key comment to include:**
Why `public` auto-generates a getter. Why SPDX is required. What `pragma solidity` does and why you pin a version range.

---

#### First App

**Concepts:** reading and writing state, increment/decrement patterns.

**Contract:** `src/basic/Counter.sol`
A `uint256 public count` with `inc()`, `dec()`, and `get()`.

**Test:** `test/basic/Counter.t.sol`
- Unit: inc increments by 1, dec decrements by 1, dec on 0 reverts (underflow)

**Fuzz:** `testFuzz_inc(uint8 times)` — call inc N times, assert count == N.
**Invariant:** no — too simple, covered by fuzz.

**Key comment:** why `uint256` underflows in Solidity 0.8+ and reverts automatically.

---

#### Primitive Data Types

**Concepts:** `bool`, `uint`, `int`, `address`, `bytes32`, default values.

**Contract:** `src/basic/Primitives.sol`
Declares one public state variable of each primitive type with their default values.

**Test:** `test/basic/Primitives.t.sol`
- Unit: assert each variable equals its type's default value

**Fuzz:** `testFuzz_uint256_never_negative(uint256 x)` — assert x >= 0 (always true, shows type safety).
**Invariant:** no.

**Key comment:** `int` vs `uint` range, why `address` is 20 bytes, `bytes32` vs `string`.

---

#### Variables

**Concepts:** local variables (stack/memory), state variables (storage), global variables (`msg.sender`, `block.timestamp`, `block.number`).

**Contract:** `src/basic/Variables.sol`
Exposes all three categories. A function that returns `msg.sender`, `block.timestamp`, `block.number`.

**Test:** `test/basic/Variables.t.sol`
- Unit: `vm.prank(alice)` → assert `msg.sender` returns alice
- Unit: `vm.warp(1000)` → assert `block.timestamp` returns 1000
- Unit: `vm.roll(42)` → assert `block.number` returns 42

**Fuzz:** `testFuzz_timestamp(uint48 ts)` — warp to ts, assert returned value matches.
**Invariant:** no.

---

#### Constants

**Concepts:** `constant` keyword, compile-time values, gas savings vs storage reads.

**Contract:** `src/basic/Constants.sol`
Declares `address public constant MY_ADDRESS` and `uint256 public constant MY_UINT`.

**Test:** `test/basic/Constants.t.sol`
- Unit: assert values match expected literals

**Fuzz:** no.
**Invariant:** `invariant_constants_never_change` — trivially true, good intro to invariant syntax.

**Key comment:** constants cost ~200 gas to read vs ~2100 for a storage variable (SLOAD). Why this matters in hot paths.

---

#### Immutable

**Concepts:** `immutable` keyword, set in constructor only, cheaper than storage.

**Contract:** `src/basic/Immutable.sol`
`uint256 public immutable MY_UINT` set in constructor.

**Test:** `test/basic/Immutable.t.sol`
- Unit: assert value matches constructor arg
- Unit: deploy with different values, assert each instance is independent

**Fuzz:** `testFuzz_constructor(uint256 val)` — deploy with fuzzed val, assert stored value matches.
**Invariant:** no.

**Key comment:** `immutable` is stored in bytecode, not storage. Reading it costs ~3 gas (like a constant) but the value is set at deployment time, not compile time.

---

#### Reading and Writing to a State Variable

**Concepts:** SSTORE vs SLOAD, getter functions, setter functions.

**Contract:** `src/basic/SimpleStorage.sol`
`uint256 public num` with `set(uint256)` and `get()`.

**Test:** `test/basic/SimpleStorage.t.sol`
- Unit: set then get returns same value
- Unit: multiple sets, final get returns last value

**Fuzz:** `testFuzz_set_get(uint256 x)` — set x, assert get() == x.
**Invariant:** `invariant_get_reflects_last_set` — ghost variable tracks last set value, assert get() matches.

---

#### Ether and Wei

**Concepts:** `ether`, `wei`, `gwei` literals, `1 ether == 1e18 wei`, `address.balance`.

**Contract:** `src/basic/EtherUnits.sol`
Exposes conversions as public pure functions. A payable receive function that tracks received ether.

**Test:** `test/basic/EtherUnits.t.sol`
- Unit: assert `1 ether == 1e18`
- Unit: assert `1 gwei == 1e9`
- Unit: `vm.deal(addr, 1 ether)` → assert `addr.balance == 1e18`

**Fuzz:** `testFuzz_wei_to_ether(uint64 gwei_amount)` — convert, assert no overflow.
**Invariant:** no.

**Key comment:** why ETH is always denominated in wei internally. Why literals like `1 ether` are just syntactic sugar for `1e18`.

---

#### Gas and Gas Price

**Concepts:** `gasleft()`, `tx.gasprice`, `block.basefee`, EIP-1559 basics.

**Contract:** `src/basic/Gas.sol`
A function that returns `gasleft()` before and after an operation, to show gas consumption.

**Test:** `test/basic/Gas.t.sol`
- Unit: assert `gasleft()` decreases after a storage write
- Unit: assert a view function costs less gas than a state-modifying one

**Fuzz:** no — gas costs are deterministic per opcode.
**Invariant:** no.

**Key comment:** difference between gas limit, gas used, and gas price. Why out-of-gas reverts the entire transaction. EIP-1559: base fee is burned, priority fee goes to the validator.

---

#### If / Else

**Concepts:** conditional branching, ternary operator.

**Contract:** `src/basic/IfElse.sol`
Pure functions demonstrating `if/else if/else` and ternary.

**Test:** `test/basic/IfElse.t.sol`
- Unit: test each branch

**Fuzz:** `testFuzz_ternary(uint256 x)` — assert ternary and if/else produce identical results.
**Invariant:** no.

---

#### For and While Loop

**Concepts:** `for`, `while`, `break`, `continue`, gas cost of loops.

**Contract:** `src/basic/Loop.sol`
Pure functions: sum from 1 to N using for loop, while loop. A function that breaks early.

**Test:** `test/basic/Loop.t.sol`
- Unit: sum(10) == 55
- Unit: break exits early

**Fuzz:** `testFuzz_for_while_equivalent(uint8 n)` — assert for-loop sum == while-loop sum.
**Invariant:** no.

**Key comment:** why unbounded loops are dangerous in production — every iteration costs gas, and if the loop exceeds the block gas limit the transaction reverts. Always bound loops by a max iteration count.

---

#### Mapping

**Concepts:** `mapping(K => V)`, nested mappings, default values, no iteration.

**Contract:** `src/basic/Mapping.sol`
`mapping(address => uint256) public balances`. Set, get, delete functions. A nested `mapping(address => mapping(address => bool)) public nested`.

**Test:** `test/basic/Mapping.t.sol`
- Unit: unset key returns 0
- Unit: set then get returns value
- Unit: delete resets to 0

**Fuzz:** `testFuzz_set_get(address key, uint256 val)` — set val at key, assert retrieval matches.
**Invariant:** no.

**Key comment:** mappings have no length, no iteration, no list of keys. You cannot enumerate them. If you need iteration, use a separate array to track keys (see Iterable Mapping in Applications).

---

#### Array

**Concepts:** fixed-size vs dynamic arrays, `push`, `pop`, `length`, `delete`, storage vs memory arrays.

**Contract:** `src/basic/Array.sol`
Dynamic `uint256[] public arr`. Functions: push, pop, get by index, get length, remove by index (shift and swap-delete patterns).

**Test:** `test/basic/Array.t.sol`
- Unit: push increases length
- Unit: pop decreases length, removes last element
- Unit: delete leaves a zero, does not change length
- Unit: remove-by-swap changes length, does not preserve order
- Unit: out-of-bounds access reverts

**Fuzz:** `testFuzz_push_pop(uint8 n)` — push n elements, pop n elements, assert length == 0.
**Invariant:** `invariant_length_matches_ghost` — handler tracks expected length, assert matches.

**Key comment:** swap-delete is O(1) but breaks ordering. Shift-delete preserves order but is O(n) and expensive on large arrays. Choose based on whether order matters.

---

#### Enum

**Concepts:** enums, default value (first member), explicit casting to/from uint8.

**Contract:** `src/basic/Enum.sol`
`enum Status { Pending, Active, Inactive }`. State variable, getter, setter, reset.

**Test:** `test/basic/Enum.t.sol`
- Unit: default value is `Pending` (0)
- Unit: set to each member, assert value
- Unit: casting to uint8

**Fuzz:** `testFuzz_set(uint8 raw)` — only valid enum values (0-2) should succeed, others revert.
**Invariant:** no.

---

#### User Defined Value Types

**Concepts:** `type X is Y`, zero-cost abstraction over primitives, `.wrap()` and `.unwrap()`.

**Contract:** `src/basic/UserDefinedValueTypes.sol`
`type Price is uint256`. Math functions that operate on Price without unwrapping unnecessarily.

**Test:** `test/basic/UserDefinedValueTypes.t.sol`
- Unit: wrap then unwrap returns original value
- Unit: type safety — Price cannot be used where uint256 is expected without explicit cast

**Fuzz:** `testFuzz_wrap_unwrap(uint256 x)` — assert roundtrip is lossless.
**Invariant:** no.

---

#### Structs

**Concepts:** struct declaration, storage vs memory initialization, nested structs, struct arrays.

**Contract:** `src/basic/Structs.sol`
`struct Todo { string text; bool completed; }`. Array of Todos with create, update text, toggle completed functions.

**Test:** `test/basic/Structs.t.sol`
- Unit: create todo, assert fields
- Unit: update text, assert updated
- Unit: toggle completed twice returns to original state

**Fuzz:** no — string fuzzing is complex; cover with unit tests.
**Invariant:** `invariant_todos_length_only_grows` — no delete function, so length must be monotonically increasing.

---

#### Data Locations — Storage, Memory and Calldata

**Concepts:** storage (persistent), memory (temporary), calldata (read-only input), gas cost differences.

**Contract:** `src/basic/DataLocations.sol`
Functions demonstrating each location. A function that shows the difference between modifying a storage reference vs a memory copy.

**Test:** `test/basic/DataLocations.t.sol`
- Unit: modifying a storage reference updates state
- Unit: modifying a memory copy does NOT update state
- Unit: calldata cannot be modified (compile-time check — document this)

**Fuzz:** no.
**Invariant:** no.

**Key comment:** using `calldata` instead of `memory` for read-only function parameters saves gas — no copy is made. Always use `calldata` for external function array/string parameters you don't modify.

---

#### Transient Storage

**Concepts:** EIP-1153, `tstore` / `tload` opcodes, slot cleared after transaction ends, use case: reentrancy locks.

**Contract:** `src/basic/TransientStorage.sol`
A reentrancy lock using transient storage instead of a boolean storage variable. Show cost difference.

**Test:** `test/basic/TransientStorage.t.sol`
- Unit: lock is set during call, cleared after
- Unit: reentrant call while locked reverts
- Unit: new transaction sees cleared lock

**Fuzz:** no.
**Invariant:** `invariant_lock_cleared_after_call` — after any call sequence, transient lock must be 0.

**Key comment:** transient storage is ~100x cheaper than regular storage for temporary values. Cleared at the end of every transaction (not just the call). Perfect for reentrancy guards and flash loan callbacks.

---

#### Function

**Concepts:** function visibility (`external`, `public`, `internal`, `private`), mutability (`pure`, `view`, `payable`), modifiers.

**Contract:** `src/basic/FunctionTypes.sol`
A contract demonstrating all visibility and mutability combinations with NatSpec explaining when to use each.

**Test:** `test/basic/FunctionTypes.t.sol`
- Unit: test each function type works as expected
- Unit: verify pure functions cannot modify state (compile time)
- Unit: verify view functions cannot modify state (compile time)

**Fuzz:** no.
**Invariant:** no.

**Key comment:** Visibility: external is cheaper than public for external calls (args read from calldata). Mutability: pure/view allow static calls, save gas by preventing SSTORE.

---

#### View and Pure Functions

**Concepts:** `view` reads state but doesn't modify, `pure` doesn't read or modify state.

**Contract:** `src/basic/ViewAndPure.sol`
Demonstrates both types, including why a pure function can call other pure functions but not view functions that read state.

**Test:** `test/basic/ViewAndPure.t.sol`
- Unit: view function reads state correctly
- Unit: pure function computes correctly without reading state
- Unit: pure function calling pure works

**Fuzz:** `testFuzz_pure_add(uint256 a, uint256 b)` — assert add(a,b) == a + b.
**Invariant:** no.

---

#### Error

**Concepts:** custom errors with `error` keyword, cheaper than revert strings, used with `revert ErrorName()`.

**Contract:** `src/basic/CustomError.sol`
Demonstrates custom errors vs require strings with gas comparison.

**Test:** `test/basic/CustomError.t.sol`
- Unit: custom error reverts with correct selector
- Unit: compare gas costs (custom error vs require string)

**Fuzz:** no.
**Invariant:** no.

**Key comment:** custom errors use 4-byte selector + abi-encoded params vs storing a full string in bytecode. Much cheaper for common revert paths.

---

#### Function Modifier

**Concepts:** modifiers for reusable validation logic, `_` placeholder, multiple modifiers, modifier arguments.

**Contract:** `src/basic/FunctionModifier.sol`
Modifiers: `onlyOwner`, `noReentrancy`, `validAddress`, `minAmount(uint256)`. Show order of execution.

**Test:** `test/basic/FunctionModifier.t.sol`
- Unit: onlyOwner rejects non-owner
- Unit: noReentrancy blocks reentrant calls
- Unit: validAddress rejects zero address
- Unit: modifiers execute in declared order

**Fuzz:** no.
**Invariant:** `invariant_owner_cannot_be_zero` — owner is never zero address.

---

#### Events

**Concepts:** `event` declaration, `emit` keyword, `indexed` topics (max 3), gas cost of logs.

**Contract:** `src/basic/Events.sol`
Multiple events: simple, with indexed params, all indexed. Function that emits for testing.

**Test:** `test/basic/Events.t.sol`
- Unit: event emitted with correct params
- Unit: indexed params are topics
- Unit: expectEmit works for topic and data verification

**Fuzz:** no.
**Invariant:** no.

**Key comment:** Events are the cheapest form of onchain storage (~375 gas per topic + 8 gas per byte). Use indexed params for efficient filtering. Unindexed params go in data (cheaper, not searchable).

---

#### Constructor

**Concepts:** `constructor` keyword, runs once at deployment, can take arguments, sets immutable state.

**Contract:** `src/basic/Constructor.sol`
Constructor takes owner address and initial value. Sets immutables and state.

**Test:** `test/basic/Constructor.t.sol`
- Unit: constructor sets owner correctly
- Unit: constructor sets value correctly

**Fuzz:** `testFuzz_constructor_values(address owner, uint256 value)` — deploy with fuzzed args, assert stored correctly.
**Invariant:** no.

---

#### Inheritance

**Concepts:** `is` keyword, `virtual` and `override`, `super`, constructor chaining, multiple inheritance with C3 linearization.

**Contract:** `src/basic/Inheritance.sol`
Base contract with virtual function. Derived contract overrides. Multiple inheritance example with C3 ordering.

**Test:** `test/basic/Inheritance.t.sol`
- Unit: override works correctly
- Unit: super calls parent implementation
- Unit: constructor chaining sets all values

**Fuzz:** no.
**Invariant:** no.

---

#### Shadowing Inherited State Variables

**Concepts:** variable shadowing when child declares same name, how to access parent's variable.

**Contract:** `src/basic/Shadowing.sol`
Parent has `uint256 public value`. Child shadows it. Show how to disambiguate.

**Test:** `test/basic/Shadowing.t.sol`
- Unit: child's value is separate from parent's
- Unit: can access both via explicit casting or getter

**Fuzz:** no.
**Invariant:** no.

**Key comment:** Shadowing is confusing. Avoid it. If you need to override behavior, use functions not variables.

---

#### Calling Parent Contracts

**Concepts:** direct parent call vs `super`, multiple inheritance with `super`.

**Contract:** `src/basic/CallingParent.sol`
Multiple parents with same function name. Shows direct call vs super behavior (C3 linearization).

**Test:** `test/basic/CallingParent.t.sol`
- Unit: direct parent call executes only that parent
- Unit: super executes parents in C3 linearization order

**Fuzz:** no.
**Invariant:** no.

---

#### Visibility

**Concepts:** `private`, `internal`, `external`, `public`. Who can call what.

**Contract:** `src/basic/Visibility.sol`
Same function name with all 4 visibilities. External functions to test each.

**Test:** `test/basic/Visibility.t.sol`
- Unit: external callable from outside only
- Unit: public callable from inside and outside
- Unit: internal callable from derived contracts
- Unit: private only callable from this contract

**Fuzz:** no.
**Invariant:** no.

**Key comment:** Default to external when possible (cheaper). Use public only if called internally. Internal for shared logic. Private for truly internal helpers.

---

#### Interface

**Concepts:** `interface` keyword, all functions external, no implementation, used for contract interaction.

**Contract:** `src/basic/Interface.sol`
ERC20-like interface. Contract that uses the interface to call external tokens.

**Test:** `test/basic/Interface.t.sol`
- Unit: can call external contract through interface
- Unit: interface enforces function signature

**Fuzz:** no.
**Invariant:** no.

---

#### Payable

**Concepts:** `payable` keyword, `msg.value`, `address(this).balance`, transferring ether.

**Contract:** `src/basic/Payable.sol`
Payable functions, receive(), fallback(). Functions to deposit and withdraw.

**Test:** `test/basic/Payable.t.sol`
- Unit: payable function receives ether
- Unit: receive() called on plain ether transfer
- Unit: withdraw transfers ether correctly

**Fuzz:** `testFuzz_deposit_withdraw(uint96 amount)` — deposit amount, withdraw, assert balance changes correctly.
**Invariant:** `invariant_balance_matches_deposits_minus_withdrawals` — ghost accounting tracks net deposits, matches balance.

---

#### Sending Ether — transfer, send, call

**Concepts:** `transfer` (2300 gas, reverts), `send` (2300 gas, returns bool), `call` (forwards all gas, returns bool+data).

**Contract:** `src/basic/SendingEther.sol`
Functions demonstrating all three methods with security considerations.

**Test:** `test/basic/SendingEther.t.sol`
- Unit: transfer reverts on failure
- Unit: send returns false on failure
- Unit: call returns success boolean
- Unit: call to contract with expensive fallback works (transfer would fail)

**Fuzz:** no.
**Invariant:** no.

**Key comment:** call is preferred post-2020. Use with reentrancy guards. Always check return value. transfer/send have 2300 gas stipend that may break with smart contract wallets.

---

#### Fallback

**Concepts:** `fallback()` external payable, called when no function matches, used for proxy patterns.

**Contract:** `src/basic/Fallback.sol`
Contract with fallback that emits an event with the calldata. Shows proxy pattern use case.

**Test:** `test/basic/Fallback.t.sol`
- Unit: fallback called on unknown function selector
- Unit: fallback receives ether when no receive() defined
- Unit: fallback gets correct calldata

**Fuzz:** no.
**Invariant:** no.

---

#### Call

**Concepts:** low-level `call`, `delegatecall`, `staticcall`, `abi.encodeWithSelector`, return data handling.

**Contract:** `src/basic/Call.sol`
Low-level call examples: calling specific functions, handling return data, checking success.

**Test:** `test/basic/Call.t.sol`
- Unit: call with encoded selector succeeds
- Unit: can decode return data
- Unit: failed call returns false (doesn't revert)

**Fuzz:** no.
**Invariant:** no.

**Key comment:** low-level call bypasses type safety. Use only when necessary (proxies, generic call routers). Always check success boolean.

---

#### Delegatecall

**Concepts:** `delegatecall` runs code in caller's context, preserves `msg.sender` and `msg.value`, storage layout must match.

**Contract:** `src/basic/Delegatecall.sol`
Implementation contract with state. Proxy contract using delegatecall. Show storage collision risks.

**Test:** `test/basic/Delegatecall.t.sol`
- Unit: delegatecall runs in caller's context
- Unit: msg.sender preserved through delegatecall
- Unit: state changes in caller's storage, not implementation

**Fuzz:** no.
**Invariant:** no.

**Key comment:** delegatecall is powerful and dangerous. Storage layout MUST match exactly between proxy and implementation. Use standard proxy patterns (EIP-1967, EIP-1822).

---

#### Function Selector

**Concepts:** first 4 bytes of keccak256(function signature), used for function dispatch.

**Contract:** `src/basic/FunctionSelector.sol`
Functions to compute selectors, show how Solidity uses them internally.

**Test:** `test/basic/FunctionSelector.t.sol`
- Unit: selector computed correctly
- Unit: different params produce different selectors

**Fuzz:** no.
**Invariant:** no.

---

#### Calling Contract with ABI

**Concepts:** using contract type vs address + interface, type safety benefits.

**Contract:** `src/basic/CallingContract.sol`
Contract that calls another contract using both typed and low-level approaches.

**Test:** `test/basic/CallingContract.t.sol`
- Unit: typed call is safer
- Unit: low-level call with correct selector works
- Unit: low-level call with wrong selector fails gracefully

**Fuzz:** no.
**Invariant:** no.

---

#### Contract that Creates Other Contracts

**Concepts:** `new` keyword, passing ether on creation, getting the created address.

**Contract:** `src/basic/ContractFactory.sol`
Factory that creates instances of another contract, tracks them in an array.

**Test:** `test/basic/ContractFactory.t.sol`
- Unit: factory creates contract
- Unit: created contract has correct constructor args
- Unit: can send ether during creation

**Fuzz:** `testFuzz_create_multiple(uint8 n)` — create n contracts, assert count matches.
**Invariant:** `invariant_factory_tracks_all_children` — sum of tracked children equals actual created count.

---

#### Try / Catch

**Concepts:** `try/catch` for external calls, different catch blocks for different error types.

**Contract:** `src/basic/TryCatch.sol`
Contract that makes external calls with try/catch, handles success, revert, and panic.

**Test:** `test/basic/TryCatch.t.sol`
- Unit: try succeeds, returns value
- Unit: catch on revert with error string
- Unit: catch on custom error
- Unit: catch on panic (division by zero)

**Fuzz:** no.
**Invariant:** no.

---

#### Import

**Concepts:** `import` statement, local vs npm vs GitHub imports, named imports.

**Contract:** `src/basic/Import.sol`
Uses OpenZeppelin and Solmate imports to demonstrate different import styles.

**Test:** `test/basic/Import.t.sol`
- Unit: imported contracts work correctly
- Unit: named imports work

**Fuzz:** no.
**Invariant:** no.

---

#### Library

**Concepts:** `library` keyword, internal functions embedded in calling contract, external functions deployed separately and called via DELEGATECALL.

**Contract:** `src/basic/Library.sol`
Math library with internal functions, sorting library with external functions.

**Test:** `test/basic/Library.t.sol`
- Unit: internal library function works
- Unit: external library function works (deployed separately)
- Unit: using-for syntax works

**Fuzz:** `testFuzz_math(uint256 a, uint256 b)` — library math operations are correct.
**Invariant:** no.

**Key comment:** Internal library functions are copied into the calling contract at compile time (no external call). External library functions are deployed once and DELEGATECALL'd (saves bytecode, costs extra gas).

---

#### ABI Encode and Decode

**Concepts:** `abi.encode`, `abi.encodePacked`, `abi.decode`, `keccak256` for hashing.

**Contract:** `src/basic/AbiEncode.sol`
Functions demonstrating encoding for different use cases (calls, hashing, tight packing).

**Test:** `test/basic/AbiEncode.t.sol`
- Unit: abi.encode produces correct format
- Unit: abi.encodePacked produces tight packing
- Unit: abi.decode correctly decodes
- Unit: keccak256 of encoded matches expected

**Fuzz:** no.
**Invariant:** no.

**Key comment:** encode for standard ABI encoding (function calls). encodePacked for tight packing (signatures, merkle proofs). decode for unpacking returned bytes.

---

#### Keccak256

**Concepts:** `keccak256` hash function, used for unique IDs, commitment schemes, signatures.

**Contract:** `src/basic/Keccak256.sol`
Hashing examples: unique IDs, simple commitment scheme, merkle leaf hashing.

**Test:** `test/basic/Keccak256.t.sol`
- Unit: same input produces same hash
- Unit: different inputs produce different hashes
- Unit: commitment scheme works (hide then reveal)

**Fuzz:** no.
**Invariant:** no.

---

#### Verify Signature

**Concepts:** `ecrecover`, ECDSA signature verification, message prefix, signature malleability.

**Contract:** `src/basic/VerifySignature.sol`
Functions to verify ECDSA signatures, handle Ethereum signed message prefix.

**Test:** `test/basic/VerifySignature.t.sol`
- Unit: valid signature verifies correctly
- Unit: wrong signer fails verification
- Unit: tampered message fails verification

**Fuzz:** no.
**Invariant:** no.

**Key comment:** Always hash with Ethereum message prefix (`\x19Ethereum Signed Message:\n32`). Check for signature malleability (s in lower half of secp256k1 curve). Consider using OpenZeppelin's ECDSA library.

---

#### Accessing Private Data

**Concepts:** all data is public on blockchain, `private` only hides from other contracts, storage layout lets you read anything.

**Contract:** `src/basic/PrivateData.sol`
Contract with private variables. Show how to read them via storage slots.

**Test:** `test/basic/PrivateData.t.sol`
- Unit: can read "private" data via vm.load
- Unit: demonstrates storage layout

**Fuzz:** no.
**Invariant:** no.

**Key comment:** Private means private-to-contracts, not private-to-the-world. Anyone can read storage. Never store secrets or passwords on chain.

---

#### Uniswap V2 Swap Example

**Concepts:** Uniswap V2 architecture, flash swaps, arbitrage, DEX integration.

**Contract:** `src/defi/UniswapV2Swap.sol`
Contract that performs flash swaps on Uniswap V2, repaying with a different token.

**Test:** `test/defi/UniswapV2Swap.t.sol`
- Unit: flash swap executes correctly
- Unit: profit calculation is correct
- Unit: revert if can't repay

**Fuzz:** `testFuzz_swap_amounts(uint256 amount)` — fuzz input amounts, verify outputs.
**Invariant:** `invariant_k_constant` — x * y = k holds after swaps (accounting for fees).

---

#### Uniswap V3 Swap Example

**Concepts:** concentrated liquidity, tick-based pricing, single-hop and multi-hop swaps, exact input vs exact output.

**Contract:** `src/defi/UniswapV3Swap.sol`
Contract integrating with Uniswap V3 for single and multi-hop swaps.

**Test:** `test/defi/UniswapV3Swap.t.sol`
- Unit: exact input single swap works
- Unit: exact output single swap works
- Unit: multi-hop swap works
- Unit: slippage protection reverts on excessive slippage

**Fuzz:** `testFuzz_swap_parameters(uint24 feeTier, uint256 amount)` — fuzz fee tier and amount.
**Invariant:** no — Uniswap V3 invariants are complex.

---

#### Uniswap V4 Swap

**Concepts:** V4 pools, hooks, flash accounting, Permit2, universal router.

**Contract:** `src/defi/UniswapV4Swap.sol`
Contract performing single and multi-hop swaps using Uniswap V4 PoolManager and Universal Router.

**Test:** `test/defi/UniswapV4Swap.t.sol`
- Unit: exact input single swap works
- Unit: exact output single swap works
- Unit: multi-hop swap works
- Unit: slippage protection reverts on excessive slippage

**Fuzz:** `testFuzz_swap_amounts(uint256 amountIn, uint256 amountOutMinimum)` — fuzz swap amounts.
**Invariant:** no — Uniswap V4 invariants are complex.

---

#### Uniswap V4 Flash Loan

**Concepts:** V4 flash loans, callback architecture, flash accounting, hook callbacks.

**Contract:** `src/defi/UniswapV4FlashLoan.sol`
Contract demonstrating flash loan functionality in Uniswap V4 using the pool callback.

**Test:** `test/defi/UniswapV4FlashLoan.t.sol`
- Unit: flash loan executes successfully
- Unit: flash loan repayment is correct
- Unit: reverts if callback fails

**Fuzz:** `testFuzz_flash_loan_amounts(uint256 amount)` — fuzz loan amounts within bounds.
**Invariant:** no.

---

#### Uniswap V4 Limit Order

**Concepts:** V4 hooks, limit orders, tick manipulation, hook-driven liquidity.

**Contract:** `src/defi/UniswapV4LimitOrder.sol`
Contract implementing a limit order using Uniswap V4 hook architecture.

**Test:** `test/defi/UniswapV4LimitOrder.t.sol`
- Unit: limit order fills at correct price
- Unit: order does not fill above limit price
- Unit: partial fills work correctly

**Fuzz:** `testFuzz_limit_order_price(uint256 amountIn, uint256 priceLimit)` — fuzz order parameters.
**Invariant:** no.

---

#### Chainlink Price Feed

**Concepts:** Chainlink oracle integration, price staleness checks, decimal handling.

**Contract:** `src/defi/ChainlinkPriceFeed.sol`
Contract that fetches ETH/USD price from Chainlink, includes staleness check.

**Test:** `test/defi/ChainlinkPriceFeed.t.sol`
- Unit: can fetch latest price
- Unit: reverts on stale price
- Unit: handles decimal conversion correctly

**Fuzz:** no.
**Invariant:** no.

---

#### Staking Rewards

**Concepts:** reward accrual, staking/unstaking, reward rate math, stake-weighted distribution.

**Contract:** `src/defi/StakingRewards.sol`
Synthetix-style staking rewards contract with reward-per-token accumulation.

**Test:** `test/defi/StakingRewards.t.sol`
- Unit: staking updates reward balance
- Unit: rewards accrue over time
- Unit: withdrawing claims rewards
- Unit: reward rate is distributed correctly

**Fuzz:** `testFuzz_stake_unstake(uint256 amount, uint256 duration)` — fuzz stake amount and time.
**Invariant:** `invariant_reward_per_token_increases` — reward per token never decreases.

---

#### Dutch Auction

**Concepts:** price decay over time, commit-reveal pattern, fair price discovery.

**Contract:** `src/defi/DutchAuction.sol`
Dutch auction for NFTs or tokens, price starts high and decreases linearly.

**Test:** `test/defi/DutchAuction.t.sol`
- Unit: price decreases over time
- Unit: purchase at current price succeeds
- Unit: purchase after auction ends reverts
- Unit: refund if overpaid

**Fuzz:** `testFuzz_purchase_timing(uint256 warpTime)` — fuzz block.timestamp, verify price calculation.
**Invariant:** `invariant_price_never_increases` — current price is always <= start price.

---

#### English Auction

**Concepts:** bidding increments, withdrawal pattern, highest bidder wins, time extensions.

**Contract:** `src/defi/EnglishAuction.sol`
Standard English auction with minimum bid increments and withdrawal.

**Test:** `test/defi/EnglishAuction.t.sol`
- Unit: bid must exceed current highest
- Unit: previous highest can withdraw
- Unit: auction ends after deadline
- Unit: winner can claim NFT

**Fuzz:** `testFuzz_bidding_war(uint256[] bids)` — fuzz sequence of bids.
**Invariant:** `invariant_highest_bidder_has_highest_bid` — highestBidder always has highestBid.

---

#### Crowd Fund

**Concepts:** goal-based funding, deadline, refund if goal not met, withdrawal if goal met.

**Contract:** `src/defi/CrowdFund.sol`
Simple crowdfunding campaign with goal and deadline.

**Test:** `test/defi/CrowdFund.t.sol`
- Unit: can pledge to campaign
- Unit: can refund if goal not met
- Unit: creator can claim if goal met
- Unit: cannot pledge after deadline

**Fuzz:** `testFuzz_pledge_refund(uint256[] pledges)` — fuzz pledge amounts.
**Invariant:** `invariant_pledged_never_exceeds_goal_if_claimed` — if claimed, totalPledged >= goal.

---

#### Multi-Sig Wallet

**Concepts:** n-of-m signatures, transaction nonce, execution threshold, replay protection.

**Contract:** `src/applications/MultiSigWallet.sol`
Gnosis-style multi-sig with configurable threshold.

**Test:** `test/applications/MultiSigWallet.t.sol`
- Unit: submit transaction
- Unit: approve by multiple owners
- Unit: execute when threshold reached
- Unit: revoke approval

**Fuzz:** `testFuzz_approve_execute(uint256 signers)` — fuzz which owners sign.
**Invariant:** `invariant_executed_only_after_threshold` — executed tx always has >= threshold approvals.

---

#### Merkle Tree

**Concepts:** Merkle proofs, leaf verification, gas-efficient airdrops.

**Contract:** `src/applications/MerkleTree.sol`
Merkle distributor for token airdrops with proof verification.

**Test:** `test/applications/MerkleTree.t.sol`
- Unit: valid proof claims successfully
- Unit: invalid proof reverts
- Unit: double claim prevented

**Fuzz:** `testFuzz_proof_verification(bytes32[] proof)` — fuzz proof elements.
**Invariant:** `invariant_claimed_amount_matches_proof` — total claimed equals sum of valid proofs.

---

#### Iterable Mapping

**Concepts:** combining mapping with array for iteration, gas tradeoffs.

**Contract:** `src/applications/IterableMapping.sol`
Mapping that tracks keys in an array for iteration.

**Test:** `test/applications/IterableMapping.t.sol`
- Unit: set adds key to array
- Unit: remove deletes key from array
- Unit: can iterate all keys

**Fuzz:** `testFuzz_set_remove(uint8 operations)` — fuzz set/remove sequence.
**Invariant:** `invariant_keys_array_has_no_duplicates` — no address appears twice in keys array.

---

#### Create2

**Concepts:** deterministic contract addresses, `salt` parameter, counterfactual deployment.

**Contract:** `src/applications/Create2.sol`
Factory using CREATE2 for deterministic addresses, useful for layer 2 addresses.

**Test:** `test/applications/Create2.t.sol`
- Unit: same salt produces same address
- Unit: different salt produces different address
- Unit: can compute address before deployment

**Fuzz:** no.
**Invariant:** no.

---

#### Minimal Proxy (EIP-1167)

**Concepts:** clone pattern, minimal bytecode, cheap deployment of identical contracts.

**Contract:** `src/applications/MinimalProxy.sol`
Factory using OpenZeppelin's Clones library for minimal proxy deployment.

**Test:** `test/applications/MinimalProxy.t.sol`
- Unit: clone creates minimal proxy
- Unit: proxy delegates to implementation
- Unit: many clones are cheap to deploy

**Fuzz:** `testFuzz_multiple_clones(uint8 n)` — deploy n clones.
**Invariant:** `invariant_all_clones_use_same_implementation` — all clones delegate to same impl.

---

#### Deploy Any Contract

**Concepts:** generic factory, bytecode deployment, initcode handling.

**Contract:** `src/applications/Deployer.sol`
Factory that can deploy any contract given its creation bytecode.

**Test:** `test/applications/Deployer.t.sol`
- Unit: can deploy simple contract
- Unit: can deploy contract with constructor args
- Unit: returns correct deployed address

**Fuzz:** no.
**Invariant:** no.

---

#### Ether Wallet

**Concepts:** simple vault, access control, withdrawal patterns.

**Contract:** `src/applications/EtherWallet.sol`
Simple contract that holds ether, only owner can withdraw.

**Test:** `test/applications/EtherWallet.t.sol`
- Unit: can receive ether
- Unit: only owner can withdraw
- Unit: withdrawal transfers correct amount

**Fuzz:** `testFuzz_deposit_withdraw(uint96 amount)` — fuzz amounts.
**Invariant:** `invariant_balance_only_changes_via_withdraw` — balance changes only on withdrawals.

---

#### Send Ether (with reentrancy protection)

**Concepts:** checks-effects-interactions pattern, reentrancy guard, push vs pull patterns.

**Contract:** `src/applications/SendEtherSecure.sol`
Secure ether sending with CEI pattern and reentrancy guard.

**Test:** `test/applications/SendEtherSecure.t.sol`
- Unit: sends ether correctly
- Unit: reentrant call is blocked
- Unit: CEI pattern prevents reentrancy

**Fuzz:** no.
**Invariant:** `invariant_no_reentrant_calls` — reentrancy flag is never set during external calls.

---

#### Assembly Math

**Concepts:** Yul/inline assembly, unchecked math, bit manipulation, gas optimization.

**Contract:** `src/evm/AssemblyMath.sol`
Math operations implemented in Yul for gas efficiency.

**Test:** `test/evm/AssemblyMath.t.sol`
- Unit: assembly add matches Solidity
- Unit: assembly mul matches Solidity
- Unit: unchecked math handles overflow correctly

**Fuzz:** `testFuzz_assembly_operations(uint256 a, uint256 b)` — fuzz operations.
**Invariant:** no.

---

#### Assembly Variable

**Concepts:** Yul variables, memory layout, storage layout, let vs :=.

**Contract:** `src/evm/AssemblyVariable.sol`
Demonstrates Yul variable declaration and assignment patterns.

**Test:** `test/evm/AssemblyVariable.t.sol`
- Unit: let declares and initializes
- Unit: := assigns to existing variable

**Fuzz:** no.
**Invariant:** no.

---

#### Assembly Conditionals

**Concepts:** Yul if/switch statements, comparison operators, jump logic.

**Contract:** `src/evm/AssemblyConditionals.sol`
Conditional logic implemented in Yul.

**Test:** `test/evm/AssemblyConditionals.t.sol`
- Unit: if statement works
- Unit: switch statement works

**Fuzz:** `testFuzz_assembly_if(uint256 x)` — fuzz condition.
**Invariant:** no.

---

#### Assembly Loop

**Concepts:** Yul for loops, continue/break equivalent, gas efficiency.

**Contract:** `src/evm/AssemblyLoop.sol`
Loops implemented in Yul.

**Test:** `test/evm/AssemblyLoop.t.sol`
- Unit: for loop sums correctly
- Unit: early exit works

**Fuzz:** `testFuzz_assembly_sum(uint8 n)` — fuzz loop iterations.
**Invariant:** no.

---

#### Assembly Math Exercise

**Concepts:** practice writing Yul, implementing math in assembly.

**Contract:** `src/evm/AssemblyMathExercise.sol`
Exercises for implementing math operations in Yul.

**Test:** `test/evm/AssemblyMathExercise.t.sol`
- Unit: implement and test subtraction
- Unit: implement and test division

**Fuzz:** no.
**Invariant:** no.

---

#### Re-Entrancy Attack

**Concepts:** reentrancy vulnerability, external call before state update, attacker contract.

**Contract:** `src/hacks/ReentrancyVulnerable.sol`, `src/hacks/ReentrancyAttacker.sol`
Vulnerable vault and attacker demonstrating the classic reentrancy exploit.

**Test:** `test/hacks/ReentrancyAttack.t.sol`
- Unit: attacker drains vault via reentrancy

**Fuzz:** no.
**Invariant:** no.

---

#### Re-Entrancy Solution

**Concepts:** checks-effects-interactions, reentrancy guard, pull over push pattern.

**Contract:** `src/hacks/ReentrancySecure.sol`
Same vault functionality, secured against reentrancy.

**Test:** `test/hacks/ReentrancySolution.t.sol`
- Unit: reentrant attack fails
- Unit: normal withdrawal still works

**Fuzz:** no.
**Invariant:** `invariant_balance_equals_sum_of_balances` — vault balance equals sum of user balances.

---

#### Oracle Manipulation (Price Oracle Attack)

**Concepts:** spot price manipulation, TWAP importance, manipulation cost.

**Contract:** `src/hacks/OracleManipulation.sol`
Lending protocol using manipulable spot price vs secure TWAP.

**Test:** `test/hacks/OracleManipulation.t.sol`
- Unit: spot price can be manipulated
- Unit: TWAP resists manipulation
- Unit: lending with spot price is vulnerable

**Fuzz:** no.
**Invariant:** no.

---

#### Self Destruct Attack

**Concepts:** `selfdestruct` force-sends ether, can bypass payable checks, contract balance manipulation.

**Contract:** `src/hacks/SelfDestructAttack.sol`
Contract vulnerable to forced ether via selfdestruct, and the attacker.

**Test:** `test/hacks/SelfDestructAttack.t.sol`
- Unit: selfdestruct forces ether into contract
- Unit: balance can exceed recorded deposits

**Fuzz:** no.
**Invariant:** no.

---

#### Access Control Attack (tx.origin)

**Concepts:** `tx.origin` vs `msg.sender`, phishing attacks via `tx.origin` usage.

**Contract:** `src/hacks/TxOriginVulnerable.sol`, `src/hacks/TxOriginAttacker.sol`
Wallet using tx.origin for authentication and the phishing attacker.

**Test:** `test/hacks/TxOriginAttack.t.sol`
- Unit: attacker can phish via tx.origin check

**Fuzz:** no.
**Invariant:** no.

---

#### Access Control Solution

**Concepts:** always use msg.sender, explicit authorization checks.

**Contract:** `src/hacks/TxOriginSecure.sol`
Secure version using msg.sender with proper access control.

**Test:** `test/hacks/TxOriginSolution.t.sol`
- Unit: phishing attack fails with msg.sender

**Fuzz:** no.
**Invariant:** no.

---

#### Delegatecall Attack

**Concepts:** delegatecall vulnerability, storage collision, malicious implementation.

**Contract:** `src/hacks/DelegatecallVulnerable.sol`, `src/hacks/DelegatecallAttacker.sol`
Vulnerable proxy and attacker showing storage collision exploit.

**Test:** `test/hacks/DelegatecallAttack.t.sol`
- Unit: attacker can overwrite owner via delegatecall

**Fuzz:** no.
**Invariant:** no.

---

#### Delegatecall Solution

**Concepts:** proper proxy patterns, implementation slot, non-upgradeable storage.

**Contract:** `src/hacks/DelegatecallSecure.sol`
EIP-1967 compliant proxy with proper storage slots.

**Test:** `test/hacks/DelegatecallSolution.t.sol`
- Unit: storage collision not possible with EIP-1967

**Fuzz:** no.
**Invariant:** no.

---

#### Force Ether (selfdestruct)

**Concepts:** contracts can receive ether without payable functions via selfdestruct.

**Contract:** `src/hacks/ForceEther.sol`
Contract that refuses ether normally but can receive via selfdestruct.

**Test:** `test/hacks/ForceEther.t.sol`
- Unit: normal transfer fails
- Unit: selfdestruct forces ether in

**Fuzz:** no.
**Invariant:** `invariant_balance_gte_recorded` — balance always >= recorded deposits.

---

#### Vault Inflation Attack

**Concepts:** first depositor attack, share dilution, decimal precision issues.

**Contract:** `src/hacks/VaultInflation.sol`
Vulnerable ERC4626 vault showing first depositor attack.

**Test:** `test/hacks/VaultInflation.t.sol`
- Unit: first depositor can inflate share price
- Unit: subsequent depositors get fewer shares

**Fuzz:** no.
**Invariant:** no.

---

#### Vault Inflation Solution

**Concepts:** virtual shares, offset, minimum deposit.

**Contract:** `src/hacks/VaultInflationSecure.sol`
ERC4626 vault with virtual shares protection.

**Test:** `test/hacks/VaultInflationSolution.t.sol`
- Unit: inflation attack fails
- Unit: shares minted proportionally

**Fuzz:** no.
**Invariant:** `invariant_share_price_stable` — share price doesn't change dramatically.

---

#### Signature Replay Attack

**Concepts:** missing nonce, signature replay across chains or contracts.

**Contract:** `src/hacks/SignatureReplayVulnerable.sol`
Vulnerable contract allowing signature replay.

**Test:** `test/hacks/SignatureReplayAttack.t.sol`
- Unit: same signature can be reused

**Fuzz:** no.
**Invariant:** no.

---

#### Signature Replay Solution

**Concepts:** unique nonces, domain separation, EIP-712.

**Contract:** `src/hacks/SignatureReplaySecure.sol`
Secure contract using nonces and EIP-712.

**Test:** `test/hacks/SignatureReplaySolution.t.sol`
- Unit: signature cannot be replayed
- Unit: nonce tracking prevents reuse

**Fuzz:** no.
**Invariant:** `invariant_nonce_increments` — nonce always increases after use.

---

#### Block Timestamp Manipulation

**Concepts:** miner manipulation of block.timestamp, don't use for entropy.

**Contract:** `src/hacks/TimestampManipulation.sol`
Game using block.timestamp for randomness (vulnerable).

**Test:** `test/hacks/TimestampManipulation.t.sol`
- Unit: miner can manipulate timestamp to win

**Fuzz:** no.
**Invariant:** no.

---

#### Block Timestamp Solution

**Concepts:** commit-reveal, VRF, external randomness.

**Contract:** `src/hacks/TimestampSecure.sol`
Game using commit-reveal for fairness.

**Test:** `test/hacks/TimestampSolution.t.sol`
- Unit: commit-reveal prevents manipulation

**Fuzz:** no.
**Invariant:** no.

---

#### Randomness (Predictable Randomness)

**Concepts:** blockhash, timestamp, difficulty are all manipulable/predictable.

**Contract:** `src/hacks/PredictableRandomness.sol`
Lottery using blockhash for randomness (vulnerable).

**Test:** `test/hacks/PredictableRandomness.t.sol`
- Unit: randomness can be predicted

**Fuzz:** no.
**Invariant:** no.

---

#### Randomness Solution

**Concepts:** Chainlink VRF, commitment schemes, external randomness.

**Contract:** `src/hacks/SecureRandomness.sol`
Lottery using commit-reveal pattern.

**Test:** `test/hacks/SecureRandomness.t.sol`
- Unit: commit-reveal provides fairness

**Fuzz:** no.
**Invariant:** no.

---

#### DoS Attack (Gas Limit)

**Concepts:** unbounded operations, gas limit attacks, push vs pull.

**Contract:** `src/hacks/DoSVulnerable.sol`
Auction with push payments (vulnerable to gas limit DoS).

**Test:** `test/hacks/DoSAttack.t.sol`
- Unit: bidder array can grow unbounded
- Unit: last bidder can't withdraw if array too large

**Fuzz:** no.
**Invariant:** no.

---

#### DoS Solution

**Concepts:** pull over push pattern, withdrawal pattern.

**Contract:** `src/hacks/DoSSecure.sol`
Auction using pull pattern for withdrawals.

**Test:** `test/hacks/DoSSolution.t.sol`
- Unit: unlimited bidders work fine
- Unit: each bidder withdraws independently

**Fuzz:** no.
**Invariant:** no.

---

#### Phishing with tx.origin

**Concepts:** tx.origin phishing, social engineering.

**Contract:** `src/hacks/PhishingVulnerable.sol`
Wallet vulnerable to tx.origin phishing.

**Test:** `test/hacks/PhishingAttack.t.sol`
- Unit: attacker can steal via phishing

**Fuzz:** no.
**Invariant:** no.

---

#### Phishing Solution

**Concepts:** msg.sender authentication, explicit approvals.

**Contract:** `src/hacks/PhishingSecure.sol`
Secure wallet using msg.sender.

**Test:** `test/hacks/PhishingSolution.t.sol`
- Unit: phishing attack fails

**Fuzz:** no.
**Invariant:** no.

---

#### Hiding Malicious Code with External Call

**Concepts:** external call to malicious contract, unexpected behavior.

**Contract:** `src/hacks/HiddenMaliceVulnerable.sol`, `src/hacks/Malicious.sol`
Contract with external call to manipulable address.

**Test:** `test/hacks/HiddenMaliceAttack.t.sol`
- Unit: external contract can behave maliciously

**Fuzz:** no.
**Invariant:** no.

---

#### Hiding Malicious Code Solution

**Concepts:** whitelist, fixed addresses, careful external calls.

**Contract:** `src/hacks/HiddenMaliceSecure.sol`
Contract with whitelist for external calls.

**Test:** `test/hacks/HiddenMaliceSolution.t.sol`
- Unit: only whitelisted addresses callable

**Fuzz:** no.
**Invariant:** no.

---

#### Assembly Binary Exponentiation

**Concepts:** efficient power calculation, Yul implementation.

**Contract:** `src/evm/AssemblyBinaryExponentiation.sol`
Binary exponentiation in Yul for gas-efficient power.

**Test:** `test/evm/AssemblyBinaryExponentiation.t.sol`
- Unit: calculates power correctly
- Unit: more gas efficient than naive multiplication

**Fuzz:** `testFuzz_exponentiation(uint256 base, uint8 exp)` — fuzz inputs.
**Invariant:** no.

---

#### Assembly Array

**Concepts:** dynamic arrays in memory, length storage, pointer arithmetic.

**Contract:** `src/evm/AssemblyArray.sol`
Dynamic array operations implemented in Yul.

**Test:** `test/evm/AssemblyArray.t.sol`
- Unit: push adds element
- Unit: get retrieves element
- Unit: length tracks correctly

**Fuzz:** `testFuzz_array_operations(uint8 n)` — fuzz operations.
**Invariant:** no.

---

#### Bitwise Operators

**Concepts:** and, or, xor, not, shifts, masks.

**Contract:** `src/evm/BitwiseOperators.sol`
Bitwise operations for packing data, permissions, flags.

**Test:** `test/evm/BitwiseOperators.t.sol`
- Unit: each operator works correctly
- Unit: can pack and unpack data

**Fuzz:** `testFuzz_bitwise(uint256 a, uint256 b)` — fuzz operations.
**Invariant:** no.

---

## References

External resources and documentation used in this training:

### Uniswap

- [Uniswap V4 Documentation](https://docs.uniswap.org/contracts/v4/overview)
- [Uniswap V4 Core](https://github.com/Uniswap/v4-core)
- [Uniswap V4 Periphery](https://github.com/Uniswap/v4-periphery)
- [Universal Router](https://github.com/Uniswap/universal-router)

---

## Progress Tracking

Track your progress through the topics:

- [ ] Basic / Hello World
- [ ] Basic / First App
- [ ] Basic / Primitive Data Types
- [ ] Basic / Variables
- [ ] Basic / Constants
- [ ] Basic / Immutable
- [ ] Basic / Reading and Writing to a State Variable
- [ ] Basic / Ether and Wei
- [ ] Basic / Gas and Gas Price
- [ ] Basic / If / Else
- [ ] Basic / For and While Loop
- [ ] Basic / Mapping
- [ ] Basic / Array
- [ ] Basic / Enum
- [ ] Basic / User Defined Value Types
- [ ] Basic / Structs
- [ ] Basic / Data Locations
- [ ] Basic / Transient Storage
- [ ] Basic / Function
- [ ] Basic / View and Pure Functions
- [ ] Basic / Error
- [ ] Basic / Function Modifier
- [ ] Basic / Events
- [ ] Basic / Constructor
- [ ] Basic / Inheritance
- [ ] Basic / Shadowing
- [ ] Basic / Calling Parent Contracts
- [ ] Basic / Visibility
- [ ] Basic / Interface
- [ ] Basic / Payable
- [ ] Basic / Sending Ether
- [ ] Basic / Fallback
- [ ] Basic / Call
- [ ] Basic / Delegatecall
- [ ] Basic / Function Selector
- [ ] Basic / Calling Contract with ABI
- [ ] Basic / Contract that Creates Other Contracts
- [ ] Basic / Try / Catch
- [ ] Basic / Import
- [ ] Basic / Library
- [ ] Basic / ABI Encode and Decode
- [ ] Basic / Keccak256
- [ ] Basic / Verify Signature
- [ ] Basic / Accessing Private Data
- [ ] DeFi / Uniswap V2 Swap
- [ ] DeFi / Uniswap V3 Swap
- [ ] DeFi / Uniswap V4 Swap
- [ ] DeFi / Uniswap V4 Flash Loan
- [ ] DeFi / Uniswap V4 Limit Order
- [ ] DeFi / Chainlink Price Feed
- [ ] DeFi / Staking Rewards
- [ ] DeFi / Dutch Auction
- [ ] DeFi / English Auction
- [ ] DeFi / Crowd Fund
- [ ] Applications / Multi-Sig Wallet
- [ ] Applications / Merkle Tree
- [ ] Applications / Iterable Mapping
- [ ] Applications / Create2
- [ ] Applications / Minimal Proxy
- [ ] Applications / Deploy Any Contract
- [ ] Applications / Ether Wallet
- [ ] Applications / Send Ether Secure
- [ ] EVM / Assembly Math
- [ ] EVM / Assembly Variable
- [ ] EVM / Assembly Conditionals
- [ ] EVM / Assembly Loop
- [ ] EVM / Assembly Math Exercise
- [ ] EVM / Assembly Binary Exponentiation
- [ ] EVM / Assembly Array
- [ ] EVM / Bitwise Operators
- [ ] Hacks / Re-Entrancy Attack
- [ ] Hacks / Re-Entrancy Solution
- [ ] Hacks / Oracle Manipulation
- [ ] Hacks / Self Destruct Attack
- [ ] Hacks / Access Control Attack
- [ ] Hacks / Access Control Solution
- [ ] Hacks / Delegatecall Attack
- [ ] Hacks / Delegatecall Solution
- [ ] Hacks / Force Ether
- [ ] Hacks / Vault Inflation
- [ ] Hacks / Vault Inflation Solution
- [ ] Hacks / Signature Replay
- [ ] Hacks / Signature Replay Solution
- [ ] Hacks / Timestamp Manipulation
- [ ] Hacks / Timestamp Solution
- [ ] Hacks / Predictable Randomness
- [ ] Hacks / Secure Randomness
- [ ] Hacks / DoS Attack
- [ ] Hacks / DoS Solution
- [ ] Hacks / Phishing
- [ ] Hacks / Phishing Solution
- [ ] Hacks / Hidden Malice
- [ ] Hacks / Hidden Malice Solution
