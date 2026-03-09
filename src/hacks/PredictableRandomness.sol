// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title PredictableRandomness
/// @notice Demonstrates predictable randomness vulnerabilities
/// @dev Educational example - DO NOT USE IN PRODUCTION

/// @title Vulnerable Randomness using blockhash
contract VulnerableRandom {
    /// @notice Generate random number - VULNERABLE!
    function generateRandom() external view returns (uint256) {
        // blockhash can be predicted by miners
        return uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender)));
    }
    
    /// @notice Generate random with nonce - still VULNERABLE
    function generateRandomWithNonce(uint256 _nonce) external view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender, _nonce)));
    }
}

/// @title Less Vulnerable Randomness using multiple sources
contract BetterRandom {
    uint256 private seed;
    
    function setSeed(uint256 _seed) external {
        seed = _seed;
    }
    
    /// @notice Better but still not perfect
    function generateRandom() external view returns (uint256) {
        return uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number - 1),
                    block.timestamp,
                    msg.sender,
                    seed,
                    block.gaslimit
                )
            )
        );
    }
}

/// @title Secure Random using Oracle (Chainlink VRF)
contract SecureRandom {
    // In production, use Chainlink VRF for verifiable randomness
    
    uint256 public latestRandomness;
    
    /// @notice Callback from Chainlink VRF
    function fulfillRandomness(bytes32 requestId, uint256 randomness) external {
        latestRandomness = randomness;
    }
    
    function getRandom() external view returns (uint256) {
        require(latestRandomness != 0, "Not initialized");
        return uint256(keccak256(abi.encodePacked(latestRandomness, block.timestamp)));
    }
}

/// @title Game using predictable randomness
contract VulnerableGame {
    mapping(address => uint256) public scores;
    address[] public players;
    
    /// @notice Award points randomly - VULNERABLE!
    function awardRandomPoints() external {
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
        uint256 points = random % 100;
        scores[msg.sender] += points;
        players.push(msg.sender);
    }
}
