// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title AssemblyMath
/// @notice Demonstrates inline assembly (Yul) for gas-efficient math.
/// @dev Yul is an intermediate language that compiles to EVM bytecode.
contract AssemblyMath {
    /// @notice Adds two numbers using assembly
    /// @param x First number
    /// @param y Second number
    /// @return result Sum of x and y
    function addAssembly(uint256 x, uint256 y) external pure returns (uint256 result) {
        assembly {
            // Add x and y, store in result
            result := add(x, y)

            // Overflow check: if result < x, overflow occurred
            if lt(result, x) {
                revert(0, 0)
            }
        }
    }

    /// @notice Multiplies two numbers using assembly
    /// @param x First number
    /// @param y Second number
    /// @return result Product of x and y
    function mulAssembly(uint256 x, uint256 y) external pure returns (uint256 result) {
        assembly {
            result := mul(x, y)

            // Overflow check: if x != 0 and result / x != y, overflow occurred
            if iszero(or(iszero(x), eq(div(result, x), y))) {
                revert(0, 0)
            }
        }
    }

    /// @notice Calculates power using binary exponentiation in assembly
    /// @param base Base number
    /// @param exponent Exponent
    /// @return result base^exponent
    function powAssembly(uint256 base, uint256 exponent) external pure returns (uint256 result) {
        assembly {
            result := 1
            for { } gt(exponent, 0) { } {
                // If exponent is odd, multiply result by base
                if and(exponent, 1) {
                    result := mul(result, base)
                }
                // Square the base
                base := mul(base, base)
                // Divide exponent by 2
                exponent := shr(1, exponent)
            }
        }
    }

    /// @notice Compares two numbers using assembly
    /// @param x First number
    /// @param y Second number
    /// @return isEqual True if x == y
    function eqAssembly(uint256 x, uint256 y) external pure returns (bool isEqual) {
        assembly {
            isEqual := eq(x, y)
        }
    }

    /// @notice Returns the larger of two numbers using assembly
    /// @param x First number
    /// @param y Second number
    /// @return max The larger number
    function maxAssembly(uint256 x, uint256 y) external pure returns (uint256 max) {
        assembly {
            // if x >= y, return x, else return y
            switch iszero(lt(x, y))
            case 1 { max := x }
            default { max := y }
        }
    }

    /// @notice Calculates sum of array using assembly loop
    /// @param arr Array of numbers
    /// @return sum Sum of all elements
    function sumArrayAssembly(uint256[] calldata arr) external pure returns (uint256 sum) {
        assembly {
            // ABI encoding: first word after selector (byte 4) is offset to array data
            // Offset is relative to start of encoded params (byte 4)
            let paramOffset := calldataload(4)
            // Array data: length at (4 + paramOffset), elements follow
            let length := calldataload(add(4, paramOffset))
            let dataOffset := add(add(4, paramOffset), 0x20)

            for { let i := 0 } lt(i, length) { i := add(i, 1) } {
                sum := add(sum, calldataload(dataOffset))
                dataOffset := add(dataOffset, 0x20)
            }
        }
    }
}
