// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/defi/ChainlinkPriceFeed.sol";

/// @title Mock Chainlink Aggregator
contract MockAggregator {
    int256 public latestAnswer;
    uint256 public latestTimestamp;
    uint256 public latestRound;
    uint8 public decimalsValue;
    string public descriptionValue;
    uint256 public versionValue;

    constructor(
        int256 _answer,
        uint8 _decimals,
        string memory _description
    ) {
        latestAnswer = _answer;
        latestTimestamp = block.timestamp;
        latestRound = 1;
        decimalsValue = _decimals;
        descriptionValue = _description;
        versionValue = 2;
    }

    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        roundId = uint80(latestRound);
        answer = latestAnswer;
        startedAt = latestTimestamp;
        updatedAt = latestTimestamp;
        answeredInRound = uint80(latestRound);
    }

    function decimals() external view returns (uint8) {
        return decimalsValue;
    }

    function description() external view returns (string memory) {
        return descriptionValue;
    }

    function version() external view returns (uint256) {
        return versionValue;
    }

    function setLatestAnswer(int256 _answer) external {
        latestAnswer = _answer;
        latestTimestamp = block.timestamp;
        latestRound++;
    }

    function setTimestamp(uint256 _timestamp) external {
        latestTimestamp = _timestamp;
    }
}

/// @title Chainlink Price Feed Test Suite
contract ChainlinkPriceFeedTest is Test {
    ChainlinkPriceFeed public priceFeed;
    MockAggregator public aggregator;

    address public user = address(0x1);

    function setUp() public {
        // Deploy mock aggregator with ETH/USD price ~$3000
        aggregator = new MockAggregator(3000e8, 8, "ETH/USD");
        
        // Deploy price feed with 1 hour stale threshold
        priceFeed = new ChainlinkPriceFeed(address(aggregator), 1 hours);
    }

    /// @notice Test can fetch latest price
    function test_CanFetchLatestPrice() public {
        (int256 price, uint256 timestamp) = priceFeed.getLatestPrice();
        
        assertEq(price, 3000e8);
        assertEq(timestamp, block.timestamp);
    }

    /// @notice Test reverts on stale price
    function test_RevertsOnStalePrice() public {
        // Warp time past the stale threshold
        vm.warp(block.timestamp + 2 hours);
        
        vm.expectRevert("Price is stale");
        priceFeed.getLatestPrice();
    }

    /// @notice Test handles decimal conversion correctly
    function test_DecimalConversion() public {
        uint256 normalized = priceFeed.getNormalizedPrice();
        
        // 3000e8 normalized to 8 decimals should be 3000e8
        assertEq(normalized, 3000e8);
    }

    /// @notice Test stale threshold can be updated
    function test_UpdateStaleThreshold() public {
        vm.prank(priceFeed.owner());
        priceFeed.setStaleThreshold(2 hours);
        
        // Old threshold should now make price look stale
        vm.warp(block.timestamp + 90 minutes);
        
        // Should still work with new threshold
        (int256 price, ) = priceFeed.getLatestPrice();
        assertEq(price, 3000e8);
    }

    /// @notice Test owner can update threshold
    function test_NonOwnerCannotUpdateThreshold() public {
        vm.prank(user);
        vm.expectRevert("Only owner");
        priceFeed.setStaleThreshold(2 hours);
    }

    /// @notice Test getDescription returns value
    function test_GetDescription() public {
        string memory desc = priceFeed.getDescription();
        assertEq(desc, "ETH/USD");
    }

    /// @notice Test getVersion returns value
    function test_GetVersion() public {
        uint256 version = priceFeed.getVersion();
        assertEq(version, 2);
    }

    /// @notice Test getPriceWithStaleCheck returns stale flag
    function test_GetPriceWithStaleCheck() public {
        (int256 price, bool isStale) = priceFeed.getPriceWithStaleCheck();
        
        assertEq(price, 3000e8);
        assertFalse(isStale);
    }

    /// @notice Test getPriceWithStaleCheck marks as stale
    function test_GetPriceWithStaleCheckMarksStale() public {
        vm.warp(block.timestamp + 2 hours);
        
        (int256 price, bool isStale) = priceFeed.getPriceWithStaleCheck();
        
        assertTrue(isStale);
    }

    /// @notice Test zero threshold reverts
    function test_ZeroThresholdReverts() public {
        vm.expectRevert("Threshold must be positive");
        new ChainlinkPriceFeed(address(aggregator), 0);
    }

    /// @notice Test zero address reverts
    function test_ZeroAddressReverts() public {
        vm.expectRevert("Invalid price feed address");
        new ChainlinkPriceFeed(address(0), 1 hours);
    }

    /// @notice Test invalid price reverts
    function test_InvalidPriceReverts() public {
        aggregator.setLatestAnswer(0);
        
        vm.expectRevert("Invalid price");
        priceFeed.getLatestPrice();
    }

    /// @notice Test negative price reverts
    function test_NegativePriceReverts() public {
        aggregator.setLatestAnswer(-100e8);
        
        vm.expectRevert("Invalid price");
        priceFeed.getLatestPrice();
    }

    /// @notice Test returns correct decimals
    function test_ReturnsDecimals() public {
        uint8 decimals = priceFeed.decimals();
        assertEq(decimals, 8);
    }

    /// @notice Test price updates are reflected
    function test_PriceUpdatesReflected() public {
        // Update price
        aggregator.setLatestAnswer(3500e8);
        
        (int256 price, ) = priceFeed.getLatestPrice();
        assertEq(price, 3500e8);
    }
}
