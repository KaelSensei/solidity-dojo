// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {Implementation, Proxy, DelegatecallDemo} from "../../src/basic/Delegatecall.sol";

/// @title DelegatecallTest
/// @notice Tests for Delegatecall contracts
contract DelegatecallTest is Test {
    Implementation public implementation;
    Proxy public proxy;
    DelegatecallDemo public demo;

    function setUp() public {
        implementation = new Implementation();
        proxy = new Proxy(address(implementation));
        demo = new DelegatecallDemo();
    }

    /// @notice Test delegatecall updates proxy storage
    function test_Delegatecall_UpdatesProxyStorage() public {
        // Call through proxy
        (bool success,) = address(proxy).call(abi.encodeWithSignature("setValue(uint256)", 42));
        assertTrue(success);
        assertEq(proxy.value(), 42);
        // Implementation storage unchanged
        assertEq(implementation.value(), 0);
    }

    /// @notice Test delegatecall context
    function test_Delegatecall_Context() public {
        demo.executeDelegatecall(address(demo), 100);
        assertEq(demo.value(), 100);
        assertEq(demo.sender(), address(this));
    }

    /// @notice Test proxy getValue
    function test_Proxy_GetValue() public {
        (bool success,) = address(proxy).call(abi.encodeWithSignature("setValue(uint256)", 50));
        assertTrue(success);
        
        (bool success2, bytes memory result) = address(proxy).staticcall(abi.encodeWithSignature("getValue()"));
        assertTrue(success2);
        assertEq(abi.decode(result, (uint256)), 50);
    }
}
