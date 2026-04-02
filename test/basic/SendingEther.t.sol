// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {SendingEther, EtherReceiver} from "../../src/basic/SendingEther.sol";

/// @title SendingEtherTest
/// @notice Tests for SendingEther contract
contract SendingEtherTest is Test {
    SendingEther public sender;
    EtherReceiver public receiver;

    function setUp() public {
        receiver = new EtherReceiver();
        sender = new SendingEther(payable(address(receiver)));
    }

    /// @notice Test transfer works
    function test_SendViaTransfer() public {
        uint256 balanceBefore = address(receiver).balance;
        sender.sendViaTransfer{value: 1 ether}(1 ether);
        assertEq(address(receiver).balance, balanceBefore + 1 ether);
    }

    /// @notice Test send works
    function test_SendViaSend() public {
        uint256 balanceBefore = address(receiver).balance;
        bool success = sender.sendViaSend{value: 1 ether}(1 ether);
        assertTrue(success);
        assertEq(address(receiver).balance, balanceBefore + 1 ether);
    }

    /// @notice Test call works
    function test_SendViaCall() public {
        uint256 balanceBefore = address(receiver).balance;
        bool success = sender.sendViaCall{value: 1 ether}(1 ether);
        assertTrue(success);
        assertEq(address(receiver).balance, balanceBefore + 1 ether);
    }

    /// @notice Test safe send works
    function test_SendSafely() public {
        uint256 balanceBefore = address(receiver).balance;
        sender.sendSafely{value: 1 ether}(1 ether);
        assertEq(address(receiver).balance, balanceBefore + 1 ether);
    }

    function test_Revert_constructor_zeroReceiver() public {
        vm.expectRevert("Zero address");
        new SendingEther(payable(address(0)));
    }

    function test_Revert_valueMismatch() public {
        vm.expectRevert("Value mismatch");
        sender.sendViaCall{value: 2 ether}(1 ether);
    }

    receive() external payable {}
}
