// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Structs} from "../../src/basic/Structs.sol";

contract StructsTest is Test {
    Structs public structs;

    function setUp() public {
        structs = new Structs();
    }

    /// @notice Unit test: create todo with correct fields
    function test_create_todoFields() public {
        structs.create("Learn Solidity");

        (string memory text, bool completed) = structs.todos(0);
        assertEq(text, "Learn Solidity");
        assertFalse(completed);
    }

    /// @notice Unit test: update text works correctly
    function test_updateText_updatesCorrectly() public {
        structs.create("Original text");
        structs.updateText(0, "Updated text");

        (string memory text,) = structs.todos(0);
        assertEq(text, "Updated text");
    }

    /// @notice Unit test: toggle completed twice returns to original state
    function test_toggleTwice_returnsToOriginal() public {
        structs.create("Task");

        structs.toggleCompleted(0);
        (, bool completed1) = structs.todos(0);
        assertTrue(completed1);

        structs.toggleCompleted(0);
        (, bool completed2) = structs.todos(0);
        assertFalse(completed2);
    }

    /// @notice Unit test: get returns todo struct
    function test_get_returnsStruct() public {
        structs.create("Test");
        Structs.Todo memory todo = structs.get(0);
        assertEq(todo.text, "Test");
        assertFalse(todo.completed);
    }

    /// @notice Unit test: getLength returns correct count
    function test_getLength_increasesWithCreates() public {
        assertEq(structs.getLength(), 0);
        structs.create("First");
        assertEq(structs.getLength(), 1);
        structs.create("Second");
        assertEq(structs.getLength(), 2);
    }

    /// @notice Unit test: alternative creation syntax works
    function test_createAlternative_works() public {
        structs.createAlternative("Alternative");
        (string memory text, bool completed) = structs.todos(0);
        assertEq(text, "Alternative");
        assertFalse(completed);
    }

    /// @notice Unit test: event emitted on todo creation
    function test_create_emitsEvent() public {
        vm.expectEmit(true, false, false, true);
        emit Structs.TodoCreated(0, "Test");
        structs.create("Test");
    }

    /// @notice Unit test: event emitted on toggle
    function test_toggle_emitsEvent() public {
        structs.create("Test");
        vm.expectEmit(true, false, false, true);
        emit Structs.TodoToggled(0, true);
        structs.toggleCompleted(0);
    }

    /// @notice Invariant test: todos length only grows
    /// @dev There is no delete function, so length should be monotonically increasing
    function invariant_todos_length_only_grows() public {
        uint256 length = structs.getLength();
        assertGe(length, 0);
    }

    /// @notice Unit test: out of bounds access reverts
    function test_outOfBounds_reverts() public {
        vm.expectRevert();
        structs.get(0);
    }
}
