// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title MultiCall
/// @notice Batch multiple calls into a single transaction, saving gas on base tx fees.
/// @dev Each transaction costs 21,000 gas base. Batching N ops into one tx saves (N-1) * 21,000.
contract MultiCall {
    /// @notice Thrown when a call in the batch fails
    error CallFailed(uint256 index);

    /// @notice Emitted after a successful multicall
    event MulticallExecuted(uint256 count);

    /// @notice Execute multiple calls in a single transaction
    /// @param targets Array of target addresses
    /// @param data Array of calldata for each call
    /// @return results Array of return data from each call
    function multicall(address[] calldata targets, bytes[] calldata data)
        external
        returns (bytes[] memory results)
    {
        uint256 len = targets.length;
        require(len == data.length, "Length mismatch");

        results = new bytes[](len);
        for (uint256 i; i < len;) {
            (bool success, bytes memory result) = targets[i].call(data[i]);
            if (!success) revert CallFailed(i);
            results[i] = result;
            unchecked { ++i; }
        }

        emit MulticallExecuted(len);
    }

    /// @notice Execute multiple view/pure calls using staticcall (read-only)
    /// @param targets Array of target addresses
    /// @param data Array of calldata for each call
    /// @return results Array of return data from each call
    function staticMulticall(address[] calldata targets, bytes[] calldata data)
        external
        view
        returns (bytes[] memory results)
    {
        uint256 len = targets.length;
        require(len == data.length, "Length mismatch");

        results = new bytes[](len);
        for (uint256 i; i < len;) {
            (bool success, bytes memory result) = targets[i].staticcall(data[i]);
            if (!success) revert CallFailed(i);
            results[i] = result;
            unchecked { ++i; }
        }
    }
}

/// @title MultiCallTarget
/// @notice Simple contract used to demonstrate MultiCall
contract MultiCallTarget {
    uint256 public counter;

    function increment() external returns (uint256) {
        return ++counter;
    }

    function getCounter() external view returns (uint256) {
        return counter;
    }

    function add(uint256 a, uint256 b) external pure returns (uint256) {
        return a + b;
    }
}
