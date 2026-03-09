// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {PrivateData} from "../../src/basic/PrivateData.sol";

/// @title PrivateDataTest
/// @notice Tests for PrivateData contract
contract PrivateDataTest is Test {
    PrivateData public privateData;

    function setUp() public {
        privateData = new PrivateData();
    }

    /// @notice Test private number accessible via getter
    function test_GetSecretNumber() public view {
        assertEq(privateData.getSecretNumber(), 42);
    }

    /// @notice Test array length
    function test_GetArrayLength() public view {
        assertEq(privateData.getArrayLength(), 3);
    }

    /// @notice Test balance mapping
    function test_GetBalance() public view {
        assertEq(privateData.getBalance(address(this)), 1000);
    }

    /// @notice Demonstrate reading private storage directly
    function test_ReadPrivateStorage() public view {
        // Slot 0: secretNumber (uint256)
        bytes32 slot0Value = vm.load(address(privateData), bytes32(uint256(0)));
        assertEq(uint256(slot0Value), 42);
    }
}
