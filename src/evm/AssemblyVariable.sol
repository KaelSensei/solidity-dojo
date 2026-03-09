// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title AssemblyVariable
/// @notice Demonstrates Yul variable declaration and assignment patterns
/// @dev Educational example - inline assembly variable handling

/// @title Yul Variable Operations
contract AssemblyVariable {
    /// @notice Declare and initialize variable in Yul
    /// @return result The initialized value (42)
    function declareAndInit() external pure returns (uint256 result) {
        assembly {
            // let declares a new variable
            // Variables must be initialized before use
            let x := 42
            result := x
        }
    }

    /// @notice Multiple variable declarations
    /// @return a First variable
    /// @return b Second variable
    /// @return c Sum of both
    function multipleVariables() external pure returns (uint256 a, uint256 b, uint256 c) {
        assembly {
            let x := 10
            let y := 20
            a := x
            b := y
            c := add(x, y)
        }
    }

    /// @notice Variable scope in Yul blocks
    /// @return innerValue Value from inner scope
    /// @return outerValue Value from outer scope
    function variableScope() external pure returns (uint256 innerValue, uint256 outerValue) {
        assembly {
            let outer := 100
            outerValue := outer
            {
                // Inner scope can access outer variables
                let inner := 200
                innerValue := inner
                // Can also modify outer in inner scope
                outer := inner
            }
            // outerValue was captured before inner block modified it
            outerValue := outer
        }
    }

    /// @notice Function local variables with assembly
    /// @param x Input value
    /// @return result Doubled value
    function doubleWithAssembly(uint256 x) external pure returns (uint256 result) {
        assembly {
            let temp := x
            result := mul(temp, 2)
        }
    }

    /// @notice Reassigning variables in Yul
    /// @return finalValue Final value after reassignment
    function reassignVariable() external pure returns (uint256 finalValue) {
        assembly {
            let x := 1
            x := 2  // Reassign to new value
            x := 3  // Reassign again
            finalValue := x
        }
    }

    /// @notice Zero initialization behavior
    /// @return result Default value
    function zeroInitialization() external pure returns (uint256 result) {
        assembly {
            // Uninitialized variables default to 0
            let x
            result := x
        }
    }

    /// @notice Nested assembly with local variables
    /// @param a First number
    /// @param b Second number
    /// @return result The larger of the two
    function max(uint256 a, uint256 b) external pure returns (uint256 result) {
        assembly {
            let x := a
            let y := b
            switch gt(x, y)
            case 1 { result := x }
            default { result := y }
        }
    }

    /// @notice Swap two values without temporary variable (in assembly)
    /// @param a First value (will be swapped)
    /// @param b Second value (will be swapped)
    /// @return x First value after swap
    /// @return y Second value after swap
    function swap(uint256 a, uint256 b) external pure returns (uint256 x, uint256 y) {
        assembly {
            x := b
            y := a
        }
    }
}
