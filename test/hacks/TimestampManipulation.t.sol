// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/hacks/TimestampManipulation.sol";

/// @title Timestamp Manipulation Test Suite
contract TimestampManipulationTest is Test {
    VulnerableLottery public lottery;
    address public user = address(0x1);

    function setUp() public {
        lottery = new VulnerableLottery(7 days);
    }

    /// @notice Test lottery has target time
    function test_LotteryHasTargetTime() public {
        assertTrue(lottery.targetTime() > 0);
    }

    /// @notice Test cannot pick winner before target time
    function test_CannotPickWinnerEarly() public {
        vm.expectRevert("Not yet");
        lottery.pickWinner();
    }

    /// @notice Test can pick winner after target time
    function test_CanPickWinnerAfterTime() public {
        vm.warp(lottery.targetTime() + 1);
        
        lottery.pickWinner();
        
        assertTrue(lottery.ended());
    }

    /// @notice Test get current time
    function test_GetCurrentTime() public {
        uint256 time = lottery.getCurrentTime();
        assertEq(time, block.timestamp);
    }
}
