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
    /// @param _addr The address to set balance for
    /// @param _amount The balance amount
    function set(address _addr, uint256 _amount) external {
        balances[_addr] = _amount;
    }

    /// @notice Gets the balance for an address
    /// @param _addr The address to query
    /// @return The balance (0 if never set)
    function get(address _addr) external view returns (uint256) {
        return balances[_addr];
    }

    /// @notice Removes a balance entry (resets to 0)
    /// @param _addr The address to remove
    /// @dev delete resets to default value; gas refund may apply
    function remove(address _addr) external {
        delete balances[_addr];
    }

    /// @notice Sets approval for a spender on behalf of owner
    /// @param _owner The owner address
    /// @param _spender The spender address
    /// @param _approved Whether spender is approved
    function setApproval(address _owner, address _spender, bool _approved) external {
        isApproved[_owner][_spender] = _approved;
    }

    /// @notice Checks if spender is approved by owner
    /// @param _owner The owner address
    /// @param _spender The spender address
    /// @return Whether spender is approved
    function checkApproval(address _owner, address _spender) external view returns (bool) {
        return isApproved[_owner][_spender];
    }
}
