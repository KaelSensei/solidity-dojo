// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title GasGolf
/// @notice Side-by-side gas optimization comparison: unoptimized vs optimized.
/// @dev Both versions compute the same result: sum of even numbers < 99 in the array.
///      The optimized version applies: calldata, cached length, unchecked increment,
///      custom error, short-circuit evaluation, and pre-increment.
contract GasGolf {
    /// @notice Thrown when input array is empty
    error EmptyArray();

    /// @notice UNOPTIMIZED — uses memory, checked loop, require string, repeated .length
    /// @param nums Array of numbers
    /// @return total Sum of even numbers less than 99
    function sumIfEvenAndLessThan99_UNOPTIMIZED(uint256[] memory nums) external pure returns (uint256 total) {
        require(nums.length > 0, "Array must not be empty");
        for (uint256 i = 0; i < nums.length; i++) {
            bool isEven = nums[i] % 2 == 0;
            bool isLessThan99 = nums[i] < 99;
            if (isEven && isLessThan99) {
                total += nums[i];
            }
        }
    }

    /// @notice OPTIMIZED — calldata, cached length, unchecked, custom error, short-circuit
    /// @param nums Array of numbers (calldata avoids memory copy)
    /// @return total Sum of even numbers less than 99
    function sumIfEvenAndLessThan99(uint256[] calldata nums) external pure returns (uint256 total) {
        uint256 len = nums.length;
        if (len == 0) revert EmptyArray();
        for (uint256 i; i < len;) {
            uint256 num = nums[i];
            if (num < 99 && num % 2 == 0) {
                total += num;
            }
            unchecked { ++i; }
        }
    }
}
