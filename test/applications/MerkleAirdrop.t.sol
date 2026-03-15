// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/applications/MerkleAirdrop.sol";
import "src/applications/ERC20Token.sol";

/// @title MerkleAirdrop Test Suite
/// @dev Builds a Merkle tree in setUp from known addresses and amounts.
contract MerkleAirdropTest is Test {
    MerkleAirdrop public airdrop;
    ERC20Token public token;

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public charlie = makeAddr("charlie");
    address public eve = makeAddr("eve");

    // Airdrop amounts
    uint256 public aliceAmount = 100e18;
    uint256 public bobAmount = 200e18;
    uint256 public charlieAmount = 300e18;

    // Merkle tree nodes
    bytes32 public leafAlice;
    bytes32 public leafBob;
    bytes32 public leafCharlie;
    // We use a 3-leaf tree, padded to 4 with a zero leaf for balance
    bytes32 public leafZero = bytes32(0);

    bytes32 public merkleRoot;

    // Proofs
    bytes32[] public proofAlice;
    bytes32[] public proofBob;
    bytes32[] public proofCharlie;

    /// @dev Helper to hash a pair in sorted order (matches the contract's logic)
    function _hashPair(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        if (a < b) {
            return keccak256(abi.encodePacked(a, b));
        } else {
            return keccak256(abi.encodePacked(b, a));
        }
    }

    function setUp() public {
        // Deploy token and mint supply to this test contract
        token = new ERC20Token("AirdropToken", "ADT", 18);
        uint256 totalAirdrop = aliceAmount + bobAmount + charlieAmount;
        token.mint(address(this), totalAirdrop);

        // Build Merkle tree:
        //         root
        //        /    \
        //      h01     h23
        //     /   \   /   \
        //   L_a  L_b L_c  L_0
        leafAlice = keccak256(abi.encodePacked(alice, aliceAmount));
        leafBob = keccak256(abi.encodePacked(bob, bobAmount));
        leafCharlie = keccak256(abi.encodePacked(charlie, charlieAmount));

        bytes32 h01 = _hashPair(leafAlice, leafBob);
        bytes32 h23 = _hashPair(leafCharlie, leafZero);
        merkleRoot = _hashPair(h01, h23);

        // Build proofs
        // Alice's proof: [leafBob, h23]
        proofAlice.push(leafBob);
        proofAlice.push(h23);

        // Bob's proof: [leafAlice, h23]
        proofBob.push(leafAlice);
        proofBob.push(h23);

        // Charlie's proof: [leafZero, h01]
        proofCharlie.push(leafZero);
        proofCharlie.push(h01);

        // Deploy airdrop and fund it with tokens
        airdrop = new MerkleAirdrop(merkleRoot, address(token));
        token.transfer(address(airdrop), totalAirdrop);
    }

    // ─── Successful Claims ──────────────────────────────────────────────

    function test_ClaimAlice() public {
        airdrop.claim(alice, aliceAmount, proofAlice);

        assertEq(token.balanceOf(alice), aliceAmount, "Alice should receive airdrop");
        assertTrue(airdrop.isClaimed(alice), "Alice should be marked as claimed");
    }

    function test_ClaimBob() public {
        airdrop.claim(bob, bobAmount, proofBob);

        assertEq(token.balanceOf(bob), bobAmount, "Bob should receive airdrop");
        assertTrue(airdrop.isClaimed(bob), "Bob should be marked as claimed");
    }

    function test_ClaimCharlie() public {
        airdrop.claim(charlie, charlieAmount, proofCharlie);

        assertEq(token.balanceOf(charlie), charlieAmount, "Charlie should receive airdrop");
    }

    function test_MultipleClaimsDifferentAccounts() public {
        airdrop.claim(alice, aliceAmount, proofAlice);
        airdrop.claim(bob, bobAmount, proofBob);
        airdrop.claim(charlie, charlieAmount, proofCharlie);

        assertEq(token.balanceOf(alice), aliceAmount);
        assertEq(token.balanceOf(bob), bobAmount);
        assertEq(token.balanceOf(charlie), charlieAmount);
        assertEq(token.balanceOf(address(airdrop)), 0, "Airdrop should be fully claimed");
    }

    // ─── Revert Cases ───────────────────────────────────────────────────

    function test_DoubleClaimReverts() public {
        airdrop.claim(alice, aliceAmount, proofAlice);

        vm.expectRevert(abi.encodeWithSelector(MerkleAirdrop.AlreadyClaimed.selector, alice));
        airdrop.claim(alice, aliceAmount, proofAlice);
    }

    function test_InvalidProofReverts() public {
        // Use bob's proof for alice
        vm.expectRevert(MerkleAirdrop.InvalidProof.selector);
        airdrop.claim(alice, aliceAmount, proofBob);
    }

    function test_WrongAmountReverts() public {
        // Correct proof but wrong amount changes the leaf hash
        vm.expectRevert(MerkleAirdrop.InvalidProof.selector);
        airdrop.claim(alice, 999e18, proofAlice);
    }

    function test_UnknownAccountReverts() public {
        // Eve is not in the Merkle tree
        bytes32[] memory fakeProof = new bytes32[](2);
        fakeProof[0] = leafBob;
        fakeProof[1] = bytes32(0);

        vm.expectRevert(MerkleAirdrop.InvalidProof.selector);
        airdrop.claim(eve, 50e18, fakeProof);
    }

    function test_ZeroAddressReverts() public {
        vm.expectRevert(MerkleAirdrop.ZeroAddress.selector);
        airdrop.claim(address(0), 100e18, proofAlice);
    }

    // ─── State Checks ───────────────────────────────────────────────────

    function test_IsClaimedReturnsFalseBeforeClaim() public view {
        assertFalse(airdrop.isClaimed(alice));
    }

    function test_ClaimEmitsEvent() public {
        vm.expectEmit(true, false, false, true);
        emit MerkleAirdrop.Claimed(alice, aliceAmount);
        airdrop.claim(alice, aliceAmount, proofAlice);
    }
}
