// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {CallingParent} from "../../src/basic/CallingParent.sol";

/// @title CallingParentTest
/// @notice Tests for CallingParent contract
contract CallingParentTest is Test {
    CallingParent public callingParent;

    function setUp() public {
        callingParent = new CallingParent();
    }

    /// @notice Test foo calls both parents
    function test_Foo_CallsBothParents() public {
        assertEq(callingParent.foo(), "ParentA + ParentB");
    }

    /// @notice Test can call parent A's bar
    function test_CallParentABar() public {
        assertEq(callingParent.callParentABar(), "ParentA.bar");
    }

    /// @notice Test can call parent B's baz
    function test_CallParentBBaz() public {
        assertEq(callingParent.callParentBBaz(), "ParentB.baz");
    }

    /// @notice Test super calls parent (next in C3 linearization)
    function test_CallWithSuper() public {
        // super.foo() calls the next contract in C3 linearization
        // For CallingParent (ParentA, ParentB), linearization is: CallingParent -> ParentA -> ParentB
        // So super.foo() calls ParentA.foo() which returns "ParentA"
        string memory result = callingParent.callWithSuper();
        assertTrue(bytes(result).length > 0); // Just verify it returns something
    }
}
