// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ViewAndPure
/// @notice Demonstrates view and pure function differences.
/// @dev Pure: no state read/write. View: reads state but doesn't write.
contract ViewAndPure {
    /// @notice Stored number
    uint256 public number = 42;

    /// @notice PURE: Does not interact with state at all
    /// @dev Can only call other pure functions
    /// @return Square of x
    function pureFunction(uint256 x) external pure returns (uint256) {
        return x * x;
    }

    /// @notice PURE: Multiple pure operations
    /// @return Sum of squares
    function sumOfSquares(uint256 a, uint256 b) external pure returns (uint256) {
        uint256 aSquared = a * a; // Local computation only
        uint256 bSquared = b * b;
        return aSquared + bSquared;
    }

    /// @notice VIEW: Reads state but doesn't modify it
    /// @dev Can read state variables and call pure/view functions
    /// @return The stored number
    function viewFunction() external view returns (uint256) {
        return number;
    }

    /// @notice VIEW: Reads state and performs computation
    /// @return number multiplied by input
    function viewWithComputation(uint256 multiplier) external view returns (uint256) {
        return number * multiplier;
    }

    /// @notice VIEW: Can call pure functions
    /// @return Result of pure function applied to state
    function viewCallingPure(uint256 x) external view returns (uint256) {
        uint256 pureResult = this.pureFunction(x); // Call pure externally
        return number + pureResult;
    }

    /// @notice PURE: Can call other pure functions
    /// @return Result from helper
    function pureCallingPure(uint256 x) external pure returns (uint256) {
        return _pureHelper(x);
    }

    /// @notice Internal pure helper
    function _pureHelper(uint256 _x) internal pure returns (uint256) {
        return _x + 100;
    }

    /// @notice VIEW: Can call view and pure functions
    /// @return Combined result
    function viewCallingViewAndPure() external view returns (uint256, uint256) {
        uint256 viewResult = this.viewFunction();
        uint256 pureResult = this.pureFunction(5);
        return (viewResult, pureResult);
    }

    /// @notice Demonstrates that pure cannot call view
    /// This would not compile:
    /// function pureCallingView() external pure returns (uint256) {
    ///     return number; // ERROR: cannot read state in pure function
    /// }
}


