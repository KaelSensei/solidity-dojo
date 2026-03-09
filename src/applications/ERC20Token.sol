// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ERC20Token
/// @notice Minimal ERC20 implementation from scratch — teaches how ERC20 works internally.
/// @dev Does NOT import OpenZeppelin. Implements the full ERC20 interface manually.
contract ERC20Token {
    /// @notice Token name
    string public name;

    /// @notice Token symbol
    string public symbol;

    /// @notice Number of decimals (standard: 18)
    uint8 public immutable decimals;

    /// @notice Total supply of tokens
    uint256 public totalSupply;

    /// @notice Contract owner (can mint)
    address public immutable owner;

    /// @notice Balance of each account
    mapping(address => uint256) public balanceOf;

    /// @notice Allowances: owner => spender => amount
    mapping(address => mapping(address => uint256)) public allowance;

    /// @notice Emitted on token transfer
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Emitted on approval
    event Approval(address indexed owner, address indexed spender, uint256 value);

    error InsufficientBalance(uint256 available, uint256 required);
    error InsufficientAllowance(uint256 available, uint256 required);
    error ZeroAddress();
    error NotOwner();

    /// @param _name Token name
    /// @param _symbol Token symbol
    /// @param _decimals Token decimals
    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;
    }

    /// @notice Transfer tokens to a recipient
    /// @param to Recipient address
    /// @param amount Amount to transfer
    function transfer(address to, uint256 amount) external returns (bool) {
        if (to == address(0)) revert ZeroAddress();
        uint256 senderBal = balanceOf[msg.sender];
        if (senderBal < amount) revert InsufficientBalance(senderBal, amount);
        unchecked { balanceOf[msg.sender] = senderBal - amount; }
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /// @notice Approve a spender to transfer tokens on your behalf
    /// @param spender Address authorized to spend
    /// @param amount Maximum amount they can spend
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /// @notice Transfer tokens on behalf of the owner (requires prior approval)
    /// @param from Token owner
    /// @param to Recipient
    /// @param amount Amount to transfer
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        if (to == address(0)) revert ZeroAddress();

        uint256 fromBal = balanceOf[from];
        uint256 currentAllowance = allowance[from][msg.sender];

        if (fromBal < amount) revert InsufficientBalance(fromBal, amount);
        if (currentAllowance < amount) revert InsufficientAllowance(currentAllowance, amount);

        unchecked {
            allowance[from][msg.sender] = currentAllowance - amount;
            balanceOf[from] = fromBal - amount;
        }
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    /// @notice Mint new tokens (owner only)
    /// @param to Recipient of minted tokens
    /// @param amount Amount to mint
    function mint(address to, uint256 amount) external {
        if (msg.sender != owner) revert NotOwner();
        if (to == address(0)) revert ZeroAddress();
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    /// @notice Burn tokens from caller's balance
    /// @param amount Amount to burn
    function burn(uint256 amount) external {
        uint256 callerBal = balanceOf[msg.sender];
        if (callerBal < amount) revert InsufficientBalance(callerBal, amount);
        unchecked { balanceOf[msg.sender] = callerBal - amount; }
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}
