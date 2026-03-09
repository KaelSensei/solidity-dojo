// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title AssemblyArray
/// @notice Dynamic array operations implemented in Yul
/// @dev Educational example - inline assembly array operations

/// @title Yul Array Operations
contract AssemblyArray {
    /// @notice Get array length
    /// @param arr Dynamic array
    /// @return length Array length
    function length(uint256[] calldata arr) external pure returns (uint256 length) {
        assembly {
            length := arr.length
        }
    }

    /// @notice Get element at index
    /// @param arr Array
    /// @param index Index
    /// @return value Element value
    function get(uint256[] calldata arr, uint256 index) external pure returns (uint256 value) {
        require(index < arr.length, "Out of bounds");
        
        assembly {
            // Calldata layout: offset (32 bytes) + length (32 bytes) + data
            // 0x04 + index * 0x20
            value := calldataload(add(0x24, mul(index, 0x20)))
        }
    }

    /// @notice Find index of element
    /// @param arr Array to search
    /// @param target Target value
    /// @return index Index or length if not found
    function indexOf(uint256[] calldata arr, uint256 target) external pure returns (uint256 index) {
        assembly {
            index := arr.length // Default "not found"
            
            for { let i := 0 } lt(i, arr.length) { i := add(i, 1) } {
                let elem := calldataload(add(0x24, mul(i, 0x20)))
                if eq(elem, target) {
                    index := i
                    break
                }
            }
        }
    }

    /// @notice Check if array contains element
    /// @param arr Array to search
    /// @param target Target value
    /// @return found True if found
    function contains(uint256[] calldata arr, uint256 target) external pure returns (bool found) {
        // Search for target
        found = false;
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == target) {
                found = true;
                break;
            }
        }
    }

    /// @notice Sum all elements
    /// @param arr Array to sum
    /// @return total Sum
    function sum(uint256[] calldata arr) external pure returns (uint256 total) {
        assembly {
            for { let i := 0 } lt(i, arr.length) { i := add(i, 1) } {
                let elem := calldataload(add(0x24, mul(i, 0x20)))
                total := add(total, elem)
            }
        }
    }

    /// @notice Find maximum element
    /// @param arr Array
    /// @return maxValue Maximum value
    function max(uint256[] calldata arr) external pure returns (uint256 maxValue) {
        require(arr.length > 0, "Empty array");
        
        assembly {
            maxValue := calldataload(0x24) // First element
            
            for { let i := 1 } lt(i, arr.length) { i := add(i, 1) } {
                let elem := calldataload(add(0x24, mul(i, 0x20)))
                if gt(elem, maxValue) {
                    maxValue := elem
                }
            }
        }
    }

    /// @notice Find minimum element
    /// @param arr Array
    /// @return minValue Minimum value
    function min(uint256[] calldata arr) external pure returns (uint256 minValue) {
        require(arr.length > 0, "Empty array");
        
        assembly {
            minValue := calldataload(0x24)
            
            for { let i := 1 } lt(i, arr.length) { i := add(i, 1) } {
                let elem := calldataload(add(0x24, mul(i, 0x20)))
                if lt(elem, minValue) {
                    minValue := elem
                }
            }
        }
    }

    /// @notice Count occurrences of value
    /// @param arr Array
    /// @param value Value to count
    /// @return count Occurrences
    function count(uint256[] calldata arr, uint256 value) external pure returns (uint256 count) {
        assembly {
            for { let i := 0 } lt(i, arr.length) { i := add(i, 1) } {
                let elem := calldataload(add(0x24, mul(i, 0x20)))
                if eq(elem, value) {
                    count := add(count, 1)
                }
            }
        }
    }

    /// @notice Get first element
    /// @param arr Array
    /// @return value First element
    function first(uint256[] calldata arr) external pure returns (uint256 value) {
        require(arr.length > 0, "Empty array");
        
        assembly {
            value := calldataload(0x24)
        }
    }

    /// @notice Get last element
    /// @param arr Array
    /// @return value Last element
    function last(uint256[] calldata arr) external pure returns (uint256 value) {
        require(arr.length > 0, "Empty array");
        
        assembly {
            let lastIdx := sub(arr.length, 1)
            value := calldataload(add(0x24, mul(lastIdx, 0x20)))
        }
    }

    /// @notice Check if array is empty
    /// @param arr Array
    /// @return isEmpty True if empty
    function isEmpty(uint256[] calldata arr) external pure returns (bool isEmpty) {
        assembly {
            isEmpty := iszero(arr.length)
        }
    }
}
