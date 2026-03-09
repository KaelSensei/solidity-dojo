// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title AssemblyLoop
/// @notice Demonstrates loops implemented in Yul
/// @dev Educational example - inline assembly loops

/// @title Yul Loop Operations
contract AssemblyLoop {
    /// @notice Sum numbers from 0 to n-1 using assembly loop
    /// @param n Upper limit (exclusive)
    /// @return sum Sum of 0 + 1 + 2 + ... + (n-1)
    function sumTo(uint256 n) external pure returns (uint256 sum) {
        assembly {
            for { let i := 0 } lt(i, n) { i := add(i, 1) } {
                sum := add(sum, i)
            }
        }
    }

    /// @notice Sum of even numbers up to n
    /// @param n Upper limit
    /// @return sum Sum of even numbers from 0 to n
    function sumEvens(uint256 n) external pure returns (uint256 sum) {
        assembly {
            for { let i := 0 } lt(i, n) { i := add(i, 2) } {
                sum := add(sum, i)
            }
        }
    }

    /// @notice Find maximum in array
    /// @param data Array of numbers
    /// @return max Maximum value
    function max(uint256[] calldata data) external pure returns (uint256 max) {
        if (data.length == 0) return 0;
        
        assembly {
            let base := add(0x04, calldataload(0x04))
            max := calldataload(add(base, 0x20))
            for { let i := 1 } lt(i, data.length) { i := add(i, 1) } {
                let elem := calldataload(add(base, add(0x20, mul(i, 0x20))))
                if gt(elem, max) {
                    max := elem
                }
            }
        }
    }

    /// @notice Find minimum in array
    /// @param data Array of numbers
    /// @return min Minimum value
    function min(uint256[] calldata data) external pure returns (uint256 min) {
        if (data.length == 0) return 0;
        
        assembly {
            let base := add(0x04, calldataload(0x04))
            min := calldataload(add(base, 0x20))
            for { let i := 1 } lt(i, data.length) { i := add(i, 1) } {
                let elem := calldataload(add(base, add(0x20, mul(i, 0x20))))
                if lt(elem, min) {
                    min := elem
                }
            }
        }
    }

    /// @notice Count occurrences of value in array
    /// @param data Array to search
    /// @param value Value to count
    /// @return count Number of occurrences
    function countInArray(uint256[] calldata data, uint256 value) external pure returns (uint256 count) {
        assembly {
            let base := add(0x04, calldataload(0x04))
            for { let i := 0 } lt(i, data.length) { i := add(i, 1) } {
                let elem := calldataload(add(base, add(0x20, mul(i, 0x20))))
                if eq(elem, value) {
                    count := add(count, 1)
                }
            }
        }
    }

    /// @notice Linear search in array
    /// @param data Array to search
    /// @param target Value to find
    /// @return index Index of target, or length if not found
    function findIndex(uint256[] calldata data, uint256 target) external pure returns (uint256 index) {
        assembly {
            let base := add(0x04, calldataload(0x04))
            index := data.length // Default to "not found"
            for { let i := 0 } lt(i, data.length) { i := add(i, 1) } {
                let elem := calldataload(add(base, add(0x20, mul(i, 0x20))))
                if eq(elem, target) {
                    index := i
                    break
                }
            }
        }
    }

    /// @notice While loop equivalent in assembly
    /// @param n Initial value
    /// @return result Factorial of n
    function factorial(uint256 n) external pure returns (uint256 result) {
        assembly {
            result := 1
            // Equivalent to while (n > 0)
            for { } gt(n, 0) { } {
                result := mul(result, n)
                n := sub(n, 1)
            }
        }
    }

    /// @notice Nested loops - multiplication table
    /// @param n Size of table
    /// @return product n * n
    function nestedLoopSum(uint256 n) external pure returns (uint256 product) {
        assembly {
            for { let i := 0 } lt(i, n) { i := add(i, 1) } {
                for { let j := 0 } lt(j, n) { j := add(j, 1) } {
                    product := add(product, 1)
                }
            }
        }
    }

    /// @notice Sum array elements
    /// @param data Array to sum
    /// @return total Sum of all elements
    function sumArray(uint256[] calldata data) external pure returns (uint256 total) {
        assembly {
            let base := add(0x04, calldataload(0x04))
            for { let i := 0 } lt(i, data.length) { i := add(i, 1) } {
                let elem := calldataload(add(base, add(0x20, mul(i, 0x20))))
                total := add(total, elem)
            }
        }
    }

    /// @notice Reverse array (returns sum to verify)
    /// @param data Array to reverse-sum
    /// @return sum Sum of reversed indices
    function reverseSum(uint256[] calldata data) external pure returns (uint256 sum) {
        assembly {
            let base := add(0x04, calldataload(0x04))
            let len := data.length
            for { let i := 0 } lt(i, len) { i := add(i, 1) } {
                let revIdx := sub(sub(len, 1), i)
                let revElem := calldataload(add(base, add(0x20, mul(revIdx, 0x20))))
                sum := add(sum, revElem)
            }
        }
    }
}
