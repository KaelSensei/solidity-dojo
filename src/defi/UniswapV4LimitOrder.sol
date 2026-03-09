// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

/// @title UniswapV4LimitOrder
/// @notice Demonstrates Uniswap V4 limit order concepts:
/// - Hook-driven liquidity
/// - Tick-based orders
/// - Partial fill support
/// - Order cancellation
/// @dev This is a simplified educational implementation using mocks.
///      This contract demonstrates the limit order interface patterns but uses
///      a simplified fill mechanism. In production, V4 limit orders are
///      implemented as hook-based positions that become executable when the
///      pool price crosses the tick.
///      DO NOT USE IN PRODUCTION - This is for learning purposes only.
contract UniswapV4LimitOrder is ReentrancyGuard {
    /// @notice Represents a limit order
    struct Order {
        address owner;           // Address that created the order
        address tokenIn;         // Token to sell
        address tokenOut;        // Token to buy
        uint256 amountIn;        // Amount of tokenIn to sell
        uint256 amountOutMin;   // Minimum amount of tokenOut to receive
        int24 tickLower;        // Lower tick of the range
        int24 tickUpper;        // Upper tick of the range
        uint256 filledAmountIn; // How much has been filled
        bool cancelled;         // Whether order is cancelled
        uint256 deadline;        // Order expiration timestamp
    }

    /// @notice Mapping of order ID to order
    mapping(uint256 => Order) public orders;

    /// @notice Counter for generating order IDs
    uint256 public orderCounter;

    /// @notice Address of the PoolManager
    address public immutable poolManager;

    /// @notice Emitted when a limit order is created
    /// @param orderId The ID of the new order
    /// @param owner The order creator
    /// @param tokenIn The token being sold
    /// @param tokenOut The token being bought
    /// @param amountIn The amount being sold
    event OrderCreated(
        uint256 indexed orderId,
        address indexed owner,
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    );

    /// @notice Emitted when a limit order is filled (partially or fully)
    /// @param orderId The ID of the order
    /// @param filler The address that filled the order
    /// @param amountInFilled How much was filled
    /// @param amountOutReceived How much was received
    event OrderFilled(
        uint256 indexed orderId,
        address indexed filler,
        uint256 amountInFilled,
        uint256 amountOutReceived
    );

    /// @notice Emitted when a limit order is cancelled
    /// @param orderId The ID of the cancelled order
    /// @param owner The order creator
    event OrderCancelled(uint256 indexed orderId, address indexed owner);

    /// @notice Initialize with PoolManager address
    /// @param _poolManager The Uniswap V4 PoolManager address
    constructor(address _poolManager) {
        poolManager = _poolManager;
    }

    /// @notice Create a limit order
    /// @dev In V4, limit orders are implemented as hook-based positions
    /// that become executable when the pool price crosses the tick
    /// @param tokenIn The token to sell
    /// @param tokenOut The token to buy
    /// @param amountIn The amount to sell
    /// @param amountOutMin Minimum output (slippage protection)
    /// @param tickLower Lower tick boundary
    /// @param tickUpper Upper tick boundary
    /// @param deadline Order expiration
    /// @return orderId The ID of the created order
    function createOrder(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        int24 tickLower,
        int24 tickUpper,
        uint256 deadline
    ) external returns (uint256 orderId) {
        // Check deadline
        require(block.timestamp <= deadline, "Order expired");

        // Validate tick range
        require(tickLower < tickUpper, "Invalid tick range");
        require(amountIn > 0, "Amount must be > 0");

        // Transfer tokens from user (they must approve first)
        require(
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn),
            "Transfer failed"
        );

        // Create order
        orderId = ++orderCounter;
        orders[orderId] = Order({
            owner: msg.sender,
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            amountIn: amountIn,
            amountOutMin: amountOutMin,
            tickLower: tickLower,
            tickUpper: tickUpper,
            filledAmountIn: 0,
            cancelled: false,
            deadline: deadline
        });

        emit OrderCreated(orderId, msg.sender, tokenIn, tokenOut, amountIn);
    }

    /// @notice Fill a limit order (simulate execution when price crosses tick)
    /// @dev In V4, this would be called by a hook when the pool price
    /// crosses the order's tick range. Uses nonReentrant for safety.
    /// @param orderId The order to fill
    /// @param amountIn Amount to fill (can be partial)
    /// @return amountOut The amount of tokenOut received
    function fillOrder(uint256 orderId, uint256 amountIn) external nonReentrant returns (uint256 amountOut) {
        Order storage order = orders[orderId];

        // Validate order exists and is active
        require(order.owner != address(0), "Order does not exist");
        require(!order.cancelled, "Order cancelled");
        require(block.timestamp <= order.deadline, "Order expired");

        // Check how much is left to fill
        uint256 remaining = order.amountIn - order.filledAmountIn;
        require(amountIn <= remaining, "Exceeds remaining");

        // Calculate output (simplified - in production would use actual pool price)
        // Using 1:1 with small spread for demo
        uint256 fee = 30; // 0.3%
        amountOut = (amountIn * (10000 - fee)) / 10000;

        // Check slippage
        require(amountOut >= order.amountOutMin, "Below minimum");

        // Update filled amount
        order.filledAmountIn += amountIn;

        // CEI: Effects before transfers
        emit OrderFilled(orderId, msg.sender, amountIn, amountOut);

        // Transfer tokens
        // In production: order owner gets tokenOut, filler gets tokenIn (at discount)
        // For simplicity: order owner gets tokenOut
        require(
            IERC20(order.tokenOut).transfer(order.owner, amountOut),
            "Transfer out failed"
        );

        // Filler gets the input tokens (at a discount in real implementation)
        // For mock: filler gets the input tokens they provided
        if (msg.sender != order.owner) {
            require(
                IERC20(order.tokenIn).transfer(msg.sender, amountIn),
                "Transfer filler failed"
            );
        }
    }

    /// @notice Cancel an order
    /// @param orderId The order to cancel
    function cancelOrder(uint256 orderId) external {
        Order storage order = orders[orderId];

        require(order.owner == msg.sender, "Not owner");
        require(!order.cancelled, "Already cancelled");
        require(order.filledAmountIn < order.amountIn, "Fully filled");

        // Mark as cancelled
        order.cancelled = true;

        // Return remaining tokens to owner
        uint256 remaining = order.amountIn - order.filledAmountIn;
        if (remaining > 0) {
            require(
                IERC20(order.tokenIn).transfer(order.owner, remaining),
                "Refund failed"
            );
        }

        emit OrderCancelled(orderId, msg.sender);
    }

    /// @notice Get order details
    /// @param orderId The order ID
    /// @return _owner Order owner
    /// @return _tokenIn Input token
    /// @return _tokenOut Output token
    /// @return _amountIn Amount to sell
    /// @return _amountOutMin Minimum output
    /// @return _tickLower Lower tick
    /// @return _tickUpper Upper tick
    /// @return _filledAmountIn Filled amount
    /// @return _cancelled Whether cancelled
    /// @return _deadline Expiration
    function getOrder(uint256 orderId) external view returns (
        address _owner,
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        int24 _tickLower,
        int24 _tickUpper,
        uint256 _filledAmountIn,
        bool _cancelled,
        uint256 _deadline
    ) {
        Order storage order = orders[orderId];
        return (
            order.owner,
            order.tokenIn,
            order.tokenOut,
            order.amountIn,
            order.amountOutMin,
            order.tickLower,
            order.tickUpper,
            order.filledAmountIn,
            order.cancelled,
            order.deadline
        );
    }

    /// @notice Get remaining amount for an order
    /// @param orderId The order ID
    /// @return remaining The amount still to be filled
    function getRemainingAmount(uint256 orderId) external view returns (uint256 remaining) {
        Order storage order = orders[orderId];
        require(order.owner != address(0), "Order does not exist");
        remaining = order.amountIn - order.filledAmountIn;
    }

    /// @notice Check if an order is fully filled
    /// @param orderId The order ID
    /// @return True if fully filled
    function isOrderFullyFilled(uint256 orderId) external view returns (bool) {
        Order storage order = orders[orderId];
        return order.filledAmountIn >= order.amountIn;
    }

    /// @notice Calculate output for a given input (quote)
    /// @param amountIn Input amount
    /// @return amountOut Output amount
    function quote(uint256 amountIn) external pure returns (uint256 amountOut) {
        // Simplified 1:1 with 0.3% fee
        amountOut = (amountIn * 997) / 1000;
    }
}
