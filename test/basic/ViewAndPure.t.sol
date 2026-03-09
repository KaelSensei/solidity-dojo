// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {ViewAndPure} from "../../src/basic/ViewAndPure.sol";

/// @title ViewAndPureTest
/// @notice Tests for ViewAndPure contract
contract ViewAndPureTest is Test {
    ViewAndPure public viewAndPure;

    function setUp() public {
        viewAndPure = new ViewAndPure();
    }

    /// @notice Test pure function returns correct result
    function test_PureFunction() public view {
        assertEq(viewAndPure.pureFunction(5), 25);
        assertEq(viewAndPure.pureFunction(10), 100);
    }

    /// @notice Test pure function with multiple operations
    function test_SumOfSquares() public view {
        assertEq(viewAndPure.sumOfSquares(3, 4), 25); // 9 + 16 = 25
    }

    /// @notice Test view function reads state correctly
    function test_ViewFunction() public view {
        assertEq(viewAndPure.viewFunction(), 42);
    }

    /// @notice Test view function with computation
    function test_ViewWithComputation() public view {
        assertEq(viewAndPure.viewWithComputation(2), 84); // 42 * 2
    }

    /// @notice Test view can call pure
    function test_ViewCallingPure() public view {
        // 42 + (10 * 10) = 142
        assertEq(viewAndPure.viewCallingPure(10), 142);
    }

    /// @notice Test pure can call pure
    function test_PureCallingPure() public view {
        assertEq(viewAndPure.pureCallingPure(50), 150); // 50 + 100
    }

    /// @notice Test view calling both view and pure
    function test_ViewCallingViewAndPure() public view {
        (uint256 viewResult, uint256 pureResult) = viewAndPure.viewCallingViewAndPure();
        assertEq(viewResult, 42); // From viewFunction
        assertEq(pureResult, 25); // pureFunction(5) = 25
    }

    /// @notice Test initial number value
    function test_InitialNumber() public view {
        assertEq(viewAndPure.number(), 42);
    }
}
