// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Events} from "../../src/basic/Events.sol";

/// @title EventsTest
/// @notice Tests for Events contract
contract EventsTest is Test {
    Events public events;

    function setUp() public {
        events = new Events();
    }

    /// @notice Test simple event emission
    function test_EmitSimple() public {
        vm.expectEmit(false, false, false, false);
        emit Events.SimpleEvent();
        events.emitSimple();
    }

    /// @notice Test value changed event
    function test_EmitValueChanged() public {
        vm.expectEmit(false, false, false, true);
        emit Events.ValueChanged(42);
        events.emitValueChanged(42);
    }

    /// @notice Test transfer event with indexed params
    function test_EmitTransfer() public {
        address to = makeAddr("recipient");
        vm.expectEmit(true, true, false, true);
        emit Events.Transfer(address(this), to, 100);
        events.emitTransfer(to, 100);
    }

    /// @notice Test approval event with all indexed params
    function test_EmitApproval() public {
        address spender = makeAddr("spender");
        vm.expectEmit(true, true, true, true);
        emit Events.Approval(address(this), spender, 50);
        events.emitApproval(spender, 50);
    }

    /// @notice Test complex event with mixed params
    function test_EmitComplex() public {
        vm.expectEmit(true, true, false, false);
        emit Events.ComplexEvent(address(this), 1, "test", block.timestamp);
        events.emitComplex("test");
    }

    /// @notice Test batch emit
    function test_BatchEmit() public {
        uint256 count = 3;
        for (uint256 i = 0; i < count; i++) {
            vm.expectEmit(false, false, false, true);
            emit Events.ValueChanged(i);
        }
        events.batchEmit(count);
    }

    /// @notice Test anonymous event
    function test_EmitAnonymous() public {
        // Anonymous events don't emit the event signature as topic 0
        // This makes them cheaper but harder to filter
        // Just verify the function executes without revert
        events.emitAnonymous(123);
    }
}
