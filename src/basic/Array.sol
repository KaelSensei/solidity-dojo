// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Array
/// @notice Demonstrates dynamic and fixed-size arrays.
/// @dev Dynamic arrays can grow/shrink. Fixed-size arrays have compile-time size.
contract Array {
    /// @notice Dynamic array of uint256
    uint256[] public arr;

    /// @notice Fixed-size array of uint256 (size 10)
    uint256[10] public fixedArr;

    /// @notice Pushes a value to the dynamic array
    function push(uint256 value) external {
        arr.push(value);
    }

    /// @notice Removes and returns the last element
    /// @return The removed element
    function pop() external returns (uint256) {
        require(arr.length > 0, "Empty array");
        uint256 val = arr[arr.length - 1];
        arr.pop();
        return val;
    }

    /// @notice Gets the length of the dynamic array
    function getLength() external view returns (uint256) {
        return arr.length;
    }

    /// @notice Gets element at index
    function get(uint256 i) external view returns (uint256) {
        require(i < arr.length, "Index out of bounds");
        return arr[i];
    }

    /// @notice Removes element at index by shifting (preserves order, O(n))
    /// @dev Shifts all elements after index left by one
    function removeByShift(uint256 index) external {
        require(index < arr.length, "Index out of bounds");
        for (uint256 i = index; i < arr.length - 1; i++) {
            arr[i] = arr[i + 1];
        }
        arr.pop();
    }

    /// @notice Removes element at index by swap-delete (O(1), breaks order)
    /// @dev Swaps with last element then pops
    function removeBySwap(uint256 index) external {
        require(index < arr.length, "Index out of bounds");
        arr[index] = arr[arr.length - 1];
        arr.pop();
    }

    /// @notice Deletes element at index (sets to 0, keeps length)
    /// @dev delete resets to default value but doesn't change array size
    function deleteAt(uint256 index) external {
        require(index < arr.length, "Index out of bounds");
        delete arr[index];
    }

    /// @notice Returns the entire array (may be expensive for large arrays)
    function getArray() external view returns (uint256[] memory) {
        return arr;
    }

    /// @notice Sets value in fixed-size array
    function setFixed(uint256 index, uint256 value) external {
        require(index < 10, "Index out of bounds");
        fixedArr[index] = value;
    }

    /// @notice Gets value from fixed-size array
    function getFixed(uint256 index) external view returns (uint256) {
        require(index < 10, "Index out of bounds");
        return fixedArr[index];
    }
}


