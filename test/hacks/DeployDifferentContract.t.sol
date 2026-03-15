// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/hacks/DeployDifferentContract.sol";

/// @title DeployDifferentContract Test Suite
/// @notice Demonstrates CREATE2 deterministic deployment and address prediction
/// @dev NOTE: Full selfdestruct + re-deploy attack cannot be fully demonstrated
///      in modern Foundry EVM due to EIP-6780 (Dencun) restrictions.
///      selfdestruct no longer clears contract code unless called in the same
///      transaction as creation. Tests focus on the concepts that ARE testable.
contract DeployDifferentContractTest is Test {
    Deployer public deployer;

    address public attacker = makeAddr("attacker");
    bytes32 public constant SALT = bytes32(uint256(1));

    function setUp() public {
        deployer = new Deployer();
    }

    /// @notice CREATE2 deploys to a predictable address
    function test_CREATE2PredictableAddress() public {
        // Compute expected address before deployment
        address predicted = deployer.computeAddressA(SALT);

        // Deploy — actual address should match prediction
        address actual = deployer.deployA(SALT);

        assertEq(actual, predicted);
    }

    /// @notice ContractA and ContractB get DIFFERENT addresses with same salt
    function test_DifferentBytecodeGetsDifferentAddress() public {
        // CREATE2 address depends on init code hash, so different contracts
        // get different addresses even with the same salt and deployer
        address addrA = deployer.computeAddressA(SALT);
        address addrB = deployer.computeAddressB(SALT);

        // Different bytecode = different address
        assertTrue(addrA != addrB);
    }

    /// @notice ContractA deployed via CREATE2 works correctly
    function test_ContractAFunctionality() public {
        address addr = deployer.deployA(SALT);
        ContractA contractA = ContractA(addr);

        contractA.setValue(42);
        assertEq(contractA.getValue(), 42);
        assertEq(contractA.whoAmI(), "ContractA");
    }

    /// @notice ContractB has different functionality than ContractA
    function test_ContractBFunctionality() public {
        address addr = deployer.deployB(SALT);
        ContractB contractB = ContractB(payable(addr));

        assertEq(contractB.whoAmI(), "ContractB");
    }

    /// @notice Same salt + same deployer always produces the same address
    function test_DeterministicAddresses() public {
        address predicted1 = deployer.computeAddressA(SALT);
        address predicted2 = deployer.computeAddressA(SALT);
        assertEq(predicted1, predicted2);
    }

    /// @notice Different salts produce different addresses
    function test_DifferentSaltsDifferentAddresses() public {
        address addr1 = deployer.computeAddressA(bytes32(uint256(1)));
        address addr2 = deployer.computeAddressA(bytes32(uint256(2)));
        assertTrue(addr1 != addr2);
    }

    /// @notice Demonstrate selfdestruct sends ETH (post-Dencun behavior)
    /// @dev Post-EIP-6780, selfdestruct only clears code if called in the same
    ///      transaction as creation. In most cases it just sends ETH now.
    function test_SelfdestructSendsETH() public {
        address addr = deployer.deployA(SALT);
        ContractA contractA = ContractA(addr);

        // Send some ETH to ContractA
        vm.deal(addr, 5 ether);
        assertEq(addr.balance, 5 ether);

        // The deployer is the owner of ContractA (deployer called new ContractA)
        // We need to call kill from the owner which is the deployer contract
        // Since deployer is a contract without a kill-forwarding function,
        // we demonstrate the concept by direct pranking
        address contractOwner = contractA.owner();
        vm.prank(contractOwner);
        contractA.kill();

        // ETH was sent to the owner via selfdestruct
        assertGt(contractOwner.balance, 0);
    }

    /// @notice Only owner can call selfdestruct
    function test_OnlyOwnerCanKill() public {
        address addr = deployer.deployA(SALT);
        ContractA contractA = ContractA(addr);

        vm.prank(attacker);
        vm.expectRevert(abi.encodeWithSelector(OnlyOwner.selector, attacker));
        contractA.kill();
    }

    /// @notice Explain the full attack scenario in a conceptual test
    /// @dev This documents the attack flow even though full re-deployment
    ///      is not possible post-Dencun without same-transaction creation+destruction
    function test_ConceptualAttackFlow() public {
        // Step 1: Deploy ContractA at a known address
        address addrA = deployer.deployA(SALT);
        ContractA contractA = ContractA(addrA);
        assertEq(contractA.whoAmI(), "ContractA");

        // Step 2: Address gets trusted by users/protocols
        // (represented by this assertion that the contract works as expected)
        contractA.setValue(100);
        assertEq(contractA.getValue(), 100);

        // Step 3: In pre-Dencun EVM, attacker would selfdestruct ContractA
        // Step 4: Then re-deploy ContractB at the same address using same salt
        // Step 5: Users interacting with the trusted address now hit ContractB
        //
        // Post-Dencun: This attack vector is largely mitigated because
        // selfdestruct no longer clears contract code (except in creation tx).
        // The address would still have ContractA's code.

        // Demonstrate that ContractB exists at a DIFFERENT address
        address addrB = deployer.deployB(SALT);
        ContractB contractB = ContractB(payable(addrB));
        assertEq(contractB.whoAmI(), "ContractB");

        // In pre-Dencun: addrA could have been reused for ContractB
        // In post-Dencun: they are forever different addresses
        assertTrue(addrA != addrB);
    }
}
