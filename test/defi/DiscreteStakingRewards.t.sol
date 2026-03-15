// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/defi/DiscreteStakingRewards.sol";

/// @title Mock ERC20 for DiscreteStakingRewards tests
contract MockStakingToken {
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

/// @title DiscreteStakingRewards Test Suite
contract DiscreteStakingRewardsTest is Test {
    DiscreteStakingRewards public staking;
    MockStakingToken public sToken;
    MockStakingToken public rToken;

    address public deployer = makeAddr("deployer");
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    address public charlie = makeAddr("charlie");

    function setUp() public {
        sToken = new MockStakingToken("StakeToken");
        rToken = new MockStakingToken("RewardToken");

        vm.prank(deployer);
        staking = new DiscreteStakingRewards(address(sToken), address(rToken));

        // Mint staking tokens to users
        sToken.mint(alice, 100_000e18);
        sToken.mint(bob, 100_000e18);
        sToken.mint(charlie, 100_000e18);

        // Mint reward tokens to deployer (owner)
        rToken.mint(deployer, 1_000_000e18);

        // Approve staking contract
        vm.prank(alice);
        sToken.approve(address(staking), type(uint256).max);

        vm.prank(bob);
        sToken.approve(address(staking), type(uint256).max);

        vm.prank(charlie);
        sToken.approve(address(staking), type(uint256).max);

        vm.prank(deployer);
        rToken.approve(address(staking), type(uint256).max);
    }

    // ============ STAKE ============

    function test_Stake() public {
        vm.prank(alice);
        staking.stake(1000e18);

        assertEq(staking.stakedBalance(alice), 1000e18);
        assertEq(staking.totalStaked(), 1000e18);
    }

    function test_StakeRevertsOnZero() public {
        vm.prank(alice);
        vm.expectRevert(DiscreteStakingRewards.ZeroAmount.selector);
        staking.stake(0);
    }

    // ============ WITHDRAW ============

    function test_Withdraw() public {
        vm.startPrank(alice);
        staking.stake(1000e18);
        staking.withdraw(500e18);
        vm.stopPrank();

        assertEq(staking.stakedBalance(alice), 500e18);
        assertEq(staking.totalStaked(), 500e18);
    }

    function test_WithdrawRevertsOnZero() public {
        vm.prank(alice);
        vm.expectRevert(DiscreteStakingRewards.ZeroAmount.selector);
        staking.withdraw(0);
    }

    function test_WithdrawRevertsOnInsufficientBalance() public {
        vm.prank(alice);
        staking.stake(1000e18);

        vm.prank(alice);
        vm.expectRevert(DiscreteStakingRewards.InsufficientBalance.selector);
        staking.withdraw(1001e18);
    }

    // ============ NOTIFY REWARD ============

    function test_NotifyReward() public {
        vm.prank(alice);
        staking.stake(1000e18);

        vm.prank(deployer);
        staking.notifyReward(100e18);

        // rewardIndex should be 100e18 * 1e18 / 1000e18 = 0.1e18
        assertEq(staking.rewardIndex(), (100e18 * 1e18) / 1000e18);
    }

    function test_NotifyRewardRevertsOnZero() public {
        vm.prank(alice);
        staking.stake(1000e18);

        vm.prank(deployer);
        vm.expectRevert(DiscreteStakingRewards.ZeroAmount.selector);
        staking.notifyReward(0);
    }

    function test_NotifyRewardRevertsIfNotOwner() public {
        vm.prank(alice);
        staking.stake(1000e18);

        vm.prank(alice);
        vm.expectRevert(DiscreteStakingRewards.NotOwner.selector);
        staking.notifyReward(100e18);
    }

    function test_NotifyRewardRevertsIfNoStakers() public {
        vm.prank(deployer);
        vm.expectRevert(DiscreteStakingRewards.InsufficientBalance.selector);
        staking.notifyReward(100e18);
    }

    // ============ EARNED ============

    function test_EarnedSingleStaker() public {
        vm.prank(alice);
        staking.stake(1000e18);

        vm.prank(deployer);
        staking.notifyReward(100e18);

        // Alice is the only staker — she should earn all 100e18
        assertEq(staking.earned(alice), 100e18);
    }

    function test_EarnedTwoStakersEqualSplit() public {
        vm.prank(alice);
        staking.stake(1000e18);

        vm.prank(bob);
        staking.stake(1000e18);

        vm.prank(deployer);
        staking.notifyReward(100e18);

        // Equal stakes => equal rewards
        assertEq(staking.earned(alice), 50e18);
        assertEq(staking.earned(bob), 50e18);
    }

    function test_EarnedProportionalToStake() public {
        vm.prank(alice);
        staking.stake(3000e18);

        vm.prank(bob);
        staking.stake(1000e18);

        vm.prank(deployer);
        staking.notifyReward(100e18);

        // Alice has 75%, Bob has 25%
        assertEq(staking.earned(alice), 75e18);
        assertEq(staking.earned(bob), 25e18);
    }

    function test_EarnedAccumulatesAcrossNotifications() public {
        vm.prank(alice);
        staking.stake(1000e18);

        vm.prank(deployer);
        staking.notifyReward(50e18);

        vm.prank(deployer);
        staking.notifyReward(50e18);

        assertEq(staking.earned(alice), 100e18);
    }

    // ============ CLAIM ============

    function test_Claim() public {
        vm.prank(alice);
        staking.stake(1000e18);

        vm.prank(deployer);
        staking.notifyReward(100e18);

        uint256 balBefore = rToken.balanceOf(alice);

        vm.prank(alice);
        uint256 claimed = staking.claim();

        assertEq(claimed, 100e18);
        assertEq(rToken.balanceOf(alice), balBefore + 100e18);
        assertEq(staking.earned(alice), 0, "Earned should be 0 after claim");
    }

    function test_ClaimRevertsIfNoRewards() public {
        vm.prank(alice);
        staking.stake(1000e18);

        vm.prank(alice);
        vm.expectRevert(DiscreteStakingRewards.NoRewards.selector);
        staking.claim();
    }

    function test_ClaimDoesNotAffectOtherUsers() public {
        vm.prank(alice);
        staking.stake(1000e18);

        vm.prank(bob);
        staking.stake(1000e18);

        vm.prank(deployer);
        staking.notifyReward(100e18);

        // Alice claims
        vm.prank(alice);
        staking.claim();

        // Bob's rewards should be unaffected
        assertEq(staking.earned(bob), 50e18);
    }

    // ============ COMPLEX SCENARIOS ============

    function test_StakeAfterRewardNotification() public {
        vm.prank(alice);
        staking.stake(1000e18);

        vm.prank(deployer);
        staking.notifyReward(100e18);

        // Bob stakes after the notification — should not receive any of the first reward
        vm.prank(bob);
        staking.stake(1000e18);

        assertEq(staking.earned(alice), 100e18);
        assertEq(staking.earned(bob), 0, "Late staker should not get prior rewards");

        // Second notification: both should split equally
        vm.prank(deployer);
        staking.notifyReward(100e18);

        assertEq(staking.earned(alice), 150e18);
        assertEq(staking.earned(bob), 50e18);
    }

    function test_WithdrawAndClaim() public {
        vm.prank(alice);
        staking.stake(1000e18);

        vm.prank(deployer);
        staking.notifyReward(100e18);

        // Withdraw all stake then claim rewards
        vm.startPrank(alice);
        staking.withdraw(1000e18);

        // Rewards should still be claimable after full withdrawal
        assertEq(staking.earned(alice), 100e18);

        uint256 balBefore = rToken.balanceOf(alice);
        staking.claim();
        assertEq(rToken.balanceOf(alice), balBefore + 100e18);
        vm.stopPrank();
    }

    // ============ FUZZ TESTS ============

    function testFuzz_SingleStakerGetsAllRewards(uint256 stakeAmount, uint256 rewardAmount) public {
        stakeAmount = bound(stakeAmount, 1e18, 50_000e18);
        rewardAmount = bound(rewardAmount, 1e18, 500_000e18);

        vm.prank(alice);
        staking.stake(stakeAmount);

        vm.prank(deployer);
        staking.notifyReward(rewardAmount);

        // Allow small rounding error from (amount * 1e18 / totalStaked) * staked / 1e18
        assertApproxEqRel(staking.earned(alice), rewardAmount, 1e14, "Sole staker gets all rewards");
    }

    function testFuzz_TwoStakersSplitProportionally(
        uint256 aliceStake,
        uint256 bobStake,
        uint256 rewardAmount
    ) public {
        aliceStake = bound(aliceStake, 1e18, 50_000e18);
        bobStake = bound(bobStake, 1e18, 50_000e18);
        rewardAmount = bound(rewardAmount, 1e18, 500_000e18);

        vm.prank(alice);
        staking.stake(aliceStake);

        vm.prank(bob);
        staking.stake(bobStake);

        vm.prank(deployer);
        staking.notifyReward(rewardAmount);

        uint256 aliceEarned = staking.earned(alice);
        uint256 bobEarned = staking.earned(bob);

        // Total earned should equal total reward (modulo rounding from integer division)
        assertApproxEqRel(
            aliceEarned + bobEarned,
            rewardAmount,
            1e14, // 0.01% relative tolerance for integer math rounding
            "Total earned should equal total reward"
        );

        // Alice's share should be proportional to her stake
        uint256 expectedAlice = (rewardAmount * aliceStake) / (aliceStake + bobStake);
        assertApproxEqRel(
            aliceEarned,
            expectedAlice,
            1e14,
            "Alice reward should be proportional"
        );
    }

    function testFuzz_WithdrawPreservesRewards(uint256 stakeAmount, uint256 rewardAmount) public {
        stakeAmount = bound(stakeAmount, 1e18, 50_000e18);
        rewardAmount = bound(rewardAmount, 1e18, 500_000e18);

        vm.prank(alice);
        staking.stake(stakeAmount);

        vm.prank(deployer);
        staking.notifyReward(rewardAmount);

        uint256 earnedBefore = staking.earned(alice);

        vm.prank(alice);
        staking.withdraw(stakeAmount);

        // Rewards should still be available after withdrawal
        assertEq(staking.earned(alice), earnedBefore, "Withdraw should not lose rewards");
    }
}
