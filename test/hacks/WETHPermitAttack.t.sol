// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/hacks/WETHPermitAttack.sol";

/// @title WETHPermitAttack Test Suite
/// @notice Demonstrates WETH permit griefing and the safe alternative
contract WETHPermitAttackTest is Test {
    SimpleWETH public weth;
    VulnerableVault public vulnerableVault;
    SafeVault public safeVault;

    address public user = makeAddr("user");
    address public attacker = makeAddr("attacker");

    function setUp() public {
        weth = new SimpleWETH();
        vulnerableVault = new VulnerableVault(address(weth));
        safeVault = new SafeVault(address(weth));

        // Fund user with ETH and WETH
        vm.deal(user, 20 ether);
        vm.prank(user);
        weth.deposit{value: 10 ether}();
    }

    /// @notice WETH deposit and withdraw works normally
    function test_WETHDepositWithdraw() public {
        assertEq(weth.balanceOf(user), 10 ether);

        vm.prank(user);
        weth.withdraw(5 ether);

        assertEq(weth.balanceOf(user), 5 ether);
        assertEq(user.balance, 15 ether);
    }

    /// @notice WETH transfer works normally
    function test_WETHTransfer() public {
        address recipient = makeAddr("recipient");

        vm.prank(user);
        weth.transfer(recipient, 3 ether);

        assertEq(weth.balanceOf(user), 7 ether);
        assertEq(weth.balanceOf(recipient), 3 ether);
    }

    /// @notice Calling permit on WETH fails — no permit function exists
    function test_PermitOnWETHReverts() public {
        // WETH doesn't implement permit(), so a low-level call returns false
        (bool success,) = address(weth).call(
            abi.encodeWithSignature(
                "permit(address,address,uint256,uint256,uint8,bytes32,bytes32)",
                user,
                address(vulnerableVault),
                uint256(1 ether),
                uint256(block.timestamp + 1 hours),
                uint8(27),
                bytes32(0),
                bytes32(0)
            )
        );
        // Call fails because WETH has no permit function
        assertFalse(success);
    }

    /// @notice VulnerableVault.depositWithPermit fails on WETH
    function test_VulnerableVaultFailsWithWETH() public {
        vm.prank(user);
        weth.approve(address(vulnerableVault), 5 ether);

        // Even with approval, depositWithPermit fails because permit() reverts
        vm.prank(user);
        vm.expectRevert(PermitFailed.selector);
        vulnerableVault.depositWithPermit(
            5 ether,
            block.timestamp + 1 hours,
            27,
            bytes32(0),
            bytes32(0)
        );

        // Deposit didn't go through
        assertEq(vulnerableVault.deposits(user), 0);
    }

    /// @notice SafeVault handles permit failure gracefully with pre-approval
    function test_SafeVaultWorksWithPreApproval() public {
        // User approves the safe vault first
        vm.prank(user);
        weth.approve(address(safeVault), 5 ether);

        // depositWithPermit works even though permit fails —
        // it falls through to use the existing approval
        vm.prank(user);
        safeVault.depositWithPermit(
            5 ether,
            block.timestamp + 1 hours,
            27,
            bytes32(0),
            bytes32(0)
        );

        assertEq(safeVault.deposits(user), 5 ether);
        assertEq(weth.balanceOf(address(safeVault)), 5 ether);
    }

    /// @notice SafeVault direct deposit works with approval
    function test_SafeVaultDirectDeposit() public {
        vm.prank(user);
        weth.approve(address(safeVault), 3 ether);

        vm.prank(user);
        safeVault.deposit(3 ether);

        assertEq(safeVault.deposits(user), 3 ether);
    }

    /// @notice SafeVault without approval reverts on transferFrom (clear error)
    function test_SafeVaultNoApprovalReverts() public {
        // No approval set — transferFrom will revert after permit fails
        vm.prank(user);
        vm.expectRevert();
        safeVault.depositWithPermit(
            5 ether,
            block.timestamp + 1 hours,
            27,
            bytes32(0),
            bytes32(0)
        );
    }

    /// @notice Griefing scenario: if permit existed, attacker could front-run it
    /// @dev Conceptual test documenting the front-running attack vector:
    ///      1. User signs permit(user, vault, 5 ETH, deadline, v, r, s)
    ///      2. User submits depositWithPermit tx to mempool
    ///      3. Attacker sees tx, extracts permit params
    ///      4. Attacker calls permit() directly (front-runs)
    ///      5. User's tx arrives — permit nonce already used, reverts
    ///      6. Result: user's deposit is blocked (griefed)
    ///
    ///      With try/catch (SafeVault): even if attacker front-runs,
    ///      the permit set the allowance, so transferFrom still works.
    function test_GriefingScenarioDocumented() public {
        // This test documents the scenario without a full permit implementation.
        // The key insight: VulnerableVault fails entirely if permit fails,
        // while SafeVault gracefully falls through to use existing allowance.

        // Simulate the "attacker already set allowance" scenario:
        // User pre-approves (as if a front-run permit succeeded)
        vm.prank(user);
        weth.approve(address(safeVault), 5 ether);

        // SafeVault still works even though permit "fails"
        vm.prank(user);
        safeVault.depositWithPermit(
            5 ether,
            block.timestamp + 1 hours,
            27,
            bytes32(0),
            bytes32(0)
        );

        assertEq(safeVault.deposits(user), 5 ether);
    }

    /// @notice WETH receive() auto-wraps ETH
    function test_WETHReceiveAutoWraps() public {
        address sender = makeAddr("sender");
        vm.deal(sender, 1 ether);

        vm.prank(sender);
        (bool success,) = address(weth).call{value: 1 ether}("");
        assertTrue(success);
        assertEq(weth.balanceOf(sender), 1 ether);
    }
}
