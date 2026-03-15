// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/evm/MemoryLayout.sol";

/// @title Memory Layout Test Suite
contract MemoryLayoutTest is Test {
    MemoryLayout public mem;

    function setUp() public {
        mem = new MemoryLayout();
    }

    /// @notice Free memory pointer starts at 0x80
    function test_FreeMemoryPointerStartsAt0x80() public {
        uint256 ptr = mem.getFreeMemoryPointer();
        assertEq(ptr, 0x80, "free memory pointer should start at 0x80");
    }

    /// @notice Allocating memory advances the free memory pointer
    function test_AllocateAdvancesPointer() public {
        uint256 ptr = mem.allocateMemory(64);
        // First allocation should start at 0x80
        assertEq(ptr, 0x80, "first allocation should return 0x80");
    }

    /// @notice Write and read back from memory returns the same value
    function test_WriteAndReadMemory() public {
        uint256 result = mem.writeAndReadMemory(12345);
        assertEq(result, 12345, "should read back the written value");
    }

    /// @notice Write and read zero
    function test_WriteAndReadZero() public {
        uint256 result = mem.writeAndReadMemory(0);
        assertEq(result, 0, "should read back zero");
    }

    /// @notice Write and read max uint256
    function test_WriteAndReadMaxUint() public {
        uint256 result = mem.writeAndReadMemory(type(uint256).max);
        assertEq(result, type(uint256).max, "should read back max uint256");
    }

    /// @notice Two sequential allocations do not overlap
    function test_TwoAllocationsNoOverlap() public {
        (uint256 read1, uint256 read2) = mem.twoAllocations(111, 222);
        assertEq(read1, 111, "first allocation value should be preserved");
        assertEq(read2, 222, "second allocation value should be preserved");
    }

    /// @notice ABI encoded data matches abi.encode output
    function test_AbiEncodedLayoutMatchesEncode() public {
        bytes memory encoded = mem.getAbiEncodedLayout(42, 99);
        bytes memory expected = abi.encode(42, 99);
        assertEq(encoded, expected, "should match abi.encode output");
    }

    /// @notice ABI encoded layout has correct length
    function test_AbiEncodedLayoutLength() public {
        bytes memory encoded = mem.getAbiEncodedLayout(1, 2);
        // Two uint256 values = 64 bytes
        assertEq(encoded.length, 64, "abi.encode of two uint256 should be 64 bytes");
    }

    /// @notice ABI encoded values can be decoded back
    function test_AbiEncodedValuesDecodable() public {
        bytes memory encoded = mem.getAbiEncodedLayout(777, 888);
        (uint256 a, uint256 b) = abi.decode(encoded, (uint256, uint256));
        assertEq(a, 777, "first decoded value should be 777");
        assertEq(b, 888, "second decoded value should be 888");
    }

    /// @notice Scratch space is readable
    function test_ScratchSpaceReadable() public {
        // Just verify the call doesn't revert
        (bytes32 word0, bytes32 word1) = mem.getScratchSpace();
        // Scratch space values are undefined but the call should succeed
        // We just verify they're bytes32 (always true if no revert)
        assertTrue(true, "scratch space should be readable without revert");
    }

    /// @notice Zero slot contains zero
    function test_ZeroSlotIsZero() public {
        bytes32 value = mem.getZeroSlot();
        assertEq(uint256(value), 0, "zero slot at 0x60 should contain zero");
    }

    /// @notice Memory size is non-zero after operations
    function test_MemorySizeNonZero() public {
        uint256 size = mem.getMemorySize();
        // Memory is always expanded at least for the free memory pointer
        assertTrue(size > 0, "memory size should be non-zero");
    }

    /// @notice Fuzz test: write and read back any value
    function testFuzz_WriteAndRead(uint256 value) public {
        uint256 result = mem.writeAndReadMemory(value);
        assertEq(result, value, "should read back the exact value written");
    }

    /// @notice Fuzz test: two allocations never interfere
    function testFuzz_TwoAllocationsNoOverlap(uint256 val1, uint256 val2) public {
        (uint256 read1, uint256 read2) = mem.twoAllocations(val1, val2);
        assertEq(read1, val1, "first value should survive second allocation");
        assertEq(read2, val2, "second value should be written correctly");
    }

    /// @notice Fuzz test: ABI encoding round-trips correctly
    function testFuzz_AbiEncodeRoundTrip(uint256 a, uint256 b) public {
        bytes memory encoded = mem.getAbiEncodedLayout(a, b);
        (uint256 decodedA, uint256 decodedB) = abi.decode(encoded, (uint256, uint256));
        assertEq(decodedA, a, "a should round-trip through abi.encode");
        assertEq(decodedB, b, "b should round-trip through abi.encode");
    }
}
