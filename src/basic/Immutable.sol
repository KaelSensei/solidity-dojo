// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Immutable
/// @notice Demonstrates immutable variables set at construction time.
/// @dev Immutable variables are stored in bytecode (like constants) but can be
///      set in the constructor (unlike constants). Reading costs ~3 gas.
contract Immutable {
    /// @notice Immutable uint256 set in constructor
    /// @dev Stored in contract bytecode, not storage. Set once at deployment.
    uint256 public immutable myUint;

    /// @notice Immutable address set in constructor
    address public immutable myAddress;

    /// @notice Immutable bytes32 set in constructor
    /// @dev bytes32 is a value type and can be immutable (unlike string)
    bytes32 public immutable myBytes32;

    /// @notice Constructor sets immutable values
    constructor(uint256 initialUint, address initialAddress, bytes32 initialBytes32) {
        require(initialAddress != address(0), "Zero address");
        myUint = initialUint;
        myAddress = initialAddress;
        myBytes32 = initialBytes32;
    }

    /// @notice Returns all immutable values
    function getValues()
        external
        view
        returns (uint256, address, bytes32)
    {
        return (myUint, myAddress, myBytes32);
    }
}

/// @title ImmutableWithDefault
/// @notice Shows immutable with default value that can be overridden in constructor
contract ImmutableWithDefault {
    /// @notice Immutable with default value, can be changed in constructor
    /// @dev If constructor doesn't set it, keeps default value
    uint256 public immutable value = 100;

    constructor() {
        // value remains 100 - not reassigned
    }
}


