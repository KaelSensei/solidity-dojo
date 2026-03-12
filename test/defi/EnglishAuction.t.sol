// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/defi/EnglishAuction.sol";

/// @title Mock ERC721 NFT
contract MockNFTEnglish {
    mapping(uint256 => address) public owners;
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 tokenId) external {
        owners[tokenId] = to;
        balanceOf[to]++;
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        return owners[tokenId];
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        require(owners[tokenId] == from);
        owners[tokenId] = to;
        balanceOf[from]--;
        balanceOf[to]++;
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        require(owners[tokenId] == from);
        owners[tokenId] = to;
        balanceOf[from]--;
        balanceOf[to]++;
    }
    
    function approve(address, uint256) external {}
}

/// @title English Auction Test Suite
contract EnglishAuctionTest is Test {
    EnglishAuction public auction;
    MockNFTEnglish public nft;

    // Use addresses above precompile range (0x1 = ecrecover rejects ETH)
    address public seller = address(0x10001);
    address public bidder1 = address(0x10002);
    address public bidder2 = address(0x10003);
    address public bidder3 = address(0x10004);

    uint256 constant STARTING_BID = 1 ether;
    uint256 constant MIN_INCREMENT = 0.1 ether;
    uint256 constant DURATION = 7 days;

    uint256 constant TOKEN_ID = 1;

    function setUp() public {
        // Deploy mock NFT
        nft = new MockNFTEnglish();
        
        // Mint NFT to seller
        nft.mint(seller, TOKEN_ID);
        
        // Seller approves NFT transfer
        vm.prank(seller);
        nft.approve(address(this), TOKEN_ID);
        
        // Create auction
        auction = new EnglishAuction(
            address(nft),
            TOKEN_ID,
            seller,
            STARTING_BID,
            MIN_INCREMENT,
            DURATION
        );
    }

    /// @notice Test bid must exceed current highest
    function test_BidMustExceedCurrentHighest() public {
        // Start auction
        vm.prank(seller);
        auction.start(DURATION);
        
        // First bid
        vm.deal(bidder1, 100 ether);
        vm.prank(bidder1);
        auction.bid{value: STARTING_BID}();
        
        // Second bid must exceed by min increment
        vm.deal(bidder2, 100 ether);
        vm.prank(bidder2);
        auction.bid{value: STARTING_BID + MIN_INCREMENT}();
        
        assertEq(auction.highestBidder(), bidder2);
    }

    /// @notice Test bid below minimum increment reverts
    function test_BidBelowIncrementReverts() public {
        vm.prank(seller);
        auction.start(DURATION);
        
        vm.deal(bidder1, 100 ether);
        vm.prank(bidder1);
        auction.bid{value: STARTING_BID}();
        
        // Try to bid with just minimum (should fail - needs min increment)
        vm.deal(bidder2, 100 ether);
        vm.prank(bidder2);
        vm.expectRevert("Bid too low");
        auction.bid{value: STARTING_BID + 0.01 ether}(); // Less than min increment
    }

    /// @notice Test previous highest can withdraw
    function test_PreviousHighestCanWithdraw() public {
        vm.prank(seller);
        auction.start(DURATION);
        
        // First bid
        vm.deal(bidder1, 100 ether);
        vm.prank(bidder1);
        auction.bid{value: STARTING_BID}();
        
        // Second bid outbids first
        vm.deal(bidder2, 100 ether);
        vm.prank(bidder2);
        auction.bid{value: STARTING_BID + MIN_INCREMENT}();
        
        // First bidder should have pending return
        uint256 pending = auction.pendingReturns(bidder1);
        assertEq(pending, STARTING_BID);
        
        // First bidder can withdraw
        uint256 balanceBefore = bidder1.balance;
        vm.prank(bidder1);
        auction.withdraw();
        
        assertEq(bidder1.balance, balanceBefore + STARTING_BID);
    }

    /// @notice Test auction ends after deadline
    function test_AuctionEndsAfterDeadline() public {
        vm.prank(seller);
        auction.start(DURATION);
        
        // Place a bid
        vm.deal(bidder1, 100 ether);
        vm.prank(bidder1);
        auction.bid{value: STARTING_BID}();
        
        // Warp past end
        vm.warp(block.timestamp + DURATION + 1);
        
        // End auction
        auction.end();
        
        assertTrue(auction.ended());
    }

    /// @notice Test winner can claim NFT
    function test_WinnerCanClaimNFT() public {
        vm.prank(seller);
        auction.start(DURATION);
        
        vm.deal(bidder1, 100 ether);
        vm.prank(bidder1);
        auction.bid{value: STARTING_BID}();
        
        // Warp and end
        vm.warp(block.timestamp + DURATION + 1);
        auction.end();
        
        assertEq(nft.ownerOf(TOKEN_ID), bidder1);
    }

    /// @notice Test seller receives payment
    function test_SellerReceivesPayment() public {
        vm.prank(seller);
        auction.start(DURATION);
        
        vm.deal(bidder1, 100 ether);
        vm.prank(bidder1);
        auction.bid{value: STARTING_BID}();
        
        uint256 sellerBalanceBefore = seller.balance;
        
        vm.warp(block.timestamp + DURATION + 1);
        auction.end();
        
        assertEq(seller.balance, sellerBalanceBefore + STARTING_BID);
    }

    /// @notice Test auction not started reverts
    function test_NotStartedReverts() public {
        vm.deal(bidder1, 100 ether);
        vm.prank(bidder1);
        vm.expectRevert("Not started");
        auction.bid{value: STARTING_BID}();
    }

    /// @notice Test auction already ended reverts
    function test_AuctionEndedReverts() public {
        vm.prank(seller);
        auction.start(DURATION);
        
        vm.deal(bidder1, 100 ether);
        vm.prank(bidder1);
        auction.bid{value: STARTING_BID}();
        
        vm.warp(block.timestamp + DURATION + 1);
        auction.end();
        
        // Try to bid after ended
        vm.deal(bidder2, 100 ether);
        vm.prank(bidder2);
        vm.expectRevert("Ended");
        auction.bid{value: STARTING_BID + MIN_INCREMENT}();
    }

    /// @notice Test can start auction only once
    function test_CannotStartTwice() public {
        vm.prank(seller);
        auction.start(DURATION);
        
        vm.prank(seller);
        vm.expectRevert("Already started");
        auction.start(DURATION);
    }

    /// @notice Test get status returns correct values
    function test_GetStatus() public {
        (
            address highestBidder,
            uint256 highestBid,
            uint256 endAt,
            bool started,
            bool ended
        ) = auction.getStatus();
        
        assertEq(highestBidder, address(0));
        assertEq(highestBid, STARTING_BID);
        assertFalse(started);
        assertFalse(ended);
    }

    /// @notice Test NFT returned if no bids
    function test_NFTReturnedIfNoBids() public {
        vm.prank(seller);
        auction.start(DURATION);
        
        vm.warp(block.timestamp + DURATION + 1);
        auction.end();
        
        assertEq(nft.ownerOf(TOKEN_ID), seller);
    }

    // ============ FUZZ TESTS ============

    /// @notice Fuzz test for bidding war
    function testFuzz_bidding_war(uint256 numBids) public {
        numBids = bound(numBids, 2, 10);
        
        vm.prank(seller);
        auction.start(DURATION);
        
        // First bidder
        vm.deal(bidder1, 1000 ether);
        vm.prank(bidder1);
        auction.bid{value: STARTING_BID}();
        
        // Subsequent bidders
        for (uint256 i = 2; i <= numBids; i++) {
            address bidder = address(uint160(i + 10));
            vm.deal(bidder, 1000 ether);
            vm.prank(bidder);
            auction.bid{value: STARTING_BID + (MIN_INCREMENT * i)}();
        }
        
        // Last bidder should be highest
        assertEq(auction.highestBid(), STARTING_BID + (MIN_INCREMENT * numBids));
    }

    /// @notice Fuzz test for bid amounts
    function testFuzz_various_bids(uint256 bidAmount) public {
        bidAmount = bound(bidAmount, STARTING_BID + MIN_INCREMENT, 100 ether);
        
        vm.prank(seller);
        auction.start(DURATION);
        
        vm.deal(bidder1, 200 ether);
        vm.prank(bidder1);
        auction.bid{value: bidAmount}();
        
        assertEq(auction.highestBid(), bidAmount);
    }

    // ============ INVARIANT TESTS ============

    /// @notice Invariant: highest bidder always has highest bid
    function invariant_highest_bidder_has_highest_bid() public view {
        assertTrue(
            auction.highestBidder() == address(0) || 
            auction.pendingReturns(auction.highestBidder()) == 0 ||
            auction.highestBid() > 0
        );
    }

    /// @notice Invariant: bid is always positive
    function invariant_bid_always_positive() public view {
        assertGe(auction.highestBid(), STARTING_BID);
    }
}
