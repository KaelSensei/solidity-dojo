// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ArithmeticOverflow
/// @notice Demonstrates pre-0.8 overflow/underflow behavior vs. 0.8+ safe math
/// @dev Educational example - DO NOT USE IN PRODUCTION
/// Before Solidity 0.8, all arithmetic silently wrapped on overflow/underflow.
/// This meant a uint256 balance of 0 minus 1 would become type(uint256).max.
/// Solidity 0.8+ added automatic overflow/underflow checks that revert on wrap.
/// The `unchecked` block in 0.8+ explicitly opts out of these checks, mimicking
/// the dangerous pre-0.8 behavior.

/// @notice Custom errors for SafeToken
error InsufficientBalance(address sender, uint256 balance, uint256 amount);

/// @title VulnerableToken - simulates pre-0.8 overflow behavior using unchecked
/// @notice This token uses unchecked math, allowing underflow exploits
/// @dev In real pre-0.8 code, ALL math behaved like this unchecked block.
///      Libraries like SafeMath were the only defense.
contract VulnerableToken {
    mapping(address => uint256) public balances;

    /// @notice Mint tokens to an address
    /// @param to The recipient address
    /// @param amount The amount to mint
    function mint(address to, uint256 amount) external {
        balances[to] += amount;
    }

    /// @notice Transfer tokens (VULNERABLE - uses unchecked math)
    /// @dev The unchecked block disables overflow/underflow checks.
    ///      If sender has 0 tokens and transfers 1, their balance wraps to
    ///      type(uint256).max (2^256 - 1), giving them essentially infinite tokens.
    /// @param to The recipient address
    /// @param amount The amount to transfer
    function transfer(address to, uint256 amount) external {
        unchecked {
            // This subtraction can underflow! If balances[msg.sender] < amount,
            // the result wraps around to a huge number instead of reverting.
            balances[msg.sender] -= amount;
            balances[to] += amount;
        }
    }
}

/// @title SafeToken - default 0.8+ behavior prevents overflow/underflow
/// @notice This token uses default checked math, auto-reverting on overflow
/// @dev No unchecked block means Solidity 0.8+ automatically checks for
///      overflow and underflow on every arithmetic operation.
contract SafeToken {
    mapping(address => uint256) public balances;

    /// @notice Mint tokens to an address
    /// @param to The recipient address
    /// @param amount The amount to mint
    function mint(address to, uint256 amount) external {
        balances[to] += amount;
    }

    /// @notice Transfer tokens (SAFE - default checked math)
    /// @dev If balances[msg.sender] < amount, this reverts with an arithmetic
    ///      underflow panic (Panic(0x11)) instead of wrapping around.
    /// @param to The recipient address
    /// @param amount The amount to transfer
    function transfer(address to, uint256 amount) external {
        // Default checked math: reverts on underflow
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
}
