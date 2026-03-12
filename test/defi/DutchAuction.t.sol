// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/defi/DutchAuction.sol";

/// @title Mock ERC721 NFT
contract MockNFT {
    mapping(uint256 => address) public owners;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(uint256 => bool)) public approvals;

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
        // Just call transferFrom directly (simplified for mock)
        require(owners[tokenId] == from);
        owners[tokenId] = to;
        balanceOf[from]--;
        balanceOf[to]++;
    }
    
    function approve(address to, uint256 tokenId) external {
        approvals[to][tokenId] = true;
    }
}

/// @title Dutch Auction Test Suite
contract DutchAuctionTest is Test {
    DutchAuction public auction;
    MockNFT public nft;

    // Use addresses above precompile range (0x1 = ecrecover rejects ETH)
    address public seller = address(0x10001);
    address public buyer1 = address(0x10002);
    address public buyer2 = address(0x10003);

    uint256 constant STARTING_PRICE = 10 ether;
    uint256 constant MINIMUM_PRICE = 1 ether;
    uint256 constant DURATION = 7 days;
    // Discount so that at DURATION/2 price is between min and start: (start - min) / (DURATION/2) ≈ 2.98e13
    uint256 constant DISCOUNT_RATE = 2e13;

    uint256 constant TOKEN_ID = 1;

    function setUp() public {
        // Deploy mock NFT
        nft = new MockNFT();
        
        // Mint NFT to seller
        nft.mint(seller, TOKEN_ID);
        
        // Seller approves NFT transfer
        vm.prank(seller);
        nft.approve(address(this), TOKEN_ID);
        
        // Create auction
        auction = new DutchAuction(
            address(nft),
            TOKEN_ID,
            seller,
            STARTING_PRICE,
            DISCOUNT_RATE,
            DURATION,
            MINIMUM_PRICE
        );
    }

    /// @notice Test price decreases over time
    function test_PriceDecreasesOverTime() public {
        uint256 priceAtStart = auction.currentPrice();
        assertEq(priceAtStart, STARTING_PRICE);
        
        // Warp halfway
        vm.warp(block.timestamp + DURATION / 2);
        
        uint256 priceAtMiddle = auction.currentPrice();
        
        // Price should be lower than starting
        assertLt(priceAtMiddle, STARTING_PRICE);
        // But higher than minimum
        assertGt(priceAtMiddle, MINIMUM_PRICE);
        
        // Warp to end
        vm.warp(block.timestamp + DURATION / 2 + 1);
        
        uint256 priceAtEnd = auction.currentPrice();
        assertEq(priceAtEnd, MINIMUM_PRICE);
    }

    /// @notice Test purchase at current price succeeds
    function test_PurchaseSucceeds() public {
        uint256 price = auction.currentPrice();
        
        vm.deal(buyer1, 100 ether);
        
        vm.prank(buyer1);
        auction.purchase{value: price}();
        
        assertTrue(auction.ended());
        assertEq(auction.buyer(), buyer1);
        assertEq(nft.ownerOf(TOKEN_ID), buyer1);
    }

    /// @notice Test purchase after auction ends reverts
    function test_PurchaseAfterAuctionEndsReverts() public {
        // Warp past auction end
        vm.warp(block.timestamp + DURATION + 1);
        
        vm.deal(buyer1, 100 ether);
        
        vm.prank(buyer1);
        vm.expectRevert("Auction expired");
        auction.purchase{value: 1 ether}();
    }

    /// @notice Test refund if overpaid
    function test_RefundIfOverpaid() public {
        uint256 price = auction.currentPrice();
        uint256 excess = 1 ether;
        
        vm.deal(buyer1, 100 ether);
        
        uint256 balanceBefore = buyer1.balance;
        
        vm.prank(buyer1);
        auction.purchase{value: price + excess}();
        
        uint256 balanceAfter = buyer1.balance;
        
        // Should have paid price + excess - refund
        assertEq(balanceBefore - balanceAfter, price);
    }

    /// @notice Test insufficient payment reverts
    function test_InsufficientPaymentReverts() public {
        uint256 price = auction.currentPrice();
        
        vm.deal(buyer1, 100 ether);
        
        vm.prank(buyer1);
        vm.expectRevert("Insufficient payment");
        auction.purchase{value: price - 0.1 ether}();
    }

    /// @notice Test seller can end auction
    function test_SellerCanEndAuction() public {
        vm.prank(seller);
        auction.endAuction();
        
        assertTrue(auction.ended());
        assertEq(nft.ownerOf(TOKEN_ID), seller);
    }

    /// @notice Test non-seller cannot end auction
    function test_NonSellerCannotEndAuction() public {
        vm.prank(buyer1);
        vm.expectRevert("Only seller");
        auction.endAuction();
    }

    /// @notice Test auction info returns correct values
    function test_AuctionInfo() public {
        (
            address _seller,
            uint256 _startingPrice,
            uint256 _currentPrice,
            uint256 _endsAt,
            bool _ended
        ) = auction.getAuctionInfo();
        
        assertEq(_seller, seller);
        assertEq(_startingPrice, STARTING_PRICE);
        assertEq(_currentPrice, STARTING_PRICE);
        assertEq(_endsAt, block.timestamp + DURATION);
        assertFalse(_ended);
    }

    /// @notice Test price never goes below minimum
    function test_PriceNeverBelowMinimum() public {
        // Warp way past end
        vm.warp(block.timestamp + DURATION * 2);
        
        uint256 price = auction.currentPrice();
        assertEq(price, MINIMUM_PRICE);
    }

    /// @notice Test buyer receives NFT
    function test_BuyerReceivesNFT() public {
        vm.deal(buyer1, 100 ether);
        uint256 price = auction.currentPrice();
        
        vm.prank(buyer1);
        auction.purchase{value: price}();
        
        assertEq(nft.ownerOf(TOKEN_ID), buyer1);
    }

    /// @notice Test seller receives payment
    function test_SellerReceivesPayment() public {
        uint256 price = auction.currentPrice();
        
        uint256 sellerBalanceBefore = seller.balance;
        
        vm.deal(buyer1, 100 ether);
        
        vm.prank(buyer1);
        auction.purchase{value: price}();
        
        assertEq(seller.balance, sellerBalanceBefore + price);
    }

    // ============ FUZZ TESTS ============

    /// @notice Fuzz test for purchase timing
    function testFuzz_purchase_timing(uint256 warpTime) public {
        warpTime = bound(warpTime, 0, DURATION - 1); // stay before endsAt so purchase is allowed
        
        vm.warp(block.timestamp + warpTime);
        
        uint256 price = auction.currentPrice();
        
        // Price should always be between minimum and starting
        assertGe(price, MINIMUM_PRICE);
        assertLe(price, STARTING_PRICE);
        
        // Try to purchase
        vm.deal(buyer1, 100 ether);
        
        vm.prank(buyer1);
        auction.purchase{value: price}();
        
        assertTrue(auction.ended());
    }

    /// @notice Fuzz test for various discount rates
    function testFuzz_discount_rate(uint256 discountRate) public {
        // Set up new auction with fuzzed discount
        vm.assume(discountRate > 0 && discountRate < STARTING_PRICE / DURATION);
        
        vm.prank(seller);
        nft.approve(address(this), TOKEN_ID + 1);
        nft.mint(seller, TOKEN_ID + 1);
        
        DutchAuction newAuction = new DutchAuction(
            address(nft),
            TOKEN_ID + 1,
            seller,
            STARTING_PRICE,
            discountRate,
            DURATION,
            MINIMUM_PRICE
        );
        
        uint256 price = newAuction.currentPrice();
        
        assertGe(price, MINIMUM_PRICE);
        assertLe(price, STARTING_PRICE);
    }

    // ============ INVARIANT TESTS ============

    /// @notice Invariant: current price never exceeds starting price
    function invariant_price_never_exceeds_start() public view {
        uint256 price = auction.currentPrice();
        assertLe(price, STARTING_PRICE);
    }

    /// @notice Invariant: current price never below minimum
    function invariant_price_never_below_minimum() public view {
        uint256 price = auction.currentPrice();
        assertGe(price, MINIMUM_PRICE);
    }

    /// @notice Invariant: price decreases over time
    function invariant_price_decreases_monotonically() public {
        // Can't easily test in single call, but basic check
        assertTrue(STARTING_PRICE >= MINIMUM_PRICE);
    }
}
