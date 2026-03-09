// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/applications/ERC721Token.sol";

/// @title Mock receiver that accepts ERC721 tokens
contract MockERC721Receiver is IERC721Receiver {
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}

/// @title Mock receiver that rejects ERC721 tokens
contract RejectingReceiver is IERC721Receiver {
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return bytes4(0xdeadbeef);
    }
}

/// @title ERC721Token Test Suite
contract ERC721TokenTest is Test {
    ERC721Token public nft;
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setUp() public {
        nft = new ERC721Token("TestNFT", "TNFT");
        nft.mint(alice, 1);
        nft.mint(alice, 2);
        nft.mint(alice, 3);
    }

    function test_InitialState() public view {
        assertEq(nft.name(), "TestNFT");
        assertEq(nft.symbol(), "TNFT");
        assertEq(nft.balanceOf(alice), 3);
        assertEq(nft.ownerOf(1), alice);
    }

    function test_Mint() public {
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), bob, 100);
        nft.mint(bob, 100);

        assertEq(nft.ownerOf(100), bob);
        assertEq(nft.balanceOf(bob), 1);
    }

    function test_MintOnlyOwner() public {
        vm.prank(alice);
        vm.expectRevert(ERC721Token.NotOwner.selector);
        nft.mint(bob, 100);
    }

    function test_MintAlreadyMinted() public {
        vm.expectRevert(abi.encodeWithSelector(ERC721Token.TokenAlreadyMinted.selector, 1));
        nft.mint(bob, 1);
    }

    function test_TransferFrom() public {
        vm.prank(alice);
        nft.transferFrom(alice, bob, 1);

        assertEq(nft.ownerOf(1), bob);
        assertEq(nft.balanceOf(alice), 2);
        assertEq(nft.balanceOf(bob), 1);
    }

    function test_Approve() public {
        vm.prank(alice);
        vm.expectEmit(true, true, true, true);
        emit Approval(alice, bob, 1);
        nft.approve(bob, 1);

        assertEq(nft.getApproved(1), bob);
    }

    function test_TransferFromWithApproval() public {
        vm.prank(alice);
        nft.approve(bob, 1);

        vm.prank(bob);
        nft.transferFrom(alice, bob, 1);
        assertEq(nft.ownerOf(1), bob);
        assertEq(nft.getApproved(1), address(0));
    }

    function test_SetApprovalForAll() public {
        vm.prank(alice);
        nft.setApprovalForAll(bob, true);
        assertTrue(nft.isApprovedForAll(alice, bob));

        vm.prank(bob);
        nft.transferFrom(alice, bob, 2);
        assertEq(nft.ownerOf(2), bob);
    }

    function test_Burn() public {
        vm.prank(alice);
        nft.burn(1);
        assertEq(nft.balanceOf(alice), 2);
        assertEq(nft.ownerOf(1), address(0));
    }

    function test_BurnNonExistent() public {
        vm.expectRevert(abi.encodeWithSelector(ERC721Token.TokenDoesNotExist.selector, 999));
        nft.burn(999);
    }

    function test_SafeTransferToEOA() public {
        vm.prank(alice);
        nft.safeTransferFrom(alice, bob, 1);
        assertEq(nft.ownerOf(1), bob);
    }

    function test_SafeTransferToContract() public {
        MockERC721Receiver receiver = new MockERC721Receiver();
        vm.prank(alice);
        nft.safeTransferFrom(alice, address(receiver), 1);
        assertEq(nft.ownerOf(1), address(receiver));
    }

    function test_SafeTransferToRejectingContract() public {
        RejectingReceiver rejector = new RejectingReceiver();
        vm.prank(alice);
        vm.expectRevert(ERC721Token.UnsafeRecipient.selector);
        nft.safeTransferFrom(alice, address(rejector), 1);
    }

    function test_SupportsInterface() public view {
        assertTrue(nft.supportsInterface(0x80ac58cd));
        assertTrue(nft.supportsInterface(0x01ffc9a7));
        assertFalse(nft.supportsInterface(0xdeadbeef));
    }

    function testFuzz_mint(uint256 tokenId) public {
        vm.assume(tokenId > 3);
        nft.mint(bob, tokenId);
        assertEq(nft.ownerOf(tokenId), bob);
    }
}
