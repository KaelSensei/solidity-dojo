// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {VerifySignature} from "../../src/basic/VerifySignature.sol";

/// @title VerifySignatureTest
/// @notice Tests for VerifySignature contract
contract VerifySignatureTest is Test {
    VerifySignature public verifier;

    function setUp() public {
        verifier = new VerifySignature();
    }

    /// @notice Test message hash generation
    function test_GetMessageHash() public view {
        bytes32 hash = verifier.getMessageHash("hello");
        assertGt(uint256(hash), 0);
    }

    /// @notice Test signature splitting
    function test_SplitSignature() public {
        // Create valid dummy signature (65 bytes)
        bytes memory sig = new bytes(65);
        // Set v to 27 or 28 (valid values)
        sig[64] = bytes1(uint8(27));
        
        (bytes32 r, bytes32 s, uint8 v) = verifier.splitSignature(sig);
        assertEq(v, 27);
    }
}
