// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Chainlink Price Feed
/// @notice Fetches price data from Chainlink oracles with staleness checks
/// @dev Educational example of oracle integration

/// @title Chainlink Aggregator V3 Interface
interface AggregatorV3Interface {
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
    
    function decimals() external view returns (uint8);
    
    function description() external view returns (string memory);
    
    function version() external view returns (uint256);
}

/// @title Chainlink Price Feed
/// @notice Provides ETH/USD price with staleness checking
contract ChainlinkPriceFeed {
    /// @notice Chainlink aggregator address
    AggregatorV3Interface public immutable priceFeed;
    
    /// @notice Decimals of the price feed
    uint8 public immutable decimals;
    
    /// @notice Staleness threshold in seconds
    uint256 public staleThreshold;
    
    /// @notice Owner address
    address public owner;
    
    /// @notice Emitted when price is updated
    event PriceUpdated(int256 price, uint256 timestamp);
    
    /// @notice Emitted when stale threshold is updated
    event StaleThresholdUpdated(uint256 newThreshold);

    /// @param _priceFeed Address of Chainlink price feed
    /// @param _staleThreshold Threshold in seconds for staleness
    constructor(address _priceFeed, uint256 _staleThreshold) {
        require(_priceFeed != address(0), "Invalid price feed address");
        
        priceFeed = AggregatorV3Interface(_priceFeed);
        decimals = priceFeed.decimals();
        staleThreshold = _staleThreshold;
        owner = msg.sender;
    }

    /// @notice Get the latest ETH/USD price
    /// @return price Latest price in USD (with decimals)
    /// @return timestamp Last update timestamp
    function getLatestPrice() public view returns (int256 price, uint256 timestamp) {
        (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        
        require(answer > 0, "Invalid price");
        require(updatedAt > 0, "Round not complete");
        require(answeredInRound >= roundId, "Stale data");
        
        // Check staleness
        uint256 timeSinceUpdate = block.timestamp - updatedAt;
        require(timeSinceUpdate <= staleThreshold, "Price is stale");
        
        return (answer, updatedAt);
    }

    /// @notice Get price with staleness check
    /// @return price Latest price
    /// @return isStale Whether price is stale
    function getPriceWithStaleCheck() external view returns (int256 price, bool isStale) {
        (
            uint80 roundId,
            int256 answer,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        
        if (answer <= 0 || answeredInRound < roundId) {
            return (0, true);
        }
        
        uint256 timeSinceUpdate = block.timestamp - updatedAt;
        isStale = timeSinceUpdate > staleThreshold;
        
        return (answer, isStale);
    }

    /// @notice Get the normalized price (8 decimals regardless of feed decimals)
    /// @return normalizedPrice Price normalized to 8 decimals
    function getNormalizedPrice() external view returns (uint256 normalizedPrice) {
        (int256 price, ) = getLatestPrice();
        
        // Normalize to 8 decimals
        if (decimals >= 8) {
            normalizedPrice = uint256(price) / (10 ** (decimals - 8));
        } else {
            normalizedPrice = uint256(price) * (10 ** (8 - decimals));
        }
    }

    /// @notice Set staleness threshold (only owner)
    /// @param _threshold New staleness threshold in seconds
    function setStaleThreshold(uint256 _threshold) external {
        require(msg.sender == owner, "Only owner");
        require(_threshold > 0, "Threshold must be positive");
        staleThreshold = _threshold;
        emit StaleThresholdUpdated(_threshold);
    }

    /// @notice Get price feed description
    function getDescription() external view returns (string memory) {
        return priceFeed.description();
    }

    /// @notice Get price feed version
    function getVersion() external view returns (uint256) {
        return priceFeed.version();
    }
}
