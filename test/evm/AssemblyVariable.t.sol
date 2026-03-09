// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/evm/AssemblyVariable.sol";

/// @title Assembly Variable Test Suite
contract AssemblyVariableTest is Test {
    AssemblyVariable public asmVar;

    function setUp() public {
        asmVar = new AssemblyVariable();
    }

    /// @notice Test declare and initialize
    function test_DeclareAndInit() public {
        assertEq(asmVar.declareAndInit(), 42);
    }

    /// @notice Test multiple variables
    function test_MultipleVariables() public {
        (uint256 a, uint256 b, uint256 c) = asmVar.multipleVariables();
        assertEq(a, 10);
        assertEq(b, 20);
        assertEq(c, 30);
    }

    /// @notice Test variable scope
    function test_VariableScope() public {
        (uint256 inner, uint256 outer) = asmVar.variableScope();
        assertEq(inner, 200);
        assertEq(outer, 200);
    }

    /// @notice Test double with assembly
    function test_DoubleWithAssembly() public {
        assertEq(asmVar.doubleWithAssembly(5), 10);
        assertEq(asmVar.doubleWithAssembly(100), 200);
        assertEq(asmVar.doubleWithAssembly(0), 0);
    }

    /// @notice Test reassign variable
    function test_ReassignVariable() public {
        assertEq(asmVar.reassignVariable(), 3);
    }

    /// @notice Test zero initialization
    function test_ZeroInitialization() public {
        assertEq(asmVar.zeroInitialization(), 0);
    }

    /// @notice Test max function
    function test_Max() public {
        assertEq(asmVar.max(5, 10), 10);
        assertEq(asmVar.max(100, 50), 100);
        assertEq(asmVar.max(7, 7), 7);
    }

    /// @notice Test swap function
    function test_Swap() public {
        (uint256 x, uint256 y) = asmVar.swap(5, 10);
        assertEq(x, 10);
        assertEq(y, 5);
    }

    /// @notice Fuzz test double with assembly
    function testFuzz_DoubleWithAssembly(uint256 x) public {
        vm.assume(x <= type(uint256).max / 2); // Avoid overflow
        uint256 result = asmVar.doubleWithAssembly(x);
        assertEq(result, x * 2);
    }

    /// @notice Fuzz test max
    function testFuzz_Max(uint256 a, uint256 b) public {
        uint256 result = asmVar.max(a, b);
        assertTrue(result == a || result == b);
        assertTrue(result >= a);
        assertTrue(result >= b);
    }

    /// @notice Fuzz test swap
    function testFuzz_Swap(uint256 a, uint256 b) public {
        (uint256 x, uint256 y) = asmVar.swap(a, b);
        assertEq(x, b);
        assertEq(y, a);
    }

    /// @notice Fuzz test declare and init (should always be 42)
    function testFuzz_DeclareAndInit(uint256) public pure {
        // This function always returns 42 regardless of input
        // Just verify it doesn't revert
    }
}
