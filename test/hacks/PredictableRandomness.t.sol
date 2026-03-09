// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/hacks/PredictableRandomness.sol";

/// @title Predictable Randomness Test Suite
contract PredictableRandomnessTest is Test {
    VulnerableRandom public vulnerable;
    BetterRandom public better;
    VulnerableGame public game;
    address public user = address(0x1);

    function setUp() public {
        vulnerable = new VulnerableRandom();
        better = new BetterRandom();
        game = new VulnerableGame();
    }

    /// @notice Test vulnerable random generates value
    function test_VulnerableRandomGenerates() public {
        uint256 random = vulnerable.generateRandom();
        assertTrue(random > 0);
    }

    /// @notice Test better random with seed
    function test_BetterRandomWithSeed() public {
        better.setSeed(12345);
        
        uint256 random = better.generateRandom();
        assertTrue(random > 0);
    }

    /// @notice Test game awards points
    function test_GameAwardsPoints() public {
        vm.prank(user);
        game.awardRandomPoints();
        
        assertTrue(game.scores(user) > 0);
    }

    /// @notice Test multiple players can join
    function test_MultiplePlayers() public {
        address player2 = address(0x2);
        
        vm.prank(user);
        game.awardRandomPoints();
        
        vm.prank(player2);
        game.awardRandomPoints();
        
        // Both players should have scores
        assertTrue(game.scores(user) > 0);
        assertTrue(game.scores(player2) > 0);
    }
}
