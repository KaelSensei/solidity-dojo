// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Staking Rewards
/// @notice Synthetix-style staking rewards contract
/// @dev Educational example of reward accrual patterns

/// @title IERC20 Token Interface
interface IERC20Minimal {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

/// @title SafeERC20 Helper
library SafeERC20 {
    function safeTransfer(
        IERC20Minimal token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Minimal token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20Minimal token, bytes memory data) private {
        (bool success, bytes memory result) = address(token).call(data);
        require(success, "SafeERC20: call failed");
    }
}

/// @title Staking Rewards
/// @notice Allows users to stake tokens and earn rewards
contract StakingRewards {
    using SafeERC20 for IERC20Minimal;

    /// @notice Staking token
    IERC20Minimal public immutable stakingToken;
    
    /// @notice Reward token
    IERC20Minimal public immutable rewardsToken;
    
    /// @notice Duration of rewards to be paid out (in seconds)
    uint256 public immutable rewardsDuration;
    
    /// @notice Owner address
    address public immutable owner;

    /// @notice Timestamp of when the rewards finish
    uint256 public periodFinish = 0;
    
    /// @notice Minimum of last updated time and reward end time
    uint256 public lastUpdateTime = 0;
    
    /// @notice Reward rate per second
    uint256 public rewardRate = 0;
    
    /// @notice Sum of (reward rate * dt * 1e18 / total supply)
    uint256 public rewardPerTokenStored = 0;
    
    /// @notice User address => rewardPerTokenPaid
    mapping(address => uint256) public userRewardPerTokenPaid;
    
    /// @notice User address => rewards to be claimed
    mapping(address => uint256) public rewards;
    
    /// @notice Total staked
    uint256 private _totalSupply = 0;
    
    /// @notice User address => staked amount
    mapping(address => uint256) private _balances;

    /// @notice Emitted when a user stakes tokens
    event Staked(address indexed user, uint256 amount);
    
    /// @notice Emitted when a user withdraws staked tokens
    event Withdrawn(address indexed user, uint256 amount);
    
    /// @notice Emitted when rewards are earned
    event RewardEarned(address indexed user, uint256 reward);
    
    /// @notice Emitted when rewards are paid out
    event RewardPaid(address indexed user, uint256 reward);

    /// @param _stakingToken Address of staking token
    /// @param _rewardsToken Address of rewards token
    /// @param _rewardsDuration Duration of rewards period
    constructor(
        address _stakingToken,
        address _rewardsToken,
        uint256 _rewardsDuration
    ) {
        require(_stakingToken != address(0), "Invalid staking token");
        require(_rewardsToken != address(0), "Invalid rewards token");
        require(_rewardsDuration > 0, "Invalid duration");
        
        stakingToken = IERC20Minimal(_stakingToken);
        rewardsToken = IERC20Minimal(_rewardsToken);
        rewardsDuration = _rewardsDuration;
        owner = msg.sender;
    }

    /// @notice Total staked
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /// @notice Balance of a user
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /// @notice Last time reward was applicable
    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    /// @notice Reward per token stored
    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + (
            (lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * 1e18 / _totalSupply
        );
    }

    /// @notice Calculate earned rewards for a user (internal helper)
    function _calculateEarned(address account) internal view returns (uint256) {
        return _balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account]) / 1e18 
            + rewards[account];
    }

    /// @notice Earned rewards for a user
    function earned(address account) external view returns (uint256) {
        return _calculateEarned(account);
    }

    /// @notice Update reward for a user
    function _updateReward(address account) internal {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        
        if (account != address(0)) {
            rewards[account] = _calculateEarned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
    }

    /// @notice Stake tokens
    function stake(uint256 amount) external {
        _stake(msg.sender, amount);
    }

    /// @notice Stake with permit
    function stakeWithPermit(uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        // Note: In production, implement permit signature
        _stake(msg.sender, amount);
    }

    /// @notice Internal stake function
    function _stake(address _user, uint256 amount) internal {
        require(amount > 0, "Cannot stake 0");
        
        // Update reward accounting
        _updateReward(_user);
        
        // Transfer tokens from user
        stakingToken.transferFrom(_user, address(this), amount);
        
        // Update state
        _balances[_user] += amount;
        _totalSupply += amount;
        
        emit Staked(_user, amount);
    }

    /// @notice Withdraw staked tokens
    function withdraw(uint256 amount) external {
        require(amount > 0, "Cannot withdraw 0");
        
        // Update reward accounting
        _updateReward(msg.sender);
        
        // Update state
        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        
        // Transfer tokens to user
        stakingToken.transfer(msg.sender, amount);
        
        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Claim earned rewards
    function getReward() external {
        _updateReward(msg.sender);
        
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    /// @notice Notify reward amount and start period
    function notifyRewardAmount(uint256 reward) external {
        require(msg.sender == owner, "Only owner");
        require(reward > 0, "No reward");
        
        _updateReward(address(0));
        
        if (block.timestamp >= periodFinish) {
            rewardRate = reward / rewardsDuration;
        } else {
            uint256 remainingRewards = (periodFinish - block.timestamp) * rewardRate;
            rewardRate = (reward + remainingRewards) / rewardsDuration;
        }
        
        require(rewardRate > 0, "Reward rate = 0");
        require(
            rewardRate * rewardsDuration <= rewardsToken.balanceOf(address(this)),
            "Reward amount > balance"
        );
        
        periodFinish = block.timestamp + rewardsDuration;
        lastUpdateTime = block.timestamp;
    }

    /// @notice Exit the staking (withdraw + claim)
    function exit() external {
        uint256 amount = _balances[msg.sender];
        require(amount > 0, "Nothing to withdraw");
        
        _updateReward(msg.sender);
        
        _balances[msg.sender] = 0;
        _totalSupply -= amount;
        
        stakingToken.transfer(msg.sender, amount);
        
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
        
        emit Withdrawn(msg.sender, amount);
    }
}
