// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/defi/Vault.sol";

/// @title Simple mock ERC20 for vault tests
contract MockVaultToken {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient");
        require(allowance[from][msg.sender] >= amount, "Not approved");
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

/// @title Vault Test Suite
contract VaultTest is Test {
    Vault public vault;
    MockVaultToken public token;

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public attacker = makeAddr("attacker");

    function setUp() public {
        token = new MockVaultToken();
        vault = new Vault(address(token));

        token.mint(alice, 10_000e18);
        token.mint(bob, 10_000e18);
        token.mint(attacker, 10_000e18);

        vm.prank(alice);
        token.approve(address(vault), type(uint256).max);
        vm.prank(bob);
        token.approve(address(vault), type(uint256).max);
        vm.prank(attacker);
        token.approve(address(vault), type(uint256).max);
    }

    function test_Deposit() public {
        vm.prank(alice);
        uint256 shares = vault.deposit(1000e18);

        assertEq(shares, 1000e18);
        assertEq(vault.sharesOf(alice), 1000e18);
        assertEq(vault.totalShares(), 1000e18);
        assertEq(vault.totalAssets(), 1000e18);
    }

    function test_Withdraw() public {
        vm.prank(alice);
        vault.deposit(1000e18);

        vm.prank(alice);
        uint256 amount = vault.withdraw(500e18);

        assertGt(amount, 0);
        assertEq(vault.sharesOf(alice), 500e18);
    }

    function test_MultipleDepositors() public {
        vm.prank(alice);
        vault.deposit(1000e18);

        vm.prank(bob);
        vault.deposit(1000e18);

        assertEq(vault.totalAssets(), 2000e18);
        assertGt(vault.sharesOf(bob), 0);
    }

    function test_ShareCalculation() public {
        vm.prank(alice);
        vault.deposit(1000e18);

        vm.prank(bob);
        uint256 bobShares = vault.deposit(2000e18);

        uint256 aliceShares = vault.sharesOf(alice);
        assertGt(bobShares, aliceShares);
    }

    function test_InflationProtection() public {
        // Step 1: Attacker deposits 1 wei
        vm.prank(attacker);
        vault.deposit(1);

        // Step 2: Attacker "donates" a large amount directly to vault
        token.mint(address(vault), 1000e18);

        // Step 3: Victim deposits a normal amount
        vm.prank(alice);
        uint256 aliceShares = vault.deposit(1000e18);

        // With OFFSET protection, alice should get meaningful shares (not 0)
        assertGt(aliceShares, 0, "Alice should get shares despite inflation attempt");

        // Alice should be able to withdraw most of her deposit
        vm.prank(alice);
        uint256 withdrawn = vault.withdraw(aliceShares);
        assertGt(withdrawn, 900e18, "Alice should recover most of her deposit");
    }

    function test_WithdrawInsufficientShares() public {
        vm.prank(alice);
        vault.deposit(100e18);

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Vault.InsufficientShares.selector, 100e18, 200e18));
        vault.withdraw(200e18);
    }

    function test_ZeroDepositReverts() public {
        vm.prank(alice);
        vm.expectRevert(Vault.ZeroAmount.selector);
        vault.deposit(0);
    }

    function testFuzz_depositWithdraw(uint256 amount) public {
        amount = bound(amount, 1, 5_000e18);

        vm.prank(alice);
        uint256 shares = vault.deposit(amount);
        assertGt(shares, 0);

        vm.prank(alice);
        uint256 withdrawn = vault.withdraw(shares);
        // Due to rounding, withdrawn might be slightly less
        assertLe(withdrawn, amount);
        assertGe(withdrawn, amount - 1);
    }
}
