// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title PaymentChannel
/// @notice Off-chain payment channel between a sender and receiver.
/// @dev The sender funds the channel at deployment. The receiver can close the channel
///      at any time by presenting a signed message from the sender specifying the amount
///      owed. The sender can reclaim funds after the channel expires.
///      This pattern enables many off-chain micro-payments with only two on-chain txs
///      (open + close).
contract PaymentChannel {
    // ─── State ──────────────────────────────────────────────────────────

    /// @notice The party who funded the channel
    address public immutable sender;

    /// @notice The party who can close the channel with a signed amount
    address public immutable receiver;

    /// @notice Timestamp after which the sender can reclaim remaining funds
    uint256 public immutable expiration;

    /// @notice Whether the channel has been closed
    bool public closed;

    // ─── Custom Errors ──────────────────────────────────────────────────

    error NotReceiver();
    error NotSender();
    error ChannelExpired();
    error ChannelNotExpired();
    error ChannelAlreadyClosed();
    error InvalidSignature();
    error TransferFailed();
    error ZeroAddress();

    // ─── Constructor ────────────────────────────────────────────────────

    /// @notice Create a payment channel
    /// @dev The sender funds the channel by sending ETH with this constructor call.
    constructor(address _receiver, uint256 _duration) payable {
        if (_receiver == address(0)) revert ZeroAddress();
        sender = msg.sender;
        receiver = _receiver;
        expiration = block.timestamp + _duration;
    }

    // ─── Public Functions ───────────────────────────────────────────────

    /// @notice Close the channel, sending `amount` to the receiver
    /// @dev Only the receiver can call this. The signature must be from the sender.
    ///      Remaining funds are sent back to the sender.
    function close(uint256 amount, bytes memory signature) external {
        if (msg.sender != receiver) revert NotReceiver();
        if (closed) revert ChannelAlreadyClosed();

        // Verify that the sender signed this amount
        if (!_verify(amount, signature)) revert InvalidSignature();

        closed = true;

        // Pay the receiver
        (bool sent,) = receiver.call{value: amount}("");
        if (!sent) revert TransferFailed();

        // Refund remaining balance to the sender
        uint256 remaining = address(this).balance;
        if (remaining > 0) {
            (sent,) = sender.call{value: remaining}("");
            if (!sent) revert TransferFailed();
        }
    }

    /// @notice Sender reclaims funds after the channel expires
    /// @dev Only callable by the sender after the expiration timestamp.
    function timeout() external {
        if (msg.sender != sender) revert NotSender();
        if (block.timestamp < expiration) revert ChannelNotExpired();
        if (closed) revert ChannelAlreadyClosed();

        closed = true;

        (bool sent,) = sender.call{value: address(this).balance}("");
        if (!sent) revert TransferFailed();
    }

    // ─── View / Pure Functions ──────────────────────────────────────────

    /// @notice Compute the hash of the payment amount bound to this contract
    /// @dev Includes the contract address to prevent cross-contract replay attacks
    /// @return The keccak256 hash
    function getHash(uint256 amount) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), amount));
    }

    /// @notice Add the Ethereum signed message prefix to a hash
    /// @dev This matches what wallets produce with personal_sign / eth_sign:
    ///      "\x19Ethereum Signed Message:\n32" + hash
    /// @return The prefixed hash ready for ecrecover
    function getEthSignedHash(bytes32 hash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /// @notice Verify that the sender signed the given amount
    /// @return True if the signature is valid and from the sender
    function verify(uint256 amount, bytes memory signature) external view returns (bool) {
        return _verify(amount, signature);
    }

    // ─── Internal Functions ─────────────────────────────────────────────

    /// @dev Internal verify: hash the amount, prefix it, then ecrecover
    function _verify(uint256 amount, bytes memory signature) internal view returns (bool) {
        bytes32 messageHash = getHash(amount);
        bytes32 ethSignedHash = getEthSignedHash(messageHash);

        // Extract r, s, v from the 65-byte signature
        // signature layout: [0..31] = r, [32..63] = s, [64] = v
        if (signature.length != 65) return false;

        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        address recovered = ecrecover(ethSignedHash, v, r, s);
        return recovered == sender;
    }
}

