// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title VerifySignature
/// @notice Demonstrates ECDSA signature verification
contract VerifySignature {
    /// @notice Thrown when signature is not 65 bytes
    error InvalidSignatureLength(uint256 length);

    /// @notice Get message hash with Ethereum prefix
    function getMessageHash(string calldata _message) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(_message))));
    }

    /// @notice Get message hash (raw)
    function getRawMessageHash(string calldata _message) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
    }

    /// @notice Recover signer from signature
    /// @param _ethSignedMessageHash Hash with Ethereum prefix
    /// @param _signature Signature bytes
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes calldata _signature) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    /// @notice Split signature into r, s, v components
    function splitSignature(bytes calldata sig) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        if (sig.length != 65) revert InvalidSignatureLength(sig.length);

        r = bytes32(sig[0:32]);
        s = bytes32(sig[32:64]);
        v = uint8(sig[64]);
    }

    /// @notice Verify signature for message
    function verify(string calldata _message, bytes calldata _signature, address _signer) external pure returns (bool) {
        bytes32 messageHash = getMessageHash(_message);
        address recovered = recoverSigner(messageHash, _signature);
        return recovered == _signer;
    }

    /// @notice Verify raw signature (no Ethereum prefix)
    function verifyRaw(bytes32 _hash, bytes calldata _signature, address _signer) external pure returns (bool) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        address recovered = ecrecover(_hash, v, r, s);
        return recovered == _signer;
    }
}
