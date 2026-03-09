// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/defi/ConstantProductAMM.sol";

/// @title Mock ERC20 for AMM tests
contract MockAMMToken {
    string public name;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name) { name = _name; }

    function mint(address to, uint256 amount) external { balanceOf[to] += amount; }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount);
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount);
        require(allowance[from][msg.sender] >= amount);
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

/// @title ConstantProductAMM Test Suite
contract ConstantProductAMMTest is Test {
    ConstantProductAMM public amm;
    MockAMMToken public tokenA;
    MockAMMToken public tokenB;

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    function setUp() public {
        tokenA = new MockAMMToken("TokenA");
        tokenB = new MockAMMToken("TokenB");
        amm = new ConstantProductAMM(address(tokenA), address(tokenB));

        tokenA.mint(alice, 100_000e18);
        tokenB.mint(alice, 100_000e18);
        tokenA.mint(bob, 100_000e18);
        tokenB.mint(bob, 100_000e18);

        vm.startPrank(alice);
        tokenA.approve(address(amm), type(uint256).max);
        tokenB.approve(address(amm), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(bob);
        tokenA.approve(address(amm), type(uint256).max);
        tokenB.approve(address(amm), type(uint256).max);
        vm.stopPrank();
    }

    function test_AddLiquidity() public {
        vm.prank(alice);
        uint256 shares = amm.addLiquidity(1000e18, 1000e18);

        assertGt(shares, 0);
        assertEq(amm.reserve0(), 1000e18);
        assertEq(amm.reserve1(), 1000e18);
        assertEq(amm.balanceOf(alice), shares);
    }

    function test_Swap() public {
        vm.prank(alice);
        amm.addLiquidity(10_000e18, 10_000e18);

        uint256 bobBalBefore = tokenB.balanceOf(bob);
        vm.prank(bob);
        uint256 amountOut = amm.swap(address(tokenA), 1000e18);

        assertGt(amountOut, 0);
        assertEq(tokenB.balanceOf(bob), bobBalBefore + amountOut);
    }

    function test_SwapFee() public {
        vm.prank(alice);
        amm.addLiquidity(10_000e18, 10_000e18);

        vm.prank(bob);
        uint256 amountOut = amm.swap(address(tokenA), 1000e18);

        // Without fee: amountOut = (10000 * 1000) / (10000 + 1000) ≈ 909.09
        // With 0.3% fee: amountOut should be less than 909
        assertTrue(amountOut < 910e18, "Fee should reduce output");
        assertTrue(amountOut > 880e18, "Output should be reasonable");
    }

    function test_SwapBothDirections() public {
        vm.prank(alice);
        amm.addLiquidity(10_000e18, 10_000e18);

        vm.prank(bob);
        amm.swap(address(tokenA), 100e18);

        vm.prank(bob);
        amm.swap(address(tokenB), 100e18);

        // K should only increase (fees accumulate)
        uint256 k = amm.reserve0() * amm.reserve1();
        assertGe(k, 10_000e18 * 10_000e18);
    }

    function test_RemoveLiquidity() public {
        vm.prank(alice);
        uint256 shares = amm.addLiquidity(1000e18, 1000e18);

        uint256 balA_before = tokenA.balanceOf(alice);
        uint256 balB_before = tokenB.balanceOf(alice);

        vm.prank(alice);
        (uint256 amount0, uint256 amount1) = amm.removeLiquidity(shares);

        assertGt(amount0, 0);
        assertGt(amount1, 0);
        assertEq(tokenA.balanceOf(alice), balA_before + amount0);
        assertEq(tokenB.balanceOf(alice), balB_before + amount1);
        assertEq(amm.totalSupply(), 0);
    }

    function test_InvalidTokenSwapReverts() public {
        vm.prank(alice);
        amm.addLiquidity(1000e18, 1000e18);

        vm.prank(bob);
        vm.expectRevert(ConstantProductAMM.InvalidToken.selector);
        amm.swap(makeAddr("random"), 100e18);
    }

    function testFuzz_swapPreservesK(uint256 amountIn) public {
        vm.prank(alice);
        amm.addLiquidity(10_000e18, 10_000e18);

        uint256 kBefore = amm.reserve0() * amm.reserve1();

        amountIn = bound(amountIn, 1e15, 5_000e18);

        vm.prank(bob);
        amm.swap(address(tokenA), amountIn);

        uint256 kAfter = amm.reserve0() * amm.reserve1();
        // K should never decrease (fees make it increase)
        assertGe(kAfter, kBefore, "K must never decrease after swap");
    }
}
