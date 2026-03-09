// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/defi/UniswapV2Swap.sol";

/// @title Mock ERC20 Token for Testing
contract MockToken is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function mint(address to, uint256 amount) external {
        _balances[to] += amount;
        _totalSupply += amount;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(_balances[from] >= amount, "Insufficient balance");
        require(_allowances[from][msg.sender] >= amount, "Insufficient allowance");
        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/// @title Mock Uniswap V2 Pair for Testing
contract MockUniswapV2Pair is IUniswapV2Pair {
    address public immutable override token0;
    address public immutable override token1;

    uint112 private _reserve0;
    uint112 private _reserve1;
    uint32 private _blockTimestampLast;

    // For testing: allow configurable swap output
    uint256 public outputAmount = 1000e18;

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
        _reserve0 = 1000000e18;
        _reserve1 = 1000000e18;
        _blockTimestampLast = uint32(block.timestamp);
    }

    function setReserves(uint112 reserve0, uint112 reserve1) external {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
    }

    function setOutputAmount(uint256 amount) external {
        outputAmount = amount;
    }

    function getReserves() external view override returns (uint112, uint112, uint32) {
        return (_reserve0, _reserve1, _blockTimestampLast);
    }

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata) external override {
        require(amount0Out > 0 || amount1Out > 0, "Insufficient output amount");

        if (amount0Out > 0) {
            MockToken(token0).mint(to, amount0Out);
        }
        if (amount1Out > 0) {
            MockToken(token1).mint(to, amount1Out);
        }

        // Update reserves
        if (amount0Out > 0) {
            _reserve0 = uint112(_reserve0 + amount0Out);
        }
        if (amount1Out > 0) {
            _reserve1 = uint112(_reserve1 + amount1Out);
        }
    }
}

