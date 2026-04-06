// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IERC20 minimal interface for token transfers
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/// @title MerkleAirdrop
/// @notice Merkle proof-based token airdrop contract.
/// @dev Extends the MerkleTree concept by combining proof verification with actual
///      ERC20 token transfers. Eligible addresses and amounts are encoded in a Merkle
///      tree — only the root is stored on-chain, saving gas. Users prove eligibility
///      by submitting a Merkle proof.
contract MerkleAirdrop {
    // ─── State ──────────────────────────────────────────────────────────

    /// @notice The Merkle root encoding all eligible (address, amount) pairs
    bytes32 public immutable merkleRoot;

    /// @notice The ERC20 token being distributed
    IERC20 public immutable token;

    /// @notice Tracks which addresses have already claimed
    mapping(address => bool) private _claimed;

    // ─── Events ─────────────────────────────────────────────────────────

    /// @notice Emitted when an account successfully claims their airdrop
    event Claimed(address indexed account, uint256 amount);

    // ─── Custom Errors ──────────────────────────────────────────────────

    error AlreadyClaimed(address account);
    error InvalidProof();
    error ZeroAddress();
    error TransferFailed();

    // ─── Constructor ────────────────────────────────────────────────────

    /// @notice Initialize the airdrop with a Merkle root and token
    constructor(bytes32 _merkleRoot, address _token) {
        if (_token == address(0)) revert ZeroAddress();
        merkleRoot = _merkleRoot;
        token = IERC20(_token);
    }

    // ─── Public Functions ───────────────────────────────────────────────

    /// @notice Claim airdrop tokens by providing a valid Merkle proof
    /// @dev The leaf is computed as keccak256(abi.encodePacked(account, amount)).
    ///      The proof must demonstrate that this leaf is part of the Merkle tree
    ///      whose root is stored in `merkleRoot`.
    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata proof
    ) external {
        if (account == address(0)) revert ZeroAddress();
        if (_claimed[account]) revert AlreadyClaimed(account);

        // Compute the leaf from account + amount
        bytes32 leaf = keccak256(abi.encodePacked(account, amount));

        // Verify the Merkle proof
        if (!_verifyProof(leaf, proof)) revert InvalidProof();

        // Mark as claimed before transfer (checks-effects-interactions)
        _claimed[account] = true;

        // Emit event before external call
        emit Claimed(account, amount);

        // Transfer tokens
        bool success = token.transfer(account, amount);
        if (!success) revert TransferFailed();
    }

    /// @notice Check if an account has already claimed
    /// @return True if the account has claimed
    function isClaimed(address account) external view returns (bool) {
        return _claimed[account];
    }

    // ─── Internal Functions ─────────────────────────────────────────────

    /// @dev Verify a Merkle proof by walking up the tree
    ///      At each level, the current hash is combined with the proof element.
    ///      The smaller hash always goes first to ensure consistent ordering.
    /// @return True if the computed root matches the stored merkleRoot
    function _verifyProof(
        bytes32 leaf,
        bytes32[] calldata proof
    ) internal view returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            // Sort pair before hashing to ensure deterministic tree construction
            if (computedHash < proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == merkleRoot;
    }
}

