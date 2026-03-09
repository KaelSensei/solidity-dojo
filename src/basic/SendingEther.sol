// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title SendingEther
/// @notice Demonstrates different ways to send ether.
/// @dev transfer: 2300 gas, reverts on failure. send: 2300 gas, returns bool. call: all gas, returns bool+data.
contract SendingEther {
    /// @notice Emitted when ether is sent
    event Sent(address indexed to, uint256 amount, string method);

    /// @notice Send via transfer (reverts on failure, 2300 gas)
    /// @param _to Recipient address
    /// @param _amount Amount to send
    function sendViaTransfer(address payable _to, uint256 _amount) external {
        _to.transfer(_amount);
        emit Sent(_to, _amount, "transfer");
    }

    /// @notice Send via send (returns bool, 2300 gas)
    /// @param _to Recipient address
    /// @param _amount Amount to send
    function sendViaSend(address payable _to, uint256 _amount) external returns (bool) {
        bool success = _to.send(_amount);
        require(success, "Send failed");
        emit Sent(_to, _amount, "send");
        return success;
    }

    /// @notice Send via call (forwards all gas, returns bool)
    /// @param _to Recipient address
    /// @param _amount Amount to send
    function sendViaCall(address payable _to, uint256 _amount) external returns (bool) {
        (bool success,) = _to.call{value: _amount}("");
        require(success, "Call failed");
        emit Sent(_to, _amount, "call");
        return success;
    }

    /// @notice Recommended way: call with reentrancy protection
    /// @param _to Recipient address
    /// @param _amount Amount to send
    function sendSafely(address payable _to, uint256 _amount) external {
        (bool success,) = _to.call{value: _amount}("");
        require(success, "Safe send failed");
        emit Sent(_to, _amount, "safe call");
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
