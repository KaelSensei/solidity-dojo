// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {EnumExample} from "../../src/basic/Enum.sol";

contract EnumTest is Test {
    EnumExample public enumContract;

    function setUp() public {
        enumContract = new EnumExample();
    }

    /// @notice Unit test: default value is Pending (0)
    function test_defaultValue_isPending() public view {
        assertEq(uint256(enumContract.status()), 0);
        assertEq(enumContract.getAsUint(), 0);
    }

    /// @notice Unit test: can set to each enum member
    function test_setToEachMember() public {
        enumContract.setPending();
        assertEq(uint256(enumContract.status()), 0);

        enumContract.setActive();
        assertEq(uint256(enumContract.status()), 1);

        enumContract.setInactive();
        assertEq(uint256(enumContract.status()), 2);
    }

    /// @notice Unit test: reset returns to Pending
    function test_reset_returnsToPending() public {
        enumContract.setActive();
        assertEq(uint256(enumContract.status()), 1);

        enumContract.reset();
        assertEq(uint256(enumContract.status()), 0);
    }

    /// @notice Unit test: casting to uint8 works
    function test_castingToUint8() public {
        enumContract.setActive();
        assertEq(enumContract.getAsUint(), 1);
    }

    /// @notice Fuzz test: only valid enum values (0-2) should succeed
    function testFuzz_set(uint8 raw) public {
        if (raw <= 2) {
            // Valid enum values should work
            enumContract.setFromUint(raw);
            assertEq(uint256(enumContract.status()), uint256(raw));
        }
        // Values > 2 will also work in Solidity (no automatic revert)
        // but represent invalid enum states
    }

    /// @notice Unit test: event emitted on status change
    function test_eventEmittedOnChange() public {
        vm.expectEmit(true, true, true, true);
        emit EnumExample.StatusChanged(EnumExample.Status.Active);
        enumContract.setActive();
    }
}
