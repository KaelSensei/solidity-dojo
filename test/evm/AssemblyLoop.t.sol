// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/evm/AssemblyLoop.sol";

/// @title Assembly Loop Test Suite
contract AssemblyLoopTest is Test {
    AssemblyLoop public asmLoop;

    function setUp() public {
        asmLoop = new AssemblyLoop();
    }

    /// @notice Test sumTo function
    function test_SumTo() public {
        assertEq(asmLoop.sumTo(0), 0);
        assertEq(asmLoop.sumTo(1), 0);
        assertEq(asmLoop.sumTo(2), 1);
        assertEq(asmLoop.sumTo(3), 3);
        assertEq(asmLoop.sumTo(4), 6);
        assertEq(asmLoop.sumTo(10), 45);
        assertEq(asmLoop.sumTo(100), 4950);
    }

    /// @notice Test sumEvens function (sum of even numbers in [0, n) )
    function test_SumEvens() public {
        assertEq(asmLoop.sumEvens(0), 0);
        assertEq(asmLoop.sumEvens(1), 0);
        assertEq(asmLoop.sumEvens(2), 0);
        assertEq(asmLoop.sumEvens(3), 2);
        assertEq(asmLoop.sumEvens(4), 2); // 0+2 (exclusive of 4)
        assertEq(asmLoop.sumEvens(10), 20); // 0+2+4+6+8
    }

    /// @notice Test max function
    function test_Max() public {
        uint256[] memory data = new uint256[](5);
        data[0] = 1;
        data[1] = 5;
        data[2] = 3;
        data[3] = 10;
        data[4] = 2;
        
        assertEq(asmLoop.max(data), 10);
    }

    /// @notice Test max with single element
    function test_MaxSingle() public {
        uint256[] memory data = new uint256[](1);
        data[0] = 42;
        
        assertEq(asmLoop.max(data), 42);
    }

    /// @notice Test max with empty array
    function test_MaxEmpty() public {
        uint256[] memory data = new uint256[](0);
        
        assertEq(asmLoop.max(data), 0);
    }

    /// @notice Test min function
    function test_Min() public {
        uint256[] memory data = new uint256[](5);
        data[0] = 1;
        data[1] = 5;
        data[2] = 3;
        data[3] = 10;
        data[4] = 2;
        
        assertEq(asmLoop.min(data), 1);
    }

    /// @notice Test min with empty array
    function test_MinEmpty() public {
        uint256[] memory data = new uint256[](0);
        
        assertEq(asmLoop.min(data), 0);
    }

    /// @notice Test countInArray
    function test_CountInArray() public {
        uint256[] memory data = new uint256[](5);
        data[0] = 1;
        data[1] = 2;
        data[2] = 1;
        data[3] = 3;
        data[4] = 1;
        
        assertEq(asmLoop.countInArray(data, 1), 3);
        assertEq(asmLoop.countInArray(data, 2), 1);
        assertEq(asmLoop.countInArray(data, 5), 0);
    }

    /// @notice Test findIndex
    function test_FindIndex() public {
        uint256[] memory data = new uint256[](4);
        data[0] = 10;
        data[1] = 20;
        data[2] = 30;
        data[3] = 40;
        
        assertEq(asmLoop.findIndex(data, 20), 1);
        assertEq(asmLoop.findIndex(data, 40), 3);
        assertEq(asmLoop.findIndex(data, 50), 4); // Not found
    }

    /// @notice Test factorial
    function test_Factorial() public {
        assertEq(asmLoop.factorial(0), 1);
        assertEq(asmLoop.factorial(1), 1);
        assertEq(asmLoop.factorial(2), 2);
        assertEq(asmLoop.factorial(3), 6);
        assertEq(asmLoop.factorial(4), 24);
        assertEq(asmLoop.factorial(5), 120);
    }

    /// @notice Test nestedLoopSum
    function test_NestedLoopSum() public {
        assertEq(asmLoop.nestedLoopSum(0), 0);
        assertEq(asmLoop.nestedLoopSum(1), 1);
        assertEq(asmLoop.nestedLoopSum(2), 4);
        assertEq(asmLoop.nestedLoopSum(3), 9);
        assertEq(asmLoop.nestedLoopSum(10), 100);
    }

    /// @notice Test sumArray
    function test_SumArray() public {
        uint256[] memory data = new uint256[](4);
        data[0] = 1;
        data[1] = 2;
        data[2] = 3;
        data[3] = 4;
        
        assertEq(asmLoop.sumArray(data), 10);
    }

    /// @notice Test reverseSum
    function test_ReverseSum() public {
        uint256[] memory data = new uint256[](4);
        data[0] = 1;
        data[1] = 2;
        data[2] = 3;
        data[3] = 4;
        
        // Sum of reversed: 4 + 3 + 2 + 1 = 10
        assertEq(asmLoop.reverseSum(data), 10);
    }

    /// @notice Fuzz test sumTo
    function testFuzz_SumTo(uint256 n) public {
        // Cap at reasonable size to avoid overflow
        n = n % 1000;
        
        uint256 expected = n == 0 ? 0 : (n * (n - 1)) / 2;
        assertEq(asmLoop.sumTo(n), expected);
    }

    /// @notice Fuzz test factorial (limit to small numbers)
    function testFuzz_Factorial(uint8 n) public {
        n = n % 10; // Limit to avoid huge numbers
        
        uint256 expected = 1;
        for (uint256 i = 2; i <= n; i++) {
            expected *= i;
        }
        
        assertEq(asmLoop.factorial(n), expected);
    }

    /// @notice Fuzz test nestedLoopSum
    function testFuzz_NestedLoopSum(uint256 n) public {
        n = n % 50;
        
        uint256 expected = n * n;
        assertEq(asmLoop.nestedLoopSum(n), expected);
    }

    /// @notice Fuzz test sumArray
    function testFuzz_SumArray(uint256[] memory data) public {
        vm.assume(data.length <= 100);
        // Bound elements to avoid overflow in expected sum
        for (uint256 i = 0; i < data.length; i++) {
            vm.assume(data[i] <= type(uint256).max / 200);
        }
        
        uint256 expected = 0;
        for (uint256 i = 0; i < data.length; i++) {
            expected += data[i];
        }
        
        assertEq(asmLoop.sumArray(data), expected);
    }

}
