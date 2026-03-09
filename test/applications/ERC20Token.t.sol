// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/applications/ERC20Token.sol";

/// @title ERC20Token Test Suite
contract ERC20TokenTest is Test {
    ERC20Token public token;
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public {
        token = new ERC20Token("TestToken", "TT", 18);
        token.mint(alice, 1000e18);
    }

    function test_InitialState() public view {
        assertEq(token.name(), "TestToken");
        assertEq(token.symbol(), "TT");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 1000e18);
        assertEq(token.balanceOf(alice), 1000e18);
    }

    function test_Transfer() public {
        vm.prank(alice);
        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, bob, 100e18);
        token.transfer(bob, 100e18);

        assertEq(token.balanceOf(alice), 900e18);
        assertEq(token.balanceOf(bob), 100e18);
    }

    function test_TransferInsufficientBalance() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(ERC20Token.InsufficientBalance.selector, 1000e18, 2000e18));
        token.transfer(bob, 2000e18);
    }

    function test_TransferToZeroAddress() public {
        vm.prank(alice);
        vm.expectRevert(ERC20Token.ZeroAddress.selector);
        token.transfer(address(0), 100e18);
    }

    function test_Approve() public {
        vm.prank(alice);
        vm.expectEmit(true, true, false, true);
        emit Approval(alice, bob, 500e18);
        token.approve(bob, 500e18);

        assertEq(token.allowance(alice, bob), 500e18);
    }

    function test_TransferFrom() public {
        vm.prank(alice);
        token.approve(bob, 500e18);

        vm.prank(bob);
        token.transferFrom(alice, bob, 200e18);

        assertEq(token.balanceOf(alice), 800e18);
        assertEq(token.balanceOf(bob), 200e18);
        assertEq(token.allowance(alice, bob), 300e18);
    }

    function test_TransferFromInsufficientAllowance() public {
        vm.prank(alice);
        token.approve(bob, 100e18);

        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(ERC20Token.InsufficientAllowance.selector, 100e18, 200e18));
        token.transferFrom(alice, bob, 200e18);
    }

    function test_Mint() public {
        token.mint(bob, 500e18);
        assertEq(token.balanceOf(bob), 500e18);
        assertEq(token.totalSupply(), 1500e18);
    }

    function test_MintOnlyOwner() public {
        vm.prank(alice);
        vm.expectRevert(ERC20Token.NotOwner.selector);
        token.mint(bob, 100e18);
    }

    function test_Burn() public {
        vm.prank(alice);
        token.burn(300e18);
        assertEq(token.balanceOf(alice), 700e18);
        assertEq(token.totalSupply(), 700e18);
    }

    function test_BurnInsufficientBalance() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(ERC20Token.InsufficientBalance.selector, 1000e18, 2000e18));
        token.burn(2000e18);
    }

    function testFuzz_transfer(uint256 amount) public {
        amount = bound(amount, 0, 1000e18);
        vm.prank(alice);
        token.transfer(bob, amount);
        assertEq(token.balanceOf(alice), 1000e18 - amount);
        assertEq(token.balanceOf(bob), amount);
    }

    function testFuzz_approve(uint256 amount) public {
        vm.prank(alice);
        token.approve(bob, amount);
        assertEq(token.allowance(alice, bob), amount);
    }

    function testFuzz_mintAndBurn(uint256 mintAmt, uint256 burnAmt) public {
        mintAmt = bound(mintAmt, 1, 1e30);
        burnAmt = bound(burnAmt, 0, mintAmt);
        token.mint(bob, mintAmt);
        vm.prank(bob);
        token.burn(burnAmt);
        assertEq(token.balanceOf(bob), mintAmt - burnAmt);
        assertEq(token.totalSupply(), 1000e18 + mintAmt - burnAmt);
    }
}
