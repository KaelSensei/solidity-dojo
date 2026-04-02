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
    function emitValueChanged(uint256 value) external {
        emit ValueChanged(value);
    }

    /// @notice Emits transfer event
    function emitTransfer(address to, uint256 amount) external {
        emit Transfer(msg.sender, to, amount);
    }

    /// @notice Emits approval event
    function emitApproval(address spender, uint256 value) external {
        emit Approval(msg.sender, spender, value);
    }

    /// @notice Emits complex event
    function emitComplex(string calldata message) external {
        counter++;
        emit ComplexEvent(msg.sender, counter, message, block.timestamp);
    }

    /// @notice Batch emit multiple events
    function batchEmit(uint256 count) external {
        for (uint256 i = 0; i < count; i++) {
            emit ValueChanged(i);
        }
    }

    /// @notice Demonstrates anonymous event (no signature hash as topic 0)
    /// @dev Anonymous events are cheaper but harder to filter
    event AnonymousEvent(uint256 value) anonymous;

    /// @notice Emits anonymous event
    function emitAnonymous(uint256 value) external {
        emit AnonymousEvent(value);
    }
}


