// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {HelloWorld} from "../../src/basic/HelloWorld.sol";

contract HelloWorldTest is Test {
    HelloWorld public hello;

    function setUp() public {
        hello = new HelloWorld();
    }

    /// @notice Unit test: greet() should return "Hello World"
    function test_greet_returnsHelloWorld() public view {
        assertEq(hello.greet(), "Hello World");
    }
}
