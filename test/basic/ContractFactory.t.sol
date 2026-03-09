// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {ContractFactory, SimpleContract} from "../../src/basic/ContractFactory.sol";

/// @title ContractFactoryTest
/// @notice Tests for ContractFactory contract
contract ContractFactoryTest is Test {
    ContractFactory public factory;

    function setUp() public {
        factory = new ContractFactory();
    }

    /// @notice Test create contract
    function test_CreateContract() public {
        SimpleContract newContract = factory.createContract(100);
        assertEq(newContract.value(), 100);
        assertEq(newContract.owner(), address(factory));
        assertEq(factory.getContractCount(), 1);
    }

    /// @notice Test create multiple contracts
    function test_CreateMultipleContracts() public {
        factory.createContract(100);
        factory.createContract(200);
        factory.createContract(300);
        
        assertEq(factory.getContractCount(), 3);
        assertEq(factory.getContract(0).value(), 100);
        assertEq(factory.getContract(1).value(), 200);
        assertEq(factory.getContract(2).value(), 300);
    }

    /// @notice Test CREATE2 with salt
    function test_CreateContractWithSalt() public {
        bytes32 salt = keccak256("test_salt");
        address predicted = factory.predictAddress(50, salt);
        
        SimpleContract newContract = factory.createContractWithSalt(50, salt);
        assertEq(address(newContract), predicted);
        assertEq(newContract.value(), 50);
    }

    /// @notice Test predict address is deterministic
    function test_PredictAddress() public {
        uint256 value = 42;
        bytes32 salt = keccak256("deterministic");
        
        address predicted = factory.predictAddress(value, salt);
        SimpleContract created = factory.createContractWithSalt(value, salt);
        
        assertEq(address(created), predicted);
    }
}
