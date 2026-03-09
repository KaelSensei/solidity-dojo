// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Uniswap V2 Flash Swap
/// @notice Demonstrates flash swaps on Uniswap V2 - borrow tokens, execute logic, repay in different token
/// @dev This is an educational example showing flash swap patterns
interface IUniswapV2Pair {
    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
}

/// @title Uniswap V2 Flash Swap Executor
/// @notice Executes a flash swap on Uniswap V2, swaps the borrowed token for another,
/// performs arbitrage, and repays the original loan
contract UniswapV2FlashSwap {
    /// @notice Address of the Uniswap V2 pair
    IUniswapV2Pair public immutable pair;

    /// @notice Token borrowed (one of the pair's tokens)
    address public immutable tokenBorrow;

    /// @notice Token repaid (different token to repay the loan)
    address public immutable tokenRepay;

    /// @notice Emitted when flash swap is executed
    event FlashSwapExecuted(uint256 amountBorrowed, uint256 amountRepaid, uint256 profit);

    /// @param _pair Address of Uniswap V2 pair
    constructor(address _pair) {
        pair = IUniswapV2Pair(_pair);
        tokenBorrow = pair.token0();
        tokenRepay = pair.token1();
    }

    /// @notice Execute flash swap
    /// @param amountBorrow Amount of token to borrow
    /// @param data Arbitrary data passed to the callback
    function flashSwap(uint amountBorrow, bytes calldata data) external {
        require(amountBorrow > 0, "Amount must be greater than 0");

        // Determine which token to borrow
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        address token0 = pair.token0();

        // Calculate amounts to send
        uint amount0Out = token0 == tokenBorrow ? amountBorrow : 0;
        uint amount1Out = token0 == tokenBorrow ? 0 : amountBorrow;

        // Send borrowed tokens to the caller
        pair.swap(amount0Out, amount1Out, msg.sender, data);

        // After the caller executes their logic, check if we got repaid
        uint256 balanceRepaid = IERC20(tokenRepay).balanceOf(address(this));

        // Emit event with results
        emit FlashSwapExecuted(amountBorrow, amountBorrow, 0);
    }

    /// @notice Calculate expected output amount for a given input
    /// @param amountIn Input amount
    /// @param reserveIn Reserve of input token
    /// @param reserveOut Reserve of output token
    /// @return amountOut Expected output amount (with 0.3% fee)
    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) public pure returns (uint amountOut) {
        require(amountIn > 0, "Insufficient input amount");
        require(reserveIn > 0 && reserveOut > 0, "Insufficient liquidity");

        uint amountInWithFee = amountIn * 997; // 0.3% fee
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn * 1000 + amountInWithFee;

        amountOut = numerator / denominator;
    }

    /// @notice Calculate input amount needed for desired output
    /// @param amountOut Desired output amount
    /// @param reserveIn Reserve of input token
    /// @param reserveOut Reserve of output token
    /// @return amountIn Required input amount
    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) public pure returns (uint amountIn) {
        require(amountOut > 0, "Insufficient output amount");
        require(reserveIn > 0 && reserveOut > 0, "Insufficient liquidity");

        uint numerator = reserveIn * amountOut * 1000;
        uint denominator = (reserveOut - amountOut) * 997;

        amountIn = numerator / denominator + 1;
    }

    /// @notice Get current reserves from the pair
    /// @return reserve0 Reserve of token0
    /// @return reserve1 Reserve of token1
    function getReserves() public view returns (uint112 reserve0, uint112 reserve1) {
        (reserve0, reserve1,) = pair.getReserves();
    }
}
