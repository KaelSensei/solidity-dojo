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
        sender = new SendingEther();
        receiver = new EtherReceiver();
        // Fund the sender contract
        (bool success,) = address(sender).call{value: 10 ether}("");
        require(success);
    }

    /// @notice Test transfer works
    function test_SendViaTransfer() public {
        uint256 balanceBefore = address(receiver).balance;
        sender.sendViaTransfer(payable(address(receiver)), 1 ether);
        assertEq(address(receiver).balance, balanceBefore + 1 ether);
    }

    /// @notice Test send works
    function test_SendViaSend() public {
        uint256 balanceBefore = address(receiver).balance;
        bool success = sender.sendViaSend(payable(address(receiver)), 1 ether);
        assertTrue(success);
        assertEq(address(receiver).balance, balanceBefore + 1 ether);
    }

    /// @notice Test call works
    function test_SendViaCall() public {
        uint256 balanceBefore = address(receiver).balance;
        bool success = sender.sendViaCall(payable(address(receiver)), 1 ether);
        assertTrue(success);
        assertEq(address(receiver).balance, balanceBefore + 1 ether);
    }

    /// @notice Test safe send works
    function test_SendSafely() public {
        uint256 balanceBefore = address(receiver).balance;
        sender.sendSafely(payable(address(receiver)), 1 ether);
        assertEq(address(receiver).balance, balanceBefore + 1 ether);
    }

    receive() external payable {}
}
