// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/hacks/TxOriginAttack.sol";

/// @title TxOrigin Attack Test Suite
contract TxOriginAttackTest is Test {
    PhishableWallet public wallet;
    TxOriginAttacker public attacker;
    address public owner = address(0x1);
    address public hacker = address(0x2);

    function setUp() public {
        vm.prank(owner);
        wallet = new PhishableWallet();
        attacker = new TxOriginAttacker(address(wallet));
    }

    /// @notice Test owner can set helper
    function test_OwnerCanSetHelper() public {
        vm.prank(owner, owner); // Set both msg.sender and tx.origin
        wallet.setHelper(address(attacker));
        
        assertEq(wallet.helper(), address(attacker));
    }

    /// @notice Test non-owner cannot set helper
    function test_NonOwnerCannotSetHelper() public {
        vm.prank(hacker);
        vm.expectRevert("Not owner");
        wallet.setHelper(address(attacker));
    }

    /// @notice Test owner can withdraw
    function test_OwnerCanWithdraw() public {
        vm.deal(address(wallet), 10 ether);
        
        vm.prank(owner, owner); // Set both msg.sender and tx.origin
        wallet.withdrawAll(payable(owner));
        
        assertEq(owner.balance, 10 ether);
    }

    /// @notice Test non-owner cannot withdraw
    function test_NonOwnerCannotWithdraw() public {
        vm.deal(address(wallet), 10 ether);
        
        vm.prank(hacker);
        vm.expectRevert("Not owner");
        wallet.withdrawAll(payable(hacker));
    }
}
