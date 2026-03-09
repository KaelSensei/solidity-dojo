// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {FunctionTypes} from "../../src/basic/FunctionTypes.sol";

/// @title FunctionTypesTest
/// @notice Tests for FunctionTypes contract
contract FunctionTypesTest is Test {
    FunctionTypes public functionTypes;

    function setUp() public {
        functionTypes = new FunctionTypes();
    }

    // ==================== VISIBILITY TESTS ====================

    /// @notice Test external function
    function test_ExternalFunction() public view {
        assertEq(functionTypes.externalFunction(5), 10);
    }

    /// @notice Test public function
    function test_PublicFunction() public view {
        assertEq(functionTypes.publicFunction(5), 15);
    }

    /// @notice Test internal function via wrapper
    function test_InternalFunction() public view {
        assertEq(functionTypes.callInternal(), 15); // 5 + 10
    }

    /// @notice Test private function via wrapper
    function test_PrivateFunction() public view {
        assertEq(functionTypes.callPrivate(), 25); // 5 + 20
    }

    // ==================== MUTABILITY TESTS ====================

    /// @notice Test pure function
    function test_PureFunction() public view {
        assertEq(functionTypes.pureFunction(3, 7), 10);
    }

    /// @notice Test view function
    function test_ViewFunction() public view {
        assertEq(functionTypes.viewFunction(), 100); // Initial value from constructor
    }

    /// @notice Test state modifying function
    function test_StateModifyingFunction() public {
        functionTypes.stateModifyingFunction(200);
        assertEq(functionTypes.getStoredValue(), 200);
    }

    /// @notice Test payable function
    function test_PayableFunction() public {
        uint256 result = functionTypes.payableFunction{value: 50}();
        assertEq(result, 150); // 100 initial + 50
        assertEq(functionTypes.getStoredValue(), 150);
    }

    /// @notice Test owner was set correctly
    function test_OwnerSetCorrectly() public view {
        assertEq(functionTypes.owner(), address(this));
    }
}
