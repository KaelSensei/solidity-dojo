// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Vulnerable Oracle
/// @notice Demonstrates price oracle manipulation attack
/// @dev Educational example - DO NOT USE IN PRODUCTION

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Simple Token with Liquidity
contract SimpleToken is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function mint(address to, uint256 amount) external {
        _balances[to] += amount;
        _totalSupply += amount;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(_balances[msg.sender] >= amount);
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(_balances[from] >= amount);
        require(_allowances[from][msg.sender] >= amount);
        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        return true;
    }
}

/// @title Vulnerable Oracle - returns price based on pool reserves
contract VulnerableOracle {
    SimpleToken public tokenA;
    SimpleToken public tokenB;
    
    uint256 public lastPrice;
    uint256 public lastUpdate;
    
    constructor(address _tokenA, address _tokenB) {
        tokenA = SimpleToken(_tokenA);
        tokenB = SimpleToken(_tokenB);
    }
    
    /// @notice Update price based on pool reserves (VULNERABLE!)
    function updatePrice() external {
        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));
        
        // Price = reserveB / reserveA (vulnerable to manipulation)
        if (reserveA > 0) {
            lastPrice = reserveB / reserveA;
        }
        lastUpdate = block.timestamp;
    }
    
    /// @notice Get current price
    function getPrice() external view returns (uint256) {
        return lastPrice;
    }
    
    /// @notice Swap tokens (adds liquidity manipulation)
    function swapAForB(uint256 amountIn) external {
        require(amountIn > 0);
        tokenA.transferFrom(msg.sender, address(this), amountIn);
        
        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));
        
        // Simple swap: 1:1 (vulnerable!)
        uint256 amountOut = amountIn * reserveB / reserveA;
        tokenB.transfer(msg.sender, amountOut);
    }
    
    /// @notice Swap tokens (adds liquidity manipulation)
    function swapBForA(uint256 amountIn) external {
        require(amountIn > 0);
        tokenB.transferFrom(msg.sender, address(this), amountIn);
        
        uint256 reserveA = tokenA.balanceOf(address(this));
        uint256 reserveB = tokenB.balanceOf(address(this));
        
        uint256 amountOut = amountIn * reserveA / reserveB;
        tokenA.transfer(msg.sender, amountOut);
    }
}
