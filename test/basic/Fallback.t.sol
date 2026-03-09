// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Fallback} from "../../src/basic/Fallback.sol";

/// @title FallbackTest
/// @notice Tests for Fallback contract
contract FallbackTest is Test {
    Fallback public fallbackContract;

    function setUp() public {
        fallbackContract = new Fallback();
    }

    /// @notice Test receive is called on empty calldata
    function test_Receive() public {
        (bool success,) = address(fallbackContract).call{value: 1 ether}("");
        assertTrue(success);
        assertEq(fallbackContract.receiveCount(), 1);
        assertEq(fallbackContract.getBalance(), 1 ether);
    }

    /// @notice Test fallback is called on unknown function
    function test_Fallback() public {
        (bool success,) = address(fallbackContract).call{value: 0.5 ether}(abi.encodeWithSignature("nonexistent()"));
        assertTrue(success);
        assertEq(fallbackContract.fallbackCount(), 1);
        assertEq(fallbackContract.getBalance(), 0.5 ether);
    }

    /// @notice Test fallback stores calldata
    function test_Fallback_StoresCalldata() public {
        bytes memory data = abi.encodeWithSignature("someFunction(uint256)", 123);
        (bool success,) = address(fallbackContract).call{value: 0.1 ether}(data);
        assertTrue(success);
        assertEq(fallbackContract.lastCalldata(), data);
    }

    receive() external payable {}
}
