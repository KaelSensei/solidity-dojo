// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title PrivateData
/// @notice Demonstrates that private data is still accessible
contract PrivateData {
    /// @notice PRIVATE: Still readable from outside via storage slots!
    uint256 private secretNumber = 42;
    
    /// @notice PRIVATE: Password stored directly
    bytes32 private password = keccak256("my_secret_password");
    
    /// @notice PRIVATE: Array storage
    uint256[] private privateArray;
    
    /// @notice PRIVATE: Mapping storage  
    mapping(address => uint256) private balances;

    constructor() {
        privateArray.push(100);
        privateArray.push(200);
        privateArray.push(300);
        balances[msg.sender] = 1000;
    }

    /// @notice Get private number (public getter for testing)
    function getSecretNumber() external view returns (uint256) {
        return secretNumber;
    }

    /// @notice Get password hash (public getter for testing)
    function getPasswordHash() external view returns (bytes32) {
        return password;
    }

    /// @notice Get array length
    function getArrayLength() external view returns (uint256) {
        return privateArray.length;
    }

    /// @notice Get balance
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }
}
