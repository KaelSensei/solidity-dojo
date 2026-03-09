// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Immutable
/// @notice Demonstrates immutable variables set at construction time.
/// @dev Immutable variables are stored in bytecode (like constants) but can be
///      set in the constructor (unlike constants). Reading costs ~3 gas.
contract Immutable {
    /// @notice Immutable uint256 set in constructor
    /// @dev Stored in contract bytecode, not storage. Set once at deployment.
    uint256 public immutable MY_UINT;

    /// @notice Immutable address set in constructor
    address public immutable MY_ADDRESS;

    /// @notice Immutable bytes32 set in constructor
    /// @dev bytes32 is a value type and can be immutable (unlike string)
    bytes32 public immutable MY_BYTES32;

    /// @notice Constructor sets immutable values
    /// @param _myUint The value for MY_UINT
    /// @param _myAddress The value for MY_ADDRESS
    /// @param _myBytes32 The value for MY_BYTES32
    constructor(uint256 _myUint, address _myAddress, bytes32 _myBytes32) {
        MY_UINT = _myUint;
        MY_ADDRESS = _myAddress;
        MY_BYTES32 = _myBytes32;
    }

    /// @notice Returns all immutable values
    function getValues()
        external
        view
        returns (uint256, address, bytes32)
    {
        return (MY_UINT, MY_ADDRESS, MY_BYTES32);
    }
}

/// @title ImmutableWithDefault
/// @notice Shows immutable with default value that can be overridden in constructor
contract ImmutableWithDefault {
    /// @notice Immutable with default value, can be changed in constructor
    /// @dev If constructor doesn't set it, keeps default value
    uint256 public immutable VALUE = 100;

    constructor() {
        // VALUE remains 100 - not reassigned
    }
}
