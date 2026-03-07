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
    /// @param _value Value to add
    function push(uint256 _value) external {
        arr.push(_value);
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
    /// @param _i Index to retrieve
    function get(uint256 _i) external view returns (uint256) {
        require(_i < arr.length, "Index out of bounds");
        return arr[_i];
    }

    /// @notice Removes element at index by shifting (preserves order, O(n))
    /// @param _index Index to remove
    /// @dev Shifts all elements after index left by one
    function removeByShift(uint256 _index) external {
        require(_index < arr.length, "Index out of bounds");
        for (uint256 i = _index; i < arr.length - 1; i++) {
            arr[i] = arr[i + 1];
        }
        arr.pop();
    }

    /// @notice Removes element at index by swap-delete (O(1), breaks order)
    /// @param _index Index to remove
    /// @dev Swaps with last element then pops
    function removeBySwap(uint256 _index) external {
        require(_index < arr.length, "Index out of bounds");
        arr[_index] = arr[arr.length - 1];
        arr.pop();
    }

    /// @notice Deletes element at index (sets to 0, keeps length)
    /// @param _index Index to delete
    /// @dev delete resets to default value but doesn't change array size
    function deleteAt(uint256 _index) external {
        require(_index < arr.length, "Index out of bounds");
        delete arr[_index];
    }

    /// @notice Returns the entire array (may be expensive for large arrays)
    function getArray() external view returns (uint256[] memory) {
        return arr;
    }

    /// @notice Sets value in fixed-size array
    function setFixed(uint256 _index, uint256 _value) external {
        require(_index < 10, "Index out of bounds");
        fixedArr[_index] = _value;
    }

    /// @notice Gets value from fixed-size array
    function getFixed(uint256 _index) external view returns (uint256) {
        require(_index < 10, "Index out of bounds");
        return fixedArr[_index];
    }
}
