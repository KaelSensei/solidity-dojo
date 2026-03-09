// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/basic/UncheckedMath.sol";

/// @title UncheckedMath Test Suite
contract UncheckedMathTest is Test {
    UncheckedMath public math;

    function setUp() public {
        math = new UncheckedMath();
    }

    function test_AddNormal() public view {
        assertEq(math.add(1, 2), 3);
        assertEq(math.add(0, 0), 0);
    }

    function test_AddOverflowReverts() public {
        vm.expectRevert();
        math.add(type(uint256).max, 1);
    }

    function test_UncheckedAddWraps() public view {
        uint256 result = math.uncheckedAdd(type(uint256).max, 1);
        assertEq(result, 0);
    }

    function test_SubNormal() public view {
        assertEq(math.sub(5, 3), 2);
    }

    function test_SubUnderflowReverts() public {
        vm.expectRevert();
        math.sub(0, 1);
    }

    function test_UncheckedSubWraps() public view {
        uint256 result = math.uncheckedSub(0, 1);
        assertEq(result, type(uint256).max);
    }

    function test_UncheckedIncrement() public view {
        assertEq(math.uncheckedIncrement(0), 1);
        assertEq(math.uncheckedIncrement(41), 42);
    }

    function test_SumWithUncheckedLoop() public view {
        assertEq(math.sumWithUncheckedLoop(0), 0);
        assertEq(math.sumWithUncheckedLoop(10), 55);
        assertEq(math.sumWithUncheckedLoop(100), 5050);
    }

    function test_SumEquivalence() public view {
        assertEq(math.sumWithUncheckedLoop(100), math.sumWithCheckedLoop(100));
    }

    function test_UncheckedLoopUsesLessGas() public {
        uint256 gasBefore = gasleft();
        math.sumWithUncheckedLoop(200);
        uint256 gasUnchecked = gasBefore - gasleft();

        gasBefore = gasleft();
        math.sumWithCheckedLoop(200);
        uint256 gasChecked = gasBefore - gasleft();

        assertTrue(gasUnchecked < gasChecked, "Unchecked should use less gas");
    }

    function testFuzz_addSafe(uint128 a, uint128 b) public view {
        assertEq(math.add(uint256(a), uint256(b)), uint256(a) + uint256(b));
    }

    function testFuzz_sumEquivalent(uint8 n) public view {
        assertEq(math.sumWithUncheckedLoop(n), math.sumWithCheckedLoop(n));
    }
}
