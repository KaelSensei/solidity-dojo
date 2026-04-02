// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IERC20Staking
/// @notice Minimal ERC20 interface for staking operations
interface IERC20Staking {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/// @title DiscreteStakingRewards
/// @notice A discrete (per-notification) reward distribution contract.
/// @dev Unlike the continuous Synthetix-style StakingRewards (which streams rewards over time),
///      this contract distributes rewards instantly at the moment the owner calls notifyReward().
///      Rewards are split among all current stakers proportionally to their stake.
///
///      Uses a cumulative reward-per-token index (similar to Synthetix rewardPerTokenStored
///      but without any time component). Each notification bumps the global index by
///      (rewardAmount * 1e18 / totalStaked). Each user's pending rewards are:
///        (globalIndex - userIndex) * userStake / 1e18  +  userAccumulatedRewards
///
///      This pattern is useful for protocols that distribute irregular, event-driven rewards
///      (e.g. protocol fees, liquidation proceeds, governance distributions).
contract DiscreteStakingRewards {
    address public immutable owner;
    address public immutable stakingToken;
    address public immutable rewardToken;

    /// @notice Cumulative reward per staked token (scaled by 1e18)
    uint256 public rewardIndex;

    /// @notice Total tokens currently staked
    uint256 public totalStaked;

    /// @notice Staked balance per user
    mapping(address => uint256) public stakedBalance;

    /// @notice Last reward index snapshot per user (for computing pending rewards)
    mapping(address => uint256) public userRewardIndex;

    /// @notice Accumulated unclaimed rewards per user
    mapping(address => uint256) public userRewards;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardNotified(uint256 amount, uint256 newRewardIndex);
    event RewardClaimed(address indexed user, uint256 amount);

    error ZeroAmount();
    error InsufficientBalance();
    error NotOwner();
    error NoRewards();
    error TransferFailed();

    constructor(address _stakingToken, address _rewardToken) {
        owner = msg.sender;
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
    }

    uint256 private _unlocked = 1;
    modifier nonReentrant() {
        require(_unlocked == 1, "Reentrancy");
        _unlocked = 2;
        _;
        _unlocked = 1;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /// @notice Stake tokens to participate in reward distributions
    function stake(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();

        // Settle any pending rewards before changing the user's stake
        _updateRewards(msg.sender);

        // Effects before interactions (CEI).
        stakedBalance[msg.sender] += amount;
        totalStaked += amount;

        if (!IERC20Staking(stakingToken).transferFrom(msg.sender, address(this), amount)) revert TransferFailed();

        emit Staked(msg.sender, amount);
    }

    /// @notice Withdraw staked tokens
    /// @dev Settles pending rewards first so they are not lost.
    function withdraw(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();
        if (stakedBalance[msg.sender] < amount) revert InsufficientBalance();

        // Settle any pending rewards before changing the user's stake
        _updateRewards(msg.sender);

        stakedBalance[msg.sender] -= amount;
        totalStaked -= amount;

        if (!IERC20Staking(stakingToken).transfer(msg.sender, amount)) revert TransferFailed();

        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Claim all accumulated rewards
    /// @return amount The amount of reward tokens transferred
    function claim() external nonReentrant returns (uint256 amount) {
        _updateRewards(msg.sender);

        amount = userRewards[msg.sender];
        if (amount == 0) revert NoRewards();

        userRewards[msg.sender] = 0;

        if (!IERC20Staking(rewardToken).transfer(msg.sender, amount)) revert TransferFailed();

        emit RewardClaimed(msg.sender, amount);
    }

    /// @notice View pending (unclaimed) rewards for an account
    /// @return The total claimable reward amount
    function earned(address account) external view returns (uint256) {
        uint256 pendingFromIndex = stakedBalance[account] * (rewardIndex - userRewardIndex[account]) / 1e18;
        return userRewards[account] + pendingFromIndex;
    }

    /// @notice Distribute rewards among current stakers
    /// @dev Transfers reward tokens from the caller and immediately bumps the reward index.
    ///      If no one is staked, the rewards would be lost — we revert to prevent that.
    function notifyReward(uint256 amount) external onlyOwner nonReentrant {
        if (amount == 0) revert ZeroAmount();
        if (totalStaked == 0) revert InsufficientBalance(); // No stakers to receive rewards

        if (!IERC20Staking(rewardToken).transferFrom(msg.sender, address(this), amount)) revert TransferFailed();

        // Increase the global reward index: each staked token earns (amount / totalStaked)
        rewardIndex += (amount * 1e18) / totalStaked;

        emit RewardNotified(amount, rewardIndex);
    }

    /// @dev Settle pending rewards for a user based on the current reward index.
    ///      Must be called before any stake/withdraw to ensure accurate accounting.
    function _updateRewards(address account) private {
        if (account == address(0)) return;

        // Calculate rewards earned since the user's last index snapshot
        uint256 pending = stakedBalance[account] * (rewardIndex - userRewardIndex[account]) / 1e18;
        userRewards[account] += pending;

        // Snapshot the current index so we don't double-count
        userRewardIndex[account] = rewardIndex;
    }
}

