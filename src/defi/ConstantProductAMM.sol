// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IERC20AMM
/// @notice Minimal ERC20 interface for AMM operations
interface IERC20AMM {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/// @title ConstantProductAMM
/// @notice A minimal x*y=k AMM with 0.3% swap fee (like Uniswap V1/V2 core).
/// @dev Teaches the constant product invariant, LP share math, and fee mechanics.
contract ConstantProductAMM {
    IERC20AMM public immutable token0;
    IERC20AMM public immutable token1;

    /// @notice Reserve of token0
    uint256 public reserve0;

    /// @notice Reserve of token1
    uint256 public reserve1;

    /// @notice Total LP shares
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
    error InvalidRatio();

    constructor(address _token0, address _token1) {
        token0 = IERC20AMM(_token0);
        token1 = IERC20AMM(_token1);
    }

    /// @notice Swap one token for another
    /// @param tokenIn Address of token being sold
    /// @param amountIn Amount of tokenIn to sell
    /// @return amountOut Amount of the other token received
    function swap(address tokenIn, uint256 amountIn) external returns (uint256 amountOut) {
        if (amountIn == 0) revert ZeroAmount();
        if (tokenIn != address(token0) && tokenIn != address(token1)) revert InvalidToken();

        bool isToken0 = tokenIn == address(token0);
        (IERC20AMM _tokenIn, IERC20AMM _tokenOut, uint256 _resIn, uint256 _resOut) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);

        _tokenIn.transferFrom(msg.sender, address(this), amountIn);

        // 0.3% fee: amountInWithFee = amountIn * 997 / 1000
        uint256 amountInWithFee = (amountIn * 997) / 1000;

        // x * y = k => amountOut = (resOut * amountInWithFee) / (resIn + amountInWithFee)
        amountOut = (_resOut * amountInWithFee) / (_resIn + amountInWithFee);

        if (amountOut == 0) revert InsufficientLiquidity();

        _tokenOut.transfer(msg.sender, amountOut);

        _updateReserves();
        emit Swap(msg.sender, tokenIn, amountIn, amountOut);
    }

    /// @notice Add liquidity to the pool
    /// @param amount0 Amount of token0
    /// @param amount1 Amount of token1
    /// @return shares LP shares minted
    function addLiquidity(uint256 amount0, uint256 amount1) external returns (uint256 shares) {
        if (amount0 == 0 || amount1 == 0) revert ZeroAmount();

        if (reserve0 > 0 && reserve1 > 0) {
            // Enforce ratio: amount0 / reserve0 == amount1 / reserve1
            if (amount0 * reserve1 != amount1 * reserve0) revert InvalidRatio();
        }

        token0.transferFrom(msg.sender, address(this), amount0);
        token1.transferFrom(msg.sender, address(this), amount1);

        if (totalSupply == 0) {
            shares = _sqrt(amount0 * amount1);
        } else {
            shares = _min(
                (amount0 * totalSupply) / reserve0,
                (amount1 * totalSupply) / reserve1
            );
        }

        if (shares == 0) revert InsufficientLiquidity();

        balanceOf[msg.sender] += shares;
        totalSupply += shares;

        _updateReserves();
        emit AddLiquidity(msg.sender, amount0, amount1, shares);
    }

    /// @notice Remove liquidity from the pool
    /// @param shares LP shares to burn
    /// @return amount0 Token0 returned
    /// @return amount1 Token1 returned
    function removeLiquidity(uint256 shares) external returns (uint256 amount0, uint256 amount1) {
        if (shares == 0) revert ZeroAmount();
        if (balanceOf[msg.sender] < shares) revert InsufficientShares();

        amount0 = (shares * reserve0) / totalSupply;
        amount1 = (shares * reserve1) / totalSupply;

        if (amount0 == 0 || amount1 == 0) revert InsufficientLiquidity();

        balanceOf[msg.sender] -= shares;
        totalSupply -= shares;

        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);

        _updateReserves();
        emit RemoveLiquidity(msg.sender, shares, amount0, amount1);
    }

    function _updateReserves() private {
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));
    }

    /// @dev Babylonian square root
    function _sqrt(uint256 y) private pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}
