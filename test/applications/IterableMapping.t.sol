// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {IterableMap} from "src/applications/IterableMapping.sol";

contract IterableMappingTest is Test {
    IterableMap public map;

    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");

    function setUp() public {
        map = new IterableMap();
    }

    /// @notice Test set adds key to array
    function test_SetAddsKeyToArray() public {
        map.set(user1, 100);

        assertTrue(map.contains(user1));
        assertEq(map.get(user1), 100);
        assertEq(map.length(), 1);
    }

    /// @notice Test set updates existing key
    function test_SetUpdatesExisting() public {
        map.set(user1, 100);
        map.set(user1, 200);

        assertEq(map.get(user1), 200);
        assertEq(map.length(), 1); // Should not increase
    }

    /// @notice Test remove deletes key from array
    function test_RemoveDeletesKey() public {
        map.set(user1, 100);
        map.set(user2, 200);

        map.remove(user1);

        assertFalse(map.contains(user1));
        assertEq(map.length(), 1);
    }

    /// @notice Test can iterate all keys
    function test_CanIterateAllKeys() public {
        map.set(user1, 100);
        map.set(user2, 200);
        map.set(user3, 300);

        assertEq(map.length(), 3);

        // Iterate and sum values
        uint256 total;
        for (uint256 i = 0; i < map.length(); i++) {
            address key = map.keyAt(i);
            total += map.valueAt(i);
        }

        assertEq(total, 600);
    }

    /// @notice Test keyAt returns correct key
    function test_KeyAt() public {
        map.set(user1, 100);
        map.set(user2, 200);

        assertEq(map.keyAt(0), user1);
        assertEq(map.keyAt(1), user2);
    }

    /// @notice Test valueAt returns correct value
    function test_ValueAt() public {
        map.set(user1, 100);
        map.set(user2, 200);

        assertEq(map.valueAt(0), 100);
        assertEq(map.valueAt(1), 200);
    }

    /// @notice Test getKeys returns all keys
    function test_GetKeys() public {
        map.set(user1, 100);
        map.set(user2, 200);

        address[] memory keys = map.getKeys();
        assertEq(keys.length, 2);
    }

    /// @notice Test multiple operations
    function test_MultipleOperations() public {
        // Add three
        map.set(user1, 10);
        map.set(user2, 20);
        map.set(user3, 30);
        assertEq(map.length(), 3);

        // Remove middle
        map.remove(user2);
        assertEq(map.length(), 2);
        assertFalse(map.contains(user2));

        // Add again
        map.set(user2, 25);
        assertEq(map.length(), 3);
    }
}
