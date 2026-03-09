// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/evm/AssemblyConditionals.sol";

/// @title Assembly Conditionals Test Suite
contract AssemblyConditionalsTest is Test {
    AssemblyConditionals public asmCond;

    function setUp() public {
        asmCond = new AssemblyConditionals();
    }

    /// @notice Test simple if statement
    function test_SimpleIf() public {
        assertEq(asmCond.simpleIf(6), 10);
        assertEq(asmCond.simpleIf(5), 0);
        assertEq(asmCond.simpleIf(0), 0);
    }

    /// @notice Test if-else
    function test_IfElse() public {
        assertEq(asmCond.ifElse(1), 1);
        assertEq(asmCond.ifElse(100), 1);
        assertEq(asmCond.ifElse(0), 0);
    }

    /// @notice Test switch statement
    function test_SwitchStatement() public {
        assertEq(asmCond.switchStatement(0), 100);
        assertEq(asmCond.switchStatement(1), 200);
        assertEq(asmCond.switchStatement(2), 300);
        assertEq(asmCond.switchStatement(3), 0);
        assertEq(asmCond.switchStatement(100), 0);
    }

    /// @notice Test compare function
    function test_Compare() public {
        (uint256 greater, uint256 equal, uint256 less) = asmCond.compare(10, 5);
        assertEq(greater, 1);
        assertEq(equal, 0);
        assertEq(less, 0);
        
        (greater, equal, less) = asmCond.compare(5, 5);
        assertEq(greater, 0);
        assertEq(equal, 1);
        assertEq(less, 0);
        
        (greater, equal, less) = asmCond.compare(3, 7);
        assertEq(greater, 0);
        assertEq(equal, 0);
        assertEq(less, 1);
    }

    /// @notice Test absolute value
    function test_Abs() public {
        assertEq(asmCond.abs(5), 5);
        assertEq(asmCond.abs(0), 0);
        assertEq(asmCond.abs(-5), 5);
        assertEq(asmCond.abs(-100), 100);
    }

    /// @notice Test clamp function
    function test_Clamp() public {
        assertEq(asmCond.clamp(5, 1, 10), 5);
        assertEq(asmCond.clamp(0, 1, 10), 1);
        assertEq(asmCond.clamp(15, 1, 10), 10);
        assertEq(asmCond.clamp(1, 1, 10), 1);
        assertEq(asmCond.clamp(10, 1, 10), 10);
    }

    /// @notice Test isEven function
    function test_IsEven() public {
        assertEq(asmCond.isEven(4), 1);
        assertEq(asmCond.isEven(5), 0);
        assertEq(asmCond.isEven(0), 1);
        assertEq(asmCond.isEven(100), 1);
    }

    /// @notice Test sign function
    function test_Sign() public {
        assertEq(asmCond.sign(5), 1);    // positive
        assertEq(asmCond.sign(0), 0);    // zero
        assertEq(asmCond.sign(-5), 2);    // negative
    }

    /// @notice Fuzz test simple if
    function testFuzz_SimpleIf(uint256 x) public {
        uint256 result = asmCond.simpleIf(x);
        if (x > 5) {
            assertEq(result, 10);
        } else {
            assertEq(result, 0);
        }
    }

    /// @notice Fuzz test switch
    function testFuzz_SwitchStatement(uint256 x) public {
        uint256 result = asmCond.switchStatement(x);
        if (x <= 2) {
            assertEq(result, (x + 1) * 100);
        } else {
            assertEq(result, 0);
        }
    }

    /// @notice Fuzz test compare
    function testFuzz_Compare(uint256 a, uint256 b) public {
        (uint256 greater, uint256 equal, uint256 less) = asmCond.compare(a, b);
        
        if (a > b) {
            assertEq(greater, 1);
            assertEq(equal, 0);
            assertEq(less, 0);
        } else if (a == b) {
            assertEq(greater, 0);
            assertEq(equal, 1);
            assertEq(less, 0);
        } else {
            assertEq(greater, 0);
            assertEq(equal, 0);
            assertEq(less, 1);
        }
    }

    /// @notice Fuzz test abs
    function testFuzz_Abs(int256 x) public {
        vm.assume(x != type(int256).min); // -x overflows for min
        uint256 result = asmCond.abs(x);
        if (x >= 0) {
            assertEq(result, uint256(x));
        } else {
            assertEq(result, uint256(-x));
        }
    }

    /// @notice Fuzz test isEven
    function testFuzz_IsEven(uint256 x) public {
        uint256 result = asmCond.isEven(x);
        if (x % 2 == 0) {
            assertEq(result, 1);
        } else {
            assertEq(result, 0);
        }
    }
}
