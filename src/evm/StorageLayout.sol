// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title StorageLayout
/// @notice Demonstrates how the EVM lays out state variables in storage
/// @dev Educational example - storage slot packing, dynamic arrays, and mappings
///
/// Storage layout rules:
/// - State variables are stored sequentially starting from slot 0
/// - Variables smaller than 32 bytes are packed right-to-left within a single slot
/// - Dynamic array: length stored at slot p, elements at keccak256(p) + index
/// - Mapping: value for key k stored at keccak256(k . p) where p is the mapping's slot
///   (k . p means abi.encode(k, p) — key concatenated with slot number)

/// @title EVM Storage Layout Operations
contract StorageLayout {
    // --- Slot 0: two uint128 values pack into one 32-byte slot ---
    uint128 public a; // lower 16 bytes of slot 0
    uint128 public b; // upper 16 bytes of slot 0

    // --- Slot 1 and Slot 2: uint256 occupies a full slot each ---
    uint256 public c; // slot 1
    uint256 public d; // slot 2

    // --- Slot 3: dynamic array (length stored here) ---
    uint256[] public arr;

    // --- Slot 4: mapping (slot itself is empty, values at computed locations) ---
    mapping(address => uint256) public map;

    /// @notice Read the raw contents of slot 0 showing packed variables a and b
    /// @dev uint128 a is in the lower 16 bytes, uint128 b is in the upper 16 bytes
    /// @return data The full 32-byte contents of slot 0
    function getSlot0() external view returns (bytes32 data) {
        assembly {
            // sload reads a full 32-byte word from the given storage slot
            data := sload(0)
        }
    }

    /// @notice Returns the slot number where the dynamic array length is stored
    /// @dev For `arr` declared as the 5th variable (index 4 counting from 0),
    ///      but it's actually at slot 3 because a and b share slot 0
    /// @return data The slot number as bytes32
    function getArraySlot() external pure returns (bytes32 data) {
        assembly {
            // arr.slot is a compile-time constant representing
            // the storage slot assigned to the array's length
            data := arr.slot
        }
    }

    /// @notice Computes the storage slot where arr[index] is stored
    /// @dev Element slot = keccak256(abi.encode(arraySlot)) + index
    ///      The EVM hashes the array's slot number to find the base,
    ///      then adds the index offset
    /// @param index The array index
    /// @return slot The storage slot of arr[index]
    function getArrayElementSlot(uint256 index) external pure returns (bytes32 slot) {
        assembly {
            // Store the array's slot number at memory position 0x00
            // This is scratch space — safe to use temporarily
            mstore(0x00, arr.slot)

            // keccak256 over 32 bytes starting at 0x00 gives the base slot
            // for array elements
            let baseSlot := keccak256(0x00, 0x20)

            // Each element occupies one full slot, so element i is at base + i
            slot := add(baseSlot, index)
        }
    }

    /// @notice Computes the storage slot where map[key] is stored
    /// @dev Slot = keccak256(abi.encode(key, mappingSlot))
    ///      The EVM concatenates the key (left-padded to 32 bytes)
    ///      with the mapping's slot number, then hashes the 64 bytes
    /// @param key The mapping key (address)
    /// @return slot The storage slot of map[key]
    function getMappingSlot(address key) external pure returns (bytes32 slot) {
        assembly {
            // Store the key in scratch space at 0x00 (left-padded to 32 bytes)
            mstore(0x00, key)

            // Store the mapping's slot number at 0x20 (next 32 bytes)
            mstore(0x20, map.slot)

            // Hash the 64-byte region [key (32 bytes) | slot (32 bytes)]
            // This produces the storage slot for map[key]
            slot := keccak256(0x00, 0x40)
        }
    }

    /// @notice Read the raw 32-byte contents of any storage slot
    /// @dev Uses sload to perform a direct storage read
    /// @param slot The storage slot number to read
    /// @return data The 32-byte value stored at that slot
    function readSlot(uint256 slot) external view returns (bytes32 data) {
        assembly {
            // sload reads the full 32-byte word at the given slot
            data := sload(slot)
        }
    }

    /// @notice Set packed values a, b and full-slot value c
    /// @dev a and b will pack into slot 0; c occupies slot 1
    /// @param _a Value for uint128 a (lower half of slot 0)
    /// @param _b Value for uint128 b (upper half of slot 0)
    /// @param _c Value for uint256 c (slot 1)
    function setValues(uint128 _a, uint128 _b, uint256 _c) external {
        assembly {
            // Build the packed slot 0 value:
            // b occupies the upper 128 bits, a occupies the lower 128 bits
            // Shift _b left by 128 bits, then OR with _a
            let packed := or(shl(128, _b), _a)

            // Write the packed value to slot 0
            sstore(0, packed)

            // Write _c to slot 1 (c.slot)
            sstore(c.slot, _c)
        }
    }

    /// @notice Push a value to the dynamic array
    /// @dev Increments length at the array's slot, then writes the value
    ///      at keccak256(arraySlot) + (newLength - 1)
    /// @param val The value to append
    function pushToArray(uint256 val) external {
        assembly {
            // Load current array length from its slot
            let len := sload(arr.slot)

            // Increment length and store it back
            let newLen := add(len, 1)
            sstore(arr.slot, newLen)

            // Compute base slot for array elements: keccak256(arr.slot)
            mstore(0x00, arr.slot)
            let baseSlot := keccak256(0x00, 0x20)

            // Store the new value at baseSlot + len (old length = new index)
            sstore(add(baseSlot, len), val)
        }
    }

    /// @notice Set a value in the mapping
    /// @dev Computes keccak256(abi.encode(key, mappingSlot)) and stores value there
    /// @param key The address key
    /// @param val The value to store
    function setMapping(address key, uint256 val) external {
        assembly {
            // Store key at scratch space 0x00
            mstore(0x00, key)

            // Store mapping slot number at 0x20
            mstore(0x20, map.slot)

            // Compute the storage slot for this key
            let slot := keccak256(0x00, 0x40)

            // Write the value to the computed slot
            sstore(slot, val)
        }
    }
}
