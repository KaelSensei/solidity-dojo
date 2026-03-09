// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Immutable, ImmutableWithDefault} from "../../src/basic/Immutable.sol";

contract ImmutableTest is Test {
    Immutable public immutableContract;
    ImmutableWithDefault public immutableDefault;

    address public constant TEST_ADDR = address(0x1234);
    bytes32 public constant TEST_BYTES = keccak256("test");

    function setUp() public {
        immutableContract = new Immutable(42, TEST_ADDR, TEST_BYTES);
        immutableDefault = new ImmutableWithDefault();
    }

    /// @notice Unit test: MY_UINT matches constructor arg
    function test_myUint_matchesConstructor() public view {
        assertEq(immutableContract.MY_UINT(), 42);
    }

    /// @notice Unit test: MY_ADDRESS matches constructor arg
    function test_myAddress_matchesConstructor() public view {
        assertEq(immutableContract.MY_ADDRESS(), TEST_ADDR);
    }

    /// @notice Unit test: MY_BYTES32 matches constructor arg
    function test_myBytes32_matchesConstructor() public view {
        assertEq(immutableContract.MY_BYTES32(), TEST_BYTES);
    }

    /// @notice Unit test: getValues returns all immutables
    function test_getValues_returnsAll() public view {
        (uint256 u, address a, bytes32 b) = immutableContract.getValues();
        assertEq(u, 42);
        assertEq(a, TEST_ADDR);
        assertEq(b, TEST_BYTES);
    }

    /// @notice Unit test: different instances have independent values
    function test_independentInstances() public {
        Immutable second = new Immutable(999, address(0x5678), keccak256("other"));

        assertEq(immutableContract.MY_UINT(), 42);
        assertEq(second.MY_UINT(), 999);
        assertEq(immutableContract.MY_ADDRESS(), TEST_ADDR);
        assertEq(second.MY_ADDRESS(), address(0x5678));
    }

    /// @notice Fuzz test: constructor accepts any uint256 value
    function testFuzz_constructor(uint256 val) public {
        Immutable fuzz = new Immutable(val, address(0x1), bytes32(0));
        assertEq(fuzz.MY_UINT(), val);
    }

    /// @notice Unit test: default immutable value is preserved
    function test_defaultValue_preserved() public view {
        assertEq(immutableDefault.VALUE(), 100);
    }
}
