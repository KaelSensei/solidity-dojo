// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Variables} from "../../src/basic/Variables.sol";

contract VariablesTest is Test {
    Variables public vars;
    address public alice = address(0x1);

    function setUp() public {
        vars = new Variables();
    }

    /// @notice Unit test: msg.sender returns the caller address
    function test_msgSender_returnsCaller() public {
        vm.prank(alice);
        (address sender,,,) = vars.getGlobalVars();
        assertEq(sender, alice);
    }

    /// @notice Unit test: block.timestamp returns the mocked timestamp
    function test_blockTimestamp_returnsMockedValue() public {
        uint256 mockTimestamp = 1000;
        vm.warp(mockTimestamp);
        (, uint256 timestamp,,) = vars.getGlobalVars();
        assertEq(timestamp, mockTimestamp);
    }

    /// @notice Unit test: block.number returns the mocked block number
    function test_blockNumber_returnsMockedValue() public {
        uint256 mockBlockNumber = 42;
        vm.roll(mockBlockNumber);
        (,, uint256 blockNum,) = vars.getGlobalVars();
        assertEq(blockNum, mockBlockNumber);
    }

    /// @notice Fuzz test: vm.warp works with any valid timestamp
    function testFuzz_timestamp(uint48 ts) public {
        vm.warp(uint256(ts));
        (, uint256 timestamp,,) = vars.getGlobalVars();
        assertEq(timestamp, uint256(ts));
    }

    /// @notice Unit test: state variable initialized correctly
    function test_stateVar_initializedCorrectly() public view {
        assertEq(vars.stateVar(), 123);
    }

    /// @notice Unit test: state variable can be updated
    function test_stateVar_canBeUpdated() public {
        vars.setStateVar(456);
        assertEq(vars.stateVar(), 456);
    }

    /// @notice Unit test: local variables work correctly
    function test_localVars_workCorrectly() public view {
        uint256 input = 10;
        // (10 * 2) + (10 + 10) = 20 + 20 = 40
        assertEq(vars.useLocalVar(input), 40);
    }
}
