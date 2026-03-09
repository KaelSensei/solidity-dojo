// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Uniswap V3 Swap
/// @notice Demonstrates single-hop and multi-hop swaps on Uniswap V3
/// @dev Educational example of Uniswap V3 swap patterns

/// @title IERC20 Token Interface
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/// @notice Uniswap V3 Swap Router interface (simplified)
interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);
}

/// @title Uniswap V3 Swap Helper
/// @notice Helper contract for executing Uniswap V3 swaps
contract UniswapV3Swap {
    /// @notice Address of Uniswap V3 SwapRouter
    ISwapRouter public immutable router;

    /// @notice Common fee tiers
    uint24 public constant FEE_LOW = 3000;    // 0.3%
    uint24 public constant FEE_MEDIUM = 3000; // 0.3%
    uint24 public constant FEE_HIGH = 10000;   // 1%

    /// @notice Emitted when swap completes
    event SwapCompleted(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);

    /// @param _router Address of Uniswap V3 Router
    constructor(address _router) {
        router = ISwapRouter(_router);
    }

    /// @notice Execute exact input single hop swap
    /// @param tokenIn Input token address
    /// @param tokenOut Output token address
    /// @param fee Fee tier
    /// @param amountIn Amount of input token to swap
    /// @param amountOutMinimum Minimum output amount (slippage protection)
    /// @return amountOut Actual output amount
    function swapExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint256 amountOutMinimum
    ) external returns (uint256 amountOut) {
        // Transfer tokens from caller
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        
        // Approve router
        IERC20(tokenIn).approve(address(router), amountIn);

        // Execute swap
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: fee,
            recipient: msg.sender,
            deadline: block.timestamp + 300, // 5 min deadline
            amountIn: amountIn,
            amountOutMinimum: amountOutMinimum,
            sqrtPriceLimitX96: 0
        });

        amountOut = router.exactInputSingle(params);

        emit SwapCompleted(tokenIn, tokenOut, amountIn, amountOut);
    }

    /// @notice Execute exact output single hop swap
    /// @param tokenIn Input token address
    /// @param tokenOut Output token address
    /// @param fee Fee tier
    /// @param amountOut Desired output amount
    /// @param amountInMaximum Maximum input amount (slippage protection)
    /// @return amountIn Actual input amount
    function swapExactOutputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountOut,
        uint256 amountInMaximum
    ) external returns (uint256 amountIn) {
        // Transfer max tokens from caller
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountInMaximum);
        
        // Approve router
        IERC20(tokenIn).approve(address(router), amountInMaximum);

        // Execute swap
        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: fee,
            recipient: msg.sender,
            deadline: block.timestamp + 300,
            amountOut: amountOut,
            amountInMaximum: amountInMaximum,
            sqrtPriceLimitX96: 0
        });

        amountIn = router.exactOutputSingle(params);

        // Refund unused tokens
        if (amountInMaximum > amountIn) {
            IERC20(tokenIn).transfer(msg.sender, amountInMaximum - amountIn);
        }

        emit SwapCompleted(tokenIn, tokenOut, amountIn, amountOut);
    }

    /// @notice Execute multi-hop swap via path encoding
    /// @param path Encoded path (tokenIn -> fee -> tokenOut -> fee -> tokenOut...)
    /// @param amountIn Amount of input token
    /// @param amountOutMinimum Minimum output amount
    /// @return amountOut Output amount
    function swapExactInputMultiHop(
        bytes calldata path,
        uint256 amountIn,
        uint256 amountOutMinimum
    ) external returns (uint256 amountOut) {
        // Transfer tokens from caller
        address tokenIn = extractTokenInFromPath(path);
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        
        // Approve router
        IERC20(tokenIn).approve(address(router), amountIn);

        // Execute multi-hop swap
        ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams({
            path: path,
            recipient: msg.sender,
            deadline: block.timestamp + 300,
            amountIn: amountIn,
            amountOutMinimum: amountOutMinimum
        });

        amountOut = router.exactInput(params);

        emit SwapCompleted(tokenIn, address(0), amountIn, amountOut);
    }

    /// @notice Extract input token from path
    /// @param path Encoded swap path
    /// @return tokenIn Input token address
    function extractTokenInFromPath(bytes calldata path) public pure returns (address tokenIn) {
        require(path.length >= 20, "Invalid path");
        tokenIn = address(bytes20(path[:20]));
    }

    /// @notice Calculate minimum output for exact input swap
    /// @param amountIn Input amount
    /// @param fee Fee tier (in 10000 = 1%)
    /// @param slippageBps Slippage tolerance in basis points
    /// @return minimumOut Minimum output amount
    function calculateMinOutput(uint256 amountIn, uint24 fee, uint256 slippageBps) external pure returns (uint256 minimumOut) {
        // Simplified: assume 1:1 for testing (in real use, would calculate from reserves)
        uint256 feeFactor = 10000 - fee;
        uint256 amountAfterFee = (amountIn * feeFactor) / 10000;
        minimumOut = (amountAfterFee * (10000 - slippageBps)) / 10000;
    }
}
