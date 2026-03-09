// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {Create2} from "src/applications/Create2.sol";

contract Create2Test is Test {
    Create2 public create2;

    function setUp() public {
        create2 = new Create2();
    }

    /// @notice Test same salt produces same address
    function test_SameSaltProducesSameAddress() public view {
        bytes32 salt = bytes32(uint256(1));
        bytes32 bytecodeHash = create2.getSimpleBytecodeHash();

        address predicted = create2.computeAddress(salt, bytecodeHash);
        
        // Compute again should give same result
        address predicted2 = create2.computeAddress(salt, bytecodeHash);
        
        assertEq(predicted, predicted2);
    }

    /// @notice Test different salt produces different address
    function test_DifferentSaltProducesDifferentAddress() public view {
        bytes32 salt1 = bytes32(uint256(1));
        bytes32 salt2 = bytes32(uint256(2));
        bytes32 bytecodeHash = create2.getSimpleBytecodeHash();

        address addr1 = create2.computeAddress(salt1, bytecodeHash);
        address addr2 = create2.computeAddress(salt2, bytecodeHash);
        
        assertFalse(addr1 == addr2);
    }

    /// @notice Test can compute address before deployment
    function test_ComputeAddressBeforeDeployment() public view {
        bytes32 salt = bytes32(uint256(123));
        bytes32 bytecodeHash = create2.getSimpleBytecodeHash();

        address predicted = create2.computeAddress(salt, bytecodeHash);
        
        // Address should be non-zero
        assertTrue(predicted != address(0));
    }

    /// @notice Test deploy with salt
    function test_DeployWithSalt() public {
        bytes32 salt = bytes32(uint256(42));
        
        address deployed = create2.deploySimple(salt, 0);
        
        // Should have code
        assertTrue(deployed.code.length > 0);
    }

    /// @notice Test deployed address matches prediction
    function test_DeployedMatchesPrediction() public {
        bytes32 salt = bytes32(uint256(99));
        
        address predicted = create2.computeAddress(salt, create2.getSimpleBytecodeHash());
        
        address deployed = create2.deploySimple(salt, 0);
        
        assertEq(deployed, predicted);
    }

    /// @notice Test different bytecode produces different address
    function test_DifferentBytecodeDifferentAddress() public view {
        bytes32 salt = bytes32(uint256(1));
        
        // Different bytecode hashes should produce different addresses
        bytes32 hash1 = keccak256(abi.encode("bytecode1"));
        bytes32 hash2 = keccak256(abi.encode("bytecode2"));
        
        address addr1 = create2.computeAddress(salt, hash1);
        address addr2 = create2.computeAddress(salt, hash2);
        
        assertFalse(addr1 == addr2);
    }

    /// @notice Test getSimpleBytecode
    function test_GetSimpleBytecode() public view {
        bytes memory bytecode = create2.getSimpleBytecode();
        assertTrue(bytecode.length > 0);
    }

    /// @notice Test getSimpleBytecodeHash
    function test_GetSimpleBytecodeHash() public view {
        bytes32 hash = create2.getSimpleBytecodeHash();
        assertTrue(hash != bytes32(0));
    }
}
