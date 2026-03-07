// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {EtherUnits} from "../../src/basic/EtherUnits.sol";

contract EtherUnitsTest is Test {
    EtherUnits public etherUnits;
    address public alice = address(0x1);

    function setUp() public {
        etherUnits = new EtherUnits();
    }

    /// @notice Unit test: 1 wei equals 1
    function test_oneWei_equalsOne() public view {
        assertEq(etherUnits.oneWei(), 1);
    }

    /// @notice Unit test: 1 gwei equals 10^9
    function test_oneGwei_equals1e9() public view {
        assertEq(etherUnits.oneGwei(), 1e9);
    }

    /// @notice Unit test: 1 ether equals 10^18
    function test_oneEther_equals1e18() public view {
        assertEq(etherUnits.oneEther(), 1e18);
    }

    /// @notice Unit test: vm.deal sets balance correctly
    function test_vmDeal_setsBalance() public {
        vm.deal(alice, 1 ether);
        assertEq(alice.balance, 1e18);
    }

    /// @notice Unit test: gweiToWei conversion is correct
    function test_gweiToWei_correct() public view {
        assertEq(etherUnits.gweiToWei(1), 1e9);
        assertEq(etherUnits.gweiToWei(5), 5e9);
        assertEq(etherUnits.gweiToWei(100), 100e9);
    }

    /// @notice Unit test: weiToEther conversion is correct
    function test_weiToEther_correct() public view {
        assertEq(etherUnits.weiToEther(1e18), 1);
        assertEq(etherUnits.weiToEther(5e18), 5);
        assertEq(etherUnits.weiToEther(0.5e18), 0);
    }

    /// @notice Unit test: gweiToEther conversion is correct
    function test_gweiToEther_correct() public view {
        assertEq(etherUnits.gweiToEther(1e9), 1); // 1e9 gwei = 1 ether
        assertEq(etherUnits.gweiToEther(5e8), 0); // 0.5e9 gwei = 0 ether (truncated)
    }

    /// @notice Unit test: contract can receive ether
    function test_receive_incrementsTotalReceived() public {
        uint256 amount = 1 ether;
        (bool success,) = address(etherUnits).call{value: amount}("");
        require(success, "Transfer failed");

        assertEq(etherUnits.totalReceived(), amount);
        assertEq(etherUnits.getBalance(), amount);
    }

    /// @notice Fuzz test: gwei to wei conversion doesn't overflow
    function testFuzz_wei_to_ether(uint64 gweiAmount) public view {
        uint256 weiAmount = etherUnits.gweiToWei(uint256(gweiAmount));
        // 1 gwei = 1e9 wei, max uint64 * 1e9 < 2^256, so no overflow
        assertEq(weiAmount, uint256(gweiAmount) * 1e9);
    }
}
