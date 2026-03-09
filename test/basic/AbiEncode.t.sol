// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {AbiEncode} from "../../src/basic/AbiEncode.sol";

/// @title AbiEncodeTest
/// @notice Tests for AbiEncode contract
contract AbiEncodeTest is Test {
    AbiEncode public abiEncode;

    function setUp() public {
        abiEncode = new AbiEncode();
    }

    /// @notice Test encode standard
    function test_EncodeStandard() public view {
        bytes memory encoded = abiEncode.encodeStandard(42, address(0x123));
        assertGt(encoded.length, 0);
    }

    /// @notice Test encode packed is shorter or equal (for single values may be same)
    function test_EncodePacked() public view {
        (, , uint256 standardLen, uint256 packedLen) = 
            abiEncode.compareEncodings(42, 100);
        assertGe(standardLen, packedLen);
    }

    /// @notice Test decode
    function test_Decode() public view {
        bytes memory encoded = abiEncode.encodeStandard(42, address(0x123));
        (uint256 a, address b) = abiEncode.decodeStandard(encoded);
        assertEq(a, 42);
        assertEq(b, address(0x123));
    }
}
