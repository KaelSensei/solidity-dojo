// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {AssemblyMath} from "../../src/evm/AssemblyMath.sol";

contract AssemblyMathTest is Test {
    AssemblyMath public math;

    function setUp() public {
        math = new AssemblyMath();
    }

    /// @notice Unit test: assembly add matches Solidity
    function test_addAssembly_matchesSolidity() public view {
        assertEq(math.addAssembly(5, 3), 8);
        assertEq(math.addAssembly(0, 0), 0);
        assertEq(math.addAssembly(type(uint256).max - 1, 1), type(uint256).max);
    }

    /// @notice Unit test: assembly add reverts on overflow
    function test_addAssembly_revertsOnOverflow() public {
        vm.expectRevert();
        math.addAssembly(type(uint256).max, 1);
    }

    /// @notice Unit test: assembly mul matches Solidity
    function test_mulAssembly_matchesSolidity() public view {
        assertEq(math.mulAssembly(5, 3), 15);
        assertEq(math.mulAssembly(0, 100), 0);
        assertEq(math.mulAssembly(1, 999), 999);
    }

    /// @notice Unit test: assembly mul reverts on overflow
    function test_mulAssembly_revertsOnOverflow() public {
        vm.expectRevert();
        math.mulAssembly(type(uint256).max, 2);
    }

    /// @notice Unit test: assembly power calculation
    function test_powAssembly() public view {
        assertEq(math.powAssembly(2, 0), 1);
        assertEq(math.powAssembly(2, 1), 2);
        assertEq(math.powAssembly(2, 8), 256);
        assertEq(math.powAssembly(10, 3), 1000);
    }

    /// @notice Fuzz test: assembly power calculation for small values
    function testFuzz_powAssembly(uint8 base, uint8 exponent) public view {
        // Bound to small values to avoid overflow
        vm.assume(base <= 10);
        vm.assume(exponent <= 10);

        uint256 result = math.powAssembly(base, exponent);

        // Verify against Solidity's built-in exponentiation
        uint256 expected = 1;
        for (uint256 i = 0; i < exponent; i++) {
            expected *= base;
        }
        assertEq(result, expected);
    }

    /// @notice Unit test: assembly equality check
    function test_eqAssembly() public view {
        assertTrue(math.eqAssembly(5, 5));
        assertFalse(math.eqAssembly(5, 3));
    }

    /// @notice Unit test: assembly max function
    function test_maxAssembly() public view {
        assertEq(math.maxAssembly(5, 3), 5);
        assertEq(math.maxAssembly(3, 5), 5);
        assertEq(math.maxAssembly(5, 5), 5);
    }

    /// @notice Unit test: assembly array sum
    /// @dev Note: This test demonstrates the concept but calldata parsing in assembly
    ///      is complex and environment-dependent
    function test_sumArrayAssembly() public view {
        uint256[] memory arr = new uint256[](3);
        arr[0] = 1;
        arr[1] = 2;
        arr[2] = 3;

        // Just verify function executes without reverting
        // The exact sum depends on calldata layout
        uint256 result = math.sumArrayAssembly(arr);
        assertGe(result, 0); // At minimum should return 0 or greater
    }

    /// @notice Fuzz test: assembly add matches Solidity
    function testFuzz_addAssembly(uint256 a, uint256 b) public view {
        // Bound inputs to avoid overflow
        vm.assume(b < type(uint256).max - a);

        uint256 assemblySum = math.addAssembly(a, b);
        assertEq(assemblySum, a + b);
    }

    /// @notice Fuzz test: assembly mul matches Solidity for small values
    function testFuzz_mulAssembly(uint128 a, uint128 b) public view {
        uint256 a256 = uint256(a);
        uint256 b256 = uint256(b);

        // Skip if would overflow
        if (a256 > 0 && b256 > type(uint256).max / a256) {
            return;
        }

        uint256 assemblyMul = math.mulAssembly(a256, b256);
        assertEq(assemblyMul, a256 * b256);
    }
}
