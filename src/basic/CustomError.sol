// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title CustomError
/// @notice Demonstrates custom errors vs require strings for gas efficiency.
/// @dev Custom errors are cheaper than revert strings (4 gas per byte saved on error data)
contract CustomError {
    /// @notice Balance mapping
    mapping(address => uint256) public balances;

    // ==================== CUSTOM ERRORS ====================

    /// @notice Thrown when sender is not authorized
    error Unauthorized(address sender);

    /// @notice Thrown when amount exceeds balance
    error InsufficientBalance(uint256 requested, uint256 available);

    /// @notice Thrown when amount is zero
    error ZeroAmount();

    /// @notice Thrown when address is zero
    error ZeroAddress();

    /// @notice Thrown when operation would cause overflow
    error Overflow();

    // ==================== EVENTS ====================

    /// @notice Emitted on successful deposit
    event Deposit(address indexed sender, uint256 amount);

    /// @notice Emitted on successful withdrawal
    event Withdrawal(address indexed recipient, uint256 amount);

    // ==================== FUNCTIONS ====================

    /// @notice Deposit ether into contract
    function deposit() external payable {
        if (msg.value == 0) revert ZeroAmount();

        uint256 newBalance = balances[msg.sender] + msg.value;
        if (newBalance < balances[msg.sender]) revert Overflow();

        balances[msg.sender] = newBalance;
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Withdraw ether using custom errors
    function withdraw(uint256 amount) external {
        if (amount == 0) revert ZeroAmount();

        uint256 balance = balances[msg.sender];
        if (amount > balance) {
            revert InsufficientBalance(amount, balance);
        }

        balances[msg.sender] = balance - amount;

        // Emit event before external call
        emit Withdrawal(msg.sender, amount);

        (bool success,) = payable(msg.sender).call{value: amount}("");
        if (!success) revert("Transfer failed");
    }

    /// @notice Transfer balance to another address using custom errors
    function transferBalance(address to, uint256 amount) external {
        if (to == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();

        uint256 senderBalance = balances[msg.sender];
        if (amount > senderBalance) {
            revert InsufficientBalance(amount, senderBalance);
        }

        uint256 recipientBalance = balances[to];
        uint256 newRecipientBalance = recipientBalance + amount;
        if (newRecipientBalance < recipientBalance) revert Overflow();

        balances[msg.sender] = senderBalance - amount;
        balances[to] = newRecipientBalance;
    }

    /// @notice Admin function using custom error with parameter
    function adminOnly() external view {
        if (msg.sender != address(this)) {
            revert Unauthorized(msg.sender);
        }
    }

    /// @notice Compare gas: this uses require with string (more expensive)
    function checkWithRequire(uint256 amount) external view {
        // This costs more gas when it reverts (stores error string in revert data)
        require(balances[msg.sender] >= amount, "Insufficient balance: not enough funds");
    }

    /// @notice Compare gas: this uses custom error (cheaper)
    function checkWithCustomError(uint256 amount) external view {
        uint256 balance = balances[msg.sender];
        // This costs less gas (just 4-byte selector + encoded params)
        if (amount > balance) {
            revert InsufficientBalance(amount, balance);
        }
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
}


