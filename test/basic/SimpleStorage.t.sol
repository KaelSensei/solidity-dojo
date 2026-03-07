// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {SimpleStorage} from "../../src/basic/SimpleStorage.sol";

contract SimpleStorageTest is Test {
    SimpleStorage public storageContract;

    function setUp() public {
        storageContract = new SimpleStorage();
    }

    /// @notice Unit test: set then get returns same value
    function test_setThenGet_returnsSameValue() public {
        uint256 value = 42;
        storageContract.set(value);
        assertEq(storageContract.get(), value);
        assertEq(storageContract.num(), value);
    }

    /// @notice Unit test: multiple sets, final get returns last value
    function test_multipleSets_finalValueCorrect() public {
        storageContract.set(10);
        storageContract.set(20);
        storageContract.set(30);
        assertEq(storageContract.get(), 30);
    }

    /// @notice Fuzz test: set any value, get returns the same
    function testFuzz_set_get(uint256 x) public {
        storageContract.set(x);
        assertEq(storageContract.get(), x);
        assertEq(storageContract.num(), x);
    }

    /// @notice Invariant test: get() reflects last set value
    uint256 public lastSetValue;

    function invariant_get_reflects_last_set() public view {
        assertEq(storageContract.num(), lastSetValue);
    }
}
