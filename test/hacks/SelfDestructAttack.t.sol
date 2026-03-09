// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/hacks/SelfDestructAttack.sol";

/// @title SelfDestruct Attack Test Suite
contract SelfDestructAttackTest is Test {
    Victim public victim;
    Attacker public attacker;

    address public owner = address(0x1);
    address public hacker = address(0x2);

    function setUp() public {
        vm.prank(owner);
        victim = new Victim();
    }

    /// @notice Test victim receives ether
    function test_VictimReceivesEther() public {
        vm.deal(hacker, 10 ether);
        
        vm.prank(hacker);
        (bool success, ) = address(victim).call{value: 1 ether}("");
        
        assertTrue(success);
        assertEq(address(victim).balance, 1 ether);
    }

    /// @notice Test selfdestruct can force ether
    function test_SelfDestructForcesEther() public {
        vm.deal(hacker, 5 ether);
        
        vm.prank(hacker);
        attacker = new Attacker(address(victim));
        
        vm.prank(hacker);
        attacker.attack{value: 2 ether}();
        
        assertEq(address(victim).balance, 2 ether);
    }

    /// @notice Test selfdestruct attack
    function test_SelfDestructAttack() public {
        // Create attacker and fund it
        vm.prank(hacker);
        attacker = new Attacker(address(victim));
        vm.deal(address(attacker), 5 ether);
        
        attacker.selfDestructAttack();
        
        assertEq(address(victim).balance, 5 ether);
    }

    /// @notice Test victim can receive and track ether
    function test_VictimCanReceive() public {
        vm.deal(hacker, 10 ether);
        vm.prank(hacker);
        (bool success, ) = address(victim).call{value: 5 ether}("");
        require(success, "call failed");
        
        // Victim tracks balance correctly
        assertEq(address(victim).balance, 5 ether);
    }
}
