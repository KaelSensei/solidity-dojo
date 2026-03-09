// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IfElse
/// @notice Demonstrates conditional branching with if/else and ternary operator.
/// @dev Solidity supports standard if/else/else if syntax and ternary expressions.
contract IfElse {
    /// @notice Returns a number based on input using if/else
    /// @param x Input number
    /// @return A number determined by the condition
    /// @dev Demonstrates if/else if/else chain
    function ifElse(uint256 x) external pure returns (uint256) {
        if (x < 10) {
            return 0;
        } else if (x < 20) {
            return 1;
        } else {
            return 2;
        }
    }

    /// @notice Returns a number based on input using ternary operator
    /// @param x Input number
    /// @return A number determined by the condition
    /// @dev Ternary: condition ? valueIfTrue : valueIfFalse
    function ternary(uint256 x) external pure returns (uint256) {
        return x < 10 ? 0 : (x < 20 ? 1 : 2);
    }

    /// @notice Returns true if x is even, false otherwise
    /// @param x Input number
    /// @return Whether x is even
    function isEven(uint256 x) external pure returns (bool) {
        return x % 2 == 0;
    }

    /// @notice Returns the maximum of two numbers
    /// @param a First number
    /// @param b Second number
    /// @return The larger of the two numbers
    function max(uint256 a, uint256 b) external pure returns (uint256) {
        return a >= b ? a : b;
    }

    /// @notice Returns the sign of a number
    /// @param x Input number (can be negative)
    /// @return 0 for zero, 1 for positive, 2 for negative
    function sign(int256 x) external pure returns (uint256) {
        if (x == 0) {
            return 0;
        } else if (x > 0) {
            return 1;
        } else {
            return 2;
        }
    }
}
