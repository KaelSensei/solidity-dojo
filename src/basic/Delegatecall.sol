// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Implementation
/// @notice Logic contract for delegatecall
contract Implementation {
    /// @notice Storage slot 0 - matches proxy
    uint256 public value;
    /// @notice Storage slot 1 - matches proxy
    address public owner;

    /// @notice Set value in storage
    function setValue(uint256 _value) external {
        value = _value;
    }

    /// @notice Get value from storage
    function getValue() external view returns (uint256) {
        return value;
    }
}

/// @title Proxy
/// @notice Proxy using delegatecall
contract Proxy {
    /// @notice Storage slot 0 - delegates to implementation
    uint256 public value;
    /// @notice Storage slot 1
    address public owner;
    /// @notice Implementation address
    address public implementation;

    constructor(address _implementation) {
        implementation = _implementation;
        owner = msg.sender;
    }

    /// @notice RECEIVE: Accept ether
    receive() external payable {}

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
}

/// @title DelegatecallDemo
/// @notice Simple delegatecall demonstration
contract DelegatecallDemo {
    /// @notice Value in this contract's storage
    uint256 public value;
    /// @notice Sender from delegatecall context
    address public sender;
    /// @notice Address of this contract
    address public selfAddress;

    /// @notice Execute delegatecall to target
    function executeDelegatecall(address _target, uint256 _value) external {
        (bool success,) = _target.delegatecall(
            abi.encodeWithSignature("setValue(uint256)", _value)
        );
        require(success, "Delegatecall failed");
    }

    /// @notice Set values showing delegatecall context
    function setValue(uint256 _value) external {
        value = _value;
        sender = msg.sender; // In delegatecall, this is the original caller
        selfAddress = address(this); // In delegatecall, this is the proxy address
    }
}
