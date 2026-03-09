// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title AssemblyBinaryExponentiation
/// @notice Binary exponentiation in Yul for gas-efficient power
/// @dev Educational example - fast exponentiation algorithm

/// @title Binary Exponentiation
contract AssemblyBinaryExponentiation {
    /// @notice Calculate a^b using binary exponentiation
    /// @param base Base number
    /// @param exponent Exponent
    /// @return result base^exponent
    function pow(uint256 base, uint256 exponent) public pure returns (uint256 result) {
        assembly {
            result := 1
            for { } gt(exponent, 0) { } {
                if and(exponent, 1) {
                    result := mul(result, base)
                }
                base := mul(base, base)
                exponent := shr(1, exponent)
            }
        }
    }

    /// @notice Calculate a^b using binary exponentiation
    /// @param a Base
    /// @param e Exponent
    /// @return result a^e using O(log(e)) operations
    function power(uint256 a, uint256 e) public pure returns (uint256 result) {
        assembly {
            result := 1
            for { } gt(e, 0) { } {
                if and(e, 1) {
                    result := mul(result, a)
                }
                a := mul(a, a)
                e := shr(1, e)
            }
        }
    }

    /// @notice Square using assembly
    /// @param x Value to square
    /// @return result x^2
    function square(uint256 x) public pure returns (uint256 result) {
        assembly {
            result := mul(x, x)
        }
    }

    /// @notice Cube using assembly  
    /// @param x Value to cube
    /// @return result x^3
    function cube(uint256 x) public pure returns (uint256 result) {
        assembly {
            result := mul(mul(x, x), x)
        }
    }

    /// @notice Power of 2: 2^n
    /// @param n Exponent
    /// @return result 2^n
    function pow2(uint256 n) public pure returns (uint256 result) {
        assembly {
            result := shl(n, 1) // 2^n = 1 << n
        }
    }

    /// @notice Power of 10: 10^n
    /// @param n Exponent
    /// @return result 10^n
    function pow10(uint256 n) public pure returns (uint256 result) {
        assembly {
            result := 1
            for { } gt(n, 0) { n := sub(n, 1) } {
                result := mul(result, 10)
            }
        }
    }

    /// @notice Log2 - floor of log base 2
    /// @param x Value
    /// @return result Floor of log2(x)
    function log2(uint256 x) public pure returns (uint256 result) {
        require(x > 0, "Log of zero");
        // Simpler Solidity implementation
        result = 0;
        while (x > 1) {
            x >>= 1;
            result++;
        }
    }

    /// @notice Check if power of 2
    /// @param x Value to check
    /// @return True if x is power of 2
    function isPowerOfTwo(uint256 x) public pure returns (bool) {
        if (x == 0) return false;
        return (x & (x - 1)) == 0;
    }

    /// @notice Next power of 2 >= x
    /// @param x Value
    /// @return result Next power of 2
    function nextPowerOfTwo(uint256 x) public pure returns (uint256 result) {
        if (x == 0) return 1;
        
        assembly {
            result := x
            // Subtract 1 to handle exact powers of 2
            result := sub(result, 1)
            // Fill in all bits below the highest set bit
            for { let i := 1 } lt(i, 256) { i := shl(i, result) } {
                result := or(result, shr(i, result))
            }
            // Add 1 to get next power of 2
            result := add(result, 1)
        }
    }

    /// @notice Integer square root using binary search
    /// @param x Value
    /// @return result Floor(sqrt(x))
    function sqrt(uint256 x) public pure returns (uint256 result) {
        require(x >= 0, "Negative");
        
        assembly {
            // Newton's method for integer sqrt
            result := x
            let z := add(div(x, 2), 1)
            for { } lt(result, z) { } {
                result := z
                z := div(add(div(x, z), z), 2)
            }
        }
    }
}
