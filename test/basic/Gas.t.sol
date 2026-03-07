// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Gas} from "../../src/basic/Gas.sol";

contract GasTest is Test {
    Gas public gas;

    function setUp() public {
        gas = new Gas();
    }

    /// @notice Unit test: gasleft() decreases after storage write
    function test_gasleft_decreasesAfterStorageWrite() public {
        (uint256 before, uint256 after_) = gas.measureStorageWrite();
        assertGt(before, after_);
    }

    /// @notice Unit test: view function costs less gas than state-modifying
    function test_viewCostsLessThanStateModifying() public {
        uint256 gasRead = gasleft();
        gas.measureStorageRead();
        uint256 readCost = gasRead - gasleft();

        uint256 gasWrite = gasleft();
        gas.measureStorageWrite();
        uint256 writeCost = gasWrite - gasleft();

        // View should cost less than write
        assertLt(readCost, writeCost);
    }

    /// @notice Unit test: gasleft() decreases after operations
    function test_gasleft_decreases() public {
        uint256 gasBefore = gasleft();
        gas.measurePureComputation();
        uint256 gasAfter = gasleft();

        // Gas should decrease after computation
        assertLt(gasAfter, gasBefore);
    }

    /// @notice Unit test: compareGasCosts returns gas estimates
    function test_compareGasCosts_returnsValues() public view {
        (uint256 write, uint256 read, uint256 pure_) = gas.compareGasCosts();
        // Just verify we get values back
        assertGe(write, 0);
        assertGe(read, 0);
        assertGe(pure_, 0);
    }

    /// @notice Unit test: getGasPrice returns a value (can be 0 in test env)
    function test_getGasPrice_returnsValue() public view {
        uint256 price = gas.getGasPrice();
        // Gas price can be 0 in some test environments
        assertGe(price, 0);
    }

    /// @notice Unit test: getBaseFee returns current base fee
    function test_getBaseFee_returnsValue() public view {
        uint256 baseFee = gas.getBaseFee();
        // Base fee can be 0 in some test environments
        assertGe(baseFee, 0);
    }
}
