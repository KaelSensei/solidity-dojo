// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/hacks/HidingMaliciousCode.sol";

/// @title HidingMaliciousCode Test Suite
/// @notice Demonstrates how an identical interface can hide malicious logic
contract HidingMaliciousCodeTest is Test {
    Bar public legitimateBar;
    MaliciousBar public maliciousBar;
    Foo public safeFoo;
    Foo public compromisedFoo;

    address public attacker = makeAddr("attacker");
    address public user = makeAddr("user");

    function setUp() public {
        // Deploy legitimate Bar
        legitimateBar = new Bar();

        // Attacker deploys MaliciousBar
        vm.prank(attacker);
        maliciousBar = new MaliciousBar();

        // Deploy Foo with legitimate Bar — safe
        safeFoo = new Foo(address(legitimateBar));

        // Deploy Foo with MaliciousBar — compromised
        compromisedFoo = new Foo(address(maliciousBar));

        // Fund both Foo contracts with ETH
        vm.deal(address(safeFoo), 10 ether);
        vm.deal(address(compromisedFoo), 10 ether);
        vm.deal(user, 1 ether);
    }

    /// @notice Foo with legitimate Bar works fine — no ETH stolen
    function test_LegitimateBarIsSafe() public {
        uint256 fooBalanceBefore = address(safeFoo).balance;

        vm.prank(user);
        safeFoo.doSomething();

        // Foo's ETH balance is unchanged
        assertEq(address(safeFoo).balance, fooBalanceBefore);
    }

    /// @notice Foo with MaliciousBar gets ETH stolen via reentrancy
    function test_MaliciousBarStealsETH() public {
        uint256 attackerBalanceBefore = attacker.balance;
        uint256 fooBalance = address(compromisedFoo).balance;
        assertEq(fooBalance, 10 ether);

        // User innocently calls doSomething — triggers the hidden reentrancy attack
        vm.prank(user);
        compromisedFoo.doSomething();

        // All of Foo's ETH was drained to the attacker
        assertEq(address(compromisedFoo).balance, 0);
        assertEq(attacker.balance, attackerBalanceBefore + fooBalance);
    }

    /// @notice Both Bar implementations satisfy the same IBar interface
    function test_InterfaceLooksIdentical() public {
        // Both have the log(address) function — indistinguishable at interface level
        bytes4 logSelector = IBar.log.selector;
        assertEq(logSelector, bytes4(keccak256("log(address)")));

        // Both can be called through the IBar interface
        IBar(address(legitimateBar)).log(user);
        // MaliciousBar looks the same but has hidden side effects
        // (We don't call it directly here since it tries to re-enter msg.sender)
    }

    /// @notice Multiple calls drain ETH each time Foo has funds
    function test_RepeatedDraining() public {
        // First call drains the initial balance
        vm.prank(user);
        compromisedFoo.doSomething();
        assertEq(address(compromisedFoo).balance, 0);

        // Someone sends more ETH to compromised Foo
        vm.deal(address(compromisedFoo), 5 ether);

        // Next call drains again
        vm.prank(user);
        compromisedFoo.doSomething();
        assertEq(address(compromisedFoo).balance, 0);
    }

    /// @notice MaliciousBar does nothing harmful when caller has no ETH
    function test_MaliciousBarNoETHNoDamage() public {
        // Deploy a Foo with no ETH
        Foo emptyFoo = new Foo(address(maliciousBar));

        // Call succeeds but no ETH is transferred
        vm.prank(user);
        emptyFoo.doSomething();
        assertEq(address(emptyFoo).balance, 0);
    }
}
