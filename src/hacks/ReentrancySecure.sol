// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ReentrancySecure
/// @notice A secure vault demonstrating reentrancy protection.
/// @dev Uses Checks-Effects-Interactions pattern and reentrancy guard.
contract ReentrancySecure {
    /// @notice User balances in the vault
    mapping(address => uint256) public balances;

    /// @notice Reentrancy guard status (1 = not entered, 2 = entered)
    /// @dev Using 1/2 instead of 0/1 avoids a zero-to-nonzero SSTORE (22,100 gas)
    ///      in favor of nonzero-to-nonzero (5,000 gas), saving ~17,100 gas on first entry.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status = _NOT_ENTERED;

    /// @notice Emitted when ether is deposited
    event Deposit(address indexed user, uint256 amount);

    /// @notice Emitted when ether is withdrawn
    event Withdraw(address indexed user, uint256 amount);

    /// @notice Thrown when reentrancy is detected
    error ReentrantCall();

    /// @notice Modifier to prevent reentrancy
    modifier nonReentrant() {
        if (_status == _ENTERED) revert ReentrantCall();
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    /// @notice Deposit ether into the vault
    function deposit() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Withdraw all ether - SECURE implementation
    /// @dev Follows Checks-Effects-Interactions pattern
    function withdraw() external nonReentrant {
        // CHECKS: Validate conditions first
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance");

        // EFFECTS: Update state before external call
        balances[msg.sender] = 0;
        emit Withdraw(msg.sender, balance);

        // INTERACTIONS: External call last
        (bool success,) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");
    }

    /// @notice Withdraw using transfer (2300 gas stipend)
    /// @dev Simpler but less flexible than call
    function withdrawTransfer() external nonReentrant {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance");

        balances[msg.sender] = 0;
        emit Withdraw(msg.sender, balance);

        payable(msg.sender).transfer(balance);
    }

    /// @notice Get contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
