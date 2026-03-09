// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {BaseContract, DerivedContract, MultipleInheritance} from "../../src/basic/Inheritance.sol";

/// @title InheritanceTest
/// @notice Tests for inheritance contracts
contract InheritanceTest is Test {
    BaseContract public base;
    DerivedContract public derived;
    MultipleInheritance public multiple;

    function setUp() public {
        base = new BaseContract("Base");
        derived = new DerivedContract();
        multiple = new MultipleInheritance();
    }

    /// @notice Test base contract stores correct values
    function test_BaseContract() public view {
        assertEq(base.name(), "Base");
        assertEq(base.baseValue(), 100);
        assertEq(base.getValue(), 100);
    }

    /// @notice Test derived contract inherits from base
    function test_DerivedContract_Inherits() public view {
        assertEq(derived.name(), "Derived");
        assertEq(derived.baseValue(), 100);
        assertEq(derived.derivedValue(), 200);
    }

    /// @notice Test derived contract overrides function
    function test_DerivedContract_Override() public view {
        assertEq(derived.getValue(), 300); // 100 + 200
    }

    /// @notice Test derived contract getCombinedValue
    function test_DerivedContract_Combined() public view {
        assertEq(derived.getCombinedValue(), 300);
    }

    /// @notice Test setBaseValue affects derived
    function test_SetBaseValue() public {
        derived.setBaseValue(150);
        assertEq(derived.getValue(), 350); // 150 + 200
    }

    /// @notice Test multiple inheritance
    function test_MultipleInheritance() public view {
        assertEq(multiple.name(), "Multiple");
        assertEq(multiple.baseValue(), 100);
        assertEq(multiple.anotherValue(), 300);
    }

    /// @notice Test multiple inheritance overrides
    function test_MultipleInheritance_Overrides() public view {
        assertEq(multiple.getValue(), 400); // 100 + 300
        assertEq(multiple.getAnotherValue(), 600); // 300 * 2
    }

    /// @notice Test multiple inheritance getTotal
    function test_MultipleInheritance_Total() public view {
        assertEq(multiple.getTotal(), 1000); // 400 + 600
    }
}
