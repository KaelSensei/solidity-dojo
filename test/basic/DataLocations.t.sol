// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {DataLocations} from "../../src/basic/DataLocations.sol";

/// @title DataLocationsTest
/// @notice Tests for DataLocations contract
contract DataLocationsTest is Test {
    DataLocations public dataLocations;

    function setUp() public {
        dataLocations = new DataLocations();
    }

    /// @notice Test adding values to storage
    function test_AddToStorage() public {
        uint256[] memory values = new uint256[](3);
        values[0] = 10;
        values[1] = 20;
        values[2] = 30;

        dataLocations.addToStorage(values);

        assertEq(dataLocations.getLength(), 3);
        assertEq(dataLocations.getFromStorage(0), 10);
        assertEq(dataLocations.getFromStorage(1), 20);
        assertEq(dataLocations.getFromStorage(2), 30);
    }

    /// @notice Test that modifying storage reference updates actual storage
    function test_ModifyStorageReference_UpdatesState() public {
        uint256[] memory values = new uint256[](3);
        values[0] = 10;
        values[1] = 20;
        values[2] = 30;
        dataLocations.addToStorage(values);

        dataLocations.modifyStorageReference(99);

        assertEq(dataLocations.getFromStorage(0), 99); // Storage was modified
        assertEq(dataLocations.getFromStorage(1), 20); // Other elements unchanged
    }

    /// @notice Test that memory copy does not affect storage
    function test_ModifyMemoryCopy_DoesNotAffectStorage() public {
        uint256[] memory values = new uint256[](3);
        values[0] = 10;
        values[1] = 20;
        values[2] = 30;
        dataLocations.addToStorage(values);

        uint256[] memory result = dataLocations.modifyMemoryCopy(0, 99);

        // Memory copy was modified
        assertEq(result[0], 99);
        // But storage remains unchanged
        assertEq(dataLocations.getFromStorage(0), 10);
    }

    /// @notice Test calldata sum calculation
    function test_SumCalldata() public view {
        uint256[] memory data = new uint256[](4);
        data[0] = 1;
        data[1] = 2;
        data[2] = 3;
        data[3] = 4;

        uint256 sum = dataLocations.sumCalldata(data);
        assertEq(sum, 10);
    }

    /// @notice Test memory doubling
    function test_DoubleMemory() public view {
        uint256[] memory data = new uint256[](3);
        data[0] = 5;
        data[1] = 10;
        data[2] = 15;

        uint256[] memory result = dataLocations.doubleMemory(data);

        assertEq(result[0], 10);
        assertEq(result[1], 20);
        assertEq(result[2], 30);
    }

    /// @notice Test sum with empty calldata
    function test_SumCalldata_Empty() public view {
        uint256[] memory data = new uint256[](0);
        uint256 sum = dataLocations.sumCalldata(data);
        assertEq(sum, 0);
    }
}
