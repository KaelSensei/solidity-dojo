// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/applications/TimeLock.sol";

/// @title TimeLock Test Suite
contract TimeLockTest is Test {
    TimeLock public timelock;
    TimeLockTarget public target;
    address public alice = makeAddr("alice");

    event Queue(bytes32 indexed txId, address indexed target, uint256 value, bytes data, uint256 executeTime);
    event Execute(bytes32 indexed txId, address indexed target, uint256 value, bytes data, uint256 executeTime);
    event Cancel(bytes32 indexed txId);

    function setUp() public {
        timelock = new TimeLock();
        target = new TimeLockTarget();
        deal(address(timelock), 10 ether);
    }

    function _getSetValueData(uint256 val) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(TimeLockTarget.setValue.selector, val);
    }

    function test_Queue() public {
        uint256 execTime = block.timestamp + 3 days;
        bytes memory data = _getSetValueData(42);
        bytes32 txId = timelock.getTxId(address(target), 0, data, execTime);

        vm.expectEmit(true, true, false, true);
        emit Queue(txId, address(target), 0, data, execTime);
        timelock.queue(address(target), 0, data, execTime);

        assertTrue(timelock.queued(txId));
    }

    function test_Execute() public {
        uint256 execTime = block.timestamp + 3 days;
        bytes memory data = _getSetValueData(42);
        bytes32 txId = timelock.getTxId(address(target), 0, data, execTime);

        timelock.queue(address(target), 0, data, execTime);

        vm.warp(execTime);
        vm.expectEmit(true, true, false, true);
        emit Execute(txId, address(target), 0, data, execTime);
        timelock.execute(address(target), 0, data, execTime);

        assertEq(target.value(), 42);
        assertFalse(timelock.queued(txId));
    }

    function test_Cancel() public {
        uint256 execTime = block.timestamp + 3 days;
        bytes memory data = _getSetValueData(42);
        bytes32 txId = timelock.getTxId(address(target), 0, data, execTime);

        timelock.queue(address(target), 0, data, execTime);
        timelock.cancel(txId);

        assertFalse(timelock.queued(txId));
    }

    function test_CannotExecuteBeforeDelay() public {
        uint256 execTime = block.timestamp + 3 days;
        bytes memory data = _getSetValueData(42);

        timelock.queue(address(target), 0, data, execTime);

        vm.expectRevert(
            abi.encodeWithSelector(TimeLock.TimestampNotPassed.selector, execTime, block.timestamp)
        );
        timelock.execute(address(target), 0, data, execTime);
    }

    function test_CannotExecuteAfterGracePeriod() public {
        uint256 execTime = block.timestamp + 3 days;
        bytes memory data = _getSetValueData(42);

        timelock.queue(address(target), 0, data, execTime);

        vm.warp(execTime + timelock.GRACE_PERIOD() + 1);
        vm.expectRevert(
            abi.encodeWithSelector(
                TimeLock.TimestampExpired.selector,
                execTime,
                execTime + timelock.GRACE_PERIOD()
            )
        );
        timelock.execute(address(target), 0, data, execTime);
    }

    function test_OnlyOwnerCanQueue() public {
        vm.prank(alice);
        vm.expectRevert(TimeLock.NotOwner.selector);
        timelock.queue(address(target), 0, _getSetValueData(42), block.timestamp + 3 days);
    }

    function test_CannotQueueDuplicate() public {
        uint256 execTime = block.timestamp + 3 days;
        bytes memory data = _getSetValueData(42);

        timelock.queue(address(target), 0, data, execTime);

        bytes32 txId = timelock.getTxId(address(target), 0, data, execTime);
        vm.expectRevert(abi.encodeWithSelector(TimeLock.AlreadyQueued.selector, txId));
        timelock.queue(address(target), 0, data, execTime);
    }

    function test_CannotQueueTooSoon() public {
        uint256 execTime = block.timestamp + 1 hours;
        vm.expectRevert();
        timelock.queue(address(target), 0, _getSetValueData(42), execTime);
    }
}
