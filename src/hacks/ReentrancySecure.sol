// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ReentrancySecure
/// @notice A secure vault demonstrating reentrancy protection.
/// @dev Uses Checks-Effects-Interactions pattern and reentrancy guard.
contract ReentrancySecure {
    /// @notice User balances in the vault
    mapping(address => uint256) public balances;

    /// @notice Reentrancy guard lock
    bool private locked;

    /// @notice Emitted when ether is deposited
    event Deposit(address indexed user, uint256 amount);

    /// @notice Emitted when ether is withdrawn
    event Withdraw(address indexed user, uint256 amount);

    /// @notice Thrown when reentrancy is detected
    error ReentrantCall();

    /// @notice Modifier to prevent reentrancy
    modifier nonReentrant() {
        if (locked) revert ReentrantCall();
        locked = true;
        _;
        locked = false;
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
