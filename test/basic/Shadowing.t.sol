// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Shadowing} from "../../src/basic/Shadowing.sol";

/// @title ShadowingTest
/// @notice Tests for Shadowing contract
contract ShadowingTest is Test {
    Shadowing public shadowing;

    function setUp() public {
        shadowing = new Shadowing();
    }

    /// @notice Test parameter shadowing
    function test_ShadowWithParameter() public view {
        assertEq(shadowing.shadowWithParameter(500), 500); // Returns parameter
        assertEq(shadowing.value(), 100); // State unchanged
    }

    /// @notice Test local variable shadowing
    function test_ShadowWithLocal() public view {
        assertEq(shadowing.shadowWithLocal(), 999); // Returns local
        assertEq(shadowing.value(), 100); // State unchanged
    }

    /// @notice Test proper naming updates state
    function test_ProperNaming() public {
        uint256 result = shadowing.properNaming(250);
        assertEq(result, 250);
        assertEq(shadowing.value(), 250);
    }

    /// @notice Test accessing state despite shadow
    function test_GetStateValueDespiteShadow() public view {
        assertEq(shadowing.getStateValueDespiteShadow(), 100);
    }

    /// @notice Test nested shadowing
    function test_NestedShadowing() public view {
        assertEq(shadowing.nestedShadowing(), 3);
    }
}
