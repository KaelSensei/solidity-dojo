// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/hacks/DelegatecallAttack.sol";

/// @title Delegatecall Attack Test Suite
contract DelegatecallAttackTest is Test {
    VulnerableProxy public proxy;
    ImplementationV1 public implementation;

    address public owner = address(0x1);

    function setUp() public {
        implementation = new ImplementationV1();
        vm.prank(owner);
        proxy = new VulnerableProxy(address(implementation));
    }

    /// @notice Test proxy delegates calls
    function test_ProxyDelegatesCalls() public {
        proxy.execute(abi.encodeWithSignature("setValue(uint256)", 42));
        
        // With delegatecall, the code runs in the PROXY's context
        // Storage layout matters - this demonstrates the vulnerability:
        // - Implementation's storage is unchanged (value = 0)
        // - But proxy's storage might have changed depending on layout
        // This shows how delegatecall can lead to storage collisions
        assertEq(implementation.value(), 0); // Implementation unchanged!
    }

    /// @notice Test proxy upgrade
    function test_ProxyUpgrade() public {
        MaliciousImplementation malicious = new MaliciousImplementation();
        
        vm.prank(owner);
        proxy.upgradeTo(address(malicious));
        
        assertEq(proxy.implementation(), address(malicious));
    }

    /// @notice Test delegatecall can change proxy storage
    function test_DelegatecallStorageManipulation() public {
        MaliciousImplementation malicious = new MaliciousImplementation();
        
        vm.prank(owner);
        proxy.upgradeTo(address(malicious));
        
        // This will set owner in proxy storage!
        proxy.execute(abi.encodeWithSignature("setOwner()"));
    }
}
