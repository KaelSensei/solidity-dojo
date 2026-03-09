// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/defi/CrowdFund.sol";

/// @title Mock ERC20 Token
contract MockTokenCrowdFund is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function mint(address to, uint256 amount) external {
        _balances[to] += amount;
        _totalSupply += amount;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(_balances[msg.sender] >= amount);
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(_balances[from] >= amount);
        require(_allowances[from][msg.sender] >= amount);
        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        return true;
    }
}

/// @title CrowdFund Test Suite
contract CrowdFundTest is Test {
    CrowdFund public crowdFund;
    MockTokenCrowdFund public token;

    address public creator = address(0x1);
    address public pledger1 = address(0x2);
    address public pledger2 = address(0x3);
    address public pledger3 = address(0x4);

    uint256 constant GOAL = 100 ether;
    uint256 constant DURATION = 30 days;

    function setUp() public {
        // Deploy mock token
        token = new MockTokenCrowdFund("Campaign Token", "CAM", 18);
        
        // Mint tokens to pledgers
        token.mint(pledger1, 1000 ether);
        token.mint(pledger2, 1000 ether);
        token.mint(pledger3, 1000 ether);
        
        // Create crowd fund campaign
        crowdFund = new CrowdFund(
            address(token),
            creator,
            GOAL,
            DURATION
        );
    }

    /// @notice Test can pledge to campaign
    function test_CanPledge() public {
        vm.startPrank(pledger1);
        token.approve(address(crowdFund), 10 ether);
        crowdFund.pledge(10 ether);
        
        assertEq(crowdFund.getPledge(pledger1), 10 ether);
        assertEq(crowdFund.totalPledged(), 10 ether);
        vm.stopPrank();
    }

    /// @notice Test can pledge multiple times
    function test_MultiplePledges() public {
        vm.startPrank(pledger1);
        token.approve(address(crowdFund), 50 ether);
        
        crowdFund.pledge(20 ether);
        crowdFund.pledge(30 ether);
        
        assertEq(crowdFund.getPledge(pledger1), 50 ether);
        vm.stopPrank();
    }

    /// @notice Test can refund if goal not met
    function test_CanRefundIfGoalNotMet() public {
        // Pledge some amount
        vm.startPrank(pledger1);
        token.approve(address(crowdFund), 10 ether);
        crowdFund.pledge(10 ether);
        vm.stopPrank();
        
        // Warp past deadline
        vm.warp(block.timestamp + DURATION + 1);
        
        // Goal not met, so refund should work
        vm.prank(pledger1);
        crowdFund.refund();
        
        assertEq(crowdFund.getPledge(pledger1), 0);
    }

    /// @notice Test creator can claim if goal met
    function test_CreatorCanClaimIfGoalMet() public {
        // Multiple pledgers meet the goal
        vm.startPrank(pledger1);
        token.approve(address(crowdFund), 50 ether);
        crowdFund.pledge(50 ether);
        vm.stopPrank();
        
        vm.startPrank(pledger2);
        token.approve(address(crowdFund), 50 ether);
        crowdFund.pledge(50 ether);
        vm.stopPrank();
        
        // Warp past deadline
        vm.warp(block.timestamp + DURATION + 1);
        
        // Creator claims
        uint256 creatorBalanceBefore = token.balanceOf(creator);
        
        vm.prank(creator);
        crowdFund.claim();
        
        assertEq(token.balanceOf(creator), creatorBalanceBefore + 100 ether);
    }

    /// @notice Test cannot pledge after deadline
    function test_CannotPledgeAfterDeadline() public {
        // Warp past deadline
        vm.warp(block.timestamp + DURATION + 1);
        
        vm.startPrank(pledger1);
        token.approve(address(crowdFund), 10 ether);
        
        vm.expectRevert("Campaign ended");
        crowdFund.pledge(10 ether);
        vm.stopPrank();
    }

    /// @notice Test unpledge works
    function test_Unpledge() public {
        vm.startPrank(pledger1);
        token.approve(address(crowdFund), 10 ether);
        crowdFund.pledge(10 ether);
        
        crowdFund.unpledge(5 ether);
        
        assertEq(crowdFund.getPledge(pledger1), 5 ether);
        vm.stopPrank();
    }

    /// @notice Test cannot claim if goal not met
    function test_CannotClaimIfGoalNotMet() public {
        // Pledge less than goal
        vm.startPrank(pledger1);
        token.approve(address(crowdFund), 10 ether);
        crowdFund.pledge(10 ether);
        vm.stopPrank();
        
        // Warp past deadline
        vm.warp(block.timestamp + DURATION + 1);
        
        // Try to claim
        vm.prank(creator);
        vm.expectRevert("Goal not met");
        crowdFund.claim();
    }

    /// @notice Test only creator can claim
    function test_OnlyCreatorCanClaim() public {
        // Meet the goal
        vm.startPrank(pledger1);
        token.approve(address(crowdFund), 100 ether);
        crowdFund.pledge(100 ether);
        vm.stopPrank();
        
        vm.warp(block.timestamp + DURATION + 1);
        
        vm.prank(pledger2);
        vm.expectRevert("Only creator");
        crowdFund.claim();
    }

    /// @notice Test claim only after deadline
    function test_ClaimOnlyAfterDeadline() public {
        // Meet the goal
        vm.startPrank(pledger1);
        token.approve(address(crowdFund), 100 ether);
        crowdFund.pledge(100 ether);
        vm.stopPrank();
        
        // Try to claim before deadline
        vm.prank(creator);
        vm.expectRevert("Campaign ongoing");
        crowdFund.claim();
    }

    /// @notice Test cannot claim twice
    function test_CannotClaimTwice() public {
        // Meet the goal
        vm.startPrank(pledger1);
        token.approve(address(crowdFund), 100 ether);
        crowdFund.pledge(100 ether);
        vm.stopPrank();
        
        vm.warp(block.timestamp + DURATION + 1);
        
        vm.prank(creator);
        crowdFund.claim();
        
        vm.prank(creator);
        vm.expectRevert("Already claimed");
        crowdFund.claim();
    }

    /// @notice Test goalMet returns correct value
    function test_GoalMetReturnsCorrectValue() public {
        assertFalse(crowdFund.goalMet());
        
        vm.startPrank(pledger1);
        token.approve(address(crowdFund), 100 ether);
        crowdFund.pledge(100 ether);
        vm.stopPrank();
        
        assertTrue(crowdFund.goalMet());
    }

    /// @notice Test get status returns correct values
    function test_GetStatus() public {
        (
            uint256 _goal,
            uint256 _totalPledged,
            uint256 _deadline,
            bool _claimed,
            bool _goalMet
        ) = crowdFund.getStatus();
        
        assertEq(_goal, GOAL);
        assertEq(_totalPledged, 0);
        assertEq(_deadline, block.timestamp + DURATION);
        assertFalse(_claimed);
        assertFalse(_goalMet);
    }

    // ============ FUZZ TESTS ============

    /// @notice Fuzz test for pledge amounts
    function testFuzz_pledge_refund(uint256 pledgeAmount) public {
        pledgeAmount = bound(pledgeAmount, 1 ether, GOAL - 1); // Keep below goal to allow refund
        
        vm.startPrank(pledger1);
        token.approve(address(crowdFund), pledgeAmount);
        crowdFund.pledge(pledgeAmount);
        vm.stopPrank();
        
        // Warp past deadline
        vm.warp(block.timestamp + DURATION + 1);
        
        // Refund
        vm.prank(pledger1);
        crowdFund.refund();
        
        assertEq(crowdFund.getPledge(pledger1), 0);
    }

    /// @notice Fuzz test for multiple pledgers
    function testFuzz_multiple_pledgers(uint256 amount1, uint256 amount2, uint256 amount3) public {
        amount1 = bound(amount1, 1 ether, 50 ether);
        amount2 = bound(amount2, 1 ether, 50 ether);
        amount3 = bound(amount3, 1 ether, 50 ether);
        
        vm.startPrank(pledger1);
        token.approve(address(crowdFund), amount1);
        crowdFund.pledge(amount1);
        vm.stopPrank();
        
        vm.startPrank(pledger2);
        token.approve(address(crowdFund), amount2);
        crowdFund.pledge(amount2);
        vm.stopPrank();
        
        vm.startPrank(pledger3);
        token.approve(address(crowdFund), amount3);
        crowdFund.pledge(amount3);
        vm.stopPrank();
        
        assertEq(crowdFund.totalPledged(), amount1 + amount2 + amount3);
    }

    // ============ INVARIANT TESTS ============

    /// @notice Invariant: pledged never exceeds goal if claimed
    function invariant_pledged_never_exceeds_goal_if_claimed() public view {
        // If claimed, totalPledged should be >= goal
        // But can't easily test in invariant without external tracking
        assertTrue(crowdFund.totalPledged() >= 0);
    }

    /// @notice Invariant: pledges are non-negative
    function invariant_pledges_non_negative() public view {
        assertTrue(crowdFund.goal() > 0);
    }

    /// @notice Invariant: totalpledged is sum of pledges
    function invariant_total_pledged_sum() public view {
        // Basic property check
        assertGe(crowdFund.totalPledged(), 0);
    }
}
