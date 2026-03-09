// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {TryCatch, ExternalContract} from "../../src/basic/TryCatch.sol";

/// @title TryCatchTest
/// @notice Tests for TryCatch contract
contract TryCatchTest is Test {
    TryCatch public tryCatch;
    ExternalContract public externalContract;

    function setUp() public {
        externalContract = new ExternalContract();
        tryCatch = new TryCatch(address(externalContract));
    }

    /// @notice Test try succeeds
    function test_Try_Success() public {
        tryCatch.tryWithRevert(false);
        assertEq(tryCatch.lastSuccessValue(), 42);
        assertEq(tryCatch.lastError(), "");
    }

    /// @notice Test catch Error on revert
    function test_Try_CatchError() public {
        tryCatch.tryWithRevert(true);
        assertEq(tryCatch.lastSuccessValue(), 0);
        assertEq(tryCatch.lastError(), "Explicit revert");
    }

    /// @notice Test catch Panic on division by zero
    function test_Try_CatchPanic() public {
        tryCatch.tryWithPanic(0);
        assertEq(tryCatch.lastErrorCode(), 0x12); // Division by zero panic code
        assertEq(tryCatch.lastSuccessValue(), 0);
    }

    /// @notice Test catch all
    function test_Try_CatchAll() public {
        tryCatch.tryCatchAll(true);
        assertEq(tryCatch.lastSuccessValue(), 0);
        assertEq(tryCatch.lastError(), "Unknown error");
    }

    /// @notice Test low-level call success
    function test_TryLowLevelCall_Success() public {
        bytes memory data = abi.encodeWithSignature("alwaysSucceeds()");
        (bool success,) = tryCatch.tryLowLevelCall(address(externalContract), data);
        assertTrue(success);
    }
}
