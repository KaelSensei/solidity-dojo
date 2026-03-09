// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title AbiEncode
/// @notice Demonstrates ABI encoding functions
contract AbiEncode {
    /// @notice Encode with padding (standard ABI encoding)
    function encodeStandard(uint256 a, address b) external pure returns (bytes memory) {
        return abi.encode(a, b);
    }

    /// @notice Encode tightly packed (no padding)
    function encodePacked(uint256 a, address b) external pure returns (bytes memory) {
        return abi.encodePacked(a, b);
    }

    /// @notice Encode for function call
    function encodeCall(address target, uint256 amount) external pure returns (bytes memory) {
        return abi.encodeWithSignature("transfer(address,uint256)", target, amount);
    }

    /// @notice Encode with selector
    function encodeWithSelector(bytes4 selector, uint256 value) external pure returns (bytes memory) {
        return abi.encodeWithSelector(selector, value);
    }

    /// @notice Decode standard encoding
    function decodeStandard(bytes calldata data) external pure returns (uint256 a, address b) {
        (a, b) = abi.decode(data, (uint256, address));
    }

    /// @notice Compare encodings
    function compareEncodings(uint256 a, uint256 b)
        external
        pure
        returns (bytes memory standard, bytes memory packed, uint256 standardLen, uint256 packedLen)
    {
        standard = abi.encode(a, b);
        packed = abi.encodePacked(a, b);
        standardLen = standard.length;
        packedLen = packed.length;
    }
}
