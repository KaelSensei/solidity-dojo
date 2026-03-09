// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/hacks/DoSAttack.sol";

/// @title DoS Attack Test Suite
contract DoSAttackTest is Test {
    VulnerableAuction public vulnerableAuction;
    SecureAuction public secureAuction;
    VulnerableTokenDistributor public distributor;
    
    address public user1 = address(0x1);
    address public user2 = address(0x2);

    function setUp() public {
        vulnerableAuction = new VulnerableAuction();
        secureAuction = new SecureAuction();
        distributor = new VulnerableTokenDistributor();
    }

    /// @notice Test vulnerable auction bid
    function test_VulnerableAuctionBid() public {
        vm.deal(user1, 10 ether);
        
        vm.prank(user1);
        vulnerableAuction.bid{value: 1 ether}();
        
        assertEq(vulnerableAuction.highestBid(), 1 ether);
    }

    /// @notice Test secure auction bid
    function test_SecureAuctionBid() public {
        vm.deal(user1, 10 ether);
        
        vm.prank(user1);
        secureAuction.bid{value: 1 ether}();
        
        assertEq(secureAuction.highestBid(), 1 ether);
    }

    /// @notice Test token distribution claim
    function test_TokenClaim() public {
        vm.prank(user1);
        distributor.claim();
        
        assertTrue(distributor.balances(user1) > 0);
    }

    /// @notice Test pending returns work
    function test_PendingReturns() public {
        vm.deal(user1, 10 ether);
        
        vm.prank(user1);
        vulnerableAuction.bid{value: 1 ether}();
        
        vm.deal(user2, 10 ether);
        vm.prank(user2);
        vulnerableAuction.bid{value: 2 ether}();
        
        // user1 should have pending returns
        assertEq(vulnerableAuction.pendingReturns(user1), 1 ether);
    }
}
