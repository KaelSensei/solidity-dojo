// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Shadowing
/// @notice Demonstrates variable shadowing - confusing, avoid it.
/// @dev Shadowing occurs when a local variable or parameter has the same name as a state variable.
contract Shadowing {
    /// @notice State variable - can be shadowed
    uint256 public value = 100;

    /// @notice Another state variable
    address public owner = address(0x123);

    /// @notice Demonstrates parameter shadowing state variable
    /// @param value Shadows the state variable 'value'
    /// @return The parameter value (not the state variable)
    function shadowWithParameter(uint256 value) public view returns (uint256) {
        // 'value' here refers to the parameter, not the state variable
        // To access state variable, use 'this.value()' or don't shadow
        return value; // Returns parameter, not state variable
    }

    /// @notice Demonstrates local variable shadowing
    /// @return The local variable value
    function shadowWithLocal() public view returns (uint256) {
        uint256 value = 999; // Local variable shadows state variable
        return value; // Returns 999, not 100
    }

    /// @notice Proper way - no shadowing
    /// @param _newValue New value to set (prefixed to avoid shadowing)
    function properNaming(uint256 _newValue) public returns (uint256) {
        value = _newValue; // Clearly refers to state variable
        return value; // Returns updated state variable
    }

    /// @notice Shows how to access shadowed variable
    function getStateValueDespiteShadow() public view returns (uint256) {
        uint256 value = 50; // Local shadows state
        uint256 stateValue = this.value(); // Access via getter
        return stateValue; // Returns 100 (the state variable)
    }

    /// @notice Multiple shadows in nested scopes
    function nestedShadowing() public pure returns (uint256) {
        uint256 x = 1;
        {
            uint256 x = 2; // Shadows outer x in this scope
            {
                uint256 x = 3; // Shadows again
                return x; // Returns 3
            }
        }
    }
}
