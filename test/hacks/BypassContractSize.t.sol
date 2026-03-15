// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/hacks/BypassContractSize.sol";

/// @title BypassContractSize Test Suite
/// @notice Demonstrates the extcodesize bypass via constructor calls
contract BypassContractSizeTest is Test {
    Target public target;
    BetterTarget public betterTarget;

    address public eoa = makeAddr("eoa");

    function setUp() public {
        target = new Target();
        betterTarget = new BetterTarget();
    }

    /// @notice EOA can call Target.protected() — passes extcodesize check
    function test_EOACanCallProtected() public {
        vm.prank(eoa);
        target.protected();
        assertEq(target.protectedValue(), 1);
    }

    /// @notice Normal deployed contract is blocked by extcodesize check
    function test_NormalContractIsBlocked() public {
        NormalContract normalContract = new NormalContract();

        vm.expectRevert(
            abi.encodeWithSelector(CallerIsContract.selector, address(normalContract))
        );
        normalContract.tryCall(address(target));
    }

    /// @notice Attacker bypasses extcodesize check from constructor
    function test_AttackerBypassesExtcodesizeCheck() public {
        // Before attack
        assertEq(target.protectedValue(), 0);

        // Deploy Attacker — its constructor calls Target.protected()
        // During construction, extcodesize(attacker) == 0, so the check passes
        Attacker attackerContract = new Attacker(address(target));

        // The attack succeeded: protectedValue was incremented
        assertEq(target.protectedValue(), 1);
        assertTrue(attackerContract.attacked());
    }

    /// @notice Verify extcodesize is 0 during construction but > 0 after
    function test_ExtcodesizeZeroDuringConstruction() public {
        // After deployment, the Attacker contract has code
        Attacker attackerContract = new Attacker(address(target));
        assertTrue(target.isContract(address(attackerContract)));

        // But during construction it appeared to be an EOA (size was 0)
        // This is proven by the fact that the attack succeeded
        assertTrue(attackerContract.attacked());
    }

    /// @notice BetterTarget blocks constructor-based attacks via tx.origin
    function test_BetterTargetBlocksConstructorAttack() public {
        // BetterTarget uses msg.sender == tx.origin check.
        // When Attacker's constructor calls BetterTarget.protected(),
        // msg.sender is the Attacker contract but tx.origin is this test contract.
        // So msg.sender != tx.origin, and the call reverts.
        vm.expectRevert();
        new Attacker(address(betterTarget));
    }

    /// @notice EOA can call BetterTarget.protected()
    function test_EOACanCallBetterTarget() public {
        // For a direct EOA call: msg.sender == tx.origin == eoa
        vm.prank(eoa, eoa); // Sets both msg.sender and tx.origin
        betterTarget.protected();
        assertEq(betterTarget.protectedValue(), 1);
    }

    /// @notice Multiple EOA calls increment the counter
    function test_MultipleEOACalls() public {
        vm.prank(eoa);
        target.protected();
        vm.prank(eoa);
        target.protected();
        assertEq(target.protectedValue(), 2);
    }
}
