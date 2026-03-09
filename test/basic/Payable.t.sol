// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Payable} from "../../src/basic/Payable.sol";

/// @title PayableTest
/// @notice Tests for Payable contract
contract PayableTest is Test {
    Payable public payableContract;
    address public owner;

    function setUp() public {
        owner = address(this);
        payableContract = new Payable();
    }

    /// @notice Test deposit receives ether
    function test_Deposit() public {
        vm.expectEmit(true, false, false, true);
        emit Payable.EtherReceived(address(this), 1 ether);
        payableContract.deposit{value: 1 ether}();
        assertEq(payableContract.getBalance(), 1 ether);
        assertEq(payableContract.totalReceived(), 1 ether);
    }

    /// @notice Test deposit with memo
    function test_DepositWithMemo() public {
        payableContract.depositWithMemo{value: 0.5 ether}("Test deposit");
        assertEq(payableContract.getBalance(), 0.5 ether);
    }

    /// @notice Test receive function
    function test_Receive() public {
        (bool success,) = address(payableContract).call{value: 1 ether}("");
        assertTrue(success);
        assertEq(payableContract.getBalance(), 1 ether);
    }

    /// @notice Test fallback function
    function test_Fallback() public {
        (bool success,) = address(payableContract).call{value: 0.5 ether}(abi.encodeWithSignature("nonexistent()"));
        assertTrue(success);
        assertEq(payableContract.getBalance(), 0.5 ether);
    }

    /// @notice Test owner can withdraw
    function test_Withdraw() public {
        payableContract.deposit{value: 2 ether}();
        // The test contract is the owner, but we need to send to a recipient
        // Use withdrawTo which sends to a different address
        address recipient = makeAddr("recipient");
        payableContract.withdrawTo(payable(recipient), 1 ether);
        assertEq(recipient.balance, 1 ether);
    }

    /// @notice Test non-owner cannot withdraw
    function test_Withdraw_NotOwner() public {
        payableContract.deposit{value: 1 ether}();
        vm.prank(makeAddr("nonOwner"));
        vm.expectRevert("Not owner");
        payableContract.withdraw();
    }

    /// @notice Test withdraw to specific address
    function test_WithdrawTo() public {
        address recipient = makeAddr("recipient");
        payableContract.deposit{value: 2 ether}();
        payableContract.withdrawTo(payable(recipient), 1 ether);
        assertEq(recipient.balance, 1 ether);
        assertEq(payableContract.getBalance(), 1 ether);
    }
}
