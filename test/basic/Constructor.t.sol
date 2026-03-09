// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Constructor, ChildConstructor} from "../../src/basic/Constructor.sol";

/// @title ConstructorTest
/// @notice Tests for Constructor contract
contract ConstructorTest is Test {
    Constructor public constructorContract;
    ChildConstructor public childConstructor;

    function setUp() public {
        constructorContract = new Constructor("TestContract", 100);
        childConstructor = new ChildConstructor("ChildContract", 200, 50);
    }

    /// @notice Test constructor sets immutable owner
    function test_Constructor_SetsOwner() public view {
        assertEq(constructorContract.owner(), address(this));
    }

    /// @notice Test constructor sets immutable name
    function test_Constructor_SetsName() public view {
        assertEq(constructorContract.name(), "TestContract");
    }

    /// @notice Test constructor sets immutable initial value
    function test_Constructor_SetsInitialValue() public view {
        assertEq(constructorContract.initialValue(), 100);
    }

    /// @notice Test constructor sets mutable value
    function test_Constructor_SetsValue() public view {
        assertEq(constructorContract.value(), 100);
    }

    /// @notice Test constructor sets initialized flag
    function test_Constructor_SetsInitialized() public view {
        assertTrue(constructorContract.initialized());
    }

    /// @notice Test constructor emits Deployed event
    function test_Constructor_EmitsEvent() public {
        vm.expectEmit(true, false, false, true);
        emit Constructor.Deployed(address(this), "NewContract", 500);
        new Constructor("NewContract", 500);
    }

    /// @notice Test setValue updates mutable value
    function test_SetValue() public {
        constructorContract.setValue(200);
        assertEq(constructorContract.value(), 200);
    }

    /// @notice Test setValue reverts for non-owner
    function test_SetValue_NotOwner() public {
        address nonOwner = makeAddr("nonOwner");
        vm.prank(nonOwner);
        vm.expectRevert("Not owner");
        constructorContract.setValue(200);
    }

    /// @notice Test getImmutables returns all values
    function test_GetImmutables() public view {
        (address _owner, string memory _name, uint256 _initialValue, uint256 _deployedAt) =
            constructorContract.getImmutables();
        assertEq(_owner, address(this));
        assertEq(_name, "TestContract");
        assertEq(_initialValue, 100);
        assertEq(_deployedAt, block.timestamp);
    }

    /// @notice Test child constructor sets parent and child values
    function test_ChildConstructor() public view {
        assertEq(childConstructor.name(), "ChildContract");
        assertEq(childConstructor.initialValue(), 200);
        assertEq(childConstructor.childValue(), 50);
    }
}
