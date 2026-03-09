// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ExternalContract
/// @notice Contract for testing try/catch
contract ExternalContract {
    /// @notice May revert with custom error
    function mayRevert(bool _shouldRevert) external pure returns (uint256) {
        require(!_shouldRevert, "Explicit revert");
        return 42;
    }

    /// @notice May panic (division by zero)
    function mayPanic(uint256 _divisor) external pure returns (uint256) {
        return 100 / _divisor;
    }

    /// @notice Always succeeds
    function alwaysSucceeds() external pure returns (uint256) {
        return 100;
    }
}

/// @title TryCatch
/// @notice Demonstrates try/catch error handling
contract TryCatch {
    /// @notice Last error message
    string public lastError;
    /// @notice Last error code
    uint256 public lastErrorCode;
    /// @notice Last success value
    uint256 public lastSuccessValue;

    ExternalContract public externalContract;

    constructor(address _external) {
        externalContract = ExternalContract(_external);
    }

    /// @notice Try/catch with string error
    function tryWithRevert(bool _shouldRevert) external {
        try externalContract.mayRevert(_shouldRevert) returns (uint256 value) {
            lastSuccessValue = value;
            lastError = "";
        } catch Error(string memory reason) {
            lastError = reason;
            lastSuccessValue = 0;
        }
    }

    /// @notice Try/catch with panic (arithmetic error)
    function tryWithPanic(uint256 _divisor) external {
        try externalContract.mayPanic(_divisor) returns (uint256 value) {
            lastSuccessValue = value;
            lastError = "";
        } catch Panic(uint256 code) {
            lastError = "Panic";
            lastErrorCode = code;
            lastSuccessValue = 0;
        }
    }

    /// @notice Try/catch all errors
    function tryCatchAll(bool _shouldRevert) external {
        try externalContract.mayRevert(_shouldRevert) returns (uint256 value) {
            lastSuccessValue = value;
            lastError = "";
        } catch {
            lastError = "Unknown error";
            lastSuccessValue = 0;
        }
    }

    /// @notice Try/catch low-level call
    function tryLowLevelCall(address _target, bytes calldata _data) external returns (bool, bytes memory) {
        (bool success, bytes memory result) = _target.call(_data);
        if (!success) {
            lastError = "Low-level call failed";
        }
        return (success, result);
    }
}
