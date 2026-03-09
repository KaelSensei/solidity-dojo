// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {FunctionSelector} from "../../src/basic/FunctionSelector.sol";

/// @title FunctionSelectorTest
/// @notice Tests for FunctionSelector contract
contract FunctionSelectorTest is Test {
    FunctionSelector public selectorContract;

    function setUp() public {
        selectorContract = new FunctionSelector();
    }

    /// @notice Test transfer selector
    function test_GetTransferSelector() public view {
        bytes4 expected = bytes4(keccak256("transfer(address,uint256)"));
        assertEq(selectorContract.getTransferSelector(), expected);
    }

    /// @notice Test compute selector
    function test_ComputeSelector() public view {
        bytes4 expected = bytes4(keccak256("transfer(address,uint256)"));
        assertEq(selectorContract.computeSelector("transfer(address,uint256)"), expected);
    }

    /// @notice Test get selector from data
    function test_GetSelectorFromData() public view {
        bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", address(0), 100);
        assertEq(selectorContract.getSelectorFromData(data), bytes4(keccak256("transfer(address,uint256)")));
    }

    /// @notice Test common selectors
    function test_CommonSelectors() public view {
        (bytes4 transfer, bytes4 approve, bytes4 transferFrom, bytes4 balanceOf) = selectorContract.commonSelectors();
        assertEq(transfer, bytes4(keccak256("transfer(address,uint256)")));
        assertEq(approve, bytes4(keccak256("approve(address,uint256)")));
        assertEq(transferFrom, bytes4(keccak256("transferFrom(address,address,uint256)")));
        assertEq(balanceOf, bytes4(keccak256("balanceOf(address)")));
    }

    /// @notice Test get my selector
    function test_GetMySelector() public view {
        bytes4 expected = bytes4(keccak256("testFunction(uint256,address)"));
        assertEq(selectorContract.getMySelector(), expected);
    }
}
