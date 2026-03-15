// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/applications/SimpleBytecodeContract.sol";

/// @title SimpleBytecodeContract Test Suite
contract SimpleBytecodeContractTest is Test {
    SimpleBytecodeContract public deployer;

    function setUp() public {
        deployer = new SimpleBytecodeContract();
    }

    function test_DeploySimpleContract() public {
        // Runtime (10 bytes): PUSH1 0x42, PUSH1 0x00, MSTORE, PUSH1 0x20, PUSH1 0x00, RETURN
        //   -> returns 0x42 left-padded to 32 bytes when called
        // Init code (11 bytes): copy runtime to memory and return it
        //   PUSH1 0x0a (size=10), DUP1, PUSH1 0x0b (offset=11), PUSH1 0x00, CODECOPY, PUSH1 0x00, RETURN
        bytes memory initCode = hex"600a80600b6000396000f3604260005260206000f3";

        address deployed = deployer.deploy(initCode);

        assertTrue(deployed != address(0), "Deployed address should be non-zero");
        assertTrue(deployed.code.length > 0, "Deployed contract should have code");
    }

    function test_DeployedContractWorks() public {
        bytes memory initCode = hex"600a80600b6000396000f3604260005260206000f3";

        address deployed = deployer.deploy(initCode);

        // Call the deployed contract — it should return 32 bytes with value 0x42
        (bool success, bytes memory data) = deployed.call("");
        assertTrue(success, "Call to deployed contract should succeed");
        assertEq(data.length, 32, "Should return 32 bytes");
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0x42, "Deployed contract should return 0x42");
    }

    function test_DeployEmitsEvent() public {
        bytes memory initCode = hex"600a80600b6000396000f3604260005260206000f3";

        // Record logs and check for Deployed event
        vm.recordLogs();
        deployer.deploy(initCode);
        Vm.Log[] memory entries = vm.getRecordedLogs();

        bool found = false;
        for (uint256 i = 0; i < entries.length; i++) {
            if (entries[i].topics[0] == keccak256("Deployed(address,uint256)")) {
                found = true;
                break;
            }
        }
        assertTrue(found, "Deployed event should be emitted");
    }

    function test_DeployWithValueSendsETH() public {
        // Runtime: just STOP (00) — 1 byte
        // Init code: PUSH1 0x01, DUP1, PUSH1 0x0a, PUSH1 0x00, CODECOPY, PUSH1 0x00, RETURN, STOP
        bytes memory initCode = hex"600180600a6000396000f300";

        vm.deal(address(this), 1 ether);
        address deployed = deployer.deployWithValue{value: 0.5 ether}(initCode);

        assertTrue(deployed != address(0), "Deployed address should be non-zero");
        assertEq(address(deployed).balance, 0.5 ether, "Deployed contract should hold ETH");
    }

    function test_FailedDeploymentReverts() public {
        // Invalid bytecode: REVERT immediately
        bytes memory badInitCode = hex"60006000fd";

        vm.expectRevert(SimpleBytecodeContract.DeploymentFailed.selector);
        deployer.deploy(badInitCode);
    }
}
