// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ParentA
/// @notice First parent contract
contract ParentA {
    /// @notice Event from ParentA
    event LogA(string message);

    /// @notice Function that can be overridden
    function foo() public virtual returns (string memory) {
        emit LogA("ParentA.foo() called");
        return "ParentA";
    }

    /// @notice Function unique to ParentA
    function bar() public virtual returns (string memory) {
        emit LogA("ParentA.bar() called");
        return "ParentA.bar";
    }
}

/// @title ParentB
/// @notice Second parent contract
contract ParentB {
    /// @notice Event from ParentB
    event LogB(string message);

    /// @notice Function that can be overridden
    function foo() public virtual returns (string memory) {
        emit LogB("ParentB.foo() called");
        return "ParentB";
    }

    /// @notice Function unique to ParentB
    function baz() public virtual returns (string memory) {
        emit LogB("ParentB.baz() called");
        return "ParentB.baz";
    }
}

/// @title CallingParent
/// @notice Demonstrates calling parent contracts
contract CallingParent is ParentA, ParentB {
    /// @notice Override foo - must resolve conflict
    function foo() public override(ParentA, ParentB) returns (string memory) {
        // Can call specific parent
        string memory aResult = ParentA.foo();
        string memory bResult = ParentB.foo();
        return string(abi.encodePacked(aResult, " + ", bResult));
    }

    /// @notice Call parent A's bar
    function callParentABar() public returns (string memory) {
        return ParentA.bar();
    }

    /// @notice Call parent B's baz
    function callParentBBaz() public returns (string memory) {
        return ParentB.baz();
    }

    /// @notice Demonstrates super - calls next in C3 linearization
    function callWithSuper() public returns (string memory) {
        // Super calls the next contract in inheritance order
        return super.foo();
    }
}
