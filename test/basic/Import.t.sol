// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Import} from "../../src/basic/Import.sol";
import {Events} from "../../src/basic/Events.sol";

/// @title ImportTest
/// @notice Tests for Import contract
contract ImportTest is Test {
    Import public importContract;
    Events public eventsContract;

    function setUp() public {
        importContract = new Import();
        eventsContract = new Events();
    }

    /// @notice Test can set imported contract address
    function test_SetEventsContract() public {
        importContract.setEventsContract(address(eventsContract));
        assertEq(address(importContract.eventsContract()), address(eventsContract));
    }

    /// @notice Test can use imported contract
    function test_UseImported() public {
        importContract.setEventsContract(address(eventsContract));
        assertEq(importContract.useImported(), address(eventsContract));
    }
}
