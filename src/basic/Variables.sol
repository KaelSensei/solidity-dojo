// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Variables
/// @notice Demonstrates the three types of variables in Solidity:
///         local, state, and global (built-in) variables.
/// @dev Local: declared inside functions, stored in memory/stack
///      State: declared outside functions, stored in storage (persistent)
///      Global: provided by EVM, accessible everywhere (msg, block, tx)
contract Variables {
    /// @notice State variable: stored permanently on blockchain
    /// @dev Each read costs 2100 gas (cold SLOAD) or 100 gas (warm SLOAD)
    uint256 public stateVar = 123;

    /// @notice Demonstrates local variables and returns global variables
    /// @return sender The address that called this function (msg.sender)
    /// @return timestamp The current block timestamp (block.timestamp)
    /// @return blockNum The current block number (block.number)
    /// @return chainId The current chain ID (block.chainid)
    function getGlobalVars() external view returns (
        address sender,
        uint256 timestamp,
        uint256 blockNum,
        uint256 chainId
    ) {
        // Local variable: exists only during function execution
        // Stored in memory (for reference types) or stack (for value types)
        // No storage cost - very cheap
        uint256 localVar = 456;

        sender = msg.sender;
        timestamp = block.timestamp;
        blockNum = block.number;
        chainId = block.chainid;

        // localVar is discarded after function returns
        localVar; // silence warning
    }

    /// @notice Demonstrates local variable usage
    /// @param input A parameter (also a local variable)
    /// @return result The computed result
    function useLocalVar(uint256 input) external pure returns (uint256 result) {
        // Pure local computation - no storage interaction
        uint256 localA = input * 2;
        uint256 localB = input + 10;
        result = localA + localB;
    }

    /// @notice Returns the state variable
    function getStateVar() external view returns (uint256) {
        return stateVar;
    }

    /// @notice Updates the state variable
    /// @dev This requires a transaction (SSTORE costs 5000+ gas)
    function setStateVar(uint256 newValue) external {
        stateVar = newValue;
    }
}
