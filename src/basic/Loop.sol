// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Loop
/// @notice Demonstrates for loops, while loops, break, and continue.
/// @dev Loops can be dangerous if unbounded due to gas limits.
///      Always ensure loops have a bounded number of iterations.
contract Loop {
    /// @notice Calculates sum from 1 to n using a for loop
    /// @param n The upper bound (inclusive)
    /// @return sum The sum from 1 to n
    /// @dev Formula: n * (n + 1) / 2 should match this result
    function sumFor(uint256 n) external pure returns (uint256 sum) {
        for (uint256 i = 1; i <= n;) {
            sum += i;
            unchecked { ++i; }
        }
    }

    /// @notice Calculates sum from 1 to n using a while loop
    /// @param n The upper bound (inclusive)
    /// @return sum The sum from 1 to n
    function sumWhile(uint256 n) external pure returns (uint256 sum) {
        uint256 i = 1;
        while (i <= n) {
            sum += i;
            unchecked { ++i; }
        }
    }

    /// @notice Sums array elements until a target is reached or array ends
    /// @param arr The array to sum
    /// @param target Stop when sum exceeds this value
    /// @return sum The calculated sum
    /// @dev Demonstrates break statement
    function sumUntilTarget(uint256[] calldata arr, uint256 target)
        external
        pure
        returns (uint256 sum)
    {
        for (uint256 i = 0; i < arr.length;) {
            sum += arr[i];
            if (sum >= target) {
                break;
            }
            unchecked { ++i; }
        }
    }

    /// @notice Sums only even numbers from array
    /// @param arr The array to process
    /// @return sum Sum of even elements only
    /// @dev Demonstrates continue statement
    function sumOnlyEven(uint256[] calldata arr) external pure returns (uint256 sum) {
        for (uint256 i = 0; i < arr.length;) {
            if (arr[i] % 2 != 0) {
                unchecked { ++i; }
                continue;
            }
            sum += arr[i];
            unchecked { ++i; }
        }
    }

    /// @notice Finds the index of a value in an array
    /// @param arr The array to search
    /// @param value The value to find
    /// @return index The index of the value, or type(uint256).max if not found
    function findIndex(uint256[] calldata arr, uint256 value)
        external
        pure
        returns (uint256 index)
    {
        index = type(uint256).max;
        for (uint256 i = 0; i < arr.length;) {
            if (arr[i] == value) {
                index = i;
                break;
            }
            unchecked { ++i; }
        }
    }

    /// @notice Calculates factorial of n
    /// @param n Input number (should be small to avoid overflow)
    /// @return result n!
    /// @dev Will overflow for n > 20 due to uint256 limits
    function factorial(uint8 n) external pure returns (uint256 result) {
        result = 1;
        for (uint8 i = 2; i <= n;) {
            result *= i;
            unchecked { ++i; }
        }
    }
}
