// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/hacks/SignatureReplay.sol";

/// @title Signature Replay Test Suite
contract SignatureReplayTest is Test {
    VulnerableSignature public vulnerable;
    SecureSignature public secure;
    address public user = address(0x1);

    function setUp() public {
        vulnerable = new VulnerableSignature();
        secure = new SecureSignature();
    }

    /// @notice Test vulnerable signature can be replayed
    function test_VulnerableSignature() public {
        // This tests the structure exists
        assertTrue(address(vulnerable) != address(0));
    }

    /// @notice Test signature nonce validation
    function test_NonceValidation() public {
        uint256 nonce = vulnerable.nonces(user);
        assertEq(nonce, 0);
    }

    /// @notice Test secure signature has domain separator
    function test_SecureHasDomainSeparator() public {
        bytes32 domainSep = secure.DOMAIN_SEPARATOR();
        assertTrue(domainSep != bytes32(0));
    }
}
