// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title EtherUnits
/// @notice Demonstrates ether unit conversions and wei/gwei literals.
/// @dev All ETH amounts are internally stored in wei (10^18 wei = 1 ETH).
///      Solidity provides literal suffixes for readability.
contract EtherUnits {
    /// @notice Tracks total ether received by this contract
    uint256 public totalReceived;

    /// @notice Returns 1 wei in wei
    /// @dev 1 wei is the smallest unit of ETH
    function oneWei() external pure returns (uint256) {
        return 1 wei;
    }

    /// @notice Returns 1 gwei in wei
    /// @dev 1 gwei = 10^9 wei = 0.000000001 ETH
    ///      Gwei is commonly used for gas prices.
    function oneGwei() external pure returns (uint256) {
        return 1 gwei;
    }

    /// @notice Returns 1 ether in wei
    /// @dev 1 ether = 10^18 wei. This is the standard unit for balances.
    function oneEther() external pure returns (uint256) {
        return 1 ether;
    }

    /// @notice Converts gwei amount to wei
    /// @param gweiAmount Amount in gwei
    /// @return weiAmount Amount in wei
    function gweiToWei(uint256 gweiAmount) external pure returns (uint256 weiAmount) {
        return gweiAmount * 1 gwei;
    }

    /// @notice Converts wei amount to ether
    /// @param weiAmount Amount in wei
    /// @return etherAmount Amount in ether (as uint256, may lose precision)
    function weiToEther(uint256 weiAmount) external pure returns (uint256 etherAmount) {
        return weiAmount / 1 ether;
    }

    /// @notice Converts gwei amount to ether
    /// @param gweiAmount Amount in gwei
    /// @return etherAmount Amount in ether
    function gweiToEther(uint256 gweiAmount) external pure returns (uint256 etherAmount) {
        return (gweiAmount * 1 gwei) / 1 ether;
    }

    /// @notice Returns the contract's balance in wei
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /// @notice Receive function called when ether is sent with no calldata
    receive() external payable {
        totalReceived += msg.value;
    }

    /// @notice Fallback function for calls with data
    fallback() external payable {
        totalReceived += msg.value;
    }
}
