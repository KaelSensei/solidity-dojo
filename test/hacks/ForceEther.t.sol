// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/hacks/ForceEther.sol";

/// @title Force Ether Test Suite
contract ForceEtherTest is Test {
    ForceEtherVictim public victim;
    address public attacker = address(0x1);

    function setUp() public {
        victim = new ForceEtherVictim();
    }

    /// @notice Test can force ether via call
    function test_ForceEtherViaCall() public {
        vm.deal(attacker, 10 ether);
        
        vm.prank(attacker);
        (bool success, ) = address(victim).call{value: 5 ether}("");
        
        assertTrue(success);
        assertEq(address(victim).balance, 5 ether);
    }

    /// @notice Test selfdestruct forces ether
    function test_SelfDestructForcesEther() public {
        vm.deal(attacker, 10 ether);
        
        vm.prank(attacker);
        ForceEtherAttacker attackerContract = new ForceEtherAttacker();
        
        vm.prank(attacker);
        attackerContract.attack{value: 3 ether}(payable(address(victim)));
        
        assertEq(address(victim).balance, 3 ether);
    }
}
