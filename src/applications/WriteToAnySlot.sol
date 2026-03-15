// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title WriteToAnySlot
/// @notice Demonstrates reading and writing to arbitrary storage slots using assembly.
/// @dev Uses `sstore` and `sload` opcodes to interact with any storage slot directly.
///      This is useful for understanding how Solidity lays out storage and for building
///      patterns like EIP-1967 proxy storage slots.
contract WriteToAnySlot {
    /// @notice A normal state variable stored at slot 0
    /// @dev Solidity assigns sequential slots to state variables starting from 0.
    uint256 public storedValue;

    /// @notice A mapping stored at slot 1 — elements are at keccak256(key . slot)
    mapping(address => uint256) public balances;

    /// @notice Write a bytes32 value to an arbitrary storage slot
    /// @param slot The storage slot to write to
    /// @param value The bytes32 value to store
    function write(bytes32 slot, bytes32 value) external {
        // sstore(slot, value) writes `value` into the storage slot `slot`
        assembly {
            sstore(slot, value)
        }
    }

    /// @notice Read a bytes32 value from an arbitrary storage slot
    /// @param slot The storage slot to read from
    /// @return value The bytes32 value currently stored in that slot
    function read(bytes32 slot) external view returns (bytes32 value) {
        // sload(slot) loads the 32-byte word stored at `slot`
        assembly {
            value := sload(slot)
        }
    }

    /// @notice Compute the storage slot for a mapping element
    /// @dev For `mapping(address => uint256)` at base slot `baseSlot`,
    ///      the element for `key` is stored at keccak256(abi.encode(key, baseSlot)).
    ///      Solidity uses this deterministic scheme so that each mapping key
    ///      maps to a unique, collision-resistant storage location.
    /// @param key The mapping key (address cast to uint256 and left-padded to 32 bytes)
    /// @param baseSlot The storage slot where the mapping variable is declared
    /// @return slot The computed storage slot for the mapping element
    function computeMappingSlot(
        address key,
        uint256 baseSlot
    ) external pure returns (bytes32 slot) {
        // The slot for mapping[key] = keccak256(abi.encode(key, baseSlot))
        // key is left-padded to 32 bytes, baseSlot is 32 bytes — concatenated then hashed
        slot = keccak256(abi.encode(key, baseSlot));
    }
}
