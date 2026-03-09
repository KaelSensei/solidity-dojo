// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title AssemblyMathExercise
/// @notice Exercises for implementing math operations in Yul
/// @dev Educational example - practice Yul math operations

/// @title Yul Math Exercises
contract AssemblyMathExercise {
    /// @notice Subtract two numbers in assembly (a - b)
    /// @param a First number
    /// @param b Second number
    /// @return result a - b
    function subtract(uint256 a, uint256 b) external pure returns (uint256 result) {
        assembly {
            result := sub(a, b)
        }
    }

    /// @notice Multiply two numbers in assembly (a * b)
    /// @param a First number
    /// @param b Second number
    /// @return result a * b
    function multiply(uint256 a, uint256 b) external pure returns (uint256 result) {
        assembly {
            result := mul(a, b)
        }
    }

    /// @notice Divide two numbers in assembly (a / b)
    /// @param a First number
    /// @param b Second number
    /// @return result a / b (integer division)
    function divide(uint256 a, uint256 b) external pure returns (uint256 result) {
        require(b != 0, "Division by zero");
        assembly {
            result := div(a, b)
        }
    }

    /// @notice Modulo operation in assembly (a % b)
    /// @param a First number
    /// @param b Second number
    /// @return result a % b
    function modulo(uint256 a, uint256 b) external pure returns (uint256 result) {
        require(b != 0, "Modulo by zero");
        assembly {
            result := mod(a, b)
        }
    }

    /// @notice Add modulo: (a + b) % mod
    /// @param a First number
    /// @param b Second number
    /// @param modValue Modulus
    /// @return result (a + b) % modValue
    function addMod(uint256 a, uint256 b, uint256 modValue) external pure returns (uint256 result) {
        require(modValue != 0, "Modulo by zero");
        assembly {
            result := addmod(a, b, modValue)
        }
    }

    /// @notice Multiply modulo: (a * b) % mod
    /// @param a First number
    /// @param b Second number
    /// @param modValue Modulus
    /// @return result (a * b) % modValue
    function mulMod(uint256 a, uint256 b, uint256 modValue) external pure returns (uint256 result) {
        require(modValue != 0, "Modulo by zero");
        assembly {
            result := mulmod(a, b, modValue)
        }
    }

    /// @notice Increment operation
    /// @param x Value to increment
    /// @return result x + 1
    function increment(uint256 x) external pure returns (uint256 result) {
        assembly {
            result := add(x, 1)
        }
    }

    /// @notice Decrement operation
    /// @param x Value to decrement
    /// @return result x - 1
    function decrement(uint256 x) external pure returns (uint256 result) {
        require(x > 0, "Underflow");
        assembly {
            result := sub(x, 1)
        }
    }

    /// @notice Square a number
    /// @param x Value to square
    /// @return result x * x
    function square(uint256 x) external pure returns (uint256 result) {
        assembly {
            result := mul(x, x)
        }
    }

    /// @notice Cube a number
    /// @param x Value to cube
    /// @return result x * x * x
    function cube(uint256 x) external pure returns (uint256 result) {
        assembly {
            let temp := mul(x, x)
            result := mul(temp, x)
        }
    }

    /// @notice Average of two numbers: (a + b) / 2
    /// @param a First number
    /// @param b Second number
    /// @return result Floor average
    function average(uint256 a, uint256 b) external pure returns (uint256 result) {
        assembly {
            // (a + b) / 2 = a/2 + b/2; add 1 only when both are odd
            result := add(shr(1, a), shr(1, b))
            if and(and(a, 1), and(b, 1)) {
                result := add(result, 1)
            }
        }
    }

    /// @notice Minimum of two numbers
    /// @param a First number
    /// @param b Second number
    /// @return result min(a, b)
    function min(uint256 a, uint256 b) external pure returns (uint256 result) {
        assembly {
            switch lt(a, b)
            case 1 { result := a }
            default { result := b }
        }
    }

    /// @notice Maximum of two numbers
    /// @param a First number
    /// @param b Second number
    /// @return result max(a, b)
    function max(uint256 a, uint256 b) external pure returns (uint256 result) {
        assembly {
            switch gt(a, b)
            case 1 { result := a }
            default { result := b }
        }
    }

    /// @notice Check if a is even
    /// @param a Number to check
    /// @return result 1 if even, 0 if odd
    function isEven(uint256 a) external pure returns (uint256 result) {
        assembly {
            // mod(a, 2) == 0 means even
            result := mod(a, 2)
        }
        // Return 1 if even (mod is 0), 0 if odd
        if (result == 0) {
            return 1;
        }
        return 0;
    }

    /// @notice Absolute difference
    /// @param a First number
    /// @param b Second number
    /// @return result |a - b|
    function absDiff(uint256 a, uint256 b) external pure returns (uint256 result) {
        assembly {
            switch gt(a, b)
            case 1 { result := sub(a, b) }
            default { result := sub(b, a) }
        }
    }
}
