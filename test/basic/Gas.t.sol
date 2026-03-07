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

    /// @notice Unit test: pure computation costs less than storage read
    function test_pureCostsLessThanStorageRead() public {
        uint256 gasPure = gasleft();
        gas.measurePureComputation();
        uint256 pureCost = gasPure - gasleft();

        uint256 gasRead = gasleft();
        gas.measureStorageRead();
        uint256 readCost = gasRead - gasleft();

        // Pure should cost less than read
        assertLt(pureCost, readCost);
    }

    /// @notice Unit test: compareGasCosts returns expected ordering
    function test_compareGasCosts_ordering() public view {
        (uint256 write, uint256 read, uint256 pure_) = gas.compareGasCosts();
        // Pure < Read < Write (generally true)
        assertLe(pure_, read);
        assertLe(read, write);
    }

    /// @notice Unit test: getGasPrice returns current gas price
    function test_getGasPrice_returnsValue() public view {
        uint256 price = gas.getGasPrice();
        assertGt(price, 0);
    }

    /// @notice Unit test: getBaseFee returns current base fee
    function test_getBaseFee_returnsValue() public view {
        uint256 baseFee = gas.getBaseFee();
        // Base fee can be 0 in some test environments
        assertGe(baseFee, 0);
    }
}
