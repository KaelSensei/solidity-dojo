// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/evm/BitwiseOperators.sol";

/// @title Bitwise Operators Test Suite
contract BitwiseOperatorsTest is Test {
    BitwiseOperators public bitwise;

    function setUp() public {
        bitwise = new BitwiseOperators();
    }

    /// @notice Test AND
    function test_And() public {
        assertEq(bitwise.and(0xFF, 0x0F), 0x0F);
        assertEq(bitwise.and(0xAA, 0x55), 0x00);
        assertEq(bitwise.and(0xFFFF, 0xFFFF), 0xFFFF);
    }

    /// @notice Test OR
    function test_Or() public {
        assertEq(bitwise.or(0x0F, 0xF0), 0xFF);
        assertEq(bitwise.or(0xAA, 0x55), 0xFF);
        assertEq(bitwise.or(0x00, 0xFF), 0xFF);
    }

    /// @notice Test XOR
    function test_Xor() public {
        assertEq(bitwise.xor(0xFF, 0x0F), 0xF0);
        assertEq(bitwise.xor(0xAA, 0x55), 0xFF);
        assertEq(bitwise.xor(0x00, 0xFF), 0xFF);
    }

    /// @notice Test NOT
    function test_Not() public {
        assertEq(bitwise.not(0x00), type(uint256).max);
        assertEq(bitwise.not(type(uint256).max), 0);
    }

    /// @notice Test shift left
    function test_ShiftLeft() public {
        assertEq(bitwise.shiftLeft(1, 0), 1);
        assertEq(bitwise.shiftLeft(1, 1), 2);
        assertEq(bitwise.shiftLeft(1, 8), 256);
        assertEq(bitwise.shiftLeft(1, 10), 1024);
    }

    /// @notice Test shift right
    function test_ShiftRight() public {
        assertEq(bitwise.shiftRight(256, 8), 1);
        assertEq(bitwise.shiftRight(1024, 10), 1);
        assertEq(bitwise.shiftRight(100, 2), 25);
    }

    /// @notice Test getBit
    function test_GetBit() public {
        assertEq(bitwise.getBit(0x0A, 0), 0); // 1010 in binary = bit 0 is 0
        assertEq(bitwise.getBit(0x0A, 1), 1); // bit 1 is 1
        assertEq(bitwise.getBit(0x0A, 2), 0); // bit 2 is 0
        assertEq(bitwise.getBit(0x0A, 3), 1); // bit 3 is 1
    }

    /// @notice Test setBit
    function test_SetBit() public {
        assertEq(bitwise.setBit(0x08, 0), 0x09); // 1000 -> 1001
        assertEq(bitwise.setBit(0x00, 2), 0x04); // 0000 -> 0100
    }

    /// @notice Test clearBit
    function test_ClearBit() public {
        assertEq(bitwise.clearBit(0x0D, 2), 0x09); // 1101 -> 1001
        assertEq(bitwise.clearBit(0x0F, 0), 0x0E); // 1111 -> 1110
    }

    /// @notice Test toggleBit
    function test_ToggleBit() public {
        assertEq(bitwise.toggleBit(0x0F, 0), 0x0E); // 1111 -> 1110
        assertEq(bitwise.toggleBit(0x00, 3), 0x08); // 0000 -> 1000
    }

    /// @notice Test trailingZeros
    function test_TrailingZeros() public {
        assertEq(bitwise.trailingZeros(0x08), 3); // 1000 in binary
        assertEq(bitwise.trailingZeros(0x01), 0); // 1 in binary
        assertEq(bitwise.trailingZeros(0x80), 7); // 10000000 in binary
    }

    /// @notice Test leadingZeros
    function test_LeadingZeros() public {
        assertEq(bitwise.leadingZeros(0x8000000000000000000000000000000000000000000000000000000000000000), 0);
        // 0x0100000000000000000000000000000000000000000000000000000000000000 has 7 leading zeros (1 at bit 248)
        assertEq(bitwise.leadingZeros(0x0100000000000000000000000000000000000000000000000000000000000000), 7);
    }

    /// @notice Test popCount
    function test_PopCount() public {
        assertEq(bitwise.popCount(0), 0);
        assertEq(bitwise.popCount(0x1), 1);  // 1 in binary
        assertEq(bitwise.popCount(0x3), 2);  // 11 in binary
        assertEq(bitwise.popCount(0xFF), 8);
    }

    /// @notice Test isPowerOfTwo
    function test_IsPowerOfTwo() public {
        assertTrue(bitwise.isPowerOfTwo(1));
        assertTrue(bitwise.isPowerOfTwo(2));
        assertTrue(bitwise.isPowerOfTwo(4));
        assertTrue(bitwise.isPowerOfTwo(16));
        assertTrue(!bitwise.isPowerOfTwo(0));
        assertTrue(!bitwise.isPowerOfTwo(3));
        assertTrue(!bitwise.isPowerOfTwo(100));
    }

    /// @notice Test rotate left
    function test_RotateLeft() public {
        assertEq(bitwise.rotateLeft(0x0000000000000000000000000000000000000000000000000000000000000001, 4), 
                 0x0000000000000000000000000000000000000000000000000000000000000010);
    }

    /// @notice Test rotate right
    function test_RotateRight() public {
        assertEq(bitwise.rotateRight(0x0000000000000000000000000000000000000000000000000000000000000001, 4), 
                 0x1000000000000000000000000000000000000000000000000000000000000000);
    }

    /// @notice Test byteSwap
    function test_ByteSwap() public {
        // Simple test - swap bytes in a value
        assertEq(bitwise.byteSwap(0x00000000000000000000000000000000000000000000000000000000000000AB),
                 0xAB00000000000000000000000000000000000000000000000000000000000000);
    }

    /// @notice Test bitMask
    function test_BitMask() public {
        assertEq(bitwise.bitMask(0, 8), 0xFF);
        assertEq(bitwise.bitMask(8, 8), 0xFF00);
        assertEq(bitwise.bitMask(4, 4), 0xF0);
    }

    /// @notice Fuzz test AND
    function testFuzz_And(uint256 a, uint256 b) public {
        assertEq(bitwise.and(a, b), a & b);
    }

    /// @notice Fuzz test OR
    function testFuzz_Or(uint256 a, uint256 b) public {
        assertEq(bitwise.or(a, b), a | b);
    }

    /// @notice Fuzz test XOR
    function testFuzz_Xor(uint256 a, uint256 b) public {
        assertEq(bitwise.xor(a, b), a ^ b);
    }

    /// @notice Fuzz test shift left
    function testFuzz_ShiftLeft(uint256 a, uint8 bits) public {
        bits = bits % 100;
        assertEq(bitwise.shiftLeft(a, bits), a << bits);
    }

    /// @notice Fuzz test shift right
    function testFuzz_ShiftRight(uint256 a, uint8 bits) public {
        bits = bits % 100;
        assertEq(bitwise.shiftRight(a, bits), a >> bits);
    }

    /// @notice Fuzz test popCount
    function testFuzz_PopCount(uint256 a) public {
        uint256 count = 0;
        uint256 x = a;
        while (x > 0) {
            if (x & 1 == 1) count++;
            x >>= 1;
        }
        assertEq(bitwise.popCount(a), count);
    }

    /// @notice Fuzz test isPowerOfTwo
    function testFuzz_IsPowerOfTwo(uint256 a) public {
        bool expected = a != 0 && (a & (a - 1)) == 0;
        assertEq(bitwise.isPowerOfTwo(a) ? 1 : 0, expected ? 1 : 0);
    }

    /// @notice Fuzz test getBit
    function testFuzz_GetBit(uint256 a, uint8 pos) public {
        uint256 position = pos % 256;
        assertEq(bitwise.getBit(a, position), (a >> position) & 1);
    }
}
