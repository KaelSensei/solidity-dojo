// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {EtherWallet} from "../../src/applications/EtherWallet.sol";

contract EtherWalletTest is Test {
    EtherWallet public wallet;
    address public owner;
    address public alice = address(0x1);

    function setUp() public {
        owner = address(this);
        wallet = new EtherWallet();
    }

    /// @notice Unit test: can receive ether via receive
    function test_receive_receivesEther() public {
        uint256 amount = 1 ether;
        uint256 balanceBefore = wallet.getBalance();
        (bool success,) = address(wallet).call{value: amount}("");
        assertTrue(success);
        // Balance should increase by amount
        assertEq(wallet.getBalance(), balanceBefore + amount);
    }

    /// @notice Unit test: only owner can withdraw
    function test_onlyOwnerCanWithdraw() public {
        // Send ether to wallet
        (bool sent,) = address(wallet).call{value: 1 ether}("");
        require(sent, "Send failed");

        // Non-owner should revert
        vm.prank(alice);
        vm.expectRevert(EtherWallet.NotOwner.selector);
        wallet.withdraw();
    }

    /// @notice Unit test: withdrawal reverts when transfer fails (no balance)
    function test_withdrawal_revertsWhenNoBalance() public {
        // Try to withdraw with 0 balance - transfer will fail
        vm.expectRevert("Transfer failed");
        wallet.withdraw();
    }

    /// @notice Unit test: owner is set correctly
    function test_owner_isSetCorrectly() public view {
        assertEq(wallet.owner(), owner);
    }

    /// @notice Unit test: event emitted on deposit
    function test_deposit_emitsEvent() public {
        vm.expectEmit(true, false, false, true);
        emit EtherWallet.Deposit(address(this), 1 ether);
        (bool success,) = address(wallet).call{value: 1 ether}("");
        assertTrue(success);
    }
}
