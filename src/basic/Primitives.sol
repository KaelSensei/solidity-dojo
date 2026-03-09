// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Primitives
/// @notice Demonstrates Solidity's primitive data types and their default values.
/// @dev Default values are what variables are initialized to if not explicitly set.
contract Primitives {
    /// @notice Boolean type - default is false
    bool public boo = false;

    /// @notice Unsigned integer 256-bit - default is 0
    /// @dev uint is alias for uint256 (0 to 2^256 - 1)
    uint256 public u256 = 0;

    /// @notice Unsigned integer 8-bit - default is 0
    /// @dev uint8: 0 to 255, used when storage size matters
    uint8 public u8 = 0;

    /// @notice Signed integer 256-bit - default is 0
    /// @dev int is alias for int256 (-2^255 to 2^255 - 1)
    int256 public i256 = 0;

    /// @notice Signed integer 8-bit - default is 0
    /// @dev int8: -128 to 127
    int8 public i8 = 0;

    /// @notice Address type - 20 bytes for Ethereum addresses - default is 0x0
    /// @dev 20 bytes = 160 bits = 40 hex characters
    ///      Why 20 bytes? Keccak256 hash truncated for security while maintaining uniqueness.
    address public addr = address(0);

    /// @notice Fixed-size byte array (32 bytes) - default is 32 zero bytes
    /// @dev Commonly used for hashes. Fixed size means stored in single storage slot.
    bytes32 public b32 = bytes32(0);

    /// @notice Demonstrates the full range of int vs uint
    /// @dev int256 min: -57896044618658097711785492504343953926634992332820282019728792003956564819968
    ///      int256 max: 57896044618658097711785492504343953926634992332820282019728792003956564819967
    ///      uint256 max: 115792089237316195423570985008687907853269984665640564039457584007913129639935
    function getIntMin() public pure returns (int256) {
        return type(int256).min;
    }

    function getIntMax() public pure returns (int256) {
        return type(int256).max;
    }

    function getUintMax() public pure returns (uint256) {
        return type(uint256).max;
    }
}
