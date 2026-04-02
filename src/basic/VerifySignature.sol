// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title VerifySignature
/// @notice Demonstrates ECDSA signature verification
contract VerifySignature {
    /// @notice Get message hash with Ethereum prefix
    function getMessageHash(string memory message) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(message))));
    }

    /// @notice Get message hash (raw)
    function getRawMessageHash(string memory message) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(message));
    }

    /// @notice Recover signer from signature
    function recoverSigner(bytes32 ethSignedMessageHash, bytes memory signature) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        return ecrecover(ethSignedMessageHash, v, r, s);
    }

    /// @notice Split signature into r, s, v components
    function splitSignature(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

    /// @notice Verify signature for message
    function verify(string memory message, bytes memory signature, address signer) external pure returns (bool) {
        bytes32 messageHash = getMessageHash(message);
        address recovered = recoverSigner(messageHash, signature);
        return recovered == signer;
    }

    /// @notice Verify raw signature (no Ethereum prefix)
    function verifyRaw(bytes32 hash, bytes memory signature, address signer) external pure returns (bool) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        address recovered = ecrecover(hash, v, r, s);
        return recovered == signer;
    }
}


