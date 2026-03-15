// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/defi/ConstantSumAMM.sol";

/// @title Mock ERC20 for ConstantSumAMM tests
contract MockSumToken {
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

/// @title ConstantSumAMM Test Suite
contract ConstantSumAMMTest is Test {
    ConstantSumAMM public amm;
    MockSumToken public tokenA;
    MockSumToken public tokenB;

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    function setUp() public {
        tokenA = new MockSumToken("TokenA");
        tokenB = new MockSumToken("TokenB");
        amm = new ConstantSumAMM(address(tokenA), address(tokenB));

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

    // ============ ADD LIQUIDITY ============

    function test_AddLiquidityFirstDeposit() public {
        vm.prank(alice);
        uint256 shares = amm.addLiquidity(1000e18, 1000e18);

        assertEq(shares, 2000e18, "First deposit shares = amount0 + amount1");
        assertEq(amm.reserve0(), 1000e18);
        assertEq(amm.reserve1(), 1000e18);
        assertEq(amm.balanceOf(alice), shares);
        assertEq(amm.totalSupply(), shares);
    }

    function test_AddLiquiditySubsequentDeposit() public {
        vm.prank(alice);
        amm.addLiquidity(1000e18, 1000e18);

        vm.prank(bob);
        uint256 shares = amm.addLiquidity(500e18, 500e18);

        // 1000 / 2000 * 2000 = 1000
        assertEq(shares, 1000e18);
        assertEq(amm.totalSupply(), 3000e18);
    }

    function test_AddLiquidityOneSided() public {
        vm.prank(alice);
        uint256 shares = amm.addLiquidity(1000e18, 0);

        assertEq(shares, 1000e18, "One-sided deposit should work");
        assertEq(amm.reserve0(), 1000e18);
        assertEq(amm.reserve1(), 0);
    }

    function test_AddLiquidityRevertsOnZero() public {
        vm.prank(alice);
        vm.expectRevert(ConstantSumAMM.ZeroAmount.selector);
        amm.addLiquidity(0, 0);
    }

    // ============ SWAP ============

    function test_SwapToken0ForToken1() public {
        vm.prank(alice);
        amm.addLiquidity(10_000e18, 10_000e18);

        uint256 bobBalBefore = tokenB.balanceOf(bob);

        vm.prank(bob);
        uint256 amountOut = amm.swap(address(tokenA), 1000e18);

        // 1:1 minus 0.3% fee => 1000 * 997 / 1000 = 997
        assertEq(amountOut, 997e18, "Output should be amountIn * 997 / 1000");
        assertEq(tokenB.balanceOf(bob), bobBalBefore + 997e18);
    }

    function test_SwapToken1ForToken0() public {
        vm.prank(alice);
        amm.addLiquidity(10_000e18, 10_000e18);

        uint256 bobBalBefore = tokenA.balanceOf(bob);

        vm.prank(bob);
        uint256 amountOut = amm.swap(address(tokenB), 500e18);

        assertEq(amountOut, (500e18 * 997) / 1000, "Swap in other direction should also work 1:1");
        assertEq(tokenA.balanceOf(bob), bobBalBefore + amountOut);
    }

    function test_SwapNoSlippage() public {
        vm.prank(alice);
        amm.addLiquidity(10_000e18, 10_000e18);

        // Even a large swap should have no slippage — just the flat 0.3% fee
        vm.prank(bob);
        uint256 amountOut = amm.swap(address(tokenA), 5000e18);

        assertEq(amountOut, (5000e18 * 997) / 1000, "Constant sum = no slippage");
    }

    function test_SwapRevertsOnInvalidToken() public {
        vm.prank(alice);
        amm.addLiquidity(1000e18, 1000e18);

        vm.prank(bob);
        vm.expectRevert(ConstantSumAMM.InvalidToken.selector);
        amm.swap(makeAddr("random"), 100e18);
    }

    function test_SwapRevertsOnZeroAmount() public {
        vm.prank(alice);
        amm.addLiquidity(1000e18, 1000e18);

        vm.prank(bob);
        vm.expectRevert(ConstantSumAMM.ZeroAmount.selector);
        amm.swap(address(tokenA), 0);
    }

    function test_SwapRevertsOnInsufficientLiquidity() public {
        vm.prank(alice);
        amm.addLiquidity(100e18, 100e18);

        // Trying to swap more than the reserve of the output token
        vm.prank(bob);
        vm.expectRevert(ConstantSumAMM.InsufficientLiquidity.selector);
        amm.swap(address(tokenA), 200e18);
    }

    // ============ REMOVE LIQUIDITY ============

    function test_RemoveLiquidity() public {
        vm.prank(alice);
        uint256 shares = amm.addLiquidity(1000e18, 1000e18);

        uint256 balA_before = tokenA.balanceOf(alice);
        uint256 balB_before = tokenB.balanceOf(alice);

        vm.prank(alice);
        (uint256 amount0, uint256 amount1) = amm.removeLiquidity(shares);

        assertEq(amount0, 1000e18);
        assertEq(amount1, 1000e18);
        assertEq(tokenA.balanceOf(alice), balA_before + amount0);
        assertEq(tokenB.balanceOf(alice), balB_before + amount1);
        assertEq(amm.totalSupply(), 0);
    }

    function test_RemoveLiquidityPartial() public {
        vm.prank(alice);
        uint256 shares = amm.addLiquidity(1000e18, 1000e18);

        vm.prank(alice);
        (uint256 amount0, uint256 amount1) = amm.removeLiquidity(shares / 2);

        assertEq(amount0, 500e18);
        assertEq(amount1, 500e18);
        assertEq(amm.balanceOf(alice), shares / 2);
    }

    function test_RemoveLiquidityRevertsOnZero() public {
        vm.prank(alice);
        vm.expectRevert(ConstantSumAMM.ZeroAmount.selector);
        amm.removeLiquidity(0);
    }

    function test_RemoveLiquidityRevertsOnInsufficientShares() public {
        vm.prank(alice);
        amm.addLiquidity(1000e18, 1000e18);

        vm.prank(bob);
        vm.expectRevert(ConstantSumAMM.InsufficientShares.selector);
        amm.removeLiquidity(1);
    }

    // ============ FEES ============

    function test_FeesAccumulateInReserves() public {
        vm.prank(alice);
        amm.addLiquidity(10_000e18, 10_000e18);

        uint256 totalBefore = amm.reserve0() + amm.reserve1();

        vm.prank(bob);
        amm.swap(address(tokenA), 1000e18);

        uint256 totalAfter = amm.reserve0() + amm.reserve1();

        // Fees stay in the pool: total reserves should increase by 0.3% of amountIn
        assertGt(totalAfter, totalBefore, "Fees should increase total reserves");
        assertEq(totalAfter - totalBefore, 3e18, "Fee = 0.3% of 1000 = 3");
    }

    // ============ FUZZ TESTS ============

    function testFuzz_SwapOutputIs997Per1000(uint256 amountIn) public {
        vm.prank(alice);
        amm.addLiquidity(50_000e18, 50_000e18);

        amountIn = bound(amountIn, 1e15, 40_000e18);

        vm.prank(bob);
        uint256 amountOut = amm.swap(address(tokenA), amountIn);

        uint256 expected = (amountIn * 997) / 1000;
        assertEq(amountOut, expected, "Constant sum: output = input * 997/1000");
    }

    function testFuzz_AddAndRemoveLiquidity(uint256 amount0, uint256 amount1) public {
        amount0 = bound(amount0, 1e18, 50_000e18);
        amount1 = bound(amount1, 1e18, 50_000e18);

        vm.prank(alice);
        uint256 shares = amm.addLiquidity(amount0, amount1);

        assertEq(shares, amount0 + amount1);

        uint256 balA_before = tokenA.balanceOf(alice);
        uint256 balB_before = tokenB.balanceOf(alice);

        vm.prank(alice);
        (uint256 out0, uint256 out1) = amm.removeLiquidity(shares);

        // Should get back exactly what was deposited (no swaps occurred)
        assertEq(out0, amount0);
        assertEq(out1, amount1);
        assertEq(tokenA.balanceOf(alice), balA_before + amount0);
        assertEq(tokenB.balanceOf(alice), balB_before + amount1);
    }

    function testFuzz_FeesAlwaysPositive(uint256 amountIn) public {
        vm.prank(alice);
        amm.addLiquidity(50_000e18, 50_000e18);

        amountIn = bound(amountIn, 1e15, 40_000e18);

        uint256 totalBefore = amm.reserve0() + amm.reserve1();

        vm.prank(bob);
        amm.swap(address(tokenA), amountIn);

        uint256 totalAfter = amm.reserve0() + amm.reserve1();
        assertGe(totalAfter, totalBefore, "Total reserves must not decrease after swap");
    }
}
