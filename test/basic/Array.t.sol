// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Array} from "../../src/basic/Array.sol";

contract ArrayTest is Test {
    Array public arr;

    function setUp() public {
        arr = new Array();
    }

    /// @notice Unit test: push increases length
    function test_push_increasesLength() public {
        assertEq(arr.getLength(), 0);
        arr.push(10);
        assertEq(arr.getLength(), 1);
        arr.push(20);
        assertEq(arr.getLength(), 2);
    }

    /// @notice Unit test: pop decreases length and removes last element
    function test_pop_decreasesLength() public {
        arr.push(10);
        arr.push(20);
        assertEq(arr.getLength(), 2);

        uint256 popped = arr.pop();
        assertEq(popped, 20);
        assertEq(arr.getLength(), 1);

        popped = arr.pop();
        assertEq(popped, 10);
        assertEq(arr.getLength(), 0);
    }

    /// @notice Unit test: pop on empty array reverts
    function test_pop_emptyReverts() public {
        vm.expectRevert();
        arr.pop();
    }

    /// @notice Unit test: delete leaves zero, does not change length
    function test_delete_leavesZero() public {
        arr.push(10);
        arr.push(20);
        assertEq(arr.getLength(), 2);

        arr.deleteAt(0);
        assertEq(arr.getLength(), 2);
        assertEq(arr.get(0), 0);
        assertEq(arr.get(1), 20);
    }

    /// @notice Unit test: removeBySwap changes length, does not preserve order
    function test_removeBySwap_changesLength() public {
        arr.push(10);
        arr.push(20);
        arr.push(30);
        assertEq(arr.getLength(), 3);

        arr.removeBySwap(0); // Remove first element
        assertEq(arr.getLength(), 2);
        // Order may not be preserved, but 10 should be gone
        bool found10 = false;
        for (uint256 i = 0; i < arr.getLength(); i++) {
            if (arr.get(i) == 10) found10 = true;
        }
        assertFalse(found10);
    }

    /// @notice Unit test: removeByShift preserves order
    function test_removeByShift_preservesOrder() public {
        arr.push(10);
        arr.push(20);
        arr.push(30);

        arr.removeByShift(1); // Remove middle element (20)
        assertEq(arr.getLength(), 2);
        assertEq(arr.get(0), 10);
        assertEq(arr.get(1), 30);
    }

    /// @notice Unit test: out-of-bounds access reverts
    function test_outOfBoundsReverts() public {
        arr.push(10);
        vm.expectRevert();
        arr.get(1);
    }

    /// @notice Fuzz test: push and pop n elements results in length 0
    function testFuzz_push_pop(uint8 n) public {
        uint256 count = uint256(n);
        for (uint256 i = 0; i < count; i++) {
            arr.push(i);
        }
        assertEq(arr.getLength(), count);

        for (uint256 i = 0; i < count; i++) {
            arr.pop();
        }
        assertEq(arr.getLength(), 0);
    }

    /// @notice Unit test: fixed array works
    function test_fixedArray() public {
        arr.setFixed(0, 100);
        arr.setFixed(5, 500);
        assertEq(arr.getFixed(0), 100);
        assertEq(arr.getFixed(5), 500);
    }

    /// @notice Unit test: fixed array bounds
    function test_fixedArrayBounds() public {
        vm.expectRevert();
        arr.setFixed(10, 100);
    }
}
