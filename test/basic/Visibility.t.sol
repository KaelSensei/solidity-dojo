// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Visibility, DerivedVisibility} from "../../src/basic/Visibility.sol";

/// @title VisibilityTest
/// @notice Tests for Visibility contract
contract VisibilityTest is Test {
    Visibility public visibility;
    DerivedVisibility public derived;

    function setUp() public {
        visibility = new Visibility();
        derived = new DerivedVisibility();
    }

    /// @notice Test external function
    function test_ExternalFunc() public view {
        assertEq(visibility.externalFunc(), "external");
    }

    /// @notice Test public function
    function test_PublicFunc() public view {
        assertEq(visibility.publicFunc(), "public");
    }

    /// @notice Test internal via wrapper
    function test_InternalFunc() public view {
        assertEq(visibility.callInternal(), "internal");
    }

    /// @notice Test private via wrapper
    function test_PrivateFunc() public view {
        assertEq(visibility.callPrivate(), "private");
    }

    /// @notice Test public variable
    function test_PublicVar() public view {
        assertEq(visibility.publicVar(), 1);
    }

    /// @notice Test internal variable via getter
    function test_InternalVar() public view {
        assertEq(visibility.getInternalVar(), 2);
    }

    /// @notice Test private variable via getter
    function test_PrivateVar() public view {
        assertEq(visibility.getPrivateVar(), 3);
    }

    /// @notice Test derived can access parent's internal
    function test_DerivedAccessInternal() public view {
        assertEq(derived.accessParentInternal(), 2);
    }

    /// @notice Test derived can call parent's internal function
    function test_DerivedCallInternal() public view {
        assertEq(derived.callParentInternal(), "internal");
    }
}
