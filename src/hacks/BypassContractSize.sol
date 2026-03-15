// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title BypassContractSize
/// @notice Demonstrates how extcodesize check can be bypassed via constructor
/// @dev Educational example - DO NOT USE IN PRODUCTION
///
/// The extcodesize check is commonly used to determine if an address is a contract
/// or an EOA (externally owned account). However, during contract construction,
/// the contract's code has not yet been stored — so extcodesize returns 0.
///
/// This means a contract can call other contracts from its constructor and
/// appear to be an EOA to any extcodesize-based check.
///
/// Prevention:
/// - Do NOT rely on extcodesize to determine if a caller is an EOA
/// - msg.sender == tx.origin works but is also flawed (breaks with account abstraction)
/// - The best approach is to not distinguish between contracts and EOAs at all

/// @notice Custom errors
error CallerIsContract(address caller);
error CallerNotEOA(address caller);

/// @title Target - uses extcodesize to restrict access to EOAs only
/// @notice This contract tries to block contract callers using extcodesize
/// @dev The extcodesize check is FLAWED: contracts calling from their constructor
///      have extcodesize == 0, bypassing this check entirely.
contract Target {
    uint256 public protectedValue;

    /// @notice Check if an address is a contract using extcodesize
    /// @dev Returns false for contracts in construction (size == 0 during constructor)
    /// @param addr The address to check
    /// @return true if the address has code (appears to be a contract)
    function isContract(address addr) public view returns (bool) {
        uint256 size;
        // extcodesize returns the size of code at an address.
        // For EOAs, this is 0. For deployed contracts, this is > 0.
        // BUT: during constructor execution, the code hasn't been stored yet,
        // so extcodesize returns 0 even for contract addresses.
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    /// @notice A function that only EOAs should be able to call (FLAWED check)
    /// @dev This check can be bypassed by calling from a contract's constructor
    function protected() external {
        if (isContract(msg.sender)) {
            revert CallerIsContract(msg.sender);
        }
        protectedValue += 1;
    }
}

/// @title Attacker - bypasses extcodesize check by calling from constructor
/// @notice Calls Target.protected() from constructor, where extcodesize == 0
/// @dev During constructor execution, this contract has no code stored yet,
///      so Target.isContract(address(this)) returns false.
contract Attacker {
    bool public attacked;

    /// @param target The Target contract address to attack
    constructor(address target) {
        // At this point, this contract's code has NOT been deployed yet.
        // extcodesize(address(this)) == 0, so Target thinks we're an EOA.
        Target(target).protected();
        attacked = true;
    }
}

/// @title NormalContract - a regular contract that tries to call protected()
/// @notice Demonstrates that a normally deployed contract is blocked
contract NormalContract {
    /// @notice Attempt to call Target.protected() — will be blocked
    /// @param target The Target contract address
    function tryCall(address target) external {
        Target(target).protected();
    }
}

/// @title BetterTarget - uses tx.origin check (also flawed, but differently)
/// @notice Uses msg.sender == tx.origin to detect EOAs
/// @dev This blocks constructor attacks BUT breaks with:
///      - Account abstraction (ERC-4337)
///      - Multisig wallets
///      - Any legitimate contract interaction
///      Neither extcodesize nor tx.origin is a reliable EOA check.
contract BetterTarget {
    uint256 public protectedValue;

    /// @notice A function that only EOAs should call (tx.origin check)
    /// @dev Blocks constructor-based attacks but breaks contract composability
    function protected() external {
        if (msg.sender != tx.origin) {
            revert CallerNotEOA(msg.sender);
        }
        protectedValue += 1;
    }
}
