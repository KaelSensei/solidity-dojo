// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IERC20AMM
/// @notice Minimal ERC20 interface for AMM operations
interface IERC20SumAMM {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/// @title ConstantSumAMM
/// @notice A minimal x+y=k AMM with 0.3% swap fee.
/// @dev Teaches the constant sum invariant — the simplest AMM with zero slippage.
///      This is only suitable for tokens that trade at the same price (e.g. stablecoins).
///      WARNING: If the tokens diverge in price, arbitrageurs will drain the cheaper token
///      from the pool, effectively converting all liquidity into the overvalued token.
///      This is purely educational — real stablecoin AMMs use StableSwap (Curve) invariants.
contract ConstantSumAMM {
    IERC20SumAMM public immutable token0;
    IERC20SumAMM public immutable token1;

    /// @notice Reserve of token0
    uint256 public reserve0;

    /// @notice Reserve of token1
    uint256 public reserve1;

    /// @notice Total LP shares outstanding
    uint256 public totalSupply;

    /// @notice LP shares per address
    mapping(address => uint256) public balanceOf;

    event Swap(address indexed user, address tokenIn, uint256 amountIn, uint256 amountOut);
    event AddLiquidity(address indexed user, uint256 amount0, uint256 amount1, uint256 shares);
    event RemoveLiquidity(address indexed user, uint256 shares, uint256 amount0, uint256 amount1);

    error InvalidToken();
    error ZeroAmount();
    error InsufficientLiquidity();
    error InsufficientShares();
    error TransferFailed();

    uint256 private _unlocked = 1;
    modifier nonReentrant() {
        require(_unlocked == 1, "Reentrancy");
        _unlocked = 2;
        _;
        _unlocked = 1;
    }

    constructor(address _token0, address _token1) {
        token0 = IERC20SumAMM(_token0);
        token1 = IERC20SumAMM(_token1);
    }

    /// @notice Swap one token for the other at a 1:1 rate minus 0.3% fee
    /// @dev Because x+y=k, amountOut = amountIn (minus fee). No slippage regardless of size.
    ///      This makes the pool vulnerable: if token prices diverge, the entire reserve of
    ///      the undervalued token gets drained by arbitrageurs.
    /// @return amountOut Amount of the other token received
    function swap(address tokenIn, uint256 amountIn) external nonReentrant returns (uint256 amountOut) {
        if (amountIn == 0) revert ZeroAmount();
        if (tokenIn != address(token0) && tokenIn != address(token1)) revert InvalidToken();

        bool isToken0 = tokenIn == address(token0);
        (IERC20SumAMM _tokenIn, IERC20SumAMM _tokenOut, uint256 _resOut) = isToken0
            ? (token0, token1, reserve1)
            : (token1, token0, reserve0);

        if (!_tokenIn.transferFrom(msg.sender, address(this), amountIn)) revert TransferFailed();

        // 0.3% fee: amountOut = amountIn * 997 / 1000
        // Constant sum means 1:1 exchange rate — no price impact
        amountOut = (amountIn * 997) / 1000;

        if (amountOut > _resOut) revert InsufficientLiquidity();
        if (amountOut < 1) revert ZeroAmount();

        if (!_tokenOut.transfer(msg.sender, amountOut)) revert TransferFailed();

        _updateReserves();
        emit Swap(msg.sender, tokenIn, amountIn, amountOut);
    }

    /// @notice Add liquidity to the pool
    /// @dev First depositor sets the ratio. Subsequent depositors get shares proportional
    ///      to their deposit relative to the total reserves (sum-based, not geometric mean).
    /// @return shares LP shares minted
    function addLiquidity(uint256 amount0, uint256 amount1) external nonReentrant returns (uint256 shares) {
        if (amount0 == 0 && amount1 == 0) revert ZeroAmount();

        if (amount0 > 0) {
            if (!token0.transferFrom(msg.sender, address(this), amount0)) revert TransferFailed();
        }
        if (amount1 > 0) {
            if (!token1.transferFrom(msg.sender, address(this), amount1)) revert TransferFailed();
        }

        if (totalSupply < 1) {
            // First deposit: shares = total tokens deposited
            shares = amount0 + amount1;
        } else {
            // Proportional to existing pool: shares = totalSupply * depositValue / poolValue
            uint256 totalReserves = reserve0 + reserve1;
            shares = ((amount0 + amount1) * totalSupply) / totalReserves;
        }

        if (shares == 0) revert InsufficientLiquidity();

        balanceOf[msg.sender] += shares;
        totalSupply += shares;

        _updateReserves();
        emit AddLiquidity(msg.sender, amount0, amount1, shares);
    }

    /// @notice Remove liquidity from the pool
    /// @return amount0 Token0 returned
    /// @return amount1 Token1 returned
    function removeLiquidity(uint256 shares) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        if (shares == 0) revert ZeroAmount();
        if (balanceOf[msg.sender] < shares) revert InsufficientShares();

        // Pro-rata share of each reserve
        amount0 = (shares * reserve0) / totalSupply;
        amount1 = (shares * reserve1) / totalSupply;

        balanceOf[msg.sender] -= shares;
        totalSupply -= shares;

        if (amount0 > 0) {
            if (!token0.transfer(msg.sender, amount0)) revert TransferFailed();
        }
        if (amount1 > 0) {
            if (!token1.transfer(msg.sender, amount1)) revert TransferFailed();
        }

        _updateReserves();
        emit RemoveLiquidity(msg.sender, shares, amount0, amount1);
    }

    /// @dev Sync reserves with actual token balances
    function _updateReserves() private {
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));
    }
}

