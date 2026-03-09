// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/hacks/OracleManipulation.sol";

/// @title Oracle Manipulation Test Suite
contract OracleManipulationTest is Test {
    VulnerableOracle public oracle;
    SimpleToken public tokenA;
    SimpleToken public tokenB;

    address public attacker = address(0x1);
    address public victim = address(0x2);

    function setUp() public {
        tokenA = new SimpleToken("Token A", "TKA", 18);
        tokenB = new SimpleToken("Token B", "TKB", 18);
        
        oracle = new VulnerableOracle(address(tokenA), address(tokenB));
        
        // Setup initial liquidity
        tokenA.mint(address(oracle), 1000e18);
        tokenB.mint(address(oracle), 1000e18);
        
        // Initial price: 1000 / 1000 = 1
        oracle.updatePrice();
    }

    /// @notice Test oracle price can be manipulated
    function test_OraclePriceManipulation() public {
        // Attacker adds massive liquidity to manipulate price
        tokenA.mint(attacker, 10000e18);
        tokenB.mint(attacker, 100e18);
        
        vm.startPrank(attacker);
        tokenA.transfer(address(oracle), 10000e18);
        tokenB.transfer(address(oracle), 100e18);
        
        // Update price - now it's 1100 / 10000 = 0.11 (manipulated!)
        oracle.updatePrice();
        
        uint256 price = oracle.getPrice();
        
        // Price was manipulated
        assertTrue(price < 100);
        
        vm.stopPrank();
    }

    /// @notice Test swap affects price
    function test_SwapAffectsPrice() public {
        uint256 priceBefore = oracle.getPrice();
        
        vm.prank(attacker);
        tokenA.mint(attacker, 100e18);
        
        vm.startPrank(attacker);
        tokenA.approve(address(oracle), 100e18);
        oracle.swapAForB(100e18);
        
        oracle.updatePrice();
        
        uint256 priceAfter = oracle.getPrice();
        
        // Price should change after swap
        assertTrue(priceAfter != priceBefore);
        
        vm.stopPrank();
    }

    /// @notice Test get price works
    function test_GetPrice() public {
        uint256 price = oracle.getPrice();
        assertEq(price, 1); // Initial price 1000 / 1000
    }
}
