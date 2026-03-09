// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title DelegatecallAttack
/// @notice Demonstrates delegatecall-based proxy attack
/// @dev Educational example - DO NOT USE IN PRODUCTION

/// @title Implementation Contract (with hidden malicious code)
contract ImplementationV1 {
    uint256 public value;
    
    function setValue(uint256 _value) external {
        value = _value;
    }
}

/// @title Malicious Implementation
contract MaliciousImplementation {
    address public owner;
    address public proxy;
    
    function setOwner() external {
        // This will change the proxy's owner!
        owner = msg.sender;
    }
    
    function setProxyAddress(address _proxy) external {
        proxy = _proxy;
    }
}

/// @title Vulnerable Proxy using delegatecall
contract VulnerableProxy {
    address public implementation;
    address public owner;
    mapping(bytes32 => uint256) public values;
    
    event ExecutionResult(bytes result);
    
    constructor(address _implementation) {
        implementation = _implementation;
        owner = msg.sender;
    }
    
    /// @notice Upgrade implementation (VULNERABLE!)
    function upgradeTo(address _implementation) external {
        require(msg.sender == owner);
        implementation = _implementation;
    }
    
    /// @notice Execute via delegatecall (VULNERABLE!)
    function execute(bytes calldata data) external payable {
        (bool success, bytes memory result) = implementation.delegatecall(data);
        emit ExecutionResult(result);
        require(success);
    }
}

/// @title Secure Proxy using staticcall
contract SecureProxy {
    address public implementation;
    address public owner;
    
    constructor(address _implementation) {
        implementation = _implementation;
        owner = msg.sender;
    }
    
    /// @notice Execute via delegatecall with proper storage isolation
    function execute(bytes calldata data) external payable {
        // Note: In production, use OpenZeppelin's Proxy contract
        // This is a simplified example
        (bool success, ) = implementation.delegatecall(data);
        require(success);
    }
    
    fallback() external payable {
        (bool success, ) = implementation.delegatecall(msg.data);
        require(success);
    }
}
