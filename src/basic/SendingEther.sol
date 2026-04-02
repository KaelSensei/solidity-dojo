// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title SendingEther
/// @notice Demonstrates different ways to send ether.
/// @dev transfer: 2300 gas, reverts on failure. send: 2300 gas, returns bool. call: all gas, returns bool+data.
contract SendingEther {
    /// @notice Emitted when ether is sent
    event Sent(address indexed to, uint256 amount, string method);

    /// @notice Send via transfer (reverts on failure, 2300 gas)
    function sendViaTransfer(address payable to, uint256 amount) external {
        to.transfer(amount);
        emit Sent(to, amount, "transfer");
    }

    /// @notice Send via send (returns bool, 2300 gas)
    function sendViaSend(address payable to, uint256 amount) external returns (bool) {
        bool success = to.send(amount);
        require(success, "Send failed");
        emit Sent(to, amount, "send");
        return success;
    }

    /// @notice Send via call (forwards all gas, returns bool)
    function sendViaCall(address payable to, uint256 amount) external returns (bool) {
        (bool success,) = to.call{value: amount}("");
        require(success, "Call failed");
        emit Sent(to, amount, "call");
        return success;
    }

    /// @notice Recommended way: call with reentrancy protection
    function sendSafely(address payable to, uint256 amount) external {
        (bool success,) = to.call{value: amount}("");
        require(success, "Safe send failed");
        emit Sent(to, amount, "safe call");
    }

    receive() external payable {}
}

/// @title EtherReceiver
/// @notice Contract that can receive ether
contract EtherReceiver {
    /// @notice Emitted when ether received
    event Received(address indexed sender, uint256 amount);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}


