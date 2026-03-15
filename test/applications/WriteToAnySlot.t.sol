// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/applications/WriteToAnySlot.sol";

/// @title WriteToAnySlot Test Suite
contract WriteToAnySlotTest is Test {
    WriteToAnySlot public ws;

    function setUp() public {
        ws = new WriteToAnySlot();
    }

    function test_WriteAndRead() public {
        bytes32 slot = bytes32(uint256(100));
        bytes32 value = bytes32(uint256(42));

        ws.write(slot, value);
        bytes32 result = ws.read(slot);

        assertEq(result, value, "Should read back the written value");
    }

    function test_ReadEmptySlotReturnsZero() public view {
        bytes32 slot = bytes32(uint256(999));
        bytes32 result = ws.read(slot);

        assertEq(result, bytes32(0), "Empty slot should return zero");
    }

    function test_WriteToKnownVariableSlot() public {
        // storedValue is at slot 0
        bytes32 slot0 = bytes32(uint256(0));
        bytes32 newValue = bytes32(uint256(777));

        ws.write(slot0, newValue);

        // Reading via the public getter should reflect the change
        assertEq(ws.storedValue(), 777, "storedValue should be updated via raw slot write");
    }

    function test_ComputeMappingSlot() public {
        address alice = makeAddr("alice");
        // balances mapping is at slot 1
        uint256 baseSlot = 1;

        bytes32 computedSlot = ws.computeMappingSlot(alice, baseSlot);

        // Write directly to the computed slot
        bytes32 amount = bytes32(uint256(500));
        ws.write(computedSlot, amount);

        // The mapping getter should return the value we wrote
        assertEq(ws.balances(alice), 500, "Mapping value should match raw slot write");
    }

    function test_OverwriteSlot() public {
        bytes32 slot = bytes32(uint256(50));

        ws.write(slot, bytes32(uint256(1)));
        assertEq(ws.read(slot), bytes32(uint256(1)));

        ws.write(slot, bytes32(uint256(2)));
        assertEq(ws.read(slot), bytes32(uint256(2)), "Should overwrite previous value");
    }

    function testFuzz_WriteAndRead(bytes32 slot, bytes32 value) public {
        ws.write(slot, value);
        assertEq(ws.read(slot), value);
    }
}
