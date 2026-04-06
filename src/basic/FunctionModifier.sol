// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title FunctionModifier
/// @notice Demonstrates function modifiers for access control and validation.
/// @dev Modifiers are reusable code blocks that run before/after function execution.
contract FunctionModifier {
    /// @notice Contract owner
    address public owner;

    /// @notice Locked status for reentrancy protection
    bool private locked;

    /// @notice Minimum amount required for certain operations
    uint256 public constant MIN_AMOUNT = 0.01 ether;

    /// @notice Emitted when owner is changed
    event OwnerChanged(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    // ==================== MODIFIERS ====================

    /// @notice Restricts function to owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /// @notice Validates address is not zero
    modifier validAddress(address _addr) {
        require(_addr != address(0), "Invalid address");
        _;
    }

    /// @notice Ensures minimum amount is sent
    modifier minAmount(uint256 _amount) {
        require(msg.value >= _amount, "Insufficient amount");
        _;
    }

    /// @notice Prevents reentrant calls
    modifier noReentrancy() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    /// @notice Demonstrates modifier with multiple checks
    modifier complexCheck(uint256 _min) {
        require(msg.value >= _min, "Below minimum");
        require(msg.sender != address(0), "Invalid sender");
        _;
    }

    /// @notice Demonstrates modifier order of execution (before)
    modifier logBefore() {
        // This runs BEFORE the function
        _;
    }

    /// @notice Demonstrates modifier order of execution (after)
    modifier logAfter() {
        _;
        // This runs AFTER the function
    }

    // ==================== FUNCTIONS ====================

    /// @notice Owner-only function
    function ownerOnlyFunction() external onlyOwner view returns (string memory) {
        return "Success";
    }

    /// @notice Function requiring valid address
    function sendToAddress(address recipient) external validAddress(recipient) view returns (address) {
        return recipient;
    }

    /// @notice Function requiring minimum payment
    function payMinimum() external payable minAmount(MIN_AMOUNT) returns (uint256) {
        return msg.value;
    }

    /// @notice Protected function using reentrancy guard
    function protectedFunction() external noReentrancy returns (string memory) {
        // Simulate some work
        return "Completed";
    }

    /// @notice Function with multiple modifiers
    function complexOperation(address recipient) 
        external 
        payable 
        onlyOwner 
        validAddress(recipient) 
        minAmount(MIN_AMOUNT) 
        noReentrancy 
        returns (uint256) 
    {
        return msg.value;
    }

    /// @notice Demonstrates complex check modifier
    function complexOperation2() external payable complexCheck(0.05 ether) returns (uint256) {
        return msg.value;
    }

    /// @notice Change owner (owner only)
    function changeOwner(address newOwner) external onlyOwner validAddress(newOwner) {
        address previousOwner = owner;
        owner = newOwner;
        emit OwnerChanged(previousOwner, newOwner);
    }

    function withdrawEther(address payable to, uint256 amount) external onlyOwner validAddress(to) {
        (bool ok,) = to.call{value: amount}("");
        require(ok, "Withdraw failed");
    }

    /// @notice Get lock status
    function isLocked() external view returns (bool) {
        return locked;
    }
}


