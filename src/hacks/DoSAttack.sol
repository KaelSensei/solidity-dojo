// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title DoSAttack
/// @notice Demonstrates Denial of Service vulnerabilities
/// @dev Educational example - DO NOT USE IN PRODUCTION

/// @title Vulnerable Auction with push payments
contract VulnerableAuction {
    address public highestBidder;
    uint256 public highestBid;
    address[] public bidders;
    mapping(address => uint256) public pendingReturns;
    
    /// @notice Bid - VULNERABLE to DoS!
    function bid() external payable {
        require(msg.value > highestBid);
        
        // Push payment to previous bidder - can revert!
        if (highestBidder != address(0)) {
            pendingReturns[highestBidder] = highestBid;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        bidders.push(msg.sender);
    }
    
    /// @notice Withdraw - vulnerable if payment reverts
    function withdraw() external {
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0);
        
        pendingReturns[msg.sender] = 0;
        // This can revert and block the contract!
        payable(msg.sender).transfer(amount);
    }
    
    /// @notice Get count - VULNERABLE to unbounded loop!
    function getBiddersCount() external view returns (uint256) {
        return bidders.length;
    }
    
    receive() external payable {}
}

/// @title Vulnerable Token Distribution
contract VulnerableTokenDistributor {
    address[] public tokenHolders;
    mapping(address => uint256) public balances;
    mapping(address => bool) public hasClaimed;
    
    /// @notice Claim tokens - VULNERABLE to gas limits!
    function claim() external {
        require(!hasClaimed[msg.sender], "Already claimed");
        
        balances[msg.sender] = 1000e18;
        hasClaimed[msg.sender] = true;
        tokenHolders.push(msg.sender);
    }
    
    /// @notice Distribute to all - VULNERABLE to gas limit!
    function distributeToAll(uint256 _amountPerHolder) external {
        for (uint256 i = 0; i < tokenHolders.length; i++) {
            // Will run out of gas eventually
            balances[tokenHolders[i]] += _amountPerHolder;
        }
    }
}

/// @title Secure Auction with pull payments
contract SecureAuction {
    address public highestBidder;
    uint256 public highestBid;
    mapping(address => uint256) public pendingReturns;
    
    /// @notice Bid - SECURE using pull payments!
    function bid() external payable {
        require(msg.value > highestBid);
        
        // Push payment to pending returns (pull pattern)
        if (highestBidder != address(0)) {
            pendingReturns[highestBidder] += highestBid;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
    }
    
    /// @notice Withdraw - SECURE - user pulls their own funds
    function withdraw() external {
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0);
        
        pendingReturns[msg.sender] = 0;
        
        // Use call with limited gas
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        // If failed, amount remains in pendingReturns for retry
    }
    
    /// @notice Batch withdraw with limited gas
    function batchWithdraw(address[] calldata _beneficiaries) external {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            address beneficiary = _beneficiaries[i];
            uint256 amount = pendingReturns[beneficiary];
            if (amount > 0) {
                pendingReturns[beneficiary] = 0;
                (bool success, ) = beneficiary.call{value: amount}("");
                if (!success) {
                    pendingReturns[beneficiary] = amount;
                }
            }
        }
    }
    
    receive() external payable {}
}
