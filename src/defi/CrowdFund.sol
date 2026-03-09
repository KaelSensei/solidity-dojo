// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title CrowdFund
/// @notice Crowdfunding campaign with goal and deadline
/// @dev Educational example of goal-based funding

/// @title IERC20 Token Interface
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/// @title CrowdFund
/// @notice Campaign contract for crowdfunding
contract CrowdFund {
    /// @notice Token used for contributions
    IERC20 public immutable token;
    
    /// @notice Campaign creator
    address public immutable creator;
    
    /// @notice Funding goal in tokens
    uint256 public immutable goal;
    
    /// @notice Campaign deadline
    uint256 public immutable deadline;
    
    /// @notice Total amount pledged
    uint256 public totalPledged;
    
    /// @notice Whether goal has been claimed
    bool public claimed;
    
    /// @notice Mapping of pledger addresses to pledged amounts
    mapping(address => uint256) public pledges;

    /// @notice Emitted when someone pledges
    event Pledged(address pledger, uint256 amount);
    
    /// @notice Emitted when someone unpledges (withdraws)
    event Unpledged(address pledger, uint256 amount);
    
    /// @notice Emitted when goal is met and claimed
    event Claimed(address claimer, uint256 amount);
    
    /// @notice Emitted when goal not met and pledges are refunded
    event Refunded(address pledger, uint256 amount);

    /// @param _token Token address for contributions
    /// @param _creator Campaign creator
    /// @param _goal Funding goal
    /// @param _duration Campaign duration in seconds
    constructor(
        address _token,
        address _creator,
        uint256 _goal,
        uint256 _duration
    ) {
        require(_token != address(0), "Invalid token");
        require(_goal > 0, "Invalid goal");
        require(_duration > 0, "Invalid duration");
        
        token = IERC20(_token);
        creator = _creator;
        goal = _goal;
        deadline = block.timestamp + _duration;
    }

    /// @notice Pledge tokens to the campaign
    function pledge(uint256 amount) external {
        require(block.timestamp < deadline, "Campaign ended");
        require(amount > 0, "Cannot pledge 0");
        
        // Transfer tokens from pledger
        token.transferFrom(msg.sender, address(this), amount);
        
        // Update state
        pledges[msg.sender] += amount;
        totalPledged += amount;
        
        emit Pledged(msg.sender, amount);
    }

    /// @notice Unpledge (withdraw) tokens from campaign
    function unpledge(uint256 amount) external {
        require(amount > 0, "Cannot unpledge 0");
        require(pledges[msg.sender] >= amount, "Insufficient pledge");
        
        // Update state
        pledges[msg.sender] -= amount;
        totalPledged -= amount;
        
        // Transfer tokens back to pledger
        token.transfer(msg.sender, amount);
        
        emit Unpledged(msg.sender, amount);
    }

    /// @notice Claim funds if goal is met (only creator)
    function claim() external {
        require(msg.sender == creator, "Only creator");
        require(block.timestamp >= deadline, "Campaign ongoing");
        require(!claimed, "Already claimed");
        require(totalPledged >= goal, "Goal not met");
        
        claimed = true;
        
        // Transfer all pledged tokens to creator
        token.transfer(creator, totalPledged);
        
        emit Claimed(creator, totalPledged);
    }

    /// @notice Get refund if goal not met (only after deadline)
    function refund() external {
        require(block.timestamp >= deadline, "Campaign ongoing");
        require(totalPledged < goal, "Goal met");
        
        uint256 amount = pledges[msg.sender];
        require(amount > 0, "Nothing to refund");
        
        // Clear pledge
        pledges[msg.sender] = 0;
        totalPledged -= amount;
        
        // Transfer tokens back
        token.transfer(msg.sender, amount);
        
        emit Refunded(msg.sender, amount);
    }

    /// @notice Get campaign status
    function getStatus() external view returns (
        uint256 _goal,
        uint256 _totalPledged,
        uint256 _deadline,
        bool _claimed,
        bool _goalMet
    ) {
        return (
            goal,
            totalPledged,
            deadline,
            claimed,
            totalPledged >= goal
        );
    }

    /// @notice Check if goal is met
    function goalMet() external view returns (bool) {
        return totalPledged >= goal;
    }

    /// @notice Get pledge balance
    function getPledge(address pledger) external view returns (uint256) {
        return pledges[pledger];
    }
}
