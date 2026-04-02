// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title SendingEther
/// @notice Demonstrates different ways to send ether.
/// @dev transfer: 2300 gas, reverts on failure. send: 2300 gas, returns bool. call: all gas, returns bool+data.
contract SendingEther {
    /// @notice Emitted when ether is sent
    event Sent(address indexed to, uint256 amount, string method);

    /// @notice Fixed receiver used by all send methods
    address payable public immutable receiver;
    address public immutable owner;

    constructor(address payable receiver_) {
        require(receiver_ != address(0), "Zero address");
        receiver = receiver_;
        owner = msg.sender;
    }

    /// @notice Send via transfer (reverts on failure, 2300 gas)
    function sendViaTransfer(uint256 amount) external payable {
        require(msg.value == amount, "Value mismatch");
        receiver.transfer(amount);
        emit Sent(receiver, amount, "transfer");
    }

    /// @notice Send via send (returns bool, 2300 gas)
    function sendViaSend(uint256 amount) external payable returns (bool) {
        require(msg.value == amount, "Value mismatch");
        bool success = receiver.send(amount);
        require(success, "Send failed");
        emit Sent(receiver, amount, "send");
        return success;
    }

    /// @notice Send via call (forwards all gas, returns bool)
    function sendViaCall(uint256 amount) external payable returns (bool) {
        require(msg.value == amount, "Value mismatch");
        (bool success,) = receiver.call{value: msg.value}("");
        require(success, "Call failed");
        emit Sent(receiver, amount, "call");
        return success;
    }

    /// @notice Recommended way: call with reentrancy protection
    function sendSafely(uint256 amount) external payable {
        require(msg.value == amount, "Value mismatch");
        (bool success,) = receiver.call{value: msg.value}("");
        require(success, "Safe send failed");
        emit Sent(receiver, amount, "safe call");
    }

    function sweepToReceiver() external {
        uint256 bal = address(this).balance;
        if (bal < 1) return;
        (bool ok,) = receiver.call{value: bal}("");
        require(ok, "Sweep failed");
    }

    function withdrawEther(address payable to, uint256 amount) external {
        require(msg.sender == owner, "Not owner");
        require(to != address(0), "Zero address");
        (bool ok,) = to.call{value: amount}("");
        require(ok, "Withdraw failed");
    }

    receive() external payable {
        // Never retain ETH: immediately forward to the fixed receiver.
        (bool ok,) = receiver.call{value: msg.value}("");
        require(ok, "Forward failed");
    }
}

/// @title EtherReceiver
/// @notice Contract that can receive ether
contract EtherReceiver {
    address public immutable owner;

    /// @notice Emitted when ether received
    event Received(address indexed sender, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function withdrawEther(address payable to, uint256 amount) external {
        require(msg.sender == owner, "Not owner");
        require(to != address(0), "Zero address");
        (bool ok,) = to.call{value: amount}("");
        require(ok, "Withdraw failed");
    }
}


