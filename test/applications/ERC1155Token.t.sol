// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/applications/ERC1155Token.sol";

/// @title ERC1155Token Test Suite
contract ERC1155TokenTest is Test {
    ERC1155Token public token;
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public operator = makeAddr("operator");

    function setUp() public {
        token = new ERC1155Token();
        // Mint some tokens for alice: id 1 => 100, id 2 => 200
        token.mint(alice, 1, 100);
        token.mint(alice, 2, 200);
    }

    // ─── Mint Tests ─────────────────────────────────────────────────────

    function test_MintSingle() public {
        token.mint(bob, 3, 50);
        assertEq(token.balanceOf(bob, 3), 50);
    }

    function test_MintBatch() public {
        uint256[] memory ids = new uint256[](2);
        ids[0] = 10;
        ids[1] = 11;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 500;
        amounts[1] = 600;

        token.mintBatch(bob, ids, amounts);

        assertEq(token.balanceOf(bob, 10), 500);
        assertEq(token.balanceOf(bob, 11), 600);
    }

    function test_MintOnlyOwner() public {
        vm.prank(alice);
        vm.expectRevert(ERC1155Token.NotOwner.selector);
        token.mint(bob, 1, 100);
    }

    function test_MintBatchOnlyOwner() public {
        uint256[] memory ids = new uint256[](1);
        ids[0] = 1;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 100;

        vm.prank(alice);
        vm.expectRevert(ERC1155Token.NotOwner.selector);
        token.mintBatch(bob, ids, amounts);
    }

    function test_MintToZeroAddress() public {
        vm.expectRevert(ERC1155Token.ZeroAddress.selector);
        token.mint(address(0), 1, 100);
    }

    // ─── Transfer Tests ─────────────────────────────────────────────────

    function test_SafeTransferFrom() public {
        vm.prank(alice);
        token.safeTransferFrom(alice, bob, 1, 40, "");

        assertEq(token.balanceOf(alice, 1), 60);
        assertEq(token.balanceOf(bob, 1), 40);
    }

    function test_SafeBatchTransferFrom() public {
        uint256[] memory ids = new uint256[](2);
        ids[0] = 1;
        ids[1] = 2;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 30;
        amounts[1] = 50;

        vm.prank(alice);
        token.safeBatchTransferFrom(alice, bob, ids, amounts, "");

        assertEq(token.balanceOf(alice, 1), 70);
        assertEq(token.balanceOf(alice, 2), 150);
        assertEq(token.balanceOf(bob, 1), 30);
        assertEq(token.balanceOf(bob, 2), 50);
    }

    function test_TransferInsufficientBalance() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(ERC1155Token.InsufficientBalance.selector, 100, 999));
        token.safeTransferFrom(alice, bob, 1, 999, "");
    }

    function test_TransferNotApproved() public {
        vm.prank(bob);
        vm.expectRevert(ERC1155Token.NotApproved.selector);
        token.safeTransferFrom(alice, bob, 1, 10, "");
    }

    function test_TransferToZeroAddress() public {
        vm.prank(alice);
        vm.expectRevert(ERC1155Token.ZeroAddress.selector);
        token.safeTransferFrom(alice, address(0), 1, 10, "");
    }

    function test_BatchTransferLengthMismatch() public {
        uint256[] memory ids = new uint256[](2);
        ids[0] = 1;
        ids[1] = 2;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 10;

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(ERC1155Token.LengthMismatch.selector, 2, 1));
        token.safeBatchTransferFrom(alice, bob, ids, amounts, "");
    }

    // ─── Approval Tests ─────────────────────────────────────────────────

    function test_SetApprovalForAll() public {
        vm.prank(alice);
        token.setApprovalForAll(operator, true);

        assertTrue(token.isApprovedForAll(alice, operator));
    }

    function test_OperatorCanTransfer() public {
        vm.prank(alice);
        token.setApprovalForAll(operator, true);

        vm.prank(operator);
        token.safeTransferFrom(alice, bob, 1, 25, "");

        assertEq(token.balanceOf(alice, 1), 75);
        assertEq(token.balanceOf(bob, 1), 25);
    }

    function test_RevokeApproval() public {
        vm.prank(alice);
        token.setApprovalForAll(operator, true);

        vm.prank(alice);
        token.setApprovalForAll(operator, false);

        assertFalse(token.isApprovedForAll(alice, operator));

        vm.prank(operator);
        vm.expectRevert(ERC1155Token.NotApproved.selector);
        token.safeTransferFrom(alice, bob, 1, 10, "");
    }

    // ─── BalanceOfBatch ─────────────────────────────────────────────────

    function test_BalanceOfBatch() public view {
        address[] memory accounts = new address[](2);
        accounts[0] = alice;
        accounts[1] = alice;
        uint256[] memory ids = new uint256[](2);
        ids[0] = 1;
        ids[1] = 2;

        uint256[] memory balances = token.balanceOfBatch(accounts, ids);

        assertEq(balances[0], 100);
        assertEq(balances[1], 200);
    }

    function test_BalanceOfBatchLengthMismatch() public {
        address[] memory accounts = new address[](1);
        accounts[0] = alice;
        uint256[] memory ids = new uint256[](2);
        ids[0] = 1;
        ids[1] = 2;

        vm.expectRevert(abi.encodeWithSelector(ERC1155Token.LengthMismatch.selector, 1, 2));
        token.balanceOfBatch(accounts, ids);
    }

    // ─── Fuzz Tests ─────────────────────────────────────────────────────

    function testFuzz_MintAndTransfer(uint256 id, uint128 mintAmt, uint128 transferAmt) public {
        // Use uint128 to avoid overflow when minting
        uint256 mintAmount = uint256(mintAmt);
        uint256 transferAmount = bound(uint256(transferAmt), 0, mintAmount);

        token.mint(alice, id, mintAmount);

        // Alice already had tokens for ids 1 and 2 from setUp; use fresh balance tracking
        uint256 aliceBalBefore = token.balanceOf(alice, id);

        vm.prank(alice);
        token.safeTransferFrom(alice, bob, id, transferAmount, "");

        assertEq(token.balanceOf(alice, id), aliceBalBefore - transferAmount);
        assertEq(token.balanceOf(bob, id), transferAmount);
    }
}
