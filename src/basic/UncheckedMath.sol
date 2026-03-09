// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title UncheckedMath
/// @notice Demonstrates Solidity 0.8+ overflow protection and `unchecked` blocks.
/// @dev Since 0.8, arithmetic reverts on overflow/underflow by default.
///      `unchecked` skips these checks, saving ~30-40 gas per operation.
///      Only safe when overflow is impossible (e.g., bounded loop counters).
contract UncheckedMath {
    /// @notice Regular addition — reverts on overflow
    function add(uint256 x, uint256 y) external pure returns (uint256) {
        return x + y;
    }

    /// @notice Unchecked addition — wraps around on overflow
    /// @dev WARNING: Only use when you can guarantee no overflow
    function uncheckedAdd(uint256 x, uint256 y) external pure returns (uint256 result) {
        unchecked { result = x + y; }
    }

    /// @notice Regular subtraction — reverts on underflow
    function sub(uint256 x, uint256 y) external pure returns (uint256) {
        return x - y;
    }

    /// @notice Unchecked subtraction — wraps around on underflow
    function uncheckedSub(uint256 x, uint256 y) external pure returns (uint256 result) {
        unchecked { result = x - y; }
    }

    /// @notice Unchecked increment — the standard gas-efficient pattern for loop counters
    function uncheckedIncrement(uint256 x) external pure returns (uint256) {
        unchecked { return x + 1; }
    }

    /// @notice Sum 1..n using unchecked loop increment (gas-efficient)
    /// @param n Upper bound (inclusive)
    /// @return sum The result
    function sumWithUncheckedLoop(uint256 n) external pure returns (uint256 sum) {
        for (uint256 i = 1; i <= n;) {
            sum += i;
            unchecked { ++i; }
        }
    }

    /// @notice Sum 1..n using checked loop increment (more expensive)
    /// @dev For comparison — identical result, higher gas cost
    function sumWithCheckedLoop(uint256 n) external pure returns (uint256 sum) {
        for (uint256 i = 1; i <= n; i++) {
            sum += i;
        }
    }
}
