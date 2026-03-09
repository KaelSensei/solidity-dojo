// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {TransientStorage} from "../../src/basic/TransientStorage.sol";

/// @title TransientStorageTest
/// @notice Tests for TransientStorage contract
contract TransientStorageTest is Test {
    TransientStorage public transientStorage;

    function setUp() public {
        transientStorage = new TransientStorage();
    }

    /// @notice Test that lock is not set initially
    function test_InitiallyUnlocked() public view {
        assertFalse(transientStorage.isLocked());
    }

    /// @notice Test that protected operation works when not locked
    function test_ProtectedOperation_Success() public {
        vm.expectEmit(true, false, false, true);
        emit TransientStorage.OperationCompleted(address(this), 100);
        transientStorage.protectedOperation(100);
    }

    /// @notice Test that lock is cleared after operation
    function test_LockClearedAfterOperation() public {
        transientStorage.protectedOperation(100);
        assertFalse(transientStorage.isLocked());
    }

    /// @notice Test reentrancy detection (would need external contract to test properly)
    function test_GasComparison() public {
        (uint256 transientGas, uint256 storageGas) = transientStorage.compareGasCosts();
        
        // Transient storage should be significantly cheaper
        // Each transient storage op costs ~100 gas vs ~5000 for SSTORE (warm)
        assertLt(transientGas, storageGas, "Transient storage should be cheaper");
    }
}
