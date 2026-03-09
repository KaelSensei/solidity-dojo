// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title FunctionTypes
/// @notice Demonstrates all function visibility and mutability combinations.
/// @dev Visibility: external, public, internal, private. Mutability: pure, view, payable, default (can write).
contract FunctionTypes {
    /// @notice Stored value for demonstrating state access
    uint256 private storedValue;

    /// @notice Owner address
    address public owner;

    constructor() {
        owner = msg.sender;
        storedValue = 100;
    }

    // ==================== VISIBILITY ====================

    /// @notice EXTERNAL: Can only be called from outside the contract
    /// @dev Most gas efficient for external calls - args read from calldata
    /// @param _value Value to return
    /// @return The input value
    function externalFunction(uint256 _value) external pure returns (uint256) {
        return _value * 2;
    }

    /// @notice PUBLIC: Can be called from inside or outside
    /// @dev Less efficient than external for external calls (copies args to memory)
    /// @param _value Value to return
    /// @return The input value
    function publicFunction(uint256 _value) public pure returns (uint256) {
        return _value * 3;
    }

    /// @notice INTERNAL: Can only be called from this contract or derived contracts
    /// @dev Not visible externally
    /// @param _value Value to process
    /// @return Processed value
    function internalFunction(uint256 _value) internal pure returns (uint256) {
        return _value + 10;
    }

    /// @notice PRIVATE: Can only be called from this contract
    /// @dev Not visible even to derived contracts
    /// @param _value Value to process
    /// @return Processed value
    function privateFunction(uint256 _value) private pure returns (uint256) {
        return _value + 20;
    }

    /// @notice Calls internal function to demonstrate it works
    function callInternal() external pure returns (uint256) {
        return internalFunction(5);
    }

    /// @notice Calls private function to demonstrate it works
    function callPrivate() external pure returns (uint256) {
        return privateFunction(5);
    }

    // ==================== MUTABILITY ====================

    /// @notice PURE: Does not read or write state
    /// @dev Can only call other pure functions
    /// @param _a First number
    /// @param _b Second number
    /// @return Sum of a and b
    function pureFunction(uint256 _a, uint256 _b) external pure returns (uint256) {
        return _a + _b;
    }

    /// @notice VIEW: Reads state but does not write
    /// @dev Can call pure and view functions
    /// @return Current stored value
    function viewFunction() external view returns (uint256) {
        return storedValue;
    }

    /// @notice DEFAULT: Can read and write state
    /// @dev No mutability keyword - can do anything except receive ether (without payable)
    /// @param _newValue New value to store
    function stateModifyingFunction(uint256 _newValue) external {
        storedValue = _newValue;
    }

    /// @notice PAYABLE: Can receive ether
    /// @dev Also allows state modifications
    function payableFunction() external payable returns (uint256) {
        storedValue += msg.value;
        return storedValue;
    }

    /// @notice Returns current stored value
    function getStoredValue() external view returns (uint256) {
        return storedValue;
    }
}
