// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Structs
/// @notice Demonstrates struct declarations and usage.
/// @dev Structs can be stored in storage, memory, or calldata.
contract Structs {
    /// @notice Todo struct with text and completion status
    struct Todo {
        string text;
        bool completed;
    }

    /// @notice Array of todos
    Todo[] public todos;

    /// @notice Emitted when a todo is created
    event TodoCreated(uint256 indexed id, string text);

    /// @notice Emitted when a todo is toggled
    event TodoToggled(uint256 indexed id, bool completed);

    /// @notice Creates a new todo
    function create(string calldata text) external {
        todos.push(Todo({
            text: text,
            completed: false
        }));
        emit TodoCreated(todos.length - 1, text);
    }

    /// @notice Gets a todo by index
    function get(uint256 index) external view returns (Todo memory) {
        require(index < todos.length, "Index out of bounds");
        return todos[index];
    }

    /// @notice Updates todo text
    function updateText(uint256 index, string calldata text) external {
        require(index < todos.length, "Index out of bounds");
        Todo storage todo = todos[index];
        todo.text = text;
    }

    /// @notice Toggles completion status
    function toggleCompleted(uint256 index) external {
        require(index < todos.length, "Index out of bounds");
        Todo storage todo = todos[index];
        todo.completed = !todo.completed;
        emit TodoToggled(index, todo.completed);
    }

    /// @notice Gets the number of todos
    function getLength() external view returns (uint256) {
        return todos.length;
    }

    /// @notice Alternative syntax for creating struct
    function createAlternative(string calldata text) external {
        // Using positional arguments instead of named
        todos.push(Todo(text, false));
        emit TodoCreated(todos.length - 1, text);
    }
}


