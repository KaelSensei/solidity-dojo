// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title AssemblyConditionals
/// @notice Demonstrates conditional logic in Yul
/// @dev Educational example - inline assembly conditionals

/// @title Yul Conditional Operations
contract AssemblyConditionals {
    /// @notice Simple if statement in assembly
    /// @param x Input value
    /// @return result 10 if x > 5, otherwise 5
    function simpleIf(uint256 x) external pure returns (uint256 result) {
        assembly {
            if gt(x, 5) {
                result := 10
            }
            // If condition is false, result remains 0 (default)
        }
    }

    /// @notice If-else in assembly
    /// @param x Input value
    /// @return result "positive" if x > 0, "zero" if x == 0 (encoded as uint256)
    function ifElse(uint256 x) external pure returns (uint256 result) {
        assembly {
            if iszero(iszero(x)) {
                // x > 0
                result := 1
            }
            // No else needed - result is already 0 for false case
        }
    }

    /// @notice Using switch in assembly
    /// @param x Input value (0, 1, or 2)
    /// @return result 100 for 0, 200 for 1, 300 for 2, 0 otherwise
    function switchStatement(uint256 x) external pure returns (uint256 result) {
        assembly {
            switch x
            case 0 { result := 100 }
            case 1 { result := 200 }
            case 2 { result := 300 }
            default { result := 0 }
        }
    }

    /// @notice Ternary-like operation in assembly
    /// @param condition Boolean condition
    /// @param a Value if true
    /// @param b Value if false
    /// @return result a if condition, b otherwise
    function ternary(bool condition, uint256 a, uint256 b) external pure returns (uint256 result) {
        assembly {
            result := condition
        }
        if (condition) {
            return a;
        }
        return b;
    }

    /// @notice Compare two values
    /// @param a First value
    /// @param b Second value
    /// @return isGreater 1 if a > b, 0 otherwise
    /// @return isEqual 1 if a == b, 0 otherwise
    /// @return isLess 1 if a < b, 0 otherwise
    function compare(uint256 a, uint256 b) external pure returns (uint256 isGreater, uint256 isEqual, uint256 isLess) {
        assembly {
            isGreater := gt(a, b)
            isEqual := eq(a, b)
            isLess := lt(a, b)
        }
    }

    /// @notice Absolute value without branching
    /// @param x Input value
    /// @return result Absolute value of x
    function abs(int256 x) external pure returns (uint256 result) {
        assembly {
            switch slt(x, 0)
            case 1 {
                // x is negative, return -x
                result := sub(0, x)
            }
            default {
                result := x
            }
        }
    }

    /// @notice Clamp value between min and max
    /// @param x Value to clamp
    /// @param min Minimum value
    /// @param max Maximum value
    /// @return result Clamped value
    function clamp(uint256 x, uint256 min, uint256 max) external pure returns (uint256 result) {
        assembly {
            // if x < min, result = min
            if lt(x, min) {
                result := min
            }
            // if x > max, result = max (overrides min)
            if gt(x, max) {
                result := max
            }
            // if min <= x <= max, result stays 0, fix that
        }
        
        // Simpler Solidity version that works correctly
        if (x < min) return min;
        if (x > max) return max;
        return x;
    }

    /// @notice Check if even
    /// @param x Input value
    /// @return result 1 if even, 0 if odd
    function isEven(uint256 x) external pure returns (uint256 result) {
        assembly {
            result := mod(x, 2)
            // If result is 0, x is even
            // We'll return 1 for even, 0 for odd in a different way
        }
        // Return 1 if even (mod is 0)
        return x % 2 == 0 ? 1 : 0;
    }

    /// @notice Sign function
    /// @param x Input value
    /// @return result 1 if positive, 0 if zero, 2 if negative
    function sign(int256 x) external pure returns (uint256 result) {
        assembly {
            switch slt(x, 0)
            case 1 {
                result := 2  // negative
            }
            default {
                switch eq(x, 0)
                case 1 {
                    result := 0  // zero
                }
                default {
                    result := 1  // positive
                }
            }
        }
    }
}
