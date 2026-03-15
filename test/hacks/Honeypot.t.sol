// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/hacks/Honeypot.sol";

/// @title Honeypot Test Suite
/// @notice Demonstrates the honeypot trap and the honest alternative
contract HoneypotTest is Test {
    HoneypotLogger public logger;
    HoneypotBank public honeypotBank;
    HonestBank public honestBank;

    address public attacker = makeAddr("attacker");
    address public victim = makeAddr("victim");

    function setUp() public {
        // Attacker deploys the logger (they become the owner)
        vm.prank(attacker);
        logger = new HoneypotLogger();

        // Attacker deploys the honeypot bank with their logger
        honeypotBank = new HoneypotBank(address(logger));

        // Deploy the honest bank for comparison
        honestBank = new HonestBank();

        // Fund test accounts
        vm.deal(attacker, 10 ether);
        vm.deal(victim, 10 ether);
    }

    /// @notice Attacker can deposit and withdraw from HoneypotBank
    function test_AttackerCanWithdraw() public {
        // Attacker deposits to make the bank look legitimate
        vm.prank(attacker);
        honeypotBank.deposit{value: 2 ether}();
        assertEq(honeypotBank.balances(attacker), 2 ether);

        // Attacker can withdraw because the logger allows their address
        vm.prank(attacker);
        honeypotBank.withdraw();

        assertEq(honeypotBank.balances(attacker), 0);
        assertEq(attacker.balance, 10 ether);
    }

    /// @notice Victim deposits but cannot withdraw — the honeypot trap
    function test_VictimCannotWithdraw() public {
        // Victim sees the bank, deposits ETH
        vm.prank(victim);
        honeypotBank.deposit{value: 5 ether}();
        assertEq(honeypotBank.balances(victim), 5 ether);

        // Victim tries to withdraw — logger reverts for non-owners
        vm.prank(victim);
        vm.expectRevert(
            abi.encodeWithSelector(NotOwner.selector, victim, attacker)
        );
        honeypotBank.withdraw();

        // Funds are still trapped in the bank
        assertEq(honeypotBank.balances(victim), 5 ether);
        assertEq(victim.balance, 5 ether); // Lost 5 ETH to the bank
    }

    /// @notice HonestBank allows anyone to deposit and withdraw
    function test_HonestBankWorksForEveryone() public {
        // Victim deposits into the honest bank
        vm.prank(victim);
        honestBank.deposit{value: 3 ether}();
        assertEq(honestBank.balances(victim), 3 ether);

        // Victim can withdraw without issues
        vm.prank(victim);
        honestBank.withdraw();

        assertEq(honestBank.balances(victim), 0);
        assertEq(victim.balance, 10 ether);
    }

    /// @notice Multiple users can use HonestBank independently
    function test_HonestBankMultipleUsers() public {
        vm.prank(attacker);
        honestBank.deposit{value: 1 ether}();

        vm.prank(victim);
        honestBank.deposit{value: 2 ether}();

        // Both can withdraw
        vm.prank(attacker);
        honestBank.withdraw();
        assertEq(attacker.balance, 10 ether);

        vm.prank(victim);
        honestBank.withdraw();
        assertEq(victim.balance, 10 ether);
    }

    /// @notice Cannot withdraw with zero balance
    function test_RevertOnZeroBalance() public {
        vm.prank(victim);
        vm.expectRevert(
            abi.encodeWithSelector(InsufficientDeposit.selector, victim, 0)
        );
        honestBank.withdraw();
    }
}
