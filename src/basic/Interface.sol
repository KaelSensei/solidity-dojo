// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IERC20
/// @notice Interface for ERC20 token
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/// @title MockToken
/// @notice Simple ERC20 implementation for testing
contract MockToken is IERC20 {
    string public name = "Mock Token";
    string public symbol = "MOCK";
    uint8 public decimals = 18;
    uint256 public override totalSupply;

    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply;
        balanceOf[msg.sender] = _initialSupply;
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        uint256 senderBal = balanceOf[msg.sender];
        require(senderBal >= amount, "Insufficient balance");
        unchecked { balanceOf[msg.sender] = senderBal - amount; }
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        uint256 fromBal = balanceOf[from];
        uint256 currentAllowance = allowance[from][msg.sender];
        require(fromBal >= amount, "Insufficient balance");
        require(currentAllowance >= amount, "Insufficient allowance");
        unchecked {
            allowance[from][msg.sender] = currentAllowance - amount;
            balanceOf[from] = fromBal - amount;
        }
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
}

/// @title TokenUser
/// @notice Uses IERC20 interface to interact with tokens
contract TokenUser {
    /// @notice Token interface
    IERC20 public token;

    /// @notice Constructor sets token address
    constructor(address _token) {
        token = IERC20(_token);
    }

    /// @notice Get token balance of an address
    function getTokenBalance(address _account) external view returns (uint256) {
        return token.balanceOf(_account);
    }

    /// @notice Transfer tokens using interface
    function transferTokens(address _to, uint256 _amount) external returns (bool) {
        return token.transfer(_to, _amount);
    }

    /// @notice Get token total supply
    function getTotalSupply() external view returns (uint256) {
        return token.totalSupply();
    }
}
