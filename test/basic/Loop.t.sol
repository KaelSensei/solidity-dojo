// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Loop} from "../../src/basic/Loop.sol";

contract LoopTest is Test {
    Loop public loop;

    function setUp() public {
        loop = new Loop();
    }

    /// @notice Unit test: sumFor(10) equals 55
    function test_sumFor_tenIsFiftyFive() public view {
        assertEq(loop.sumFor(10), 55);
    }

    /// @notice Unit test: sumFor(0) equals 0
    function test_sumFor_zeroIsZero() public view {
        assertEq(loop.sumFor(0), 0);
    }

    /// @notice Unit test: sumWhile matches sumFor
    function testFuzz_for_while_equivalent(uint8 n) public view {
        uint256 forSum = loop.sumFor(n);
        uint256 whileSum = loop.sumWhile(n);
        assertEq(forSum, whileSum);
    }

    /// @notice Unit test: break exits early
    function test_sumUntilTarget_breaksEarly() public view {
        uint256[] memory arr = new uint256[](5);
        arr[0] = 10;
        arr[1] = 20;
        arr[2] = 30;
        arr[3] = 40;
        arr[4] = 50;

        // Target 35: should stop after adding 10+20=30 and 30 (total 60 >= 35)
        // Actually it adds 10+20=30, then 30 makes 60 >= 35, breaks
        assertEq(loop.sumUntilTarget(arr, 35), 60);
    }

    /// @notice Unit test: sumOnlyEven skips odd numbers
    function test_sumOnlyEven_skipsOdd() public view {
        uint256[] memory arr = new uint256[](5);
        arr[0] = 1; // odd, skip
        arr[1] = 2; // even, add
        arr[2] = 3; // odd, skip
        arr[3] = 4; // even, add
        arr[4] = 5; // odd, skip

        assertEq(loop.sumOnlyEven(arr), 6); // 2 + 4 = 6
    }

    /// @notice Unit test: findIndex finds correct index
    function test_findIndex_findsCorrectIndex() public view {
        uint256[] memory arr = new uint256[](5);
        arr[0] = 10;
        arr[1] = 20;
        arr[2] = 30;
        arr[3] = 40;
        arr[4] = 50;

        assertEq(loop.findIndex(arr, 30), 2);
        assertEq(loop.findIndex(arr, 10), 0);
        assertEq(loop.findIndex(arr, 50), 4);
    }

    /// @notice Unit test: findIndex returns max for not found
    function test_findIndex_returnsMaxForNotFound() public view {
        uint256[] memory arr = new uint256[](3);
        arr[0] = 1;
        arr[1] = 2;
        arr[2] = 3;

        assertEq(loop.findIndex(arr, 99), type(uint256).max);
    }

    /// @notice Unit test: factorial works correctly
    function test_factorial() public view {
        assertEq(loop.factorial(0), 1);
        assertEq(loop.factorial(1), 1);
        assertEq(loop.factorial(5), 120);
        assertEq(loop.factorial(10), 3628800);
    }

    /// @notice Unit test: sumFor matches formula n*(n+1)/2
    function test_sumFor_matchesFormula() public view {
        for (uint8 i = 0; i <= 50; i++) {
            uint256 expected = uint256(i) * (uint256(i) + 1) / 2;
            assertEq(loop.sumFor(i), expected);
        }
    }
}
