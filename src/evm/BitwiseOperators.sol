// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title BitwiseOperators
/// @notice Demonstrates bitwise operations in Yul
/// @dev Educational example - inline assembly bitwise operations

/// @title Yul Bitwise Operations
contract BitwiseOperators {
    /// @notice Bitwise AND
    /// @param a First value
    /// @param b Second value
    /// @return result Bitwise AND of a and b
    function and(uint256 a, uint256 b) external pure returns (uint256 result) {
        assembly {
            result := and(a, b)
        }
    }

    /// @notice Bitwise OR
    /// @param a First value
    /// @param b Second value
    /// @return result Bitwise OR of a and b
    function or(uint256 a, uint256 b) external pure returns (uint256 result) {
        assembly {
            result := or(a, b)
        }
    }

    /// @notice Bitwise XOR
    /// @param a First value
    /// @param b Second value
    /// @return result Bitwise XOR of a and b
    function xor(uint256 a, uint256 b) external pure returns (uint256 result) {
        assembly {
            result := xor(a, b)
        }
    }

    /// @notice Bitwise NOT
    /// @param a Value
    /// @return result Bitwise NOT of a
    function not(uint256 a) external pure returns (uint256 result) {
        assembly {
            result := not(a)
        }
    }

    /// @notice Left shift
    /// @param a Value to shift
    /// @param bits Number of bits
    /// @return result Left shifted value
    function shiftLeft(uint256 a, uint256 bits) external pure returns (uint256 result) {
        assembly {
            result := shl(bits, a)
        }
    }

    /// @notice Right shift
    /// @param a Value to shift
    /// @param bits Number of bits
    /// @return result Right shifted value
    function shiftRight(uint256 a, uint256 bits) external pure returns (uint256 result) {
        assembly {
            result := shr(bits, a)
        }
    }

    /// @notice Get bit at position
    /// @param a Value
    /// @param pos Bit position
    /// @return result Bit value (0 or 1)
    function getBit(uint256 a, uint256 pos) external pure returns (uint256 result) {
        assembly {
            result := and(shr(pos, a), 1)
        }
    }

    /// @notice Set bit at position
    /// @param a Value
    /// @param pos Bit position
    /// @return result Value with bit set
    function setBit(uint256 a, uint256 pos) external pure returns (uint256 result) {
        assembly {
            result := or(a, shl(pos, 1))
        }
    }

    /// @notice Clear bit at position
    /// @param a Value
    /// @param pos Bit position
    /// @return result Value with bit cleared
    function clearBit(uint256 a, uint256 pos) external pure returns (uint256 result) {
        assembly {
            result := and(a, not(shl(pos, 1)))
        }
    }

    /// @notice Toggle bit at position
    /// @param a Value
    /// @param pos Bit position
    /// @return result Value with bit toggled
    function toggleBit(uint256 a, uint256 pos) external pure returns (uint256 result) {
        assembly {
            result := xor(a, shl(pos, 1))
        }
    }

    /// @notice Count trailing zeros
    /// @param a Value
    /// @return count Number of trailing zeros
    function trailingZeros(uint256 a) external pure returns (uint256 count) {
        if (a == 0) return 256;
        
        assembly {
            for { } iszero(and(a, 1)) { } {
                count := add(count, 1)
                a := shr(1, a)
            }
        }
    }

    /// @notice Count leading zeros
    /// @param a Value
    /// @return count Number of leading zeros
    function leadingZeros(uint256 a) external pure returns (uint256 count) {
        if (a == 0) return 256;
        
        assembly {
            for { } lt(and(a, 0x8000000000000000000000000000000000000000000000000000000000000000), 1) { } {
                count := add(count, 1)
                a := shl(1, a)
            }
        }
    }

    /// @notice Count set bits (population count)
    /// @param a Value
    /// @return count Number of 1 bits
    function popCount(uint256 a) external pure returns (uint256 count) {
        assembly {
            for { } a { } {
                count := add(count, 1)
                a := and(a, sub(a, 1))
            }
        }
    }

    /// @notice Check if power of 2
    /// @param a Value
    /// @return result True if power of 2
    function isPowerOfTwo(uint256 a) external pure returns (bool result) {
        if (a == 0) return false;
        
        assembly {
            result := iszero(and(a, sub(a, 1)))
        }
    }

    /// @notice Rotate left
    /// @param a Value
    /// @param r Rotation amount
    /// @return result Rotated value
    function rotateLeft(uint256 a, uint256 r) external pure returns (uint256 result) {
        r = r % 256;
        assembly {
            result := or(shl(r, a), shr(sub(256, r), a))
        }
    }

    /// @notice Rotate right
    /// @param a Value
    /// @param r Rotation amount
    /// @return result Rotated value
    function rotateRight(uint256 a, uint256 r) external pure returns (uint256 result) {
        r = r % 256;
        assembly {
            result := or(shr(r, a), shl(sub(256, r), a))
        }
    }

    /// @notice Byteswap (reverse endianness)
    /// @param a Value
    /// @return result Byte-reversed value
    function byteSwap(uint256 a) external pure returns (uint256 result) {
        assembly {
            // Swap bytes in 32-byte word
            result := 0
            for { let i := 0 } lt(i, 32) { i := add(i, 1) } {
                let byteVal := and(shr(mul(i, 8), a), 0xff)
                result := or(result, shl(mul(sub(31, i), 8), byteVal))
            }
        }
    }

    /// @notice Bit mask
    /// @param pos Starting position
    /// @param width Number of bits
    /// @return result Mask
    function bitMask(uint256 pos, uint256 width) external pure returns (uint256 result) {
        assembly {
            result := sub(shl(width, 1), 1)
            result := shl(pos, result)
        }
    }
}
