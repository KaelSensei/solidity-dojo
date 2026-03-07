// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title SimpleStorage
/// @notice Demonstrates reading and writing to state variables.
/// @dev Shows the difference between SSTORE (write, expensive) and SLOAD (read, cheaper).
contract SimpleStorage {
    /// @notice The stored number
    /// @dev Stored in contract storage (persistent). SSTORE costs 20000 gas for initial
    ///      write, 5000 for subsequent writes. SLOAD costs 2100 (cold) or 100 (warm).
    uint256 public num;

    /// @notice Sets the stored number
    /// @param _num The new value to store
    /// @dev This triggers an SSTORE operation which modifies blockchain state
    function set(uint256 _num) external {
        num = _num;
    }

    /// @notice Gets the stored number
    /// @return The current value of num
    /// @dev This triggers an SLOAD operation. Since num is public, this getter
    ///      is auto-generated, but we include it for explicit demonstration.
    function get() external view returns (uint256) {
        return num;
    }
}
