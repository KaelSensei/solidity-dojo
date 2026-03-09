// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {CustomError} from "../../src/basic/CustomError.sol";

/// @title CustomErrorTest
/// @notice Tests for CustomError contract
contract CustomErrorTest is Test {
    CustomError public customError;

    function setUp() public {
        customError = new CustomError();
    }

    /// @notice Test deposit works correctly
    function test_Deposit() public {
        vm.expectEmit(true, false, false, true);
        emit CustomError.Deposit(address(this), 100);
        customError.deposit{value: 100}();
        assertEq(customError.balances(address(this)), 100);
    }

    /// @notice Test deposit reverts on zero amount
    function test_Deposit_ZeroAmount_Reverts() public {
        vm.expectRevert(CustomError.ZeroAmount.selector);
        customError.deposit{value: 0}();
    }

    /// @notice Test withdraw works correctly
    function test_Withdraw() public {
        address user = makeAddr("user");
        vm.deal(user, 100);
        vm.prank(user);
        customError.deposit{value: 100}();
        
        vm.prank(user);
        customError.withdraw(50);
        
        assertEq(customError.balances(user), 50);
    }

    /// @notice Test withdraw reverts on zero amount
    function test_Withdraw_ZeroAmount_Reverts() public {
        vm.expectRevert(CustomError.ZeroAmount.selector);
        customError.withdraw(0);
    }

    /// @notice Test withdraw reverts on insufficient balance with parameters
    function test_Withdraw_InsufficientBalance_Reverts() public {
        customError.deposit{value: 50}();
        
        vm.expectRevert(
            abi.encodeWithSelector(CustomError.InsufficientBalance.selector, 100, 50)
        );
        customError.withdraw(100);
    }

    /// @notice Test transfer works correctly
    function test_Transfer() public {
        address recipient = makeAddr("recipient");
        customError.deposit{value: 100}();
        
        customError.transfer(recipient, 30);
        
        assertEq(customError.balances(address(this)), 70);
        assertEq(customError.balances(recipient), 30);
    }

    /// @notice Test transfer reverts on zero address
    function test_Transfer_ZeroAddress_Reverts() public {
        customError.deposit{value: 100}();
        vm.expectRevert(CustomError.ZeroAddress.selector);
        customError.transfer(address(0), 50);
    }

    /// @notice Test unauthorized admin call reverts with address
    function test_AdminOnly_Unauthorized_Reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(CustomError.Unauthorized.selector, address(this))
        );
        customError.adminOnly();
    }

    /// @notice Test receive function
    function test_Receive() public {
        (bool success,) = address(customError).call{value: 50}("");
        assertTrue(success);
        assertEq(customError.balances(address(this)), 50);
    }
}
