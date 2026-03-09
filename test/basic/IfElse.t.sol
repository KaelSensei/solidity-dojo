// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {IfElse} from "../../src/basic/IfElse.sol";

contract IfElseTest is Test {
    IfElse public ifElse;

    function setUp() public {
        ifElse = new IfElse();
    }

    /// @notice Unit test: ifElse returns 0 for x < 10
    function test_ifElse_returns0_forLessThan10() public view {
        assertEq(ifElse.ifElse(0), 0);
        assertEq(ifElse.ifElse(5), 0);
        assertEq(ifElse.ifElse(9), 0);
    }

    /// @notice Unit test: ifElse returns 1 for 10 <= x < 20
    function test_ifElse_returns1_for10To19() public view {
        assertEq(ifElse.ifElse(10), 1);
        assertEq(ifElse.ifElse(15), 1);
        assertEq(ifElse.ifElse(19), 1);
    }

    /// @notice Unit test: ifElse returns 2 for x >= 20
    function test_ifElse_returns2_for20OrMore() public view {
        assertEq(ifElse.ifElse(20), 2);
        assertEq(ifElse.ifElse(100), 2);
        assertEq(ifElse.ifElse(type(uint256).max), 2);
    }

    /// @notice Unit test: ternary matches ifElse output
    function testFuzz_ternary_matchesIfElse(uint256 x) public view {
        assertEq(ifElse.ternary(x), ifElse.ifElse(x));
    }

    /// @notice Unit test: isEven works correctly
    function test_isEven() public view {
        assertTrue(ifElse.isEven(0));
        assertTrue(ifElse.isEven(2));
        assertTrue(ifElse.isEven(100));
        assertFalse(ifElse.isEven(1));
        assertFalse(ifElse.isEven(3));
        assertFalse(ifElse.isEven(99));
    }

    /// @notice Unit test: max returns correct value
    function test_max() public view {
        assertEq(ifElse.max(1, 2), 2);
        assertEq(ifElse.max(2, 1), 2);
        assertEq(ifElse.max(5, 5), 5);
        assertEq(ifElse.max(0, type(uint256).max), type(uint256).max);
    }

    /// @notice Unit test: sign returns correct value
    function test_sign() public view {
        assertEq(ifElse.sign(0), 0);
        assertEq(ifElse.sign(1), 1);
        assertEq(ifElse.sign(100), 1);
        assertEq(ifElse.sign(-1), 2);
        assertEq(ifElse.sign(-100), 2);
    }
}
