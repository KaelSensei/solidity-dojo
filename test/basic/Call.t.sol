// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Call, TargetContract} from "../../src/basic/Call.sol";

/// @title CallTest
/// @notice Tests for Call contract
contract CallTest is Test {
    Call public caller;
    TargetContract public target;

    function setUp() public {
        caller = new Call();
        target = new TargetContract();
    }

    /// @notice Test call by selector
    function test_CallBySelector() public {
        bytes4 selector = bytes4(keccak256("getValue()"));
        (bool success, bytes memory result) = caller.callBySelector(address(target), selector);
        assertTrue(success);
        assertEq(abi.decode(result, (uint256)), 0); // Initial value is 0
    }

    /// @notice Test call with value
    function test_CallWithValue() public {
        bytes memory data = abi.encodeWithSignature("deposit()");
        (bool success,) = caller.callWithValue{value: 1 ether}(address(target), data, 1 ether);
        assertTrue(success);
        assertEq(target.balances(address(caller)), 1 ether);
    }

    /// @notice Test static call
    function test_StaticCall() public {
        target.setValue(42);
        bytes memory data = abi.encodeWithSignature("getValue()");
        (bool success, bytes memory result) = caller.staticCall(address(target), data);
        assertTrue(success);
        assertEq(abi.decode(result, (uint256)), 42);
    }

    /// @notice Test batch call
    function test_BatchCall() public {
        address[] memory targets = new address[](2);
        targets[0] = address(target);
        targets[1] = address(target);

        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeWithSignature("setValue(uint256)", 10);
        data[1] = abi.encodeWithSignature("setValue(uint256)", 20);

        (bool[] memory successes,) = caller.batchCall(targets, data);
        assertTrue(successes[0]);
        assertTrue(successes[1]);
        assertEq(target.value(), 20); // Last call sets value to 20
    }

    receive() external payable {}
}
