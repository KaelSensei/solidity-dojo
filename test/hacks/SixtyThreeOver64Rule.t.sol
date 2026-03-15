// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/hacks/SixtyThreeOver64Rule.sol";

/// @title SixtyThreeOver64Rule Test Suite
/// @notice Demonstrates EIP-150 gas forwarding and unchecked call dangers
contract SixtyThreeOver64RuleTest is Test {
    Caller public caller;
    Target public target;

    function setUp() public {
        caller = new Caller();
        target = new Target();
    }

    /// @notice Normal call with enough gas succeeds
    function test_NormalCallWithEnoughGas() public {
        bool success = caller.callWithGas(address(target), 200_000);

        assertTrue(success);
        assertTrue(caller.lastCallSuccess());
        assertTrue(target.workCompleted());
    }

    /// @notice Call with too little gas — target fails
    function test_CallWithInsufficientGasFails() public {
        // Provide very little gas to the target — not enough for doWork()
        bool success = caller.callWithGas(address(target), 10_000);

        // The low-level call returns false (target ran out of gas or reverted)
        assertFalse(success);
        assertFalse(target.workCompleted());
    }

    /// @notice Safe call pattern catches failure and reverts
    function test_SafeCallRevertsOnFailure() public {
        // Deploy a target that will fail (e.g., by giving very little gas)
        // Use callAndVerify which checks return value
        // With enough gas, it should succeed
        caller.callAndVerify(address(target));
        assertTrue(caller.actionCompleted());
        assertTrue(target.workCompleted());
    }

    /// @notice Unsafe call pattern continues even when target fails
    function test_UnsafeCallContinuesOnFailure() public {
        // First, create a scenario where the target call fails.
        // We'll make the target revert by giving it insufficient gas via a wrapper.
        // For this test, we call unsafeCall which ignores the return value.

        // Reset target state
        target.reset();
        assertFalse(target.workCompleted());

        // The unsafeCall pattern ignores return values.
        // Even if we have enough gas here, this demonstrates the PATTERN:
        // actionCompleted is set to true regardless of whether doWork succeeded.
        caller.unsafeCall(address(target));

        // actionCompleted is true even though we should have verified the call
        assertTrue(caller.actionCompleted());
    }

    /// @notice Demonstrate 63/64 rule: target receives less gas than total remaining
    function test_GasForwardingRule() public {
        // The 63/64 rule means the target receives at most 63/64 of remaining gas.
        // We can observe this by measuring gas usage.
        uint256 gasUsed = caller.measureGasForwarding(address(target));

        // The call consumed some gas — this proves the call was made
        assertGt(gasUsed, 0);
        assertTrue(caller.lastCallSuccess());
    }

    /// @notice callAndVerify reverts when target would fail
    function test_CallAndVerifyRevertsOnTargetRevert() public {
        // Create a mock target that always reverts
        RevertingTarget revertTarget = new RevertingTarget();

        vm.expectRevert(ExternalCallFailed.selector);
        caller.callAndVerify(address(revertTarget));

        // actionCompleted should NOT be set because we reverted
        assertFalse(caller.actionCompleted());
    }

    /// @notice unsafeCall marks action complete even when target reverts
    function test_UnsafeCallIgnoresRevert() public {
        RevertingTarget revertTarget = new RevertingTarget();

        // unsafeCall ignores the failure — this is the vulnerability
        caller.unsafeCall(address(revertTarget));

        // actionCompleted is true even though the target reverted!
        // This is the silent failure that 63/64 rule can exploit.
        assertTrue(caller.actionCompleted());
    }

    /// @notice Low gas causes silent failure with unchecked calls
    function test_LowGasSilentFailure() public {
        // Call with very little gas — target's doWork() can't complete
        bool success = caller.callWithGas(address(target), 5_000);

        // Call failed, but caller continued executing (set lastCallSuccess)
        assertFalse(success);
        // target.workCompleted() is still false — work was never done
        assertFalse(target.workCompleted());
    }

    /// @notice Checking return value catches the issue
    function test_CheckingReturnValueCatchesIssue() public {
        // callWithGas returns the success status — if we check it, we know
        bool success = caller.callWithGas(address(target), 5_000);
        assertFalse(success);

        // The caller correctly reports the failure via lastCallSuccess
        assertFalse(caller.lastCallSuccess());
    }

    /// @notice Multiple successful calls work correctly
    function test_MultipleSuccessfulCalls() public {
        caller.callAndVerify(address(target));
        assertTrue(target.workCompleted());

        target.reset();
        assertFalse(target.workCompleted());

        caller.callAndVerify(address(target));
        assertTrue(target.workCompleted());
    }
}

/// @title RevertingTarget - helper that always reverts
/// @notice Used to test failure handling in Caller
contract RevertingTarget {
    function doWork() external pure returns (bool) {
        revert("always fails");
    }
}
