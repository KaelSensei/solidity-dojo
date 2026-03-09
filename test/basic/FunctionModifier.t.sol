// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {FunctionModifier} from "../../src/basic/FunctionModifier.sol";

/// @title FunctionModifierTest
/// @notice Tests for FunctionModifier contract
contract FunctionModifierTest is Test {
    FunctionModifier public functionModifier;
    address public owner;
    address public nonOwner;

    function setUp() public {
        owner = address(this);
        nonOwner = makeAddr("nonOwner");
        functionModifier = new FunctionModifier();
    }

    /// @notice Test owner can call owner-only function
    function test_OnlyOwner_Success() public view {
        assertEq(functionModifier.ownerOnlyFunction(), "Success");
    }

    /// @notice Test non-owner cannot call owner-only function
    function test_OnlyOwner_Fail() public {
        vm.prank(nonOwner);
        vm.expectRevert("Not owner");
        functionModifier.ownerOnlyFunction();
    }

    /// @notice Test valid address modifier accepts valid address
    function test_ValidAddress_Success() public {
        address valid = makeAddr("valid");
        assertEq(functionModifier.sendToAddress(valid), valid);
    }

    /// @notice Test valid address modifier rejects zero address
    function test_ValidAddress_Zero_Fail() public {
        vm.expectRevert("Invalid address");
        functionModifier.sendToAddress(address(0));
    }

    /// @notice Test min amount modifier accepts sufficient payment
    function test_MinAmount_Success() public {
        uint256 result = functionModifier.payMinimum{value: 0.01 ether}();
        assertEq(result, 0.01 ether);
    }

    /// @notice Test min amount modifier rejects insufficient payment
    function test_MinAmount_Fail() public {
        vm.expectRevert("Insufficient amount");
        functionModifier.payMinimum{value: 0.005 ether}();
    }

    /// @notice Test reentrancy guard allows single call
    function test_NoReentrancy_Success() public {
        assertEq(functionModifier.protectedFunction(), "Completed");
    }

    /// @notice Test lock is cleared after function
    function test_NoReentrancy_LockCleared() public {
        functionModifier.protectedFunction();
        assertFalse(functionModifier.isLocked());
    }

    /// @notice Test multiple modifiers work together
    function test_MultipleModifiers_Success() public {
        address recipient = makeAddr("recipient");
        uint256 result = functionModifier.complexOperation{value: 0.01 ether}(recipient);
        assertEq(result, 0.01 ether);
    }

    /// @notice Test change owner works for owner
    function test_ChangeOwner_Success() public {
        address newOwner = makeAddr("newOwner");
        functionModifier.changeOwner(newOwner);
        assertEq(functionModifier.owner(), newOwner);
    }

    /// @notice Test change owner fails for non-owner
    function test_ChangeOwner_NotOwner_Fail() public {
        vm.prank(nonOwner);
        vm.expectRevert("Not owner");
        functionModifier.changeOwner(makeAddr("newOwner"));
    }

    /// @notice Test change owner fails with zero address
    function test_ChangeOwner_ZeroAddress_Fail() public {
        vm.expectRevert("Invalid address");
        functionModifier.changeOwner(address(0));
    }
}
