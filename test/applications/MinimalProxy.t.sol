// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {MinimalProxy, MinimalProxyFactory} from "src/applications/MinimalProxy.sol";

contract MinimalProxyTest is Test {
    MinimalProxy public minimalProxy;
    MinimalProxyFactory public factory;
    
    Implementation public implementation;

    function setUp() public {
        implementation = new Implementation();
        minimalProxy = new MinimalProxy(address(implementation));
        factory = new MinimalProxyFactory();
    }

    /// @notice Test clone creates minimal proxy
    function test_CloneCreatesProxy() public {
        address proxy = minimalProxy.clone();
        
        assertTrue(proxy != address(0));
        assertTrue(proxy.code.length > 0);
    }

    /// @notice Test proxy delegates to implementation
    function test_ProxyDelegatesToImplementation() public {
        address proxy = minimalProxy.clone();
        
        Implementation impl = Implementation(proxy);
        
        impl.setValue(42);
        assertEq(impl.getValue(), 42);
    }

    /// @notice Test many clones are cheap to deploy
    function test_ManyClones() public {
        address[] memory proxies = minimalProxy.cloneMany(5);
        
        assertEq(proxies.length, 5);
        
        for (uint256 i = 0; i < proxies.length; i++) {
            assertTrue(proxies[i] != address(0));
        }
    }

    /// @notice Test predict clone address
    function test_PredictCloneAddress() public view {
        address predicted = minimalProxy.predictCloneAddress();
        assertTrue(predicted != address(0));
    }

    /// @notice Test predict with salt
    function test_PredictCloneAddressWithSalt() public view {
        bytes32 salt = bytes32(uint256(42));
        address predicted = minimalProxy.predictCloneAddress(salt);
        assertTrue(predicted != address(0));
    }

    /// @notice Test clone deterministic
    function test_CloneDeterministic() public {
        bytes32 salt = bytes32(uint256(999));
        
        address proxy1 = minimalProxy.cloneDeterministic(salt);
        
        // Verify it was deployed
        assertTrue(proxy1 != address(0));
        assertTrue(proxy1.code.length > 0);
    }

    /// @notice Test factory deploy
    function test_FactoryDeploy() public {
        address proxy = factory.deploy(address(implementation));
        
        assertTrue(proxy != address(0));
        assertTrue(proxy.code.length > 0);
    }

    /// @notice Test factory deterministic
    function test_FactoryDeployDeterministic() public {
        bytes32 salt = bytes32(uint256(99));
        
        address proxy = factory.deployDeterministic(address(implementation), salt);
        
        assertTrue(proxy != address(0));
    }

    /// @notice Test predict address
    function test_FactoryPredictAddress() public view {
        bytes32 salt = bytes32(uint256(55));
        
        address predicted = factory.predictAddress(address(implementation), salt);
        
        assertTrue(predicted != address(0));
    }

    /// @notice Test isDeployed
    function test_IsDeployed() public {
        address proxy = minimalProxy.clone();
        
        assertTrue(factory.isDeployed(proxy));
        assertFalse(factory.isDeployed(address(0x1234)));
    }

    /// @notice Test getImplementation
    function test_GetImplementation() public view {
        assertEq(minimalProxy.getImplementation(), address(implementation));
    }
}

contract Implementation {
    uint256 public value;

    function setValue(uint256 _value) external {
        value = _value;
    }

    function getValue() external view returns (uint256) {
        return value;
    }
}
