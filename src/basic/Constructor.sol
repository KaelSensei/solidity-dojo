// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Constructor
/// @notice Demonstrates constructor patterns for contract initialization.
/// @dev Constructor runs once at deployment. Cannot be called again.
contract Constructor {
    /// @notice Owner address (immutable for gas savings)
    address public immutable owner;

    /// @notice Contract name
    string public name; // Cannot be immutable (reference type)

    /// @notice Initial value set in constructor
    uint256 public immutable initialValue;

    /// @notice Timestamp of deployment
    uint256 public immutable deployedAt;

    /// @notice Mutable state initialized in constructor
    uint256 public value;

    /// @notice Flag set in constructor
    bool public initialized;

    /// @notice Emitted when contract is deployed
    /// @param deployer Address that deployed the contract
    /// @param name Contract name
    /// @param initialValue Initial value set
    event Deployed(address indexed deployer, string name, uint256 initialValue);

    /// @notice Constructor sets immutable values and initial state
    /// @param _name Contract name
    /// @param _initialValue Initial value
    constructor(string memory _name, uint256 _initialValue) {
        owner = msg.sender;
        name = _name;
        initialValue = _initialValue;
        deployedAt = block.timestamp;

        // Set mutable state
        value = _initialValue;
        initialized = true;

        emit Deployed(msg.sender, _name, _initialValue);
    }

    /// @notice Updates the mutable value
    /// @param _newValue New value to set
    function setValue(uint256 _newValue) external {
        require(msg.sender == owner, "Not owner");
        value = _newValue;
    }

    /// @notice Returns all immutable values
    function getImmutables()
        external
        view
        returns (address _owner, string memory _name, uint256 _initialValue, uint256 _deployedAt)
    {
        return (owner, name, initialValue, deployedAt);
    }
}

/// @title ChildConstructor
/// @notice Demonstrates constructor in inherited contract
contract ChildConstructor is Constructor {
    /// @notice Additional immutable from child
    uint256 public immutable childValue;

    /// @notice Constructor passes args to parent
    /// @param _name Passed to parent
    /// @param _initialValue Passed to parent
    /// @param _childValue Child's own value
    constructor(string memory _name, uint256 _initialValue, uint256 _childValue)
        Constructor(_name, _initialValue)
    {
        childValue = _childValue;
    }
}
