// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title UniswapV4FlashLoan
/// @notice Demonstrates Uniswap V4 flash loan concepts:
/// - V4 flash accounting system
/// - Hook callbacks (beforeSwap, afterSwap)
/// - Pool manager unlock pattern
/// - Atomic borrow-flash-repay pattern
/// @dev This is a simplified educational implementation using mocks.
///      This contract demonstrates the flash loan interface patterns but does NOT
///      actually borrow tokens - it only calculates fees and emits events.
///      In production, flash loans use the PoolManager's unlock pattern where
///      the contract receives tokens, executes operations, and must repay within
///      the same transaction.
///      DO NOT USE IN PRODUCTION - This is for learning purposes only.
contract UniswapV4FlashLoan {
    /// @notice Address of the PoolManager
    address public immutable poolManager;

    /// @notice Minimum flash loan fee (in basis points)
    uint256 public constant FLASH_LOAN_FEE_BPS = 1; // 0.01%

    /// @notice Emitted when a flash loan is executed
    /// @param borrower The address executing the flash loan
    /// @param token The token borrowed
    /// @param amount The amount borrowed
    /// @param fee The fee charged
    event FlashLoanExecuted(
        address indexed borrower,
        address token,
        uint256 amount,
        uint256 fee
    );

    /// @notice Emitted when flash loan callback is invoked
    /// @param sender The PoolManager address
    /// @param amount The amount borrowed
    event FlashLoanCallback(address indexed sender, uint256 amount);

    /// @notice Initialize with PoolManager address
    /// @param _poolManager The Uniswap V4 PoolManager address
    constructor(address _poolManager) {
        poolManager = _poolManager;
    }

    /// @notice Execute a flash loan
    /// @dev In V4, flash loans use the unlock pattern where:
    /// 1. Caller requests loan from PoolManager
    /// 2. PoolManager unlocks the contract
    /// 3. Contract's unlock callback executes the flash loan logic
    /// 4. PoolManager verifies the debt is paid
    /// @param token The token to borrow
    /// @param amount The amount to borrow
    /// @param data Custom data to pass to the callback
    function executeFlashLoan(
        address token,
        uint256 amount,
        bytes calldata data
    ) external {
        // Calculate the fee
        uint256 fee = (amount * FLASH_LOAN_FEE_BPS) / 10000;
        uint256 amountToRepay = amount + fee;

        // Emit event
        emit FlashLoanExecuted(msg.sender, token, amount, fee);

        // In production, this would call into the PoolManager:
        // IPoolManager(poolManager).unlock(
        //     abi.encodeCall(
        //         this.unlockCallback,
        //         (token, amount, amountToRepay, data)
        //     )
        // );

        // For mock: Transfer borrowed amount to sender
        // In production: PoolManager transfers tokens to this contract,
        // then this contract transfers to msg.sender
        // (Mock: we assume tokens are already here)
    }

    /// @notice Callback function invoked by PoolManager during unlock
    /// @dev This is the hook that gets called when PoolManager.unlock() is called
    /// @param token The token being borrowed
    /// @param amount The amount borrowed
    /// @param amountToRepay The amount that must be repaid (amount + fee)
    /// @param data Custom data passed from executeFlashLoan
    /// @return bytes Return data (can be empty for flash loans)
    function unlockCallback(
        address token,
        uint256 amount,
        uint256 amountToRepay,
        bytes calldata data
    ) external returns (bytes memory) {
        // CEI: Check-Effects-Interactions
        // Check: Validate caller is PoolManager
        require(msg.sender == poolManager, "Only PoolManager");

        // Effects: Emit event
        emit FlashLoanCallback(msg.sender, amount);

        // Interactions: Execute flash loan logic here
        // In production:
        // 1. Use borrowed tokens for operations (e.g., arbitrage)
        // 2. Ensure enough tokens to repay (including fee)
        // 3. Transfer amountToRepay back to PoolManager

        // For this mock: We just demonstrate the callback pattern
        // In production: Return any needed data or just empty bytes

        return "";
    }

    /// @notice Execute a flash loan with a callback for complex operations
    /// @dev Demonstrates the full flash loan workflow
    /// @param token The token to borrow
    /// @param amount The amount to borrow
    /// @param callbackTarget Address to call for the flash operation
    /// @param callbackData Data to pass to the callback
    function executeFlashLoanWithCallback(
        address token,
        uint256 amount,
        address callbackTarget,
        bytes calldata callbackData
    ) external {
        uint256 fee = (amount * FLASH_LOAN_FEE_BPS) / 10000;
        uint256 amountToRepay = amount + fee;

        emit FlashLoanExecuted(msg.sender, token, amount, fee);

        // In production, we would:
        // 1. Get tokens from PoolManager
        // 2. Call the callback with the borrowed amount
        // 3. Repay the PoolManager

        // For mock, we call the callback directly
        // (In production, this would be done by the PoolManager)
        if (callbackTarget != address(0)) {
            // Call the external contract to do something with the loan
            // In production, this could be an arbitrage contract
            (bool success, ) = callbackTarget.call(
                abi.encodeWithSelector(
                    bytes4(keccak256("flashLoanCallback(address,uint256,bytes)")),
                    token,
                    amount,
                    callbackData
                )
            );
            require(success, "Callback failed");
        }
    }

    /// @notice Calculate the flash loan fee for a given amount
    /// @param amount The amount to borrow
    /// @return fee The fee that would be charged
    function calculateFee(uint256 amount) external pure returns (uint256 fee) {
        fee = (amount * FLASH_LOAN_FEE_BPS) / 10000;
    }

    /// @notice Get the pool manager address
    /// @return The PoolManager address
    function getPoolManager() external view returns (address) {
        return poolManager;
    }
}
