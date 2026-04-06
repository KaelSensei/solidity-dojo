// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Fallback
/// @notice Demonstrates fallback and receive functions.
/// @dev receive(): called on empty calldata. fallback(): called when no function matches.
contract Fallback {
    address public immutable owner = msg.sender;
    /// @notice Tracks calls
    uint256 public receiveCount;
    uint256 public fallbackCount;
    bytes public lastCalldata;

    /// @notice Emitted when receive is called
    event ReceiveCalled(uint256 amount, uint256 count);
    /// @notice Emitted when fallback is called
    event FallbackCalled(bytes data, uint256 amount, uint256 count);

    /// @notice RECEIVE: Called when ether sent with empty calldata
    receive() external payable {
        receiveCount++;
        emit ReceiveCalled(msg.value, receiveCount);
    }

    /// @notice FALLBACK: Called when function doesn't exist
    fallback() external payable {
        fallbackCount++;
        lastCalldata = msg.data;
        emit FallbackCalled(msg.data, msg.value, fallbackCount);
    }

    /// @notice Get contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function withdrawEther(address payable to, uint256 amount) external {
        require(msg.sender == owner, "Not owner");
        require(to != address(0), "Zero address");
        (bool ok,) = to.call{value: amount}("");
        require(ok, "Withdraw failed");
    }
}

/// @title Proxy
/// @notice Simple proxy using fallback
contract Proxy {
    /// @notice Implementation address
    address public immutable implementation;
    address public immutable owner;

    constructor(address _implementation) {
        require(_implementation != address(0), "Zero address");
        implementation = _implementation;
        owner = msg.sender;
    }

    /// @notice FALLBACK: Delegate all calls to implementation
    fallback() external payable {
        address impl = implementation;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}

    function withdrawEther(address payable to, uint256 amount) external {
        require(msg.sender == owner, "Not owner");
        require(to != address(0), "Zero address");
        (bool ok,) = to.call{value: amount}("");
        require(ok, "Withdraw failed");
    }
}

