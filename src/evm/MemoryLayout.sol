// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title MemoryLayout
/// @notice Demonstrates how the EVM organizes and manages memory
/// @dev Educational example - memory regions, free memory pointer, and ABI encoding
///
/// EVM memory layout:
/// - 0x00-0x3f  Scratch space (64 bytes) — used by hashing operations, safe for temp use
/// - 0x40-0x5f  Free memory pointer — points to the next available memory location
/// - 0x60-0x7f  Zero slot — always contains 0, used as initial value for dynamic memory
/// - 0x80+      Free memory — where allocations begin
///
/// Key properties:
/// - Memory is byte-addressable but operates in 32-byte (word) chunks
/// - Memory expansion costs gas quadratically: cost = memory_size_words^2 / 512
/// - ABI encoding in memory: each value is padded to 32 bytes

/// @title EVM Memory Layout Operations
contract MemoryLayout {
    /// @notice Read the current free memory pointer
    /// @dev The free memory pointer lives at address 0x40 and tracks
    ///      where the next memory allocation should begin.
    ///      Solidity initializes it to 0x80 (after reserved regions).
    /// @return ptr The current free memory pointer value
    function getFreeMemoryPointer() external pure returns (uint256 ptr) {
        assembly {
            // mload(0x40) reads the 32-byte word at memory address 0x40
            // This is the free memory pointer — Solidity's allocator bookmark
            ptr := mload(0x40)
        }
    }

    /// @notice Get the current size of active memory in bytes
    /// @dev msize returns the highest memory offset that has been accessed + 1,
    ///      rounded up to the nearest 32-byte word boundary.
    ///      Note: msize grows whenever memory beyond the current boundary is touched.
    /// @return size The current memory size in bytes
    function getMemorySize() external pure returns (uint256 size) {
        assembly {
            // msize returns the size of active memory in bytes
            // It tracks the highest offset accessed so far (rounded up to 32 bytes)
            size := msize()
        }
    }

    /// @notice Manually allocate memory by advancing the free memory pointer
    /// @dev Mimics what Solidity does internally for `new` and `abi.encode`:
    ///      1. Read current pointer from 0x40
    ///      2. Calculate new pointer (current + requested size)
    ///      3. Store new pointer at 0x40
    ///      4. Return the old pointer (start of allocated region)
    /// @param size Number of bytes to allocate
    /// @return ptr Pointer to the start of the allocated memory region
    function allocateMemory(uint256 size) external pure returns (uint256 ptr) {
        assembly {
            // Step 1: Read the current free memory pointer
            ptr := mload(0x40)

            // Step 2: Compute the new free memory pointer
            // The allocated region spans [ptr, ptr + size)
            let newPtr := add(ptr, size)

            // Step 3: Update the free memory pointer at 0x40
            // All future allocations will start from newPtr
            mstore(0x40, newPtr)

            // ptr (the old value) is returned as the start of our allocation
        }
    }

    /// @notice Write a value to freshly allocated memory and read it back
    /// @dev Demonstrates mstore (write) and mload (read) on allocated memory.
    ///      Allocates 32 bytes, writes the value, then reads it back.
    /// @param value The uint256 value to write and read
    /// @return result The value read back from memory (should equal input)
    function writeAndReadMemory(uint256 value) external pure returns (uint256 result) {
        assembly {
            // Allocate 32 bytes: read free pointer, advance it
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, 0x20))

            // mstore writes a 32-byte word to the given memory address
            mstore(ptr, value)

            // mload reads a 32-byte word from the given memory address
            result := mload(ptr)
        }
    }

    /// @notice Show how abi.encode lays out two uint256 values in memory
    /// @dev abi.encode produces a bytes array in memory with:
    ///      - First 32 bytes: length of the encoded data
    ///      - Following 32-byte slots: each value padded to 32 bytes
    ///      For two uint256 values, the layout is:
    ///        [length=64][value_a][value_b]
    /// @param a First value to encode
    /// @param b Second value to encode
    /// @return The ABI-encoded bytes
    function getAbiEncodedLayout(uint256 a, uint256 b) external pure returns (bytes memory) {
        // abi.encode writes to memory:
        //   offset 0x00 (relative): length = 64 (0x40)
        //   offset 0x20 (relative): a (32-byte padded)
        //   offset 0x40 (relative): b (32-byte padded)
        return abi.encode(a, b);
    }

    /// @notice Read the scratch space at memory addresses 0x00 and 0x20
    /// @dev Scratch space (0x00-0x3f) is used by Solidity for:
    ///      - keccak256 hashing (stores inputs temporarily)
    ///      - ecrecover and other precompiles
    ///      These slots are NOT safe for persistent data — any hash
    ///      operation may overwrite them.
    /// @return word0 The 32-byte word at memory address 0x00
    /// @return word1 The 32-byte word at memory address 0x20
    function getScratchSpace() external pure returns (bytes32 word0, bytes32 word1) {
        assembly {
            // Read the first 32 bytes of scratch space
            word0 := mload(0x00)

            // Read the second 32 bytes of scratch space
            word1 := mload(0x20)
        }
    }

    /// @notice Demonstrate that two sequential allocations don't overlap
    /// @dev Allocates two 32-byte regions and writes different values to each,
    ///      then reads both back to prove they occupy separate memory.
    /// @param val1 Value to write in the first allocation
    /// @param val2 Value to write in the second allocation
    /// @return read1 Value read from first allocation
    /// @return read2 Value read from second allocation
    function twoAllocations(uint256 val1, uint256 val2) external pure returns (uint256 read1, uint256 read2) {
        assembly {
            // First allocation: 32 bytes
            let ptr1 := mload(0x40)
            mstore(0x40, add(ptr1, 0x20))
            mstore(ptr1, val1)

            // Second allocation: 32 bytes (starts where first ended)
            let ptr2 := mload(0x40)
            mstore(0x40, add(ptr2, 0x20))
            mstore(ptr2, val2)

            // Read both back — they should not interfere
            read1 := mload(ptr1)
            read2 := mload(ptr2)
        }
    }

    /// @notice Read the zero slot at memory address 0x60
    /// @dev The zero slot (0x60-0x7f) is used as the initial value for
    ///      dynamic memory arrays and should always contain 0.
    /// @return value The 32-byte word at memory address 0x60
    function getZeroSlot() external pure returns (bytes32 value) {
        assembly {
            // The zero slot at 0x60 always contains zero
            // Solidity uses it as the default value for empty dynamic arrays
            value := mload(0x60)
        }
    }
}
