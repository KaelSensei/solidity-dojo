// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title MathLibrary
/// @notice Library with math functions
library MathLibrary {
    /// @notice Add two numbers with overflow check
    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Overflow");
        return c;
    }

    /// @notice Max of two numbers
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /// @notice Min of two numbers
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a <= b ? a : b;
    }

    /// @notice Calculate average
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + ((a ^ b) / 2);
    }
}

/// @title ArrayLibrary
/// @notice Library for array operations
library ArrayLibrary {
    /// @notice Find index of element, returns length if not found
    function find(uint256[] storage arr, uint256 value) internal view returns (uint256) {
        for (uint256 i = 0; i < arr.length;) {
            if (arr[i] == value) {
                return i;
            }
            unchecked { ++i; }
        }
        return arr.length;
    }

    /// @notice Remove element at index (unordered)
    function removeUnordered(uint256[] storage arr, uint256 index) internal {
        uint256 len = arr.length;
        require(index < len, "Index out of bounds");
        arr[index] = arr[len - 1];
        arr.pop();
    }
}

/// @title LibraryUser
/// @notice Contract using libraries
contract LibraryUser {
    using MathLibrary for uint256;
    using ArrayLibrary for uint256[];

    uint256[] public numbers;

    /// @notice Add safely using library
    function safeAdd(uint256 a, uint256 b) external pure returns (uint256) {
        return a.safeAdd(b);
    }

    /// @notice Get max using library
    function getMax(uint256 a, uint256 b) external pure returns (uint256) {
        return MathLibrary.max(a, b);
    }

    /// @notice Add number to array
    function addNumber(uint256 n) external {
        numbers.push(n);
    }

    /// @notice Find number in array
    function findNumber(uint256 n) external view returns (uint256) {
        return numbers.find(n);
    }

    /// @notice Remove number at index
    function removeAt(uint256 index) external {
        numbers.removeUnordered(index);
    }
}
