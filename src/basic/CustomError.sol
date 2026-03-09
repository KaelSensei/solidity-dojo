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
    /// @param sender The unauthorized sender address
    error Unauthorized(address sender);

    /// @notice Thrown when amount exceeds balance
    /// @param requested Amount requested
    /// @param available Amount available
    error InsufficientBalance(uint256 requested, uint256 available);

    /// @notice Thrown when amount is zero
    error ZeroAmount();

    /// @notice Thrown when address is zero
    error ZeroAddress();

    /// @notice Thrown when operation would cause overflow
    error Overflow();

    // ==================== EVENTS ====================

    /// @notice Emitted on successful deposit
    /// @param sender Address depositing
    /// @param amount Amount deposited
    event Deposit(address indexed sender, uint256 amount);

    /// @notice Emitted on successful withdrawal
    /// @param recipient Address receiving
    /// @param amount Amount withdrawn
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
    /// @param _amount Amount to withdraw
    function withdraw(uint256 _amount) external {
        if (_amount == 0) revert ZeroAmount();

        uint256 balance = balances[msg.sender];
        if (_amount > balance) {
            revert InsufficientBalance(_amount, balance);
        }

        balances[msg.sender] = balance - _amount;

        (bool success,) = payable(msg.sender).call{value: _amount}("");
        if (!success) revert("Transfer failed");

        emit Withdrawal(msg.sender, _amount);
    }

    /// @notice Transfer to another address using custom errors
    /// @param _to Recipient address
    /// @param _amount Amount to transfer
    function transfer(address _to, uint256 _amount) external {
        if (_to == address(0)) revert ZeroAddress();
        if (_amount == 0) revert ZeroAmount();

        uint256 senderBalance = balances[msg.sender];
        if (_amount > senderBalance) {
            revert InsufficientBalance(_amount, senderBalance);
        }

        uint256 recipientBalance = balances[_to];
        uint256 newRecipientBalance = recipientBalance + _amount;
        if (newRecipientBalance < recipientBalance) revert Overflow();

        balances[msg.sender] = senderBalance - _amount;
        balances[_to] = newRecipientBalance;
    }

    /// @notice Admin function using custom error with parameter
    function adminOnly() external view {
        if (msg.sender != address(this)) {
            revert Unauthorized(msg.sender);
        }
    }

    /// @notice Compare gas: this uses require with string (more expensive)
    /// @param _amount Amount to check
    function checkWithRequire(uint256 _amount) external view {
        // This costs more gas when it reverts (stores error string in revert data)
        require(balances[msg.sender] >= _amount, "Insufficient balance: not enough funds");
    }

    /// @notice Compare gas: this uses custom error (cheaper)
    /// @param _amount Amount to check
    function checkWithCustomError(uint256 _amount) external view {
        uint256 balance = balances[msg.sender];
        // This costs less gas (just 4-byte selector + encoded params)
        if (_amount > balance) {
            revert InsufficientBalance(_amount, balance);
        }
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
}
