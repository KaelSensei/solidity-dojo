// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title FunctionSelector
/// @notice Demonstrates function selector computation.
/// @dev Selector is first 4 bytes of keccak256 of function signature.
contract FunctionSelector {
    /// @notice Compute selector for transfer(address,uint256)
    function getTransferSelector() external pure returns (bytes4) {
        return bytes4(keccak256("transfer(address,uint256)"));
    }

    /// @notice Compute selector for any function signature
    /// @param _signature Function signature like "transfer(address,uint256)"
    function computeSelector(string calldata _signature) external pure returns (bytes4) {
        return bytes4(keccak256(bytes(_signature)));
    }

    /// @notice Get selector from function call data
    function getSelectorFromData(bytes calldata _data) external pure returns (bytes4) {
        return bytes4(_data[:4]);
    }

    /// @notice Common selectors for reference
    function commonSelectors()
        external
        pure
        returns (bytes4 transfer, bytes4 approve, bytes4 transferFrom, bytes4 balanceOf)
    {
        transfer = bytes4(keccak256("transfer(address,uint256)"));
        approve = bytes4(keccak256("approve(address,uint256)"));
        transferFrom = bytes4(keccak256("transferFrom(address,address,uint256)"));
        balanceOf = bytes4(keccak256("balanceOf(address)"));
    }

    /// @notice Test function to get selector from
    function testFunction(uint256 _value, address _addr) external pure returns (uint256, address) {
        return (_value, _addr);
    }

    /// @notice Get selector of this contract's function
    function getMySelector() external pure returns (bytes4) {
        return this.testFunction.selector;
    }

    /// @notice Demonstrate selector collision is possible (rare)
    /// These two functions have different signatures but could theoretically collide
    function example1(uint256) external pure returns (bytes4) {
        return this.example1.selector;
    }

    function example2(uint256) external pure returns (bytes4) {
        return this.example2.selector;
    }
}
