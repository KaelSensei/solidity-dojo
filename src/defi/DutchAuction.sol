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
    event AuctionEnded(address buyer, uint256 price, uint256 timestamp);
    
    /// @notice Emitted when bid is placed
    event BidPlaced(address bidder, uint256 bid, uint256 price);

    /// @param _nft NFT contract address
    /// @param _tokenId Token ID to sell
    /// @param _seller Seller address
    /// @param _startingPrice Starting price in wei
    /// @param _discountRate Price decrease per second in wei
    /// @param _duration Auction duration in seconds
    /// @param _minimumPrice Minimum/floor price
    constructor(
        address _nft,
        uint256 _tokenId,
        address _seller,
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
        seller = _seller;
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startsAt = block.timestamp;
        endsAt = block.timestamp + _duration;
        minimumPrice = _minimumPrice;
        
        // Transfer NFT to auction contract
        nft.transferFrom(_seller, address(this), _tokenId);
    }

    /// @notice Get current price based on time elapsed
    function currentPrice() public view returns (uint256) {
        if (block.timestamp >= endsAt) {
            return minimumPrice;
        }
        
        uint256 timePassed = block.timestamp - startsAt;
        uint256 discount = timePassed * discountRate;
        
        if (startingPrice - discount < minimumPrice) {
            return minimumPrice;
        }
        
        return startingPrice - discount;
    }

    /// @notice Purchase the NFT at current price
    function purchase() external payable {
        require(!ended, "Auction ended");
        require(block.timestamp < endsAt, "Auction expired");
        
        uint256 price = currentPrice();
        require(msg.value >= price, "Insufficient payment");
        
        // Mark as ended
        ended = true;
        buyer = msg.sender;
        
        // Transfer NFT to buyer
        nft.safeTransferFrom(address(this), msg.sender, tokenId);
        
        // Refund excess
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
        
        // Transfer payment to seller
        payable(seller).transfer(price);
        
        emit AuctionEnded(msg.sender, price, block.timestamp);
    }

    /// @notice End auction without sale (seller can reclaim)
    function endAuction() external {
        require(msg.sender == seller, "Only seller");
        require(!ended, "Already ended");
        
        ended = true;
        
        // Return NFT to seller
        nft.safeTransferFrom(address(this), seller, tokenId);
        
        emit AuctionEnded(address(0), 0, block.timestamp);
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
