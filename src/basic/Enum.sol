// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title EnumExample
/// @notice Demonstrates Solidity enums.
/// @dev Enums are user-defined types with a fixed set of named values.
///      Internally stored as uint8 (0 to 255 members max).
contract EnumExample {
    /// @notice Status enum with three states
    enum Status {
        Pending,    // 0
        Active,     // 1
        Inactive    // 2
    }

    /// @notice Current status
    Status public status;

    /// @notice Emitted when status changes
    event StatusChanged(Status newStatus);

    /// @notice Gets the current status
    function get() external view returns (Status) {
        return status;
    }

    /// @notice Sets status to Pending (0)
    function setPending() external {
        status = Status.Pending;
        emit StatusChanged(status);
    }

    /// @notice Sets status to Active (1)
    function setActive() external {
        status = Status.Active;
        emit StatusChanged(status);
    }

    /// @notice Sets status to Inactive (2)
    function setInactive() external {
        status = Status.Inactive;
        emit StatusChanged(status);
    }

    /// @notice Resets status to default (Pending)
    /// @dev delete resets enum to first member (index 0)
    function reset() external {
        delete status;
    }

    /// @notice Sets status from uint8
    /// @param _status Raw uint8 value
    /// @dev Only valid enum values (0-2) should be used
    function setFromUint(uint8 _status) external {
        status = Status(_status);
        emit StatusChanged(status);
    }

    /// @notice Gets status as uint8
    function getAsUint() external view returns (uint8) {
        return uint8(status);
    }
}
