// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {MultiSigWallet} from "src/applications/MultiSigWallet.sol";

contract MultiSigWalletTest is Test {
    MultiSigWallet public wallet;
    address[] public owners;
    uint256 public threshold = 2;

    address owner1 = makeAddr("owner1");
    address owner2 = makeAddr("owner2");
    address owner3 = makeAddr("owner3");
    address nonOwner = makeAddr("nonOwner");

    function setUp() public {
        owners = [owner1, owner2, owner3];
        wallet = new MultiSigWallet(owners, threshold);
    }

    /// @notice Test that owners are set correctly
    function test_OwnersSetCorrectly() public view {
        assertTrue(wallet.isOwner(owner1));
        assertTrue(wallet.isOwner(owner2));
        assertTrue(wallet.isOwner(owner3));
        assertEq(wallet.getOwners().length, 3);
    }

    /// @notice Test that threshold is set correctly
    function test_ThresholdSetCorrectly() public view {
        assertEq(wallet.threshold(), 2);
    }

    /// @notice Test that non-owner cannot submit transaction
    function test_NonOwnerCannotSubmit() public {
        vm.prank(nonOwner);
        vm.expectRevert();
        wallet.submitTransaction(address(0), 0, "");
    }

    /// @notice Test submitting a transaction
    function test_SubmitTransaction() public {
        vm.prank(owner1);
        wallet.submitTransaction(address(0x1234), 1 ether, "");

        (address to, uint256 value, , bool executed, ) = wallet.getTransaction(0);
        assertEq(to, address(0x1234));
        assertEq(value, 1 ether);
        assertFalse(executed);
    }

    /// @notice Test confirming a transaction
    function test_ConfirmTransaction() public {
        vm.prank(owner1);
        wallet.submitTransaction(address(0x1234), 0, "");

        vm.prank(owner1);
        wallet.confirmTransaction(0);

        assertTrue(wallet.getConfirmation(0, owner1));
    }

    /// @notice Test executing transaction after threshold reached
    function test_ExecuteAfterThreshold() public {
        address target = address(new TargetContract());

        vm.prank(owner1);
        wallet.submitTransaction(target, 0, abi.encodeCall(TargetContract.setValue, (42)));

        vm.prank(owner1);
        wallet.confirmTransaction(0);

        vm.prank(owner2);
        wallet.confirmTransaction(0);

        vm.prank(owner1);
        wallet.executeTransaction(0);

        (,,, bool executed, ) = wallet.getTransaction(0);
        assertTrue(executed);
    }

    /// @notice Test revoking confirmation
    function test_RevokeConfirmation() public {
        vm.prank(owner1);
        wallet.submitTransaction(address(0x1234), 0, "");

        vm.prank(owner1);
        wallet.confirmTransaction(0);

        vm.prank(owner1);
        wallet.revokeConfirmation(0);

        assertFalse(wallet.getConfirmation(0, owner1));
    }

    /// @notice Test cannot execute with insufficient confirmations
    function test_CannotExecuteWithoutThreshold() public {
        vm.prank(owner1);
        wallet.submitTransaction(address(0x1234), 0, "");

        vm.prank(owner1);
        wallet.confirmTransaction(0);

        vm.prank(owner1);
        vm.expectRevert();
        wallet.executeTransaction(0);
    }

    /// @notice Test receive ether
    function test_ReceiveEther() public {
        (bool success, ) = address(wallet).call{value: 1 ether}("");
        assertTrue(success);
        assertEq(address(wallet).balance, 1 ether);
    }
}

contract TargetContract {
    uint256 public value;

    function setValue(uint256 _value) external {
        value = _value;
    }
}
