// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title EtherWallet
/// @notice A simple contract that holds ether with owner-only withdrawal.
/// @dev Demonstrates payable functions, receive/fallback, and access control.
contract EtherWallet {
    /// @notice Contract owner
    address public owner;

    /// @notice Emitted when ether is deposited
    event Deposit(address indexed sender, uint256 amount);

    /// @notice Emitted when ether is withdrawn
    event Withdraw(address indexed recipient, uint256 amount);

    /// @notice Thrown when non-owner tries to withdraw
    error NotOwner();

    /// @notice Constructor sets owner
    constructor() {
        owner = msg.sender;
    }

    /// @notice Modifier to restrict to owner
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /// @notice Receive function for plain ether transfers
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Fallback function for calls with data
    fallback() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Gets the contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /// @notice Withdraws all ether to owner
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        // CEI: Check-Effects-Interactions pattern
        // Effects: emit event before external call
        emit Withdraw(owner, balance);
        // Interactions: external call last
        (bool success,) = owner.call{value: balance}("");
        require(success, "Transfer failed");
    }

    /// @notice Withdraws specific amount to owner
    /// @param _amount Amount to withdraw
    function withdrawAmount(uint256 _amount) external onlyOwner {
        require(_amount <= address(this).balance, "Insufficient balance");
        emit Withdraw(owner, _amount);
        (bool success,) = owner.call{value: _amount}("");
        require(success, "Transfer failed");
    }
}
