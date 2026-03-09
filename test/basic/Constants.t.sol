// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Constants, NonConstant} from "../../src/basic/Constants.sol";

contract ConstantsTest is Test {
    Constants public constants;
    NonConstant public nonConstant;

    function setUp() public {
        constants = new Constants();
        nonConstant = new NonConstant();
    }

    /// @notice Unit test: MY_ADDRESS constant is correct
    function test_myAddress_isCorrect() public view {
        assertEq(
            constants.MY_ADDRESS(),
            0x777788889999AaAAbBbbCcccddDdeeeEfFFfCcCc
        );
    }

    /// @notice Unit test: MY_UINT constant is correct
    function test_myUint_isCorrect() public view {
        assertEq(constants.MY_UINT(), 123);
    }

    /// @notice Unit test: BASIS_POINTS constant is 10000
    function test_basisPoints_is10000() public view {
        assertEq(constants.BASIS_POINTS(), 10000);
    }

    /// @notice Unit test: MAX_SUPPLY constant is correct
    function test_maxSupply_isCorrect() public view {
        assertEq(constants.MAX_SUPPLY(), 1_000_000 * 10 ** 18);
    }

    /// @notice Unit test: getConstant returns correct value
    function test_getConstant_returnsCorrect() public view {
        assertEq(constants.getConstant(), 123);
    }

    /// @notice Unit test: calculatePercentage works correctly
    function test_calculatePercentage_works() public view {
        // 5% of 1000 = 50
        assertEq(constants.calculatePercentage(1000, 500), 50);
        // 1% of 10000 = 100
        assertEq(constants.calculatePercentage(10000, 100), 100);
        // 100% of 500 = 500
        assertEq(constants.calculatePercentage(500, 10000), 500);
    }


    /// @notice Unit test: gas comparison between constant and storage
    /// @dev Demonstrates that constants use less gas than storage reads
    function test_gas_constantVsStorage() public {
        uint256 gasConstant = gasleft();
        constants.getConstant();
        uint256 gasUsedConstant = gasConstant - gasleft();

        uint256 gasStorage = gasleft();
        nonConstant.getValue();
        uint256 gasUsedStorage = gasStorage - gasleft();

        // Constant should use significantly less gas
        assertLt(gasUsedConstant, gasUsedStorage);
    }
}
