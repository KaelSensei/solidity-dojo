// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title DataLocations
/// @notice Demonstrates storage, memory, and calldata data locations.
/// @dev Storage: persistent state. Memory: temporary, mutable. Calldata: temporary, immutable (external calls).
contract DataLocations {
    /// @notice Stored permanently on blockchain
    uint256[] public storageArray;

    /// @notice Adds values to storage array
    /// @param _values Values to store
    function addToStorage(uint256[] calldata _values) external {
        for (uint256 i = 0; i < _values.length; i++) {
            storageArray.push(_values[i]);
        }
    }

    /// @notice Modifies storage via reference - changes persist
    /// @param _newValue New value to set
    function modifyStorageReference(uint256 _newValue) external {
        // storageRef is a reference to storageArray[0]
        uint256[] storage storageRef = storageArray;
        if (storageRef.length > 0) {
            storageRef[0] = _newValue; // Modifies actual storage
        }
    }

    /// @notice Creates memory copy - changes don't persist to storage
    /// @param _index Index to modify in memory
    /// @param _newValue New value to set
    /// @return The modified memory array (not stored)
    function modifyMemoryCopy(uint256 _index, uint256 _newValue) external view returns (uint256[] memory) {
        // memoryCopy is a COPY of storage data
        uint256[] memory memoryCopy = storageArray;
        if (_index < memoryCopy.length) {
            memoryCopy[_index] = _newValue; // Only modifies memory, not storage
        }
        return memoryCopy;
    }

    /// @notice Demonstrates calldata - read-only, gas efficient for external calls
    /// @param _data Calldata array (cannot be modified)
    /// @return Sum of all elements
    function sumCalldata(uint256[] calldata _data) external pure returns (uint256) {
        uint256 sum;
        for (uint256 i = 0; i < _data.length; i++) {
            sum += _data[i];
        }
        return sum;
    }

    /// @notice Demonstrates memory - mutable temporary copy
    /// @param _data Memory array (can be modified)
    /// @return Doubled values
    function doubleMemory(uint256[] memory _data) external pure returns (uint256[] memory) {
        for (uint256 i = 0; i < _data.length; i++) {
            _data[i] *= 2;
        }
        return _data;
    }

    /// @notice Returns storage array length
    function getLength() external view returns (uint256) {
        return storageArray.length;
    }

    /// @notice Returns element at index from storage
    /// @param _index Index to retrieve
    function getFromStorage(uint256 _index) external view returns (uint256) {
        require(_index < storageArray.length, "Index out of bounds");
        return storageArray[_index];
    }
}
