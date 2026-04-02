// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title DataLocations
/// @notice Demonstrates storage, memory, and calldata data locations.
/// @dev Storage: persistent state. Memory: temporary, mutable. Calldata: temporary, immutable (external calls).
contract DataLocations {
    /// @notice Stored permanently on blockchain
    uint256[] public storageArray;

    /// @notice Adds values to storage array
    function addToStorage(uint256[] calldata values) external {
        for (uint256 i = 0; i < values.length; i++) {
            storageArray.push(values[i]);
        }
    }

    /// @notice Modifies storage via reference - changes persist
    function modifyStorageReference(uint256 newValue) external {
        // storageRef is a reference to storageArray[0]
        uint256[] storage storageRef = storageArray;
        if (storageRef.length > 0) {
            storageRef[0] = newValue; // Modifies actual storage
        }
    }

    /// @notice Creates memory copy - changes don't persist to storage
    /// @return The modified memory array (not stored)
    function modifyMemoryCopy(uint256 index, uint256 newValue) external view returns (uint256[] memory) {
        // memoryCopy is a COPY of storage data
        uint256[] memory memoryCopy = storageArray;
        if (index < memoryCopy.length) {
            memoryCopy[index] = newValue; // Only modifies memory, not storage
        }
        return memoryCopy;
    }

    /// @notice Demonstrates calldata - read-only, gas efficient for external calls
    /// @return Sum of all elements
    function sumCalldata(uint256[] calldata data) external pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < data.length; i++) {
            sum += data[i];
        }
        return sum;
    }

    /// @notice Demonstrates memory - mutable temporary copy
    /// @return Doubled values
    function doubleMemory(uint256[] memory data) external pure returns (uint256[] memory) {
        for (uint256 i = 0; i < data.length; i++) {
            data[i] *= 2;
        }
        return data;
    }

    /// @notice Returns storage array length
    function getLength() external view returns (uint256) {
        return storageArray.length;
    }

    /// @notice Returns element at index from storage
    function getFromStorage(uint256 index) external view returns (uint256) {
        require(index < storageArray.length, "Index out of bounds");
        return storageArray[index];
    }
}


