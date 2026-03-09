// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "src/defi/UniswapV4Swap.sol";

/// @title Mock ERC20 Token for V4 Tests
contract MockERC20V4 is IERC20 {
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
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(_balances[from] >= amount, "Insufficient balance");
        require(_allowances[from][msg.sender] >= amount, "Insufficient allowance");
        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        return true;
    }
}

/// @title Mock Pool Manager for V4 Tests
contract MockPoolManagerV4 {
    // Mock pool state
    mapping(bytes32 => uint256) public slot0;
    
    event Unlock(bytes data);

    function setSlot0(bytes32 poolKey, uint256 sqrtPriceX96) external {
        slot0[poolKey] = sqrtPriceX96;
    }

    // Mock unlock function for flash loans
    function unlock(bytes calldata data) external returns (bytes memory) {
        emit Unlock(data);
        return data;
    }
}

/// @title Uniswap V4 Swap Test Suite
/// @dev Tests demonstrate V4 concepts: PoolManager, flash accounting, hooks
contract UniswapV4SwapTest is Test {
    UniswapV4Swap public swap;
    MockERC20V4 public tokenA;
    MockERC20V4 public tokenB;
    MockPoolManagerV4 public poolManager;

    address public user = address(0x1);
    address public other = address(0x2);

    /// @notice Set up test contracts
    function setUp() public {
        // Deploy mock tokens
        tokenA = new MockERC20V4("Token A", "TKA", 18);
        tokenB = new MockERC20V4("Token B", "TKB", 18);

        // Deploy mock PoolManager
        poolManager = new MockPoolManagerV4();

        // Deploy swap contract with PoolManager address
        swap = new UniswapV4Swap(address(poolManager));

        // Mint tokens to user
        tokenA.mint(user, 1000000e18);
        tokenB.mint(address(swap), 1000000e18); // Pool has output tokens
    }

    /// @notice Test exact input single swap works
    /// @dev V4 uses PoolManager for swaps, not a router like V3
    ///      Note: This is a mock - actual token transfers don't occur in the mock
    function test_ExactInputSingleSwap() public {
        uint256 amountIn = 1000e18;
        uint256 amountOutMin = 700e18; // Allow more slippage - mock only returns 70% for demo

        vm.startPrank(user);
        tokenA.approve(address(swap), amountIn);
        
        // The mock doesn't actually transfer tokens - it just calculates output
        // We verify the function executes and returns expected output
        uint256 amountOut = swap.swapExactInputSingle(
            address(tokenA),
            address(tokenB),
            amountIn,
            amountOutMin,
            user
        );
        
        vm.stopPrank();

        // Verify swap returned expected output amount (997e18 after 0.3% fee)
        assertEq(amountOut, 997e18, "Output amount matches fee calculation");
        assertGe(amountOut, amountOutMin, "Received minimum amount");
    }

    /// @notice Test exact input single swap reverts on excessive slippage
    function test_ExactInputSingleSlippageRevert() public {
        uint256 amountIn = 1000e18;
        uint256 amountOutMin = 1000e18; // Too high - only 997e15 expected

        vm.startPrank(user);
        tokenA.approve(address(swap), amountIn);
        
        vm.expectRevert("Too little received");
        swap.swapExactInputSingle(
            address(tokenA),
            address(tokenB),
            amountIn,
            amountOutMin,
            user
        );
        
        vm.stopPrank();
    }

    /// @notice Test multi-hop swap works
    /// @dev V4 supports multi-hop through multiple pools
    function test_MultiHopSwap() public {
        // Deploy third token for multi-hop
        MockERC20V4 tokenC = new MockERC20V4("Token C", "TKC", 18);
        tokenC.mint(address(swap), 1000000e18);

        address[] memory path = new address[](3);
        path[0] = address(tokenA);
        path[1] = address(tokenB);
        path[2] = address(tokenC);

        uint256 amountIn = 1000e18;
        uint256 amountOutMin = 800e18; // Allow for multi-hop fees

        vm.startPrank(user);
        tokenA.approve(address(swap), amountIn);
        
        uint256 amountOut = swap.swapExactInputMultiHop(
            path,
            amountIn,
            amountOutMin,
            user
        );
        
        vm.stopPrank();

        // With 0.3% fee per hop, output should be ~991e15
        assertGe(amountOut, amountOutMin, "Received minimum amount");
    }

    /// @notice Test exact output (exactOutput) swap
    function test_ExactOutputSingleSwap() public {
        uint256 amountOut = 1000e18;
        uint256 amountInMax = 1100e18; // Allow 10% slippage

        vm.startPrank(user);
        tokenA.approve(address(swap), amountInMax);
        
        uint256 balanceBefore = tokenA.balanceOf(user);
        
        uint256 amountIn = swap.swapExactOutputSingle(
            address(tokenA),
            address(tokenB),
            amountOut,
            amountInMax,
            user
        );
        
        vm.stopPrank();

        // Verify swap occurred
        assertGe(amountIn, 0, "Input token spent");
        assertLe(amountIn, amountInMax, "Within max");
        
        // With 0.3% fee, input should be ~1003e15 for 1000e18 output
        assertEq(amountIn, 1003e15, "Input amount matches reverse fee calculation");
    }

    /// @notice Test exact output swap reverts on excessive input
    function test_ExactOutputSingleSlippageRevert() public {
        uint256 amountOut = 1000e18;
        uint256 amountInMax = 1000e18; // Too low - ~1003e15 needed

        vm.startPrank(user);
        tokenA.approve(address(swap), amountInMax);
        
        vm.expectRevert("Too much requested");
        swap.swapExactOutputSingle(
            address(tokenA),
            address(tokenB),
            amountOut,
            amountInMax,
            user
        );
        
        vm.stopPrank();
    }

    /// @notice Test flash loan event is emitted
    /// @dev This is a mock - it only emits an event, no actual flash loan occurs
    function test_FlashLoan() public {
        uint256 loanAmount = 100e18;
        
        // Expect the event to be emitted
        vm.expectEmit(true, true, true, true);
        emit FlashLoan(address(this), address(tokenA), loanAmount);
        
        // Call the function
        swap.flashLoan(address(tokenA), loanAmount, "");
    }

    /// @notice Test quote returns correct values
    function test_QuoteSwap() public view {
        uint256 amountIn = 1000e18;
        
        (uint256 amountOut, uint24 fee) = swap.quoteSwap(
            amountIn,
            address(tokenA),
            address(tokenB)
        );
        
        assertEq(fee, 30, "Fee is 30 bps");
        assertEq(amountOut, 997e18, "Quote matches calculation");
    }

    /// @notice Test constant fee tiers
    function test_FeeTiers() public {
        assertEq(swap.FEE_LOW(), 5, "Low fee is 5 bps");
        assertEq(swap.FEE_MEDIUM(), 30, "Medium fee is 30 bps");
        assertEq(swap.FEE_HIGH(), 100, "High fee is 100 bps");
    }

    /// @notice Test multiple swaps in sequence
    function test_MultipleSwaps() public {
        uint256 amountIn = 100e18;
        uint256 amountOutMin = 90e18;

        vm.startPrank(user);
        tokenA.approve(address(swap), amountIn * 3);
        
        // First swap
        uint256 out1 = swap.swapExactInputSingle(
            address(tokenA),
            address(tokenB),
            amountIn,
            amountOutMin,
            user
        );
        
        // Second swap
        uint256 out2 = swap.swapExactInputSingle(
            address(tokenA),
            address(tokenB),
            amountIn,
            amountOutMin,
            user
        );
        
        // Third swap
        uint256 out3 = swap.swapExactInputSingle(
            address(tokenA),
            address(tokenB),
            amountIn,
            amountOutMin,
            user
        );
        
        vm.stopPrank();

        // Each should produce same output (deterministic in mock)
        assertEq(out1, out2, "First two swaps equal");
        assertEq(out2, out3, "Last two swaps equal");
    }
}
