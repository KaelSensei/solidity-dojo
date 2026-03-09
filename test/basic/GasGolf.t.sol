// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/basic/GasGolf.sol";

/// @title GasGolf Test Suite
contract GasGolfTest is Test {
    GasGolf public golf;

    function setUp() public {
        golf = new GasGolf();
    }

    function test_BothVersionsSameResult() public view {
        uint256[] memory nums = new uint256[](6);
        nums[0] = 1;
        nums[1] = 2;
        nums[2] = 3;
        nums[3] = 4;
        nums[4] = 99;
        nums[5] = 98;

        uint256 unoptimized = golf.sumIfEvenAndLessThan99_UNOPTIMIZED(nums);
        uint256 optimized = golf.sumIfEvenAndLessThan99(nums);
        assertEq(unoptimized, optimized);
        assertEq(optimized, 2 + 4 + 98);
    }

    function test_OptimizedUsesLessGas() public {
        uint256[] memory nums = new uint256[](10);
        for (uint256 i; i < 10;) {
            nums[i] = i * 10;
            unchecked { ++i; }
        }

        uint256 gasBefore = gasleft();
        golf.sumIfEvenAndLessThan99_UNOPTIMIZED(nums);
        uint256 gasUnoptimized = gasBefore - gasleft();

        gasBefore = gasleft();
        golf.sumIfEvenAndLessThan99(nums);
        uint256 gasOptimized = gasBefore - gasleft();

        assertTrue(gasOptimized < gasUnoptimized, "Optimized should use less gas");
    }

    function test_EmptyArrayOptimizedReverts() public {
        uint256[] memory nums = new uint256[](0);
        vm.expectRevert(GasGolf.EmptyArray.selector);
        golf.sumIfEvenAndLessThan99(nums);
    }

    function test_EmptyArrayUnoptimizedReverts() public {
        uint256[] memory nums = new uint256[](0);
        vm.expectRevert("Array must not be empty");
        golf.sumIfEvenAndLessThan99_UNOPTIMIZED(nums);
    }

    function test_AllOddNumbers() public view {
        uint256[] memory nums = new uint256[](3);
        nums[0] = 1;
        nums[1] = 3;
        nums[2] = 5;
        assertEq(golf.sumIfEvenAndLessThan99(nums), 0);
    }

    function test_AllAbove99() public view {
        uint256[] memory nums = new uint256[](3);
        nums[0] = 100;
        nums[1] = 200;
        nums[2] = 300;
        assertEq(golf.sumIfEvenAndLessThan99(nums), 0);
    }

    function testFuzz_equivalence(uint8 len) public view {
        vm.assume(len > 0 && len <= 50);
        uint256[] memory nums = new uint256[](len);
        for (uint256 i; i < len;) {
            nums[i] = i * 7;
            unchecked { ++i; }
        }
        assertEq(
            golf.sumIfEvenAndLessThan99_UNOPTIMIZED(nums),
            golf.sumIfEvenAndLessThan99(nums)
        );
    }
}
