// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title SixtyThreeOver64Rule
/// @notice Demonstrates EIP-150 gas forwarding rule exploitation
/// @dev Educational example - DO NOT USE IN PRODUCTION
///
/// EIP-150 Gas Forwarding Rule:
/// When contract A calls contract B, only 63/64 of the remaining gas is forwarded
/// to B. The remaining 1/64 is reserved for A to finish execution after B returns.
///
/// This creates a subtle attack vector:
/// - An attacker can provide just enough gas so that B receives less than it needs
/// - B runs out of gas and fails (returns false on a low-level call)
/// - A still has its reserved 1/64 gas and continues execution
/// - If A doesn't check the return value, it silently proceeds as if B succeeded
///
/// Prevention:
/// - ALWAYS check return values of low-level calls (.call, .delegatecall, .staticcall)
/// - Use high-level calls (contract.function()) which auto-revert on failure
/// - Set explicit minimum gas requirements for critical operations
/// - Use Solidity's built-in function calls instead of assembly when possible

/// @notice Custom errors
error InsufficientGas(uint256 available, uint256 required);
error CallFailed(address target);
error ExternalCallFailed();

/// @title Target - a contract that requires minimum gas to complete work
/// @notice Performs gas-consuming operations that need a minimum gas threshold
contract Target {
    uint256 public lastResult;
    bool public workCompleted;

    /// @notice Minimum gas needed for doWork to complete
    uint256 public constant MIN_GAS = 50_000;

    /// @notice Perform work that requires gas — reverts if insufficient
    /// @dev Uses a storage write to consume gas. If called with too little gas,
    ///      the transaction reverts, which is the safe behavior.
    /// @return success Always true if the function completes
    function doWork() external returns (bool success) {
        if (gasleft() < MIN_GAS) {
            revert InsufficientGas(gasleft(), MIN_GAS);
        }

        // Simulate meaningful work with gas-consuming storage operations
        lastResult = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
        workCompleted = true;

        return true;
    }

    /// @notice Gas-consuming function that uses significant gas
    /// @dev Writes to storage multiple times to consume gas predictably
    function gasConsuming() external {
        // Each SSTORE costs ~20,000 gas (cold) or ~5,000 gas (warm)
        for (uint256 i = 0; i < 5; i++) {
            lastResult = uint256(keccak256(abi.encodePacked(lastResult, i)));
        }
        workCompleted = true;
    }

    /// @notice Reset state for testing
    function reset() external {
        lastResult = 0;
        workCompleted = false;
    }
}

/// @title Caller - demonstrates unsafe and safe external call patterns
/// @notice Shows the difference between checking and ignoring return values
contract Caller {
    bool public lastCallSuccess;
    bool public actionCompleted;

    event CallResult(bool success, uint256 gasUsed);

    /// @notice Call target with specific gas amount (UNSAFE if return unchecked)
    /// @dev Forwards only the specified gas. Due to 63/64 rule, the target
    ///      may receive less than gasAmount if remaining gas is the bottleneck.
    /// @param target The contract to call
    /// @param gasAmount The gas to forward
    /// @return success Whether the call succeeded
    function callWithGas(address target, uint256 gasAmount) external returns (bool success) {
        uint256 gasBefore = gasleft();

        // Low-level call with specific gas — target.doWork()
        // The 63/64 rule means target gets min(gasAmount, 63/64 * gasleft())
        (success,) = target.call{gas: gasAmount}(
            abi.encodeWithSignature("doWork()")
        );

        uint256 gasUsed = gasBefore - gasleft();
        lastCallSuccess = success;
        emit CallResult(success, gasUsed);

        return success;
    }

    /// @notice Call target and verify result (SAFE - checks return value)
    /// @dev This is the correct pattern: always check the return value of
    ///      low-level calls and revert if the call failed.
    /// @param target The contract to call
    function callAndVerify(address target) external {
        (bool success, bytes memory data) = target.call(
            abi.encodeWithSignature("doWork()")
        );

        // SAFE: explicitly check return value and revert on failure
        if (!success) {
            revert ExternalCallFailed();
        }

        // Decode and verify the return value
        bool result = abi.decode(data, (bool));
        if (!result) {
            revert CallFailed(target);
        }

        lastCallSuccess = true;
        actionCompleted = true;
    }

    /// @notice Unsafe call pattern — ignores return value (VULNERABLE)
    /// @dev This is the dangerous pattern: the call might fail silently,
    ///      but execution continues as if everything succeeded.
    /// @param target The contract to call
    function unsafeCall(address target) external {
        // VULNERABLE: return value is ignored!
        // If the call fails (out of gas, revert), this code continues
        // as if the call succeeded.
        target.call(
            abi.encodeWithSignature("doWork()")
        );

        // This executes even if the call above failed
        actionCompleted = true;
    }

    /// @notice Demonstrate gas forwarding: show how much gas target receives
    /// @param target The contract to call
    /// @return gasForwarded Approximate gas the target received
    function measureGasForwarding(address target) external returns (uint256 gasForwarded) {
        uint256 gasBefore = gasleft();

        // Call with all available gas — target gets 63/64 of remaining
        (bool success,) = target.call(
            abi.encodeWithSignature("doWork()")
        );

        uint256 gasAfter = gasleft();
        gasForwarded = gasBefore - gasAfter;
        lastCallSuccess = success;

        return gasForwarded;
    }
}
