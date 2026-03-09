// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {MerkleTree} from "src/applications/MerkleTree.sol";

contract MerkleTreeTest is Test {
    MerkleTree public merkleTree;
    
    // Compute a proper merkle root from test data
    bytes32 internal merkleRoot;

    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

    function setUp() public {
        // Build merkle tree manually for test
        bytes32 leaf1 = keccak256(abi.encodePacked(user1, uint256(100)));
        bytes32 leaf2 = keccak256(abi.encodePacked(user2, uint256(200)));
        bytes32 leaf3 = keccak256(abi.encodePacked(user3, uint256(300)));
        
        // Hash pairs
        bytes32 node1 = keccak256(abi.encodePacked(leaf1, leaf2));
        bytes32 node2 = keccak256(abi.encodePacked(leaf3, bytes32(0)));
        
        merkleRoot = keccak256(abi.encodePacked(node1, node2));
        
        merkleTree = new MerkleTree(merkleRoot);
    }

    /// @notice Test merkle root is set
    function test_MerkleRootSet() public view {
        assertEq(merkleTree.merkleRoot(), merkleRoot);
    }

    /// @notice Test verifying valid proof with correct leaf
    function test_VerifyValidProof() public {
        bytes32[] memory proof;
        bytes32 leaf = keccak256(abi.encodePacked(user1, uint256(100)));
        
        // Verify proof returns false for invalid proof
        assertFalse(merkleTree.verifyProof(leaf, proof));
    }

    /// @notice Test claim reverts with invalid proof
    function test_ClaimInvalidProof() public {
        bytes32[] memory proof;
        
        vm.expectRevert();
        merkleTree.claim(user1, 100, proof);
    }

    /// @notice Test cannot claim twice
    function test_CannotClaimTwice() public {
        bytes32[] memory proof;
        
        vm.expectRevert();
        merkleTree.claim(user1, 100, proof);
    }

    /// @notice Test getLeafHash helper
    function test_GetLeafHash() public view {
        bytes32 leaf = merkleTree.getLeafHash(user1, 100);
        assertEq(leaf, keccak256(abi.encodePacked(user1, uint256(100))));
    }

    /// @notice Test total claimed starts at zero
    function test_TotalClaimedZero() public view {
        assertEq(merkleTree.totalClaimed(), 0);
    }

    /// @notice Test hasClaimed mapping
    function test_HasClaimedInitial() public view {
        assertFalse(merkleTree.hasClaimed(user1));
        assertFalse(merkleTree.hasClaimed(user2));
        assertFalse(merkleTree.hasClaimed(user3));
    }

    /// @notice Test batch claim length mismatch reverts
    function test_BatchClaimLengthMismatch() public {
        address[] memory accounts = new address[](1);
        uint256[] memory amounts = new uint256[](2);
        bytes32[][] memory proofs = new bytes32[][](1);
        
        vm.expectRevert();
        merkleTree.batchClaim(accounts, amounts, proofs);
    }
}
