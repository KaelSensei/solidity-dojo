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
        (bool success,) = address(wallet).call{value: amount}("");
        assertTrue(success);
        assertEq(wallet.getBalance(), amount);
    }

    /// @notice Unit test: only owner can withdraw
    function test_onlyOwnerCanWithdraw() public {
        vm.deal(address(wallet), 1 ether);

        // Non-owner should revert
        vm.prank(alice);
        vm.expectRevert(EtherWallet.NotOwner.selector);
        wallet.withdraw();

        // Owner should succeed
        wallet.withdraw();
    }

    /// @notice Unit test: withdrawal transfers correct amount
    function test_withdrawal_transfersAmount() public {
        uint256 amount = 1 ether;
        vm.deal(address(wallet), amount);

        uint256 ownerBalanceBefore = owner.balance;
        wallet.withdraw();
        uint256 ownerBalanceAfter = owner.balance;

        assertEq(ownerBalanceAfter - ownerBalanceBefore, amount);
        assertEq(wallet.getBalance(), 0);
    }

    /// @notice Fuzz test: deposit and withdraw various amounts
    function testFuzz_deposit_withdraw(uint96 amount) public {
        vm.assume(amount > 0);
        vm.deal(address(wallet), amount);

        uint256 ownerBalanceBefore = owner.balance;
        wallet.withdraw();
        uint256 ownerBalanceAfter = owner.balance;

        assertEq(ownerBalanceAfter - ownerBalanceBefore, amount);
    }

    /// @notice Unit test: event emitted on deposit
    function test_deposit_emitsEvent() public {
        vm.expectEmit(true, false, false, true);
        emit EtherWallet.Deposit(address(this), 1 ether);
        (bool success,) = address(wallet).call{value: 1 ether}("");
        assertTrue(success);
    }

    /// @notice Unit test: event emitted on withdraw
    function test_withdraw_emitsEvent() public {
        vm.deal(address(wallet), 1 ether);
        vm.expectEmit(true, false, false, true);
        emit EtherWallet.Withdraw(owner, 1 ether);
        wallet.withdraw();
    }
}
