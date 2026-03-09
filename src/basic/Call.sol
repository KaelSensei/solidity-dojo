// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Call
/// @notice Demonstrates low-level call operations.
/// @dev call is powerful but dangerous - check return values carefully.
contract Call {
    /// @notice Emitted on successful call
    event CallSuccess(address indexed target, bytes data, bytes result);
    /// @notice Emitted on failed call
    event CallFailed(address indexed target, bytes data);

    /// @notice Call a function by selector
    /// @param _target Target contract address
    /// @param _selector Function selector
    function callBySelector(address _target, bytes4 _selector) external returns (bool, bytes memory) {
        (bool success, bytes memory data) = _target.call(abi.encodePacked(_selector));
        if (success) {
            emit CallSuccess(_target, abi.encodePacked(_selector), data);
        } else {
            emit CallFailed(_target, abi.encodePacked(_selector));
        }
        return (success, data);
    }

    /// @notice Call with specific value
    /// @param _target Target address
    /// @param _data Call data
    /// @param _value Ether to send
    function callWithValue(address _target, bytes calldata _data, uint256 _value) external payable returns (bool, bytes memory) {
        (bool success, bytes memory result) = _target.call{value: _value}(_data);
        require(success, "Call failed");
        return (success, result);
    }

    /// @notice Static call (no state changes)
    /// @param _target Target address
    /// @param _data Call data
    function staticCall(address _target, bytes calldata _data) external view returns (bool, bytes memory) {
        (bool success, bytes memory result) = _target.staticcall(_data);
        return (success, result);
    }

    /// @notice Batch multiple calls
    /// @param _targets Array of target addresses
    /// @param _data Array of call data
    function batchCall(address[] calldata _targets, bytes[] calldata _data) external returns (bool[] memory, bytes[] memory) {
        require(_targets.length == _data.length, "Length mismatch");
        bool[] memory successes = new bool[](_targets.length);
        bytes[] memory results = new bytes[](_targets.length);

        for (uint256 i = 0; i < _targets.length; i++) {
            (bool success, bytes memory result) = _targets[i].call(_data[i]);
            successes[i] = success;
            results[i] = result;
        }
        return (successes, results);
    }

    receive() external payable {}
}

/// @title TargetContract
/// @notice Target for call demonstrations
contract TargetContract {
    uint256 public value;
    mapping(address => uint256) public balances;

    function setValue(uint256 _value) external {
        value = _value;
    }

    function getValue() external view returns (uint256) {
        return value;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }
}
