// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title TxOriginAttack
/// @notice Demonstrates tx.origin phishing attack
/// @dev Educational example - DO NOT USE IN PRODUCTION

/// @title Phishable Wallet using tx.origin (VULNERABLE!)
contract PhishableWallet {
    address public owner;
    address public helper;
    
    constructor() {
        owner = msg.sender;
    }
    
    /// @notice Set helper (VULNERABLE: uses tx.origin)
    function setHelper(address _helper) external {
        require(tx.origin == owner, "Not owner");
        helper = _helper;
    }
    
    /// @notice Withdraw using tx.origin (VULNERABLE!)
    function withdrawAll(address payable _recipient) external {
        require(tx.origin == owner, "Not owner");
        (bool success, ) = _recipient.call{value: address(this).balance}("");
        require(success);
    }
    
    receive() external payable {}
}

/// @title Attack Contract using tx.origin
contract TxOriginAttacker {
    address public owner;
    PhishableWallet public wallet;
    
    constructor(address _wallet) {
        wallet = PhishableWallet(payable(_wallet));
        owner = msg.sender;
    }
    
    /// @notice Attack - trick owner into calling this
    function attack() external {
        // This would be called by the vulnerable wallet when owner
        // tries to call withdrawAll() - but owner is tricked into 
        // calling this contract first
    }
    
    /// @notice Withdraw from wallet (called by owner unknowingly)
    function stealFunds() external {
        wallet.withdrawAll(payable(owner));
    }
    
    receive() external payable {}
}

/// @title Secure Wallet using msg.sender
contract SecureWallet {
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    /// @notice Set helper (SECURE: uses msg.sender)
    function setHelper(address _helper) external {
        require(msg.sender == owner, "Not owner");
        // ... set helper
    }
    
    /// @notice Withdraw using msg.sender (SECURE!)
    function withdrawAll(address payable _recipient) external {
        require(msg.sender == owner, "Not owner");
        (bool success, ) = _recipient.call{value: address(this).balance}("");
        require(success);
    }
    
    receive() external payable {}
}
