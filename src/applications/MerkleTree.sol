// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title MerkleTree
/// @notice Merkle proof verifier for token airdrops.
/// @dev Verifies that a leaf is part of a Merkle tree using proof verification.
contract MerkleTree {
    /// @notice Emitted when a user claims tokens
    event Claimed(address indexed account, uint256 amount);

    /// @notice Thrown when proof is invalid
    error InvalidProof();

    /// @notice Thrown when account has already claimed
    error AlreadyClaimed(address account);

    /// @notice Merkle root hash
    bytes32 public merkleRoot;

    /// @notice Mapping to track claimed accounts
    mapping(address => bool) public hasClaimed;

    /// @notice Total amount claimed
    uint256 public totalClaimed;

    /// @notice Constructor sets the merkle root
    /// @param _merkleRoot Root hash of the Merkle tree
    constructor(bytes32 _merkleRoot) {
        merkleRoot = _merkleRoot;
    }

    /// @notice Verify a Merkle proof
    /// @param leaf Leaf node (account address + amount hash)
    /// @param proof Array of sibling hashes
    /// @return True if proof is valid
    function verifyProof(
        bytes32 leaf,
        bytes32[] memory proof
    ) public view returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash < proofElement) {
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }
        }

        return computedHash == merkleRoot;
    }

    /// @notice Claim tokens using Merkle proof
    /// @param account Address claiming tokens
    /// @param amount Amount of tokens to claim
    /// @param proof Merkle proof
    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata proof
    ) external {
        if (hasClaimed[account]) revert AlreadyClaimed(account);

        // Create leaf from account and amount
        bytes32 leaf = keccak256(abi.encodePacked(account, amount));

        // Verify proof
        if (!verifyProof(leaf, proof)) revert InvalidProof();

        // Mark as claimed
        hasClaimed[account] = true;
        totalClaimed += amount;

        emit Claimed(account, amount);
    }

    /// @notice Batch claim for multiple accounts
    /// @param accounts Array of accounts
    /// @param amounts Array of amounts
    /// @param proofs Array of Merkle proofs (one per account)
    function batchClaim(
        address[] calldata accounts,
        uint256[] calldata amounts,
        bytes32[][] calldata proofs
    ) external {
        require(
            accounts.length == amounts.length && accounts.length == proofs.length,
            "Length mismatch"
        );

        for (uint256 i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            uint256 amount = amounts[i];
            bytes32[] calldata proof = proofs[i];

            if (hasClaimed[account]) revert AlreadyClaimed(account);

            bytes32 leaf = keccak256(abi.encodePacked(account, amount));

            if (!verifyProof(leaf, proof)) revert InvalidProof();

            hasClaimed[account] = true;
            totalClaimed += amount;

            emit Claimed(account, amount);
        }
    }

    /// @notice Helper function to compute leaf hash
    /// @param account Account address
    /// @param amount Amount
    /// @return Leaf hash
    function getLeafHash(
        address account,
        uint256 amount
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, amount));
    }
}
