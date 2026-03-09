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
    /// @param _text The todo text
    function create(string calldata _text) external {
        uint256 id = todos.length;
        todos.push(Todo({
            text: _text,
            completed: false
        }));
        emit TodoCreated(id, _text);
    }

    /// @notice Gets a todo by index
    /// @param _index The todo index
    function get(uint256 _index) external view returns (Todo memory) {
        require(_index < todos.length, "Index out of bounds");
        return todos[_index];
    }

    /// @notice Updates todo text
    /// @param _index The todo index
    /// @param _text New text
    function updateText(uint256 _index, string calldata _text) external {
        require(_index < todos.length, "Index out of bounds");
        Todo storage todo = todos[_index];
        todo.text = _text;
    }

    /// @notice Toggles completion status
    /// @param _index The todo index
    function toggleCompleted(uint256 _index) external {
        require(_index < todos.length, "Index out of bounds");
        Todo storage todo = todos[_index];
        todo.completed = !todo.completed;
        emit TodoToggled(_index, todo.completed);
    }

    /// @notice Gets the number of todos
    function getLength() external view returns (uint256) {
        return todos.length;
    }

    /// @notice Alternative syntax for creating struct
    function createAlternative(string calldata _text) external {
        uint256 id = todos.length;
        todos.push(Todo(_text, false));
        emit TodoCreated(id, _text);
    }
}
