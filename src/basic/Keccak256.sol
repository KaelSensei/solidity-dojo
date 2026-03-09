// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Keccak256
/// @notice Demonstrates hashing with keccak256
contract Keccak256 {
    /// @notice Hash single value
    function hashUint(uint256 value) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(value));
    }

    /// @notice Hash address
    function hashAddress(address addr) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(addr));
    }

    /// @notice Hash string
    function hashString(string calldata str) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(str));
    }

    /// @notice Hash multiple values (order matters!)
    function hashMultiple(uint256 a, uint256 b) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(a, b));
    }

    /// @notice Hash array
    function hashArray(uint256[] calldata arr) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(arr));
    }

    /// @notice Generate unique ID from multiple inputs
    function generateId(address user, uint256 nonce, uint256 timestamp) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(user, nonce, timestamp));
    }

    /// @notice Simple commitment scheme (hash of secret)
    function createCommitment(bytes32 secret) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(secret));
    }

    /// @notice Verify commitment matches secret
    function verifyCommitment(bytes32 commitment, bytes32 secret) external pure returns (bool) {
        return keccak256(abi.encodePacked(secret)) == commitment;
    }

    /// @notice Compute merkle leaf hash
    function merkleLeaf(bytes32 data) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(data));
    }

    /// @notice Compute merkle node hash (ordered)
    function merkleNode(bytes32 left, bytes32 right) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(left, right));
    }
}
