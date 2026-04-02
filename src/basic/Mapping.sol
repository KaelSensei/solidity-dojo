// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Mapping
/// @notice Demonstrates Solidity mappings and nested mappings.
/// @dev Mappings have no length, no iteration, and no list of keys.
///      All possible keys exist with default values.
contract Mapping {
    /// @notice Maps addresses to their balances
    /// @dev Unset keys return 0 (default value for uint256)
    mapping(address => uint256) public balances;

    /// @notice Nested mapping: checks if an address is approved by another
    /// @dev Owner => (Spender => IsApproved)
    mapping(address => mapping(address => bool)) public isApproved;

    /// @notice Sets the balance for an address
    function set(address addr, uint256 amount) external {
        balances[addr] = amount;
    }

    /// @notice Gets the balance for an address
    /// @return The balance (0 if never set)
    function get(address addr) external view returns (uint256) {
        return balances[addr];
    }

    /// @notice Removes a balance entry (resets to 0)
    /// @dev delete resets to default value; gas refund may apply
    function remove(address addr) external {
        delete balances[addr];
    }

    /// @notice Sets approval for a spender on behalf of owner
    function setApproval(address owner, address spender, bool approved) external {
        isApproved[owner][spender] = approved;
    }

    /// @notice Checks if spender is approved by owner
    /// @return Whether spender is approved
    function checkApproval(address owner, address spender) external view returns (bool) {
        return isApproved[owner][spender];
    }
}


