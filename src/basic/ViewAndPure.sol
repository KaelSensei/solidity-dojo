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
    /// @param _x Input number
    /// @return Square of x
    function pureFunction(uint256 _x) external pure returns (uint256) {
        return _x * _x;
    }

    /// @notice PURE: Multiple pure operations
    /// @param _a First number
    /// @param _b Second number
    /// @return Sum of squares
    function sumOfSquares(uint256 _a, uint256 _b) external pure returns (uint256) {
        uint256 aSquared = _a * _a; // Local computation only
        uint256 bSquared = _b * _b;
        return aSquared + bSquared;
    }

    /// @notice VIEW: Reads state but doesn't modify it
    /// @dev Can read state variables and call pure/view functions
    /// @return The stored number
    function viewFunction() external view returns (uint256) {
        return number;
    }

    /// @notice VIEW: Reads state and performs computation
    /// @param _multiplier Value to multiply by
    /// @return number multiplied by input
    function viewWithComputation(uint256 _multiplier) external view returns (uint256) {
        return number * _multiplier;
    }

    /// @notice VIEW: Can call pure functions
    /// @param _x Input for pure function
    /// @return Result of pure function applied to state
    function viewCallingPure(uint256 _x) external view returns (uint256) {
        uint256 pureResult = this.pureFunction(_x); // Call pure externally
        return number + pureResult;
    }

    /// @notice PURE: Can call other pure functions
    /// @param _x Input
    /// @return Result from helper
    function pureCallingPure(uint256 _x) external pure returns (uint256) {
        return _pureHelper(_x);
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
