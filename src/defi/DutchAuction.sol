// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Dutch Auction
/// @notice Dutch auction where price starts high and decreases linearly
/// @dev Educational example of price decay auctions

/// @title IERC721 NFT Interface
interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

/// @title Dutch Auction
/// @notice Contract for Dutch auction with decreasing price
contract DutchAuction {
    /// @notice NFT being sold
    IERC721 public immutable nft;
    
    /// @notice Token ID of NFT
    uint256 public immutable tokenId;
    
    /// @notice Address of the seller
    address public immutable seller;
    
    /// @notice Starting price in wei
    uint256 public immutable startingPrice;
    
    /// @notice Discount rate (price decrease per second)
    uint256 public immutable discountRate;
    
    /// @notice Auction end time
    uint256 public immutable endsAt;
    
    /// @notice Minimum price (floor)
    uint256 public immutable minimumPrice;
    
    /// @notice Auction start time
    uint256 public immutable startsAt;
    
    /// @notice Whether the NFT has been sold
    bool public ended;
    
    /// @notice Buyer address
    address public buyer;

    /// @notice Emitted when auction ends
    event AuctionEnded(address indexed buyer, uint256 price, uint256 timestamp);
    
    /// @notice Emitted when bid is placed
    event BidPlaced(address indexed bidder, uint256 bid, uint256 price);

    /// @notice Pull-payment balances for refunds and seller proceeds
    mapping(address => uint256) public pendingWithdrawals;

    constructor(
        address _nft,
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _discountRate,
        uint256 _duration,
        uint256 _minimumPrice
    ) {
        require(_nft != address(0), "Invalid NFT address");
        require(_startingPrice >= _minimumPrice, "Starting < minimum");
        require(_duration > 0, "Invalid duration");
        
        nft = IERC721(_nft);
        tokenId = _tokenId;
        seller = msg.sender;
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startsAt = block.timestamp;
        endsAt = block.timestamp + _duration;
        minimumPrice = _minimumPrice;
        
        // Transfer NFT to auction contract
        nft.transferFrom(msg.sender, address(this), _tokenId);
    }

    /// @notice Get current price based on time elapsed
    function currentPrice() public view returns (uint256) {
        // slither-disable-next-line timestamp
        if (block.timestamp >= endsAt) {
            return minimumPrice;
        }
        
        // slither-disable-next-line timestamp
        uint256 timePassed = block.timestamp - startsAt;
        uint256 maxDiscount = startingPrice - minimumPrice;
        // Avoid overflow: timePassed * discountRate
        if (discountRate > 0 && timePassed > type(uint256).max / discountRate) {
            return minimumPrice;
        }
        uint256 discount = timePassed * discountRate;
        if (discount >= maxDiscount || discount > startingPrice) {
            return minimumPrice;
        }
        
        return startingPrice - discount;
    }

    /// @notice Purchase the NFT at current price
    function purchase() external payable {
        require(!ended, "Auction ended");
        // slither-disable-next-line timestamp
        require(block.timestamp < endsAt, "Auction expired");
        
        uint256 price = currentPrice();
        require(msg.value >= price, "Insufficient payment");
        
        // Mark as ended
        ended = true;
        buyer = msg.sender;

        // Pull-payment accounting (avoids direct ETH sends during purchase)
        pendingWithdrawals[seller] += price;
        if (msg.value > price) {
            pendingWithdrawals[msg.sender] += (msg.value - price);
        }
        
        // Emit event before external call
        emit AuctionEnded(msg.sender, price, block.timestamp);

        // Transfer NFT to buyer
        nft.safeTransferFrom(address(this), msg.sender, tokenId);
    }

    /// @notice Withdraw any refundable amount or seller proceeds
    function withdraw() external {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "Nothing to withdraw");
        pendingWithdrawals[msg.sender] = 0;
        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, "Withdraw failed");
    }

    /// @notice End auction without sale (seller can reclaim)
    function endAuction() external {
        require(msg.sender == seller, "Only seller");
        require(!ended, "Already ended");

        ended = true;

        // Emit event before external call
        emit AuctionEnded(address(0), 0, block.timestamp);

        // Return NFT to seller
        nft.safeTransferFrom(address(this), seller, tokenId);
    }

    /// @notice Get auction info
    function getAuctionInfo() external view returns (
        address _seller,
        uint256 _startingPrice,
        uint256 _currentPrice,
        uint256 _endsAt,
        bool _ended
    ) {
        return (
            seller,
            startingPrice,
            currentPrice(),
            endsAt,
            ended
        );
    }
}

