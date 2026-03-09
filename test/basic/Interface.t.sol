// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {MockToken, TokenUser} from "../../src/basic/Interface.sol";

/// @title InterfaceTest
/// @notice Tests for Interface contracts
contract InterfaceTest is Test {
    MockToken public token;
    TokenUser public tokenUser;
    address public user;

    function setUp() public {
        token = new MockToken(1000 ether);
        user = makeAddr("user");
        tokenUser = new TokenUser(address(token));
        
        // Send some tokens to tokenUser
        token.transfer(address(tokenUser), 100 ether);
    }

    /// @notice Test can get balance through interface
    function test_GetTokenBalance() public view {
        assertEq(tokenUser.getTokenBalance(address(tokenUser)), 100 ether);
    }

    /// @notice Test can transfer through interface
    function test_TransferTokens() public {
        tokenUser.transferTokens(user, 50 ether);
        assertEq(token.balanceOf(user), 50 ether);
        assertEq(token.balanceOf(address(tokenUser)), 50 ether);
    }

    /// @notice Test can get total supply through interface
    function test_GetTotalSupply() public view {
        assertEq(tokenUser.getTotalSupply(), 1000 ether);
    }

    /// @notice Test token direct transfer
    function test_TokenDirectTransfer() public {
        token.transfer(user, 100 ether);
        assertEq(token.balanceOf(user), 100 ether);
    }

    /// @notice Test token approval and transferFrom
    function test_TokenApproveAndTransferFrom() public {
        address spender = makeAddr("spender");
        token.approve(spender, 50 ether);
        
        vm.prank(spender);
        token.transferFrom(address(this), user, 50 ether);
        
        assertEq(token.balanceOf(user), 50 ether);
    }
}
