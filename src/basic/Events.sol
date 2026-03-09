// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Events
/// @notice Demonstrates event logging with various parameter types.
/// @dev Events are the cheapest form of onchain storage. Use indexed for filtering.
contract Events {
    /// @notice Simple event with no parameters
    event SimpleEvent();

    /// @notice Event with single parameter (not indexed)
    event ValueChanged(uint256 newValue);

    /// @notice Event with indexed parameter (topic) - searchable
    /// @dev Up to 3 indexed params per event. Indexed = stored as topic (expensive but searchable).
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @notice Event with all parameters indexed
    event Approval(address indexed owner, address indexed spender, uint256 indexed value);

    /// @notice Event with mixed indexed and non-indexed params
    /// @dev Non-indexed params go in data (cheaper, not searchable).
    event ComplexEvent(
        address indexed sender,
        uint256 indexed id,
        string message,
        uint256 timestamp
    );

    /// @notice Counter for generating IDs
    uint256 private counter;

    /// @notice Emits a simple event
    function emitSimple() external {
        emit SimpleEvent();
    }

    /// @notice Emits value changed event
    /// @param _value New value
    function emitValueChanged(uint256 _value) external {
        emit ValueChanged(_value);
    }

    /// @notice Emits transfer event
    /// @param _to Recipient
    /// @param _amount Amount transferred
    function emitTransfer(address _to, uint256 _amount) external {
        emit Transfer(msg.sender, _to, _amount);
    }

    /// @notice Emits approval event
    /// @param _spender Spender address
    /// @param _value Approved amount
    function emitApproval(address _spender, uint256 _value) external {
        emit Approval(msg.sender, _spender, _value);
    }

    /// @notice Emits complex event
    /// @param _message Message string
    function emitComplex(string calldata _message) external {
        counter++;
        emit ComplexEvent(msg.sender, counter, _message, block.timestamp);
    }

    /// @notice Batch emit multiple events
    /// @param _count Number of events to emit
    function batchEmit(uint256 _count) external {
        for (uint256 i = 0; i < _count;) {
            emit ValueChanged(i);
            unchecked { ++i; }
        }
    }

    /// @notice Demonstrates anonymous event (no signature hash as topic 0)
    /// @dev Anonymous events are cheaper but harder to filter
    event AnonymousEvent(uint256 value) anonymous;

    /// @notice Emits anonymous event
    function emitAnonymous(uint256 _value) external {
        emit AnonymousEvent(_value);
    }
}
