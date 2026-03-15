// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/defi/StableSwapAMM.sol";

/// @title Mock ERC20 for StableSwapAMM tests
contract MockStableToken {
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

/// @title StableSwapAMM Test Suite
contract StableSwapAMMTest is Test {
    StableSwapAMM public amm;
    MockStableToken public tokenA;
    MockStableToken public tokenB;

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    /// @dev A = 85 is a typical amplification coefficient for stablecoin pools
    uint256 constant AMP = 85;

    function setUp() public {
        tokenA = new MockStableToken("USDC");
        tokenB = new MockStableToken("DAI");
        amm = new StableSwapAMM(address(tokenA), address(tokenB), AMP);

        tokenA.mint(alice, 1_000_000e18);
        tokenB.mint(alice, 1_000_000e18);
        tokenA.mint(bob, 1_000_000e18);
        tokenB.mint(bob, 1_000_000e18);

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
        uint256 shares = amm.addLiquidity(10_000e18, 10_000e18);

        assertGt(shares, 0, "Should mint shares");
        assertEq(amm.reserve0(), 10_000e18);
        assertEq(amm.reserve1(), 10_000e18);
        assertEq(amm.balanceOf(alice), shares);
    }

    function test_AddLiquiditySubsequentDeposit() public {
        vm.prank(alice);
        amm.addLiquidity(10_000e18, 10_000e18);

        vm.prank(bob);
        uint256 shares = amm.addLiquidity(5_000e18, 5_000e18);

        assertGt(shares, 0);
        // Bob deposits half as much, should get roughly half the shares
        uint256 aliceShares = amm.balanceOf(alice);
        assertApproxEqRel(shares, aliceShares / 2, 0.01e18, "Bob should get ~half of Alice's shares");
    }

    function test_AddLiquidityRevertsOnZero() public {
        vm.prank(alice);
        vm.expectRevert(StableSwapAMM.ZeroAmount.selector);
        amm.addLiquidity(0, 0);
    }

    // ============ SWAP ============

    function test_SwapNearPegLowSlippage() public {
        vm.prank(alice);
        amm.addLiquidity(100_000e18, 100_000e18);

        vm.prank(bob);
        uint256 amountOut = amm.swap(address(tokenA), 1_000e18);

        // Near peg with high A, output should be close to input minus 0.3% fee
        // Ideal (constant sum) = 1000 * 0.997 = 997
        // StableSwap should be close to that
        assertGt(amountOut, 990e18, "Near-peg slippage should be very low");
        assertLe(amountOut, 997e18, "Output should not exceed constant-sum output");
    }

    function test_SwapBothDirections() public {
        vm.prank(alice);
        amm.addLiquidity(100_000e18, 100_000e18);

        vm.prank(bob);
        uint256 out1 = amm.swap(address(tokenA), 1_000e18);

        vm.prank(bob);
        uint256 out2 = amm.swap(address(tokenB), 1_000e18);

        // Both directions should yield similar output near the peg
        assertGt(out1, 0);
        assertGt(out2, 0);
    }

    function test_SwapCollectsFees() public {
        vm.prank(alice);
        amm.addLiquidity(100_000e18, 100_000e18);

        uint256 totalBefore = amm.reserve0() + amm.reserve1();

        vm.prank(bob);
        amm.swap(address(tokenA), 1_000e18);

        uint256 totalAfter = amm.reserve0() + amm.reserve1();

        // Fees (0.3%) remain in the pool, so total reserves should increase
        assertGt(totalAfter, totalBefore, "Fees should increase total reserves");
    }

    function test_SwapRevertsOnInvalidToken() public {
        vm.prank(alice);
        amm.addLiquidity(10_000e18, 10_000e18);

        vm.prank(bob);
        vm.expectRevert(StableSwapAMM.InvalidToken.selector);
        amm.swap(makeAddr("random"), 100e18);
    }

    function test_SwapRevertsOnZeroAmount() public {
        vm.prank(alice);
        amm.addLiquidity(10_000e18, 10_000e18);

        vm.prank(bob);
        vm.expectRevert(StableSwapAMM.ZeroAmount.selector);
        amm.swap(address(tokenA), 0);
    }

    // ============ REMOVE LIQUIDITY ============

    function test_RemoveLiquidity() public {
        vm.prank(alice);
        uint256 shares = amm.addLiquidity(10_000e18, 10_000e18);

        uint256 balA_before = tokenA.balanceOf(alice);
        uint256 balB_before = tokenB.balanceOf(alice);

        vm.prank(alice);
        (uint256 amount0, uint256 amount1) = amm.removeLiquidity(shares);

        assertEq(amount0, 10_000e18);
        assertEq(amount1, 10_000e18);
        assertEq(tokenA.balanceOf(alice), balA_before + amount0);
        assertEq(tokenB.balanceOf(alice), balB_before + amount1);
        assertEq(amm.totalSupply(), 0);
    }

    function test_RemoveLiquidityPartial() public {
        vm.prank(alice);
        uint256 shares = amm.addLiquidity(10_000e18, 10_000e18);

        vm.prank(alice);
        (uint256 amount0, uint256 amount1) = amm.removeLiquidity(shares / 2);

        assertEq(amount0, 5_000e18);
        assertEq(amount1, 5_000e18);
    }

    function test_RemoveLiquidityRevertsOnZero() public {
        vm.prank(alice);
        vm.expectRevert(StableSwapAMM.ZeroAmount.selector);
        amm.removeLiquidity(0);
    }

    function test_RemoveLiquidityRevertsOnInsufficientShares() public {
        vm.prank(alice);
        amm.addLiquidity(10_000e18, 10_000e18);

        vm.prank(bob);
        vm.expectRevert(StableSwapAMM.InsufficientShares.selector);
        amm.removeLiquidity(1);
    }

    // ============ STABLESWAP-SPECIFIC ============

    function test_HighAMeansLessSlippage() public {
        // Deploy two AMMs with different A values
        StableSwapAMM lowA = new StableSwapAMM(address(tokenA), address(tokenB), 10);
        StableSwapAMM highA = new StableSwapAMM(address(tokenA), address(tokenB), 200);

        // Fund both pools equally
        vm.startPrank(alice);
        tokenA.approve(address(lowA), type(uint256).max);
        tokenB.approve(address(lowA), type(uint256).max);
        tokenA.approve(address(highA), type(uint256).max);
        tokenB.approve(address(highA), type(uint256).max);
        lowA.addLiquidity(100_000e18, 100_000e18);
        highA.addLiquidity(100_000e18, 100_000e18);
        vm.stopPrank();

        // Swap same amount on both
        vm.startPrank(bob);
        tokenA.approve(address(lowA), type(uint256).max);
        tokenA.approve(address(highA), type(uint256).max);
        uint256 outLow = lowA.swap(address(tokenA), 10_000e18);
        uint256 outHigh = highA.swap(address(tokenA), 10_000e18);
        vm.stopPrank();

        // Higher A should give more output (less slippage)
        assertGt(outHigh, outLow, "Higher A should produce less slippage");
    }

    // ============ FUZZ TESTS ============

    function testFuzz_SwapPreservesOrIncreasesReserves(uint256 amountIn) public {
        vm.prank(alice);
        amm.addLiquidity(100_000e18, 100_000e18);

        amountIn = bound(amountIn, 1e15, 50_000e18);

        uint256 totalBefore = amm.reserve0() + amm.reserve1();

        vm.prank(bob);
        amm.swap(address(tokenA), amountIn);

        uint256 totalAfter = amm.reserve0() + amm.reserve1();
        assertGe(totalAfter, totalBefore, "Fees mean total reserves never decrease");
    }

    function testFuzz_AddAndRemoveLiquidity(uint256 amount) public {
        amount = bound(amount, 1e18, 100_000e18);

        vm.prank(alice);
        uint256 shares = amm.addLiquidity(amount, amount);

        uint256 balA_before = tokenA.balanceOf(alice);
        uint256 balB_before = tokenB.balanceOf(alice);

        vm.prank(alice);
        (uint256 out0, uint256 out1) = amm.removeLiquidity(shares);

        assertEq(out0, amount);
        assertEq(out1, amount);
        assertEq(tokenA.balanceOf(alice), balA_before + amount);
        assertEq(tokenB.balanceOf(alice), balB_before + amount);
    }
}
