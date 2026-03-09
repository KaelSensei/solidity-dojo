// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/applications/MultiCall.sol";

/// @title MultiCall Test Suite
contract MultiCallTest is Test {
    MultiCall public mc;
    MultiCallTarget public target;

    event MulticallExecuted(uint256 count);

    function setUp() public {
        mc = new MultiCall();
        target = new MultiCallTarget();
    }

    function test_MulticallSingleCall() public {
        address[] memory targets = new address[](1);
        bytes[] memory data = new bytes[](1);
        targets[0] = address(target);
        data[0] = abi.encodeWithSelector(MultiCallTarget.increment.selector);

        mc.multicall(targets, data);
        assertEq(target.counter(), 1);
    }

    function test_MulticallMultipleCalls() public {
        address[] memory targets = new address[](3);
        bytes[] memory data = new bytes[](3);
        for (uint256 i; i < 3;) {
            targets[i] = address(target);
            data[i] = abi.encodeWithSelector(MultiCallTarget.increment.selector);
            unchecked { ++i; }
        }

        vm.expectEmit(false, false, false, true);
        emit MulticallExecuted(3);
        mc.multicall(targets, data);

        assertEq(target.counter(), 3);
    }

    function test_MulticallWithReturnData() public {
        address[] memory targets = new address[](1);
        bytes[] memory data = new bytes[](1);
        targets[0] = address(target);
        data[0] = abi.encodeWithSelector(MultiCallTarget.add.selector, 10, 20);

        bytes[] memory results = mc.multicall(targets, data);
        uint256 sum = abi.decode(results[0], (uint256));
        assertEq(sum, 30);
    }

    function test_MulticallFailReverts() public {
        address[] memory targets = new address[](1);
        bytes[] memory data = new bytes[](1);
        targets[0] = address(target);
        data[0] = abi.encodeWithSelector(bytes4(0xdeadbeef));

        vm.expectRevert(abi.encodeWithSelector(MultiCall.CallFailed.selector, 0));
        mc.multicall(targets, data);
    }

    function test_StaticMulticall() public {
        target.increment();
        target.increment();

        address[] memory targets = new address[](2);
        bytes[] memory data = new bytes[](2);
        targets[0] = address(target);
        targets[1] = address(target);
        data[0] = abi.encodeWithSelector(MultiCallTarget.getCounter.selector);
        data[1] = abi.encodeWithSelector(MultiCallTarget.add.selector, 5, 7);

        bytes[] memory results = mc.staticMulticall(targets, data);
        assertEq(abi.decode(results[0], (uint256)), 2);
        assertEq(abi.decode(results[1], (uint256)), 12);
    }

    function test_MulticallBatchIncrement() public {
        uint256 batchSize = 10;
        address[] memory targets = new address[](batchSize);
        bytes[] memory data = new bytes[](batchSize);
        for (uint256 i; i < batchSize;) {
            targets[i] = address(target);
            data[i] = abi.encodeWithSelector(MultiCallTarget.increment.selector);
            unchecked { ++i; }
        }

        mc.multicall(targets, data);
        assertEq(target.counter(), batchSize);
    }
}
