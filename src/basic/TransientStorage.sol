// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title TransientStorage
/// @notice Demonstrates EIP-1153 transient storage for reentrancy protection.
/// @dev Transient storage is cleared at end of transaction, cheaper than regular storage.
contract TransientStorage {
    /// @notice Transient storage slot for reentrancy lock
    /// @dev Using assembly to access tload/tstore
    bytes32 constant LOCK_SLOT = keccak256("reentrancy.lock");

    /// @notice Emitted when operation completes
    event OperationCompleted(address indexed caller, uint256 amount);

    /// @notice Error thrown on reentrancy attempt
    error ReentrancyDetected();

    /// @notice Modifier to prevent reentrant calls using transient storage
    modifier nonReentrant() {
        // Check if locked using tload
        bool locked;
        bytes32 slot = LOCK_SLOT;
        assembly {
            locked := tload(slot)
        }
        if (locked) revert ReentrancyDetected();

        // Set lock using tstore
        assembly {
            tstore(slot, 1)
        }

        _;

        // Clear lock
        assembly {
            tstore(slot, 0)
        }
    }

    /// @notice Protected function that could be vulnerable to reentrancy
    /// @param _amount Amount to process
    function protectedOperation(uint256 _amount) external nonReentrant {
        // Simulate some work
        // In a real scenario, this might involve external calls
        emit OperationCompleted(msg.sender, _amount);
    }

    /// @notice Returns current lock status
    /// @return locked True if currently locked
    function isLocked() external view returns (bool locked) {
        bytes32 slot = LOCK_SLOT;
        assembly {
            locked := tload(slot)
        }
    }

    /// @notice Compares gas cost: transient storage vs regular storage for lock
    /// @return transientGas Gas used with transient storage
    /// @return storageGas Gas used with regular storage
    function compareGasCosts() external returns (uint256 transientGas, uint256 storageGas) {
        // Measure transient storage
        uint256 gasBefore = gasleft();
        bytes32 slot = LOCK_SLOT;
        assembly {
            tstore(slot, 1)
            tstore(slot, 0)
        }
        transientGas = gasBefore - gasleft();

        // Measure regular storage (using a temporary slot)
        bytes32 tempSlot = keccak256("temp.lock");
        gasBefore = gasleft();
        assembly {
            sstore(tempSlot, 1)
            sstore(tempSlot, 0)
        }
        storageGas = gasBefore - gasleft();
    }
}
