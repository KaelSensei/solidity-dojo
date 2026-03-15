// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/evm/StorageLayout.sol";

/// @title Storage Layout Test Suite
contract StorageLayoutTest is Test {
    StorageLayout public layout;

    function setUp() public {
        layout = new StorageLayout();
    }

    /// @notice Packed uint128 values share slot 0
    function test_PackedValuesInSameSlot() public {
        layout.setValues(100, 200, 0);

        bytes32 slot0 = layout.getSlot0();

        // Slot 0 should contain both a and b packed together
        // a (100) in lower 128 bits, b (200) in upper 128 bits
        uint256 packed = uint256(slot0);
        uint128 extractedA = uint128(packed);
        uint128 extractedB = uint128(packed >> 128);

        assertEq(extractedA, 100, "a should be in lower 128 bits of slot 0");
        assertEq(extractedB, 200, "b should be in upper 128 bits of slot 0");
    }

    /// @notice uint256 c occupies slot 1 by itself
    function test_Uint256InSeparateSlot() public {
        layout.setValues(0, 0, 999);

        bytes32 slot1 = layout.readSlot(1);
        assertEq(uint256(slot1), 999, "c should be stored in slot 1");
    }

    /// @notice Slot 0 is non-zero only when a or b are set
    function test_Slot0ReflectsPackedValues() public {
        // Initially slot 0 should be zero
        bytes32 slot0 = layout.getSlot0();
        assertEq(uint256(slot0), 0, "slot 0 should start at zero");

        layout.setValues(1, 0, 0);
        slot0 = layout.getSlot0();
        assertTrue(uint256(slot0) != 0, "slot 0 should be non-zero after setting a");
    }

    /// @notice Array length slot is correct and pushToArray updates it
    function test_ArrayLengthSlot() public {
        bytes32 arraySlot = layout.getArraySlot();
        // arr is the 5th state variable declaration but slot 3
        // (a+b share slot 0, c=slot 1, d=slot 2, arr=slot 3)
        assertEq(uint256(arraySlot), 3, "arr length should be at slot 3");

        // Initially length is 0
        bytes32 lengthData = layout.readSlot(3);
        assertEq(uint256(lengthData), 0, "array length starts at 0");

        // Push a value and verify length increases
        layout.pushToArray(42);
        lengthData = layout.readSlot(3);
        assertEq(uint256(lengthData), 1, "array length should be 1 after push");
    }

    /// @notice Array element slots follow keccak256(slot) + index pattern
    function test_ArrayElementSlots() public {
        layout.pushToArray(111);
        layout.pushToArray(222);
        layout.pushToArray(333);

        // Verify each element is at the computed slot
        for (uint256 i = 0; i < 3; i++) {
            bytes32 elementSlot = layout.getArrayElementSlot(i);
            bytes32 storedValue = layout.readSlot(uint256(elementSlot));
            uint256 expected = (i + 1) * 111;
            assertEq(uint256(storedValue), expected, "element at computed slot should match");
        }
    }

    /// @notice Mapping slot computation matches keccak256(key . slot)
    function test_MappingSlotComputation() public {
        address alice = makeAddr("alice");
        layout.setMapping(alice, 500);

        // Compute expected slot: keccak256(abi.encode(alice, 4))
        // map is at slot 4
        bytes32 expectedSlot = keccak256(abi.encode(alice, uint256(4)));
        bytes32 computedSlot = layout.getMappingSlot(alice);

        assertEq(computedSlot, expectedSlot, "computed slot should match manual keccak256");

        // Verify the value is actually stored there
        bytes32 storedValue = layout.readSlot(uint256(computedSlot));
        assertEq(uint256(storedValue), 500, "value at mapping slot should be 500");
    }

    /// @notice Reading raw slots returns correct values
    function test_ReadRawSlots() public {
        layout.setValues(10, 20, 30);

        // Slot 0: packed a=10, b=20
        bytes32 slot0 = layout.readSlot(0);
        uint256 packed = uint256(slot0);
        assertEq(uint128(packed), 10);
        assertEq(uint128(packed >> 128), 20);

        // Slot 1: c=30
        bytes32 slot1 = layout.readSlot(1);
        assertEq(uint256(slot1), 30);

        // Slot 2: d=0 (not set)
        bytes32 slot2 = layout.readSlot(2);
        assertEq(uint256(slot2), 0);
    }

    /// @notice Multiple mapping keys store at different slots
    function test_MappingDifferentKeys() public {
        address alice = makeAddr("alice");
        address bob = makeAddr("bob");

        layout.setMapping(alice, 100);
        layout.setMapping(bob, 200);

        bytes32 aliceSlot = layout.getMappingSlot(alice);
        bytes32 bobSlot = layout.getMappingSlot(bob);

        // Different keys should produce different slots
        assertTrue(aliceSlot != bobSlot, "different keys should have different slots");

        // Values should be correct
        assertEq(uint256(layout.readSlot(uint256(aliceSlot))), 100);
        assertEq(uint256(layout.readSlot(uint256(bobSlot))), 200);
    }

    /// @notice Fuzz test: set and read back packed values
    function testFuzz_SetAndReadPackedValues(uint128 _a, uint128 _b, uint256 _c) public {
        layout.setValues(_a, _b, _c);

        bytes32 slot0 = layout.getSlot0();
        uint256 packed = uint256(slot0);
        assertEq(uint128(packed), _a, "a should round-trip through storage");
        assertEq(uint128(packed >> 128), _b, "b should round-trip through storage");

        bytes32 slot1 = layout.readSlot(1);
        assertEq(uint256(slot1), _c, "c should round-trip through storage");
    }

    /// @notice Fuzz test: push to array and verify element slot
    function testFuzz_PushAndVerifySlot(uint256 val) public {
        layout.pushToArray(val);

        bytes32 elementSlot = layout.getArrayElementSlot(0);
        bytes32 storedValue = layout.readSlot(uint256(elementSlot));
        assertEq(uint256(storedValue), val, "pushed value should be at computed element slot");
    }

    /// @notice Fuzz test: mapping slot computation is deterministic
    function testFuzz_MappingSlotDeterministic(address key, uint256 val) public {
        layout.setMapping(key, val);

        bytes32 slot = layout.getMappingSlot(key);
        bytes32 storedValue = layout.readSlot(uint256(slot));
        assertEq(uint256(storedValue), val, "mapping value should round-trip through storage");

        // Verify determinism: calling getMappingSlot again yields same result
        bytes32 slotAgain = layout.getMappingSlot(key);
        assertEq(slot, slotAgain, "slot computation should be deterministic");
    }
}
