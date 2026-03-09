// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title English Auction
/// @notice Standard English auction with minimum bid increments
/// @dev Educational example of bidding auctions

/// @title IERC721 NFT Interface
interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

/// @title English Auction
/// @notice Auction contract where highest bidder wins
contract EnglishAuction {
    /// @notice NFT being auctioned
    IERC721 public immutable nft;
    
    /// @notice Token ID of NFT
    uint256 public immutable tokenId;
    
    /// @notice Seller address
    address public immutable seller;
    
    /// @notice Minimum bid increment
    uint256 public immutable minBidIncrement;
    
    /// @notice Auction end time
    uint256 public endAt;
    
    /// @notice Current highest bidder
    address public highestBidder;
    
    /// @notice Current highest bid
    uint256 public highestBid;
    
    /// @notice Whether auction has started
    bool public started;
    
    /// @notice Whether auction has ended
    bool public ended;

    /// @notice Mapping of pending returns (for outbid users)
    mapping(address => uint256) public pendingReturns;

    /// @notice Emitted when auction starts
    event Started(uint256 startTime, uint256 endAt);
    
    /// @notice Emitted when bid is placed
    event Bid(address indexed bidder, uint256 amount);
    
    /// @notice Emitted when auction is ended
    event Ended(address winner, uint256 amount);

    /// @param _nft NFT contract address
    /// @param _tokenId Token ID to sell
    /// @param _seller Seller address
    /// @param _startingBid Starting bid amount
    /// @param _minBidIncrement Minimum bid increment
    /// @param _duration Auction duration in seconds
    constructor(
        address _nft,
        uint256 _tokenId,
        address _seller,
        uint256 _startingBid,
        uint256 _minBidIncrement,
        uint256 _duration
    ) {
        require(_nft != address(0), "Invalid NFT");
        require(_startingBid > 0, "Invalid starting bid");
        
        nft = IERC721(_nft);
        tokenId = _tokenId;
        seller = _seller;
        highestBid = _startingBid;
        minBidIncrement = _minBidIncrement;
        
        // Transfer NFT to auction contract
        nft.transferFrom(_seller, address(this), _tokenId);
    }

    /// @notice Start the auction
    function start(uint256 _duration) external {
        require(msg.sender == seller, "Only seller");
        require(!started, "Already started");
        
        started = true;
        endAt = block.timestamp + _duration;
        
        emit Started(block.timestamp, endAt);
    }

    /// @notice Place a bid
    function bid() external payable {
        require(started, "Not started");
        require(block.timestamp < endAt, "Ended");
        require(msg.value >= highestBid + minBidIncrement, "Bid too low");
        
        // Store previous bid for refund
        if (highestBidder != address(0)) {
            pendingReturns[highestBidder] += highestBid;
        }
        
        // Update highest bidder
        highestBidder = msg.sender;
        highestBid = msg.value;
        
        emit Bid(msg.sender, msg.value);
    }

    /// @notice Withdraw pending returns
    function withdraw() external {
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0, "Nothing to withdraw");
        
        pendingReturns[msg.sender] = 0;
        
        payable(msg.sender).transfer(amount);
    }

    /// @notice End the auction
    function end() external {
        require(started, "Not started");
        require(!ended, "Already ended");
        require(block.timestamp >= endAt, "Not yet ended");
        
        ended = true;
        
        if (highestBidder != address(0)) {
            // Transfer NFT to winner
            nft.safeTransferFrom(address(this), highestBidder, tokenId);
            
            // Transfer payment to seller
            payable(seller).transfer(highestBid);
        } else {
            // No bids - return NFT to seller
            nft.safeTransferFrom(address(this), seller, tokenId);
        }
        
        emit Ended(highestBidder, highestBid);
    }

    /// @notice Get auction status
    function getStatus() external view returns (
        address _highestBidder,
        uint256 _highestBid,
        uint256 _endAt,
        bool _started,
        bool _ended
    ) {
        return (
            highestBidder,
            highestBid,
            endAt,
            started,
            ended
        );
    }
}
