// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Constants
/// @notice Demonstrates constant variables and gas savings compared to storage reads.
/// @dev Constants are evaluated at compile time and embedded directly in bytecode.
///      Reading a constant costs ~3 gas (PUSH32) vs ~2100 gas (cold SLOAD) for storage.
contract Constants {
    /// @notice A constant address example
    /// @dev Compile-time constant, embedded in contract bytecode
    address public constant MY_ADDRESS = 0x777788889999AaAAbBbbCcccddDdeeeEfFFfCcCc;

    /// @notice A constant uint256 example
    /// @dev Used for values that never change, like MAX_SUPPLY, BASIS_POINTS, etc.
    uint256 public constant MY_UINT = 123;

    /// @notice Basis points constant (100% = 10000 bps)
    /// @dev Common DeFi pattern for percentages without floating point
    uint256 public constant BASIS_POINTS = 10000;

    /// @notice Maximum supply for a token
    /// @dev Immutable supply cap, enforced at compile time
    uint256 public constant MAX_SUPPLY = 1_000_000 * 10 ** 18; // 1M tokens with 18 decimals

    /// @notice Demonstrates gas efficiency of constants
    /// @return The constant value (read from bytecode, not storage)
    function getConstant() external pure returns (uint256) {
        return MY_UINT;
    }

    /// @notice Calculates percentage using basis points
    /// @param amount The base amount
    /// @param bps The percentage in basis points (e.g., 500 = 5%)
    /// @return The calculated percentage of amount
    function calculatePercentage(uint256 amount, uint256 bps) external pure returns (uint256) {
        return (amount * bps) / BASIS_POINTS;
    }
}

/// @title NonConstant
/// @notice Same functionality but using storage variables for comparison
/// @dev Use this to compare gas costs between storage reads and constants
contract NonConstant {
    /// @notice Same value as the constant version, but stored in storage
    /// @dev Reading this costs ~2100 gas (cold) or 100 gas (warm)
    uint256 public myUint = 123;

    function getValue() external view returns (uint256) {
        return myUint;
    }
}
