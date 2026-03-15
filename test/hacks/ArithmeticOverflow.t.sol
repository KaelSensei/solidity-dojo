// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/hacks/ArithmeticOverflow.sol";

/// @title ArithmeticOverflow Test Suite
/// @notice Demonstrates the difference between unchecked (pre-0.8) and checked (0.8+) math
contract ArithmeticOverflowTest is Test {
    VulnerableToken public vulnerable;
    SafeToken public safe;

    address public attacker = makeAddr("attacker");
    address public victim = makeAddr("victim");

    function setUp() public {
        vulnerable = new VulnerableToken();
        safe = new SafeToken();
    }

    /// @notice Underflow attack: transfer more than balance wraps to max uint256
    function test_VulnerableTokenUnderflow() public {
        // Attacker has 0 tokens
        assertEq(vulnerable.balances(attacker), 0);

        // Transfer 1 token with 0 balance — underflow in unchecked wraps around
        vm.prank(attacker);
        vulnerable.transfer(victim, 1);

        // Attacker's balance wrapped to type(uint256).max (2^256 - 1)
        assertEq(vulnerable.balances(attacker), type(uint256).max);
        // Victim received the 1 token
        assertEq(vulnerable.balances(victim), 1);
    }

    /// @notice SafeToken reverts on the same underflow operation
    function test_SafeTokenRevertsOnUnderflow() public {
        assertEq(safe.balances(attacker), 0);

        // Same operation reverts with arithmetic underflow panic
        vm.prank(attacker);
        vm.expectRevert();
        safe.transfer(victim, 1);

        // Balances unchanged
        assertEq(safe.balances(attacker), 0);
        assertEq(safe.balances(victim), 0);
    }

    /// @notice Normal transfer works on both tokens
    function test_NormalTransferWorks() public {
        // Mint tokens first
        vulnerable.mint(attacker, 100);
        safe.mint(attacker, 100);

        // Transfer within balance works on both
        vm.prank(attacker);
        vulnerable.transfer(victim, 50);
        assertEq(vulnerable.balances(attacker), 50);
        assertEq(vulnerable.balances(victim), 50);

        vm.prank(attacker);
        safe.transfer(victim, 50);
        assertEq(safe.balances(attacker), 50);
        assertEq(safe.balances(victim), 50);
    }

    /// @notice Fuzz test: SafeToken never underflows
    /// @param mintAmount Amount to mint to sender
    /// @param transferAmount Amount to attempt to transfer
    function test_FuzzSafeTokenNeverUnderflows(uint256 mintAmount, uint256 transferAmount) public {
        // Bound mint to avoid overflow when adding to balances
        mintAmount = bound(mintAmount, 0, type(uint256).max / 2);

        safe.mint(attacker, mintAmount);

        if (transferAmount > mintAmount) {
            // Should revert on underflow
            vm.prank(attacker);
            vm.expectRevert();
            safe.transfer(victim, transferAmount);
        } else {
            // Should succeed
            vm.prank(attacker);
            safe.transfer(victim, transferAmount);
            assertEq(safe.balances(attacker), mintAmount - transferAmount);
            assertEq(safe.balances(victim), transferAmount);
        }
    }

    /// @notice Vulnerable token overflow on mint (unchecked addition wraps)
    function test_VulnerableTokenOverflowOnTransfer() public {
        // Give victim max balance
        vulnerable.mint(victim, type(uint256).max);

        // Attacker mints 1 token
        vulnerable.mint(attacker, 1);

        // Transfer 1 to victim causes overflow in victim's balance (wraps to 0)
        vm.prank(attacker);
        vulnerable.transfer(victim, 1);

        // Victim balance wrapped around: max + 1 = 0
        assertEq(vulnerable.balances(victim), 0);
    }
}
