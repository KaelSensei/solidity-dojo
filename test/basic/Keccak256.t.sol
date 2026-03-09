// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Keccak256} from "../../src/basic/Keccak256.sol";

/// @title Keccak256Test
/// @notice Tests for Keccak256 contract
contract Keccak256Test is Test {
    Keccak256 public hasher;

    function setUp() public {
        hasher = new Keccak256();
    }

    /// @notice Test hash is deterministic
    function test_HashDeterministic() public view {
        bytes32 hash1 = hasher.hashUint(42);
        bytes32 hash2 = hasher.hashUint(42);
        assertEq(hash1, hash2);
    }

    /// @notice Test different inputs produce different hashes
    function test_DifferentInputs() public view {
        bytes32 hash1 = hasher.hashUint(42);
        bytes32 hash2 = hasher.hashUint(43);
        assertTrue(hash1 != hash2);
    }

    /// @notice Test commitment scheme
    function test_CommitmentScheme() public view {
        bytes32 secret = keccak256("secret");
        bytes32 commitment = hasher.createCommitment(secret);
        assertTrue(hasher.verifyCommitment(commitment, secret));
        assertFalse(hasher.verifyCommitment(commitment, keccak256("wrong")));
    }

    /// @notice Test merkle node hashing
    function test_MerkleNode() public view {
        bytes32 left = keccak256("left");
        bytes32 right = keccak256("right");
        bytes32 node = hasher.merkleNode(left, right);
        assertGt(uint256(node), 0);
    }
}
