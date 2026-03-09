// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title VaultInflation
/// @notice Demonstrates share price manipulation in ERC4626
/// @dev Educational example - DO NOT USE IN PRODUCTION

/// @title Vulnerable Vault (VULNERABLE!)
contract VulnerableVault {
    uint256 public totalAssets;
    uint256 public totalShares;
    mapping(address => uint256) public shares;
    
    /// @notice Deposit - VULNERABLE to first depositor attack
    function deposit() external payable {
        require(msg.value > 0);
        
        uint256 sharesToMint;
        if (totalShares == 0) {
            // First depositor can manipulate price
            sharesToMint = msg.value;
        } else {
            // Price can be manipulated
            sharesToMint = msg.value * totalShares / totalAssets;
        }
        
        shares[msg.sender] += sharesToMint;
        totalShares += sharesToMint;
        totalAssets += msg.value;
    }
    
    /// @notice Withdraw
    function withdraw(uint256 _shares) external {
        require(shares[msg.sender] >= _shares);
        
        uint256 assetsToWithdraw = _shares * totalAssets / totalShares;
        
        shares[msg.sender] -= _shares;
        totalShares -= _shares;
        totalAssets -= assetsToWithdraw;
        
        payable(msg.sender).transfer(assetsToWithdraw);
    }
    
    /// @notice Get share price
    function getSharePrice() external view returns (uint256) {
        if (totalShares == 0) return 1e18;
        return totalAssets * 1e18 / totalShares;
    }
    
    receive() external payable {}
}

/// @title Secure Vault
contract SecureVault {
    uint256 public totalAssets;
    uint256 public totalShares;
    uint256 public constant INITIAL_SHARES = 1000e18;
    mapping(address => uint256) public shares;
    
    /// @notice Deposit - SECURE with initial shares
    function deposit() external payable {
        require(msg.value > 0);
        
        uint256 sharesToMint;
        if (totalShares == 0) {
            // Initialize with minimum shares to prevent manipulation
            sharesToMint = INITIAL_SHARES;
            totalShares = INITIAL_SHARES;
        } else {
            sharesToMint = msg.value * totalShares / totalAssets;
        }
        
        shares[msg.sender] += sharesToMint;
        totalShares += sharesToMint;
        totalAssets += msg.value;
    }
    
    /// @notice Withdraw
    function withdraw(uint256 _shares) external {
        require(shares[msg.sender] >= _shares);
        
        uint256 assetsToWithdraw = _shares * totalAssets / totalShares;
        
        shares[msg.sender] -= _shares;
        totalShares -= _shares;
        totalAssets -= assetsToWithdraw;
        
        payable(msg.sender).transfer(assetsToWithdraw);
    }
    
    function getSharePrice() external view returns (uint256) {
        if (totalShares == 0) return 1e18;
        return totalAssets * 1e18 / totalShares;
    }
    
    receive() external payable {}
}
