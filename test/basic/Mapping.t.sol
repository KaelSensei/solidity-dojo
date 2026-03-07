// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Mapping} from "../../src/basic/Mapping.sol";

contract MappingTest is Test {
    Mapping public mappingContract;

    function setUp() public {
        mappingContract = new Mapping();
    }

    /// @notice Unit test: unset key returns 0
    function test_unsetKey_returnsZero() public view {
        assertEq(mappingContract.balances(address(0x1234)), 0);
        assertEq(mappingContract.get(address(0x1234)), 0);
    }

    /// @notice Unit test: set then get returns value
    function test_setThenGet_returnsValue() public {
        address addr = address(0x1234);
        uint256 value = 100;

        mappingContract.set(addr, value);
        assertEq(mappingContract.get(addr), value);
        assertEq(mappingContract.balances(addr), value);
    }

    /// @notice Unit test: delete resets to 0
    function test_delete_resetsToZero() public {
        address addr = address(0x1234);

        mappingContract.set(addr, 100);
        assertEq(mappingContract.get(addr), 100);

        mappingContract.remove(addr);
        assertEq(mappingContract.get(addr), 0);
    }

    /// @notice Fuzz test: set and get any address and value
    function testFuzz_set_get(address key, uint256 val) public {
        mappingContract.set(key, val);
        assertEq(mappingContract.get(key), val);
    }

    /// @notice Unit test: nested mapping works correctly
    function test_nestedMapping() public {
        address owner = address(0x1);
        address spender = address(0x2);

        // Initially not approved
        assertFalse(mappingContract.checkApproval(owner, spender));

        // Set approval
        mappingContract.setApproval(owner, spender, true);
        assertTrue(mappingContract.checkApproval(owner, spender));

        // Remove approval
        mappingContract.setApproval(owner, spender, false);
        assertFalse(mappingContract.checkApproval(owner, spender));
    }

    /// @notice Unit test: different keys have independent values
    function test_independentKeys() public {
        address addr1 = address(0x1);
        address addr2 = address(0x2);

        mappingContract.set(addr1, 100);
        mappingContract.set(addr2, 200);

        assertEq(mappingContract.get(addr1), 100);
        assertEq(mappingContract.get(addr2), 200);
    }
}
