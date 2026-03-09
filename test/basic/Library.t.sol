// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {LibraryUser} from "../../src/basic/Library.sol";

/// @title LibraryTest
/// @notice Tests for Library contract
contract LibraryTest is Test {
    LibraryUser public libraryUser;

    function setUp() public {
        libraryUser = new LibraryUser();
    }

    /// @notice Test safe add
    function test_SafeAdd() public view {
        assertEq(libraryUser.safeAdd(5, 3), 8);
    }

    /// @notice Test get max
    function test_GetMax() public view {
        assertEq(libraryUser.getMax(10, 5), 10);
        assertEq(libraryUser.getMax(5, 10), 10);
    }

    /// @notice Test find number
    function test_FindNumber() public {
        libraryUser.addNumber(10);
        libraryUser.addNumber(20);
        libraryUser.addNumber(30);
        
        assertEq(libraryUser.findNumber(20), 1);
        assertEq(libraryUser.findNumber(99), 3); // Not found, returns length
    }

    /// @notice Test remove at index
    function test_RemoveAt() public {
        libraryUser.addNumber(10);
        libraryUser.addNumber(20);
        libraryUser.addNumber(30);
        
        libraryUser.removeAt(1); // Remove 20
        
        assertEq(libraryUser.numbers(1), 30); // Last element moved to index 1
    }
}
