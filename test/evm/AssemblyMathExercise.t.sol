// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/evm/AssemblyMathExercise.sol";

/// @title Assembly Math Exercise Test Suite
contract AssemblyMathExerciseTest is Test {
    AssemblyMathExercise public asmMath;

    function setUp() public {
        asmMath = new AssemblyMathExercise();
    }

    /// @notice Test subtract
    function test_Subtract() public {
        assertEq(asmMath.subtract(10, 5), 5);
        // Yul sub wraps: 5 - 10 = type(uint256).max - 4
        assertEq(asmMath.subtract(5, 10), type(uint256).max - 4);
    }

    /// @notice Test multiply
    function test_Multiply() public {
        assertEq(asmMath.multiply(3, 4), 12);
        assertEq(asmMath.multiply(0, 100), 0);
        assertEq(asmMath.multiply(100, 1), 100);
    }

    /// @notice Test divide
    function test_Divide() public {
        assertEq(asmMath.divide(10, 2), 5);
        assertEq(asmMath.divide(15, 4), 3);
        assertEq(asmMath.divide(100, 100), 1);
    }

    /// @notice Test modulo
    function test_Modulo() public {
        assertEq(asmMath.modulo(10, 3), 1);
        assertEq(asmMath.modulo(15, 5), 0);
        assertEq(asmMath.modulo(7, 7), 0);
    }

    /// @notice Test addMod
    function test_AddMod() public {
        assertEq(asmMath.addMod(3, 5, 4), 0); // 8 % 4 = 0
        assertEq(asmMath.addMod(3, 5, 5), 3); // 8 % 5 = 3
        assertEq(asmMath.addMod(10, 10, 7), 6); // 20 % 7 = 6
    }

    /// @notice Test mulMod
    function test_MulMod() public {
        assertEq(asmMath.mulMod(3, 4, 5), 2); // 12 % 5 = 2
        assertEq(asmMath.mulMod(10, 10, 7), 2); // 100 % 7 = 2
        assertEq(asmMath.mulMod(5, 5, 25), 0); // 25 % 25 = 0
    }

    /// @notice Test increment
    function test_Increment() public {
        assertEq(asmMath.increment(0), 1);
        assertEq(asmMath.increment(100), 101);
        assertEq(asmMath.increment(type(uint256).max), 0); // Overflows
    }

    /// @notice Test decrement
    function test_Decrement() public {
        assertEq(asmMath.decrement(1), 0);
        assertEq(asmMath.decrement(100), 99);
    }

    /// @notice Test square
    function test_Square() public {
        assertEq(asmMath.square(0), 0);
        assertEq(asmMath.square(1), 1);
        assertEq(asmMath.square(5), 25);
        assertEq(asmMath.square(10), 100);
    }

    /// @notice Test cube
    function test_Cube() public {
        assertEq(asmMath.cube(0), 0);
        assertEq(asmMath.cube(1), 1);
        assertEq(asmMath.cube(2), 8);
        assertEq(asmMath.cube(3), 27);
    }

    /// @notice Test average
    function test_Average() public {
        assertEq(asmMath.average(2, 4), 3);
        assertEq(asmMath.average(1, 2), 1);
        assertEq(asmMath.average(5, 6), 5);
        assertEq(asmMath.average(100, 200), 150);
    }

    /// @notice Test min
    function test_Min() public {
        assertEq(asmMath.min(1, 2), 1);
        assertEq(asmMath.min(10, 5), 5);
        assertEq(asmMath.min(7, 7), 7);
    }

    /// @notice Test max
    function test_Max() public {
        assertEq(asmMath.max(1, 2), 2);
        assertEq(asmMath.max(10, 5), 10);
        assertEq(asmMath.max(7, 7), 7);
    }

    /// @notice Test isEven
    function test_IsEven() public {
        assertEq(asmMath.isEven(0), 1);
        assertEq(asmMath.isEven(2), 1);
        assertEq(asmMath.isEven(4), 1);
        assertEq(asmMath.isEven(1), 0);
        assertEq(asmMath.isEven(3), 0);
    }

    /// @notice Test absDiff
    function test_AbsDiff() public {
        assertEq(asmMath.absDiff(10, 5), 5);
        assertEq(asmMath.absDiff(5, 10), 5);
        assertEq(asmMath.absDiff(7, 7), 0);
    }

    /// @notice Fuzz test add (contract has no add; this tests Solidity)
    function testFuzz_Add(uint256 a, uint256 b) public {
        vm.assume(a <= type(uint256).max - b);
        uint256 result = a + b;
        assertTrue(result >= a);
    }

    /// @notice Fuzz test subtract
    function testFuzz_Subtract(uint256 a, uint256 b) public {
        if (a >= b) {
            assertEq(asmMath.subtract(a, b), a - b);
        }
    }

    /// @notice Fuzz test multiply
    function testFuzz_Multiply(uint256 a, uint256 b) public {
        vm.assume(a == 0 || b <= type(uint256).max / a);
        assertEq(asmMath.multiply(a, b), a * b);
    }

    /// @notice Fuzz test divide
    function testFuzz_Divide(uint256 a, uint256 b) public {
        vm.assume(b != 0);
        assertEq(asmMath.divide(a, b), a / b);
    }

    /// @notice Fuzz test modulo
    function testFuzz_Modulo(uint256 a, uint256 b) public {
        vm.assume(b != 0);
        assertEq(asmMath.modulo(a, b), a % b);
    }

    /// @notice Fuzz test square
    function testFuzz_Square(uint256 x) public {
        vm.assume(x <= 340282366920938463463374607431768211455); // sqrt(max)
        assertEq(asmMath.square(x), x * x);
    }

    /// @notice Fuzz test cube
    function testFuzz_Cube(uint256 x) public {
        // Limit to avoid overflow
        vm.assume(x < 10 ** 19);
        assertEq(asmMath.cube(x), x * x * x);
    }

    /// @notice Fuzz test min
    function testFuzz_Min(uint256 a, uint256 b) public {
        uint256 result = asmMath.min(a, b);
        assertTrue(result <= a);
        assertTrue(result <= b);
        assertTrue(result == a || result == b);
    }

    /// @notice Fuzz test max
    function testFuzz_Max(uint256 a, uint256 b) public {
        uint256 result = asmMath.max(a, b);
        assertTrue(result >= a);
        assertTrue(result >= b);
        assertTrue(result == a || result == b);
    }

    /// @notice Fuzz test isEven
    function testFuzz_IsEven(uint256 x) public {
        uint256 result = asmMath.isEven(x);
        if (x % 2 == 0) {
            assertEq(result, 1);
        } else {
            assertEq(result, 0);
        }
    }

    /// @notice Fuzz test absDiff
    function testFuzz_AbsDiff(uint256 a, uint256 b) public {
        uint256 result = asmMath.absDiff(a, b);
        uint256 expected = a >= b ? a - b : b - a;
        assertEq(result, expected);
    }
}