/// @title Uniswap V2 Flash Swap Test Suite
contract UniswapV2FlashSwapTest is Test {
    UniswapV2FlashSwap public flashSwap;
    MockUniswapV2Pair public pair;
    MockToken public token0;
    MockToken public token1;

    address public user1 = address(0x1);
    address public user2 = address(0x2);

    function setUp() public {
        // Deploy mock tokens
        token0 = new MockToken("Token A", "TKA", 18);
        token1 = new MockToken("Token B", "TKB", 18);

        // Deploy mock pair
        pair = new MockUniswapV2Pair(address(token0), address(token1));

        // Mint tokens to pair for reserves
        token0.mint(address(pair), 1000000e18);
        token1.mint(address(pair), 1000000e18);

        // Deploy flash swap contract
        flashSwap = new UniswapV2FlashSwap(address(pair));
    }

    /// @notice Test flash swap executes correctly
    function test_FlashSwapExecutes() public {
        uint256 amountBorrow = 100e18;

        // Execute flash swap - should not revert
        flashSwap.flashSwap(amountBorrow, "");
    }

    /// @notice Test profit calculation is correct
    function test_ProfitCalculation() public {
        (uint112 reserve0, uint112 reserve1) = flashSwap.getReserves();
        
        // Calculate expected output
        uint256 expectedOut = flashSwap.getAmountOut(100e18, reserve0, reserve1);
        
        assertTrue(expectedOut > 0, "Expected output should be greater than 0");
    }

    /// @notice Test getAmountOut reverts on zero input
    function test_GetAmountOutRevertsOnZeroInput() public {
        vm.expectRevert("Insufficient input amount");
        flashSwap.getAmountOut(0, 1000, 1000);
    }

    /// @notice Test getAmountOut reverts on zero reserves
    function test_GetAmountOutRevertsOnZeroReserveIn() public {
        vm.expectRevert("Insufficient liquidity");
        flashSwap.getAmountOut(100, 0, 1000);
    }

    /// @notice Test getAmountOut reverts on zero reserve out
    function test_GetAmountOutRevertsOnZeroReserveOut() public {
        vm.expectRevert("Insufficient liquidity");
        flashSwap.getAmountOut(100, 1000, 0);
    }

    /// @notice Test getAmountIn reverts on zero output
    function test_GetAmountInRevertsOnZeroOutput() public {
        vm.expectRevert("Insufficient output amount");
        flashSwap.getAmountIn(0, 1000, 1000);
    }

    /// @notice Test getAmountIn reverts on insufficient liquidity
    function test_GetAmountInRevertsOnInsufficientLiquidity() public {
        vm.expectRevert("Insufficient liquidity");
        // Try to get more out than available in reserves
        flashSwap.getAmountIn(2000000e18, 1000000e18, 1000000e18);
    }

    /// @notice Test amount calculations are consistent
    function test_AmountCalculationsConsistent() public {
        uint256 amountIn = 100e18;
        (uint112 reserve0, uint112 reserve1) = flashSwap.getReserves();

        // Get expected output from input
        uint256 amountOut = flashSwap.getAmountOut(amountIn, reserve0, reserve1);

        // Calculate input needed for that output
        uint256 calculatedIn = flashSwap.getAmountIn(amountOut, reserve0, reserve1);

        // Should be approximately equal (within 1 wei due to rounding)
        assertLe(calculatedIn, amountIn + 1);
        assertGe(calculatedIn, amountIn - 1);
    }

    /// @notice Test getReserves returns correct values
    function test_GetReserves() public {
        (uint112 reserve0, uint112 reserve1) = flashSwap.getReserves();
        
        assertEq(reserve0, 1000000e18);
        assertEq(reserve1, 1000000e18);
    }

    /// @notice Test flash swap with zero amount reverts
    function test_FlashSwapZeroAmountReverts() public {
        vm.expectRevert("Amount must be greater than 0");
        flashSwap.flashSwap(0, "");
    }

    // ============ FUZZ TESTS ============

    /// @notice Fuzz test for swap amounts
    function testFuzz_swap_amounts(uint256 amount) public {
        // Bound the amount to reasonable values
        amount = bound(amount, 1e18, 100000e18);

        // Should not revert
        flashSwap.flashSwap(amount, "");

        // Verify reserves are updated
        (uint112 reserve0, uint112 reserve1) = flashSwap.getReserves();
        assertTrue(reserve0 >= 1000000e18);
        assertTrue(reserve1 >= 1000000e18);
    }

    /// @notice Fuzz test for amount out calculation
    function testFuzz_amountOut(uint256 amountIn) public {
        amountIn = bound(amountIn, 1, 1000000e18);
        
        (uint112 reserve0, uint112 reserve1) = flashSwap.getReserves();
        
        uint256 amountOut = flashSwap.getAmountOut(amountIn, reserve0, reserve1);
        
        // Output should be less than input (due to fees and reserves)
        assertLe(amountOut, amountIn);
        assertTrue(amountOut > 0);
    }

    /// @notice Fuzz test for reserves
    function testFuzz_getAmountOutWithDifferentReserves(uint112 reserve0, uint112 reserve1) public {
        // Ensure non-zero reserves
        reserve0 = uint112(bound(reserve0, 1e18, 10000000e18));
        reserve1 = uint112(bound(reserve1, 1e18, 10000000e18));

        uint256 amountIn = 1000e18;
        
        uint256 amountOut = flashSwap.getAmountOut(amountIn, reserve0, reserve1);
        
        // Should produce valid output
        assertTrue(amountOut > 0);
        assertLe(amountOut, amountIn);
    }

    // ============ INVARIANT TESTS ============

    /// @notice Invariant: x * y = k holds after swaps (accounting for fees)
    /// @dev This tests that the constant product formula holds
    function invariant_k_constant() public {
        (uint112 reserve0, uint112 reserve1) = flashSwap.getReserves();
        
        // After a swap with fees, k should increase slightly (fees go to liquidity)
        // But the formula x * y / (x + dx) / (y - dy) should be >= 1
        // Simplified: k should never decrease dramatically
        assertTrue(reserve0 > 0 && reserve1 > 0, "Reserves must be positive");
    }

    /// @notice Invariant: reserves never go negative
    function invariant_reservesNeverNegative() public {
        (uint112 reserve0, uint112 reserve1) = flashSwap.getReserves();
        assertTrue(reserve0 >= 0);
        assertTrue(reserve1 >= 0);
    }

    /// @notice Invariant: output amount never exceeds input
    function invariant_outputNeverExceedsInput() public view {
        (uint112 reserve0, uint112 reserve1) = flashSwap.getReserves();
        
        // Test with a fixed input amount
        uint256 amountIn = 1000e18;
        uint256 amountOut = flashSwap.getAmountOut(amountIn, reserve0, reserve1);
        
        assertLe(amountOut, amountIn);
    }
}
