// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/evm/AssemblyArray.sol";

/// @title Assembly Array Test Suite
contract AssemblyArrayTest is Test {
    AssemblyArray public asmArray;

    function setUp() public {
        asmArray = new AssemblyArray();
    }

    /// @notice Test length
    function test_Length() public {
        uint256[] memory arr = new uint256[](5);
        assertEq(asmArray.length(arr), 5);
        
        arr = new uint256[](0);
        assertEq(asmArray.length(arr), 0);
    }

    /// @notice Test get
    function test_Get() public {
        uint256[] memory arr = new uint256[](3);
        arr[0] = 10;
        arr[1] = 20;
        arr[2] = 30;
        
        assertEq(asmArray.get(arr, 0), 10);
        assertEq(asmArray.get(arr, 1), 20);
        assertEq(asmArray.get(arr, 2), 30);
    }

    /// @notice Test indexOf
    function test_IndexOf() public {
        uint256[] memory arr = new uint256[](4);
        arr[0] = 5;
        arr[1] = 10;
        arr[2] = 15;
        arr[3] = 20;
        
        assertEq(asmArray.indexOf(arr, 5), 0);
        assertEq(asmArray.indexOf(arr, 10), 1);
        assertEq(asmArray.indexOf(arr, 20), 3);
        assertEq(asmArray.indexOf(arr, 100), 4); // Not found
    }

    /// @notice Test contains
    function test_Contains() public {
        uint256[] memory arr = new uint256[](3);
        arr[0] = 1;
        arr[1] = 2;
        arr[2] = 3;
        
        assertTrue(asmArray.contains(arr, 1));
        assertTrue(asmArray.contains(arr, 2));
        assertTrue(asmArray.contains(arr, 3));
        assertTrue(!asmArray.contains(arr, 4));
        assertTrue(!asmArray.contains(arr, 0));
    }

    /// @notice Test sum
    function test_Sum() public {
        uint256[] memory arr = new uint256[](4);
        arr[0] = 1;
        arr[1] = 2;
        arr[2] = 3;
        arr[3] = 4;
        
        assertEq(asmArray.sum(arr), 10);
        
        arr = new uint256[](0);
        assertEq(asmArray.sum(arr), 0);
    }

    /// @notice Test max
    function test_Max() public {
        uint256[] memory arr = new uint256[](5);
        arr[0] = 3;
        arr[1] = 1;
        arr[2] = 4;
        arr[3] = 1;
        arr[4] = 9;
        
        assertEq(asmArray.max(arr), 9);
        
        arr = new uint256[](1);
        arr[0] = 42;
        assertEq(asmArray.max(arr), 42);
    }

    /// @notice Test min
    function test_Min() public {
        uint256[] memory arr = new uint256[](5);
        arr[0] = 3;
        arr[1] = 1;
        arr[2] = 4;
        arr[3] = 1;
        arr[4] = 9;
        
        assertEq(asmArray.min(arr), 1);
        
        arr = new uint256[](1);
        arr[0] = 42;
        assertEq(asmArray.min(arr), 42);
    }

    /// @notice Test count
    function test_Count() public {
        uint256[] memory arr = new uint256[](5);
        arr[0] = 1;
        arr[1] = 2;
        arr[2] = 1;
        arr[3] = 3;
        arr[4] = 1;
        
        assertEq(asmArray.count(arr, 1), 3);
        assertEq(asmArray.count(arr, 2), 1);
        assertEq(asmArray.count(arr, 5), 0);
    }

    /// @notice Test first
    function test_First() public {
        uint256[] memory arr = new uint256[](3);
        arr[0] = 100;
        arr[1] = 200;
        arr[2] = 300;
        
        assertEq(asmArray.first(arr), 100);
    }

    /// @notice Test last
    function test_Last() public {
        uint256[] memory arr = new uint256[](3);
        arr[0] = 100;
        arr[1] = 200;
        arr[2] = 300;
        
        assertEq(asmArray.last(arr), 300);
    }

    /// @notice Test isEmpty
    function test_IsEmpty() public {
        uint256[] memory arr = new uint256[](0);
        assertTrue(asmArray.isEmpty(arr));
        
        arr = new uint256[](1);
        arr[0] = 1;
        assertTrue(!asmArray.isEmpty(arr));
    }

    /// @notice Fuzz test length
    function testFuzz_Length(uint256 n) public {
        n = n % 100;
        uint256[] memory arr = new uint256[](n);
        assertEq(asmArray.length(arr), n);
    }

    /// @notice Fuzz test sum
    function testFuzz_Sum(uint256[] memory arr) public {
        vm.assume(arr.length <= 100);
        
        uint256 expected = 0;
        for (uint256 i = 0; i < arr.length; i++) {
            expected += arr[i];
        }
        
        assertEq(asmArray.sum(arr), expected);
    }

    /// @notice Fuzz test max
    function testFuzz_Max(uint256[] memory arr) public {
        vm.assume(arr.length > 0 && arr.length <= 100);
        
        uint256 expected = arr[0];
        for (uint256 i = 1; i < arr.length; i++) {
            if (arr[i] > expected) {
                expected = arr[i];
            }
        }
        
        assertEq(asmArray.max(arr), expected);
    }

    /// @notice Fuzz test min
    function testFuzz_Min(uint256[] memory arr) public {
        vm.assume(arr.length > 0 && arr.length <= 100);
        
        uint256 expected = arr[0];
        for (uint256 i = 1; i < arr.length; i++) {
            if (arr[i] < expected) {
                expected = arr[i];
            }
        }
        
        assertEq(asmArray.min(arr), expected);
    }

    /// @notice Fuzz test contains
    function testFuzz_Contains(uint256[] memory arr, uint256 target) public {
        vm.assume(arr.length <= 50);
        
        bool found = false;
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == target) {
                found = true;
                break;
            }
        }
        
        assertEq(asmArray.contains(arr, target) ? 1 : 0, found ? 1 : 0);
    }
}
