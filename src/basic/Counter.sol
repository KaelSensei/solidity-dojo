// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Counter
/// @notice A simple counter demonstrating state variable read/write patterns.
/// @dev Shows increment/decrement operations and underflow protection in Solidity 0.8+.
contract Counter {
    /// @notice The current count value.
    /// @dev uint256 means 0 to 2^256-1. In Solidity 0.8+, arithmetic operations
    ///      automatically check for overflow/underflow and revert if violated.
    uint256 public count;

    /// @notice Increments the counter by 1.
    /// @dev Uses prefix increment (++count) which is slightly more gas efficient
    ///      than postfix (count++) in older Solidity versions. In 0.8+ they're
    ///      equivalent for standalone statements.
    function inc() external {
        ++count;
    }

    /// @notice Decrements the counter by 1.
    /// @dev In Solidity 0.8+, this will automatically revert with panic code 0x11
    ///      (arithmetic overflow/underflow) if count is already 0.
    ///      This is a security feature - explicit underflow is no longer possible.
    function dec() external {
        --count;
    }

    /// @notice Returns the current count.
    /// @dev Redundant with auto-generated getter from `public` visibility,
    ///      but included to demonstrate explicit getter pattern.
    /// @return The current count value.
    function get() external view returns (uint256) {
        return count;
    }
}
