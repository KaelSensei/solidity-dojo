// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Payable
/// @notice Demonstrates payable functions and receiving ether.
contract Payable {
    /// @notice Owner address
    address public owner;

    /// @notice Total received ether
    uint256 public totalReceived;

    /// @notice Emitted when ether is received
    event EtherReceived(address indexed sender, uint256 amount);
    event EtherSent(address indexed recipient, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    /// @notice PAYABLE: Function that can receive ether
    function deposit() external payable {
        totalReceived += msg.value;
        emit EtherReceived(msg.sender, msg.value);
    }

    /// @notice PAYABLE: Function with parameter that can receive ether
    /// @param _memo Memo for the deposit
    function depositWithMemo(string calldata _memo) external payable {
        totalReceived += msg.value;
        emit EtherReceived(msg.sender, msg.value);
        // _memo can be logged or used
        (_memo);
    }

    /// @notice RECEIVE: Called when ether sent with empty calldata
    receive() external payable {
        totalReceived += msg.value;
        emit EtherReceived(msg.sender, msg.value);
    }

    /// @notice FALLBACK: Called when no function matches
    fallback() external payable {
        totalReceived += msg.value;
        emit EtherReceived(msg.sender, msg.value);
    }

    /// @notice Get contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /// @notice Withdraw all ether (owner only)
    function withdraw() external {
        require(msg.sender == owner, "Not owner");
        uint256 balance = address(this).balance;
        (bool success,) = payable(owner).call{value: balance}("");
        require(success, "Transfer failed");
        emit EtherSent(owner, balance);
    }

    /// @notice Withdraw to specific address
    /// @param _to Address to send to
    /// @param _amount Amount to send
    function withdrawTo(address payable _to, uint256 _amount) external {
        require(msg.sender == owner, "Not owner");
        require(_amount <= address(this).balance, "Insufficient balance");
        (bool success,) = _to.call{value: _amount}("");
        require(success, "Transfer failed");
        emit EtherSent(_to, _amount);
    }
}
