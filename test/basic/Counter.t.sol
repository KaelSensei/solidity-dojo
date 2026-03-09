// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../../src/basic/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
    }

    /// @notice Unit test: inc() increments count by 1
    function test_inc_incrementsByOne() public {
        assertEq(counter.count(), 0);
        counter.inc();
        assertEq(counter.count(), 1);
        counter.inc();
        assertEq(counter.count(), 2);
    }

    /// @notice Unit test: dec() decrements count by 1
    function test_dec_decrementsByOne() public {
        counter.inc();
        counter.inc();
        assertEq(counter.count(), 2);
        counter.dec();
        assertEq(counter.count(), 1);
        counter.dec();
        assertEq(counter.count(), 0);
    }

    /// @notice Unit test: dec() reverts on underflow (0.8+ auto-check)
    function test_dec_revertsOnUnderflow() public {
        vm.expectRevert();
        counter.dec();
    }

    /// @notice Fuzz test: calling inc N times results in count == N
    function testFuzz_inc(uint8 times) public {
        uint256 n = uint256(times);
        for (uint256 i = 0; i < n; i++) {
            counter.inc();
        }
        assertEq(counter.count(), n);
    }

    /// @notice Unit test: get() returns the same as count()
    function test_get_matchesCount() public view {
        assertEq(counter.get(), counter.count());
    }
}
