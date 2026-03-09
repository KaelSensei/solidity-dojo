// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IERC20Vault
/// @notice Minimal ERC20 interface for vault operations
interface IERC20Vault {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/// @title Vault
/// @notice A simple deposit vault that accepts ERC20 tokens and mints shares proportionally.
/// @dev Teaches the share/asset math behind ERC4626. Uses virtual shares/assets offset
///      to protect against the vault inflation (first-depositor) attack.
contract Vault {
    /// @notice The underlying asset token
    IERC20Vault public immutable token;

    /// @notice Total vault shares outstanding
    uint256 public totalShares;

    /// @notice Shares held by each depositor
    mapping(address => uint256) public sharesOf;

    /// @dev Virtual offset to prevent inflation attack (dead shares pattern)
    uint256 private constant OFFSET = 1e3;

    event Deposit(address indexed user, uint256 amount, uint256 shares);
    event Withdraw(address indexed user, uint256 shares, uint256 amount);

    error ZeroAmount();
    error InsufficientShares(uint256 available, uint256 requested);

    constructor(address _token) {
        token = IERC20Vault(_token);
    }

    /// @notice Total assets held by the vault
    function totalAssets() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    /// @notice Deposit assets and receive shares
    /// @param amount Amount of tokens to deposit
    /// @return shares Number of shares minted
    function deposit(uint256 amount) external returns (uint256 shares) {
        if (amount == 0) revert ZeroAmount();

        // Virtual shares/assets with OFFSET prevent inflation attack
        uint256 _totalAssets = totalAssets();
        uint256 _totalShares = totalShares;

        if (_totalShares == 0) {
            shares = amount;
        } else {
            shares = (amount * (_totalShares + OFFSET)) / (_totalAssets + OFFSET);
        }

        token.transferFrom(msg.sender, address(this), amount);
        totalShares += shares;
        sharesOf[msg.sender] += shares;

        emit Deposit(msg.sender, amount, shares);
    }

    /// @notice Withdraw assets by burning shares
    /// @param shares Number of shares to burn
    /// @return amount Amount of tokens returned
    function withdraw(uint256 shares) external returns (uint256 amount) {
        if (shares == 0) revert ZeroAmount();
        uint256 userShares = sharesOf[msg.sender];
        if (userShares < shares) revert InsufficientShares(userShares, shares);

        uint256 _totalShares = totalShares;
        amount = (shares * (totalAssets() + OFFSET)) / (_totalShares + OFFSET);

        sharesOf[msg.sender] = userShares - shares;
        totalShares = _totalShares - shares;

        token.transfer(msg.sender, amount);
        emit Withdraw(msg.sender, shares, amount);
    }

    /// @notice Preview how many shares a deposit would yield
    function previewDeposit(uint256 amount) external view returns (uint256) {
        uint256 _totalShares = totalShares;
        if (_totalShares == 0) return amount;
        return (amount * (_totalShares + OFFSET)) / (totalAssets() + OFFSET);
    }

    /// @notice Preview how many assets a withdrawal would yield
    function previewWithdraw(uint256 shares) external view returns (uint256) {
        return (shares * (totalAssets() + OFFSET)) / (totalShares + OFFSET);
    }
}
