// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/defi/TokenLocker.sol";

/// @title Mock ERC20 for TokenLocker tests
contract MockLockerToken {
    string public name;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name) { name = _name; }

    function mint(address to, uint256 amount) external { balanceOf[to] += amount; }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount);
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(balanceOf[from] >= amount);
        require(allowance[from][msg.sender] >= amount);
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

/// @title TokenLocker Test Suite
contract TokenLockerTest is Test {
    TokenLocker public locker;
    MockLockerToken public token;

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public charlie = makeAddr("charlie");

    uint256 constant LOCK_AMOUNT = 1000e18;
    uint256 constant ONE_YEAR = 365 days;

    function setUp() public {
        locker = new TokenLocker();
        token = new MockLockerToken("LockToken");

        token.mint(alice, 100_000e18);
        token.mint(bob, 100_000e18);

        vm.prank(alice);
        token.approve(address(locker), type(uint256).max);

        vm.prank(bob);
        token.approve(address(locker), type(uint256).max);
    }

    // ============ CREATE LOCK ============

    function test_CreateLock() public {
        uint256 unlockTime = block.timestamp + ONE_YEAR;

        vm.prank(alice);
        uint256 lockId = locker.createLock(address(token), bob, LOCK_AMOUNT, unlockTime);

        assertEq(lockId, 0, "First lock should have ID 0");
        assertEq(locker.lockCount(), 1);

        (address t, address beneficiary, uint256 amount, uint256 unlock, bool withdrawn) =
            locker.getLock(lockId);

        assertEq(t, address(token));
        assertEq(beneficiary, bob);
        assertEq(amount, LOCK_AMOUNT);
        assertEq(unlock, unlockTime);
        assertFalse(withdrawn);

        // Tokens should have been transferred to the locker
        assertEq(token.balanceOf(address(locker)), LOCK_AMOUNT);
    }

    function test_CreateMultipleLocks() public {
        uint256 unlockTime = block.timestamp + ONE_YEAR;

        vm.startPrank(alice);
        uint256 id0 = locker.createLock(address(token), bob, LOCK_AMOUNT, unlockTime);
        uint256 id1 = locker.createLock(address(token), charlie, 500e18, unlockTime + 30 days);
        vm.stopPrank();

        assertEq(id0, 0);
        assertEq(id1, 1);
        assertEq(locker.lockCount(), 2);
    }

    function test_CreateLockRevertsOnZeroAmount() public {
        vm.prank(alice);
        vm.expectRevert(TokenLocker.ZeroAmount.selector);
        locker.createLock(address(token), bob, 0, block.timestamp + ONE_YEAR);
    }

    function test_CreateLockRevertsOnZeroTokenAddress() public {
        vm.prank(alice);
        vm.expectRevert(TokenLocker.ZeroAddress.selector);
        locker.createLock(address(0), bob, LOCK_AMOUNT, block.timestamp + ONE_YEAR);
    }

    function test_CreateLockRevertsOnZeroBeneficiary() public {
        vm.prank(alice);
        vm.expectRevert(TokenLocker.ZeroAddress.selector);
        locker.createLock(address(token), address(0), LOCK_AMOUNT, block.timestamp + ONE_YEAR);
    }

    function test_CreateLockRevertsOnPastUnlockTime() public {
        vm.prank(alice);
        vm.expectRevert(TokenLocker.UnlockTimeInPast.selector);
        locker.createLock(address(token), bob, LOCK_AMOUNT, block.timestamp);
    }

    // ============ WITHDRAW ============

    function test_WithdrawAfterUnlockTime() public {
        uint256 unlockTime = block.timestamp + ONE_YEAR;

        vm.prank(alice);
        uint256 lockId = locker.createLock(address(token), bob, LOCK_AMOUNT, unlockTime);

        // Warp past the unlock time
        vm.warp(unlockTime + 1);

        uint256 bobBalBefore = token.balanceOf(bob);

        vm.prank(bob);
        locker.withdraw(lockId);

        assertEq(token.balanceOf(bob), bobBalBefore + LOCK_AMOUNT);

        (, , , , bool withdrawn) = locker.getLock(lockId);
        assertTrue(withdrawn);
    }

    function test_WithdrawRevertsBeforeUnlockTime() public {
        uint256 unlockTime = block.timestamp + ONE_YEAR;

        vm.prank(alice);
        uint256 lockId = locker.createLock(address(token), bob, LOCK_AMOUNT, unlockTime);

        // Try to withdraw before unlock time
        vm.prank(bob);
        vm.expectRevert(TokenLocker.NotYetUnlocked.selector);
        locker.withdraw(lockId);
    }

    function test_WithdrawRevertsIfNotBeneficiary() public {
        uint256 unlockTime = block.timestamp + ONE_YEAR;

        vm.prank(alice);
        uint256 lockId = locker.createLock(address(token), bob, LOCK_AMOUNT, unlockTime);

        vm.warp(unlockTime + 1);

        // Alice (creator) cannot withdraw — only bob (beneficiary)
        vm.prank(alice);
        vm.expectRevert(TokenLocker.NotBeneficiary.selector);
        locker.withdraw(lockId);
    }

    function test_WithdrawRevertsIfAlreadyWithdrawn() public {
        uint256 unlockTime = block.timestamp + ONE_YEAR;

        vm.prank(alice);
        uint256 lockId = locker.createLock(address(token), bob, LOCK_AMOUNT, unlockTime);

        vm.warp(unlockTime + 1);

        vm.prank(bob);
        locker.withdraw(lockId);

        // Second withdrawal should revert
        vm.prank(bob);
        vm.expectRevert(TokenLocker.AlreadyWithdrawn.selector);
        locker.withdraw(lockId);
    }

    function test_WithdrawExactlyAtUnlockTime() public {
        uint256 unlockTime = block.timestamp + ONE_YEAR;

        vm.prank(alice);
        uint256 lockId = locker.createLock(address(token), bob, LOCK_AMOUNT, unlockTime);

        // Warp to exactly the unlock time — should still revert (< not <=)
        vm.warp(unlockTime);

        // block.timestamp == unlockTime, condition is block.timestamp < unlockTime which is false
        // So this should succeed
        uint256 bobBalBefore = token.balanceOf(bob);
        vm.prank(bob);
        locker.withdraw(lockId);
        assertEq(token.balanceOf(bob), bobBalBefore + LOCK_AMOUNT);
    }

    // ============ VIEW FUNCTIONS ============

    function test_LockCountStartsAtZero() public view {
        assertEq(locker.lockCount(), 0);
    }

    function test_GetLockReturnsCorrectData() public {
        uint256 unlockTime = block.timestamp + 90 days;

        vm.prank(alice);
        locker.createLock(address(token), charlie, 500e18, unlockTime);

        (address t, address beneficiary, uint256 amount, uint256 unlock, bool withdrawn) =
            locker.getLock(0);

        assertEq(t, address(token));
        assertEq(beneficiary, charlie);
        assertEq(amount, 500e18);
        assertEq(unlock, unlockTime);
        assertFalse(withdrawn);
    }

    // ============ FUZZ TESTS ============

    function testFuzz_CreateAndWithdrawLock(uint256 amount, uint256 duration) public {
        amount = bound(amount, 1e18, 50_000e18);
        duration = bound(duration, 1, 10 * 365 days);

        uint256 unlockTime = block.timestamp + duration;

        vm.prank(alice);
        uint256 lockId = locker.createLock(address(token), bob, amount, unlockTime);

        // Cannot withdraw before unlock
        vm.prank(bob);
        vm.expectRevert(TokenLocker.NotYetUnlocked.selector);
        locker.withdraw(lockId);

        // Warp past unlock and withdraw
        vm.warp(unlockTime + 1);

        uint256 bobBalBefore = token.balanceOf(bob);
        vm.prank(bob);
        locker.withdraw(lockId);

        assertEq(token.balanceOf(bob), bobBalBefore + amount);
    }

    function testFuzz_OnlyBeneficiaryCanWithdraw(address attacker) public {
        vm.assume(attacker != bob);
        vm.assume(attacker != address(0));

        uint256 unlockTime = block.timestamp + ONE_YEAR;

        vm.prank(alice);
        uint256 lockId = locker.createLock(address(token), bob, LOCK_AMOUNT, unlockTime);

        vm.warp(unlockTime + 1);

        vm.prank(attacker);
        vm.expectRevert(TokenLocker.NotBeneficiary.selector);
        locker.withdraw(lockId);
    }
}
