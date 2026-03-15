// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/applications/PaymentChannel.sol";

/// @title PaymentChannel Test Suite
contract PaymentChannelTest is Test {
    PaymentChannel public channel;

    address public senderAddr;
    uint256 public senderKey;
    address public receiverAddr = makeAddr("receiver");

    uint256 public constant CHANNEL_BALANCE = 10 ether;
    uint256 public constant DURATION = 1 days;

    function setUp() public {
        (senderAddr, senderKey) = makeAddrAndKey("sender");

        vm.deal(senderAddr, CHANNEL_BALANCE);
        vm.prank(senderAddr);
        channel = new PaymentChannel{value: CHANNEL_BALANCE}(receiverAddr, DURATION);
    }

    /// @dev Helper: sign an amount using the sender's private key
    function _signAmount(uint256 amount) internal view returns (bytes memory) {
        bytes32 messageHash = channel.getHash(amount);
        bytes32 ethSignedHash = channel.getEthSignedHash(messageHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(senderKey, ethSignedHash);
        return abi.encodePacked(r, s, v);
    }

    // ─── Close Tests ────────────────────────────────────────────────────

    function test_ReceiverCanCloseWithValidSignature() public {
        uint256 payment = 3 ether;
        bytes memory sig = _signAmount(payment);

        uint256 receiverBalBefore = receiverAddr.balance;
        uint256 senderBalBefore = senderAddr.balance;

        vm.prank(receiverAddr);
        channel.close(payment, sig);

        assertEq(receiverAddr.balance, receiverBalBefore + payment, "Receiver should get payment");
        assertEq(
            senderAddr.balance,
            senderBalBefore + (CHANNEL_BALANCE - payment),
            "Sender should get refund"
        );
        assertTrue(channel.closed(), "Channel should be closed");
    }

    function test_CloseWithInvalidAmountReverts() public {
        // Sign for 3 ETH but try to close with 5 ETH
        bytes memory sig = _signAmount(3 ether);

        vm.prank(receiverAddr);
        vm.expectRevert(PaymentChannel.InvalidSignature.selector);
        channel.close(5 ether, sig);
    }

    function test_OnlyReceiverCanClose() public {
        bytes memory sig = _signAmount(1 ether);

        vm.prank(senderAddr);
        vm.expectRevert(PaymentChannel.NotReceiver.selector);
        channel.close(1 ether, sig);
    }

    function test_CannotCloseAlreadyClosed() public {
        bytes memory sig = _signAmount(1 ether);

        vm.prank(receiverAddr);
        channel.close(1 ether, sig);

        vm.prank(receiverAddr);
        vm.expectRevert(PaymentChannel.ChannelAlreadyClosed.selector);
        channel.close(1 ether, sig);
    }

    // ─── Timeout Tests ──────────────────────────────────────────────────

    function test_SenderCanTimeoutAfterExpiration() public {
        // Warp past expiration
        vm.warp(block.timestamp + DURATION + 1);

        uint256 senderBalBefore = senderAddr.balance;

        vm.prank(senderAddr);
        channel.timeout();

        assertEq(senderAddr.balance, senderBalBefore + CHANNEL_BALANCE, "Sender should reclaim all funds");
        assertTrue(channel.closed(), "Channel should be closed");
    }

    function test_CannotTimeoutBeforeExpiration() public {
        vm.prank(senderAddr);
        vm.expectRevert(PaymentChannel.ChannelNotExpired.selector);
        channel.timeout();
    }

    function test_OnlySenderCanTimeout() public {
        vm.warp(block.timestamp + DURATION + 1);

        vm.prank(receiverAddr);
        vm.expectRevert(PaymentChannel.NotSender.selector);
        channel.timeout();
    }

    // ─── Verify Tests ───────────────────────────────────────────────────

    function test_VerifyValidSignature() public view {
        uint256 amount = 2 ether;
        bytes memory sig = _signAmount(amount);

        assertTrue(channel.verify(amount, sig), "Valid signature should verify");
    }

    function test_VerifyInvalidSignature() public view {
        bytes memory sig = _signAmount(2 ether);

        // Verify with wrong amount
        assertFalse(channel.verify(5 ether, sig), "Wrong amount should not verify");
    }

    function test_CloseFullBalance() public {
        bytes memory sig = _signAmount(CHANNEL_BALANCE);

        vm.prank(receiverAddr);
        channel.close(CHANNEL_BALANCE, sig);

        assertEq(receiverAddr.balance, CHANNEL_BALANCE, "Receiver should get full balance");
    }
}
