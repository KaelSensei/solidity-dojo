// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Primitives} from "../../src/basic/Primitives.sol";

contract PrimitivesTest is Test {
    Primitives public primitives;

    function setUp() public {
        primitives = new Primitives();
    }

    /// @notice Unit test: boolean defaults to false
    function test_bool_defaultsToFalse() public view {
        assertEq(primitives.boo(), false);
    }

    /// @notice Unit test: uint256 defaults to 0
    function test_uint256_defaultsToZero() public view {
        assertEq(primitives.u256(), 0);
    }

    /// @notice Unit test: uint8 defaults to 0
    function test_uint8_defaultsToZero() public view {
        assertEq(primitives.u8(), 0);
    }

    /// @notice Unit test: int256 defaults to 0
    function test_int256_defaultsToZero() public view {
        assertEq(primitives.i256(), 0);
    }

    /// @notice Unit test: int8 defaults to 0
    function test_int8_defaultsToZero() public view {
        assertEq(primitives.i8(), 0);
    }

    /// @notice Unit test: address defaults to zero address
    function test_address_defaultsToZero() public view {
        assertEq(primitives.addr(), address(0));
    }

    /// @notice Unit test: bytes32 defaults to zero bytes
    function test_bytes32_defaultsToZero() public view {
        assertEq(primitives.b32(), bytes32(0));
    }

    /// @notice Fuzz test: uint256 is never negative (always >= 0)
    /// @dev This test demonstrates type safety - uint256 cannot hold negative values
    function testFuzz_uint256_never_negative(uint256 x) public pure {
        assertGe(x, 0);
    }

    /// @notice Unit test: int256 min value is correct
    function test_int256_min() public view {
        assertEq(primitives.getIntMin(), type(int256).min);
    }

    /// @notice Unit test: int256 max value is correct
    function test_int256_max() public view {
        assertEq(primitives.getIntMax(), type(int256).max);
    }

    /// @notice Unit test: uint256 max value is correct
    function test_uint256_max() public view {
        assertEq(primitives.getUintMax(), type(uint256).max);
    }
}
