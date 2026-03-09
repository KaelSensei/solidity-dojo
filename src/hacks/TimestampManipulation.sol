// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title TimestampManipulation
/// @notice Demonstrates block.timestamp manipulation vulnerabilities
/// @dev Educational example - DO NOT USE IN PRODUCTION

/// @title Vulnerable Lottery using block.timestamp
contract VulnerableLottery {
    address public winner;
    uint256 public targetTime;
    bool public ended;
    
    constructor(uint256 _duration) {
        targetTime = block.timestamp + _duration;
    }
    
    /// @notice Pick winner - VULNERABLE to timestamp manipulation!
    function pickWinner() external {
        require(block.timestamp >= targetTime, "Not yet");
        require(!ended, "Already ended");
        
        // Miner can manipulate block.timestamp within limits
        // Using block.timestamp for randomness is VULNERABLE
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp)));
        winner = address(uint160(random % 100));
        
        ended = true;
    }
    
    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }
}

/// @title Secure Lottery using commit-reveal
contract SecureLottery {
    struct Commit {
        bytes32 commitHash;
        uint256 revealBlock;
        bool revealed;
    }
    
    mapping(address => Commit) public commits;
    address public winner;
    bool public ended;
    uint256 public commitPhaseEnd;
    uint256 public revealPhaseEnd;
    
    constructor(uint256 _commitDuration, uint256 _revealDuration) {
        commitPhaseEnd = block.timestamp + _commitDuration;
        revealPhaseEnd = commitPhaseEnd + _revealDuration;
    }
    
    /// @notice Commit a bid (hash of random number + secret)
    function commit(bytes32 _commitHash) external {
        require(block.timestamp < commitPhaseEnd, "Commit phase ended");
        commits[msg.sender].commitHash = _commitHash;
        commits[msg.sender].revealBlock = block.number + 1;
    }
    
    /// @notice Reveal - SECURE!
    function reveal(uint256 _random, bytes32 _secret) external {
        require(block.timestamp >= commitPhaseEnd, "Commit phase not ended");
        require(block.timestamp < revealPhaseEnd, "Reveal phase ended");
        require(!commits[msg.sender].revealed, "Already revealed");
        
        bytes32 expectedHash = keccak256(abi.encodePacked(_random, _secret));
        require(expectedHash == commits[msg.sender].commitHash, "Invalid reveal");
        
        commits[msg.sender].revealed = true;
        
        if (winner == address(0)) {
            uint256 random = uint256(keccak256(abi.encodePacked(_random, _secret, block.timestamp)));
            winner = address(uint160(random % 100));
        }
    }
}

/// @title Game with time-based actions
contract TimeSensitiveGame {
    uint256 public lastActionTime;
    uint256 public constant TIMEOUT = 1 hours;
    
    function doAction() external {
        require(block.timestamp - lastActionTime < TIMEOUT, "Too slow!");
        lastActionTime = block.timestamp;
    }
}
