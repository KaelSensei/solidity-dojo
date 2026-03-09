// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IterableMapping
/// @notice A mapping library that allows iteration over keys.
/// @dev Combines a mapping with an array to track keys for iteration.
library IterableMapping {
    /// @notice Iterable mapping structure
    struct It {
        // Mapping from address to value
        mapping(address => uint256) values;
        // Array of keys for iteration
        address[] keys;
        // Mapping from key to key index in the array
        mapping(address => uint256) keyIndices;
        // Track if a key exists
        mapping(address => bool) inserted;
    }

    /// @notice Set a value for a key
    /// @param self Mapping instance
    /// @param key Key to set
    /// @param value Value to set
    function set(
        It storage self,
        address key,
        uint256 value
    ) internal {
        if (!self.inserted[key]) {
            self.inserted[key] = true;
            self.keys.push(key);
            self.keyIndices[key] = self.keys.length - 1;
        }
        self.values[key] = value;
    }

    /// @notice Get value for a key
    /// @param self Mapping instance
    /// @param key Key to query
    /// @return Value for the key
    function get(
        It storage self,
        address key
    ) internal view returns (uint256) {
        return self.values[key];
    }

    /// @notice Get value for a key, or a default if not set
    /// @param self Mapping instance
    /// @param key Key to query
    /// @param defaultValue Value to return if key not set
    /// @return Value for the key or default
    function getOr(
        It storage self,
        address key,
        uint256 defaultValue
    ) internal view returns (uint256) {
        return self.inserted[key] ? self.values[key] : defaultValue;
    }

    /// @notice Remove a key from the mapping
    /// @param self Mapping instance
    /// @param key Key to remove
    function remove(
        It storage self,
        address key
    ) internal {
        if (!self.inserted[key]) {
            return;
        }

        delete self.inserted[key];
        delete self.values[key];

        uint256 index = self.keyIndices[key];
        uint256 lastIndex = self.keys.length - 1;
        address lastKey = self.keys[lastIndex];

        // Move last key to the removed position
        self.keys[index] = lastKey;
        self.keyIndices[lastKey] = index;

        // Remove last element
        self.keys.pop();
        delete self.keyIndices[key];
    }

    /// @notice Get number of keys
    /// @param self Mapping instance
    /// @return Number of keys
    function length(
        It storage self
    ) internal view returns (uint256) {
        return self.keys.length;
    }

    /// @notice Get key at index
    /// @param self Mapping instance
    /// @param index Index to query
    /// @return Key at the given index
    function keyAt(
        It storage self,
        uint256 index
    ) internal view returns (address) {
        return self.keys[index];
    }

    /// @notice Get value at index
    /// @param self Mapping instance
    /// @param index Index to query
    /// @return Value at the given index
    function valueAt(
        It storage self,
        uint256 index
    ) internal view returns (uint256) {
        address key = self.keys[index];
        return self.values[key];
    }

    /// @notice Check if key exists
    /// @param self Mapping instance
    /// @param key Key to check
    /// @return True if key exists
    function contains(
        It storage self,
        address key
    ) internal view returns (bool) {
        return self.inserted[key];
    }

    /// @notice Get all keys as an array
    /// @param self Mapping instance
    /// @return Array of all keys
    function getKeys(
        It storage self
    ) internal view returns (address[] memory) {
        return self.keys;
    }
}

/// @title IterableMap
/// @notice Contract that uses the IterableMapping library.
contract IterableMap {
    using IterableMapping for IterableMapping.It;

    /// @notice Iterable mapping instance
    IterableMapping.It private map;

    /// @notice Event when a value is set
    event ValueSet(address indexed key, uint256 value);

    /// @notice Event when a value is removed
    event ValueRemoved(address indexed key);

    /// @notice Set a value for an address
    /// @param key Address key
    /// @param value Value to set
    function set(address key, uint256 value) external {
        map.set(key, value);
        emit ValueSet(key, value);
    }

    /// @notice Get value for an address
    /// @param key Address key
    /// @return Value for the address
    function get(address key) external view returns (uint256) {
        return map.get(key);
    }

    /// @notice Remove a key
    /// @param key Address key to remove
    function remove(address key) external {
        map.remove(key);
        emit ValueRemoved(key);
    }

    /// @notice Get number of entries
    /// @return Number of entries
    function length() external view returns (uint256) {
        return map.length();
    }

    /// @notice Get key at index
    /// @param index Index
    /// @return Key at index
    function keyAt(uint256 index) external view returns (address) {
        return map.keyAt(index);
    }

    /// @notice Get value at index
    /// @param index Index
    /// @return Value at index
    function valueAt(uint256 index) external view returns (uint256) {
        return map.valueAt(index);
    }

    /// @notice Check if key exists
    /// @param key Key to check
    /// @return True if exists
    function contains(address key) external view returns (bool) {
        return map.contains(key);
    }

    /// @notice Get all keys
    /// @return Array of keys
    function getKeys() external view returns (address[] memory) {
        return map.getKeys();
    }
}
