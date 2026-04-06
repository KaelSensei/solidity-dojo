// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Call
/// @notice Demonstrates low-level call operations.
/// @dev call is powerful but dangerous - check return values carefully.
contract Call {
    /// @notice Default target used for value-carrying calls
    address public immutable valueTarget;
    address public immutable owner;

    /// @notice Emitted on successful call
    event CallSuccess(address indexed target, bytes data, bytes result);
    /// @notice Emitted on failed call
    event CallFailed(address indexed target, bytes data);

    constructor(address valueTarget_) {
        require(valueTarget_ != address(0), "Zero address");
        valueTarget = valueTarget_;
        owner = msg.sender;
    }

    /// @notice Call a function by selector
    function callBySelector(address target, bytes4 selector) external returns (bool, bytes memory) {
        require(target != address(0), "Zero address");
        bytes memory encodedSelector = abi.encodePacked(selector);
        (bool success, bytes memory data) = target.call(encodedSelector);
        // Emit event before returning (avoid reentrancy concerns)
        if (success) {
            emit CallSuccess(target, encodedSelector, data);
        } else {
            emit CallFailed(target, encodedSelector);
        }
        return (success, data);
    }

    /// @notice Call with specific value
    function callWithValue(bytes calldata data, uint256 value) external payable returns (bool, bytes memory) {
        require(msg.value == value, "Value mismatch");
        (bool success, bytes memory result) = valueTarget.call{value: msg.value}(data);
        require(success, "Call failed");
        return (success, result);
    }

    /// @notice Static call (no state changes)
    function staticCall(address target, bytes calldata data) external view returns (bool, bytes memory) {
        require(target != address(0), "Zero address");
        (bool success, bytes memory result) = target.staticcall(data);
        return (success, result);
    }

    /// @notice Batch multiple calls
    function batchCall(address[] calldata targets, bytes[] calldata data) external returns (bool[] memory, bytes[] memory) {
        require(targets.length == data.length, "Length mismatch");
        bool[] memory successes = new bool[](targets.length);
        bytes[] memory results = new bytes[](targets.length);

        for (uint256 i = 0; i < targets.length; i++) {
            require(targets[i] != address(0), "Zero address");
            (bool success, bytes memory result) = targets[i].call(data[i]);
            successes[i] = success;
            results[i] = result;
        }
        return (successes, results);
    }

    // No receive/deposit: this contract should not retain ETH.
    function sweepToValueTarget() external {
        uint256 bal = address(this).balance;
        if (bal < 1) return;
        (bool ok,) = valueTarget.call{value: bal}("");
        require(ok, "Sweep failed");
    }

    function withdrawEther(address payable to, uint256 amount) external {
        require(msg.sender == owner, "Not owner");
        require(to != address(0), "Zero address");
        (bool ok,) = to.call{value: amount}("");
        require(ok, "Withdraw failed");
    }

    receive() external payable {
        // Never retain ETH: immediately forward to the fixed target.
        (bool ok,) = valueTarget.call{value: msg.value}("");
        require(ok, "Forward failed");
    }
}

/// @title TargetContract
/// @notice Target for call demonstrations
contract TargetContract {
    address public immutable owner;
    uint256 public value;
    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    function setValue(uint256 newValue) external {
        value = newValue;
    }

    function getValue() external view returns (uint256) {
        return value;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawEther(address payable to, uint256 amount) external {
        require(msg.sender == owner, "Not owner");
        require(to != address(0), "Zero address");
        (bool ok,) = to.call{value: amount}("");
        require(ok, "Withdraw failed");
    }
}


