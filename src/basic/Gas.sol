// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Gas
/// @notice Demonstrates gas measurement and EIP-1559 concepts.
/// @dev Gas is the computational cost of executing operations.
contract Gas {
    uint256 public count;

    /// @notice Returns gasleft() before and after a storage write
    /// @return gasBefore Gas remaining before operation
    /// @return gasAfter Gas remaining after operation
    /// @dev SSTORE (storage write) costs 5000+ gas depending on context
    function measureStorageWrite() external returns (uint256 gasBefore, uint256 gasAfter) {
        gasBefore = gasleft();
        count += 1;
        gasAfter = gasleft();
    }

    /// @notice Returns gasleft() before and after a view operation
    /// @return gasBefore Gas remaining before operation
    /// @return gasAfter Gas remaining after operation
    /// @dev View operations that only read storage cost ~2100 gas (cold SLOAD)
    function measureStorageRead() external view returns (uint256 gasBefore, uint256 gasAfter) {
        gasBefore = gasleft();
        uint256 val = count;
        gasAfter = gasleft();
        val; // silence warning
    }

    /// @notice Returns gasleft() before and after pure computation
    /// @return gasBefore Gas remaining before operation
    /// @return gasAfter Gas remaining after operation
    /// @dev Pure computation is cheapest - no storage access.
    ///      Note: gasleft() is actually view, not pure, since gas price can vary.
    function measurePureComputation() external view returns (uint256 gasBefore, uint256 gasAfter) {
        gasBefore = gasleft();
        uint256 sum = 0;
        for (uint256 i = 0; i < 10; i++) {
            sum += i;
        }
        gasAfter = gasleft();
        sum; // silence warning
    }

    /// @notice Returns gas costs for different operations
    /// @return writeGas Gas used for storage write
    /// @return readGas Gas used for storage read
    /// @return pureGas Gas used for pure computation
    function compareGasCosts()
        external
        view
        returns (uint256 writeGas, uint256 readGas, uint256 pureGas)
    {
        // Measure pure computation
        uint256 gasBefore = gasleft();
        uint256 sum = 0;
        for (uint256 i = 0; i < 10; i++) {
            sum += i;
        }
        pureGas = gasBefore - gasleft();
        sum; // silence warning

        // Measure storage read
        gasBefore = gasleft();
        uint256 val = count;
        readGas = gasBefore - gasleft();
        val; // silence warning

        // Note: can't measure write in view function, use estimate
        writeGas = 5000; // Approximate SSTORE cost
    }

    /// @notice Returns current gas price
    /// @return The current gas price in wei per gas unit
    /// @dev tx.gasprice is set by the transaction sender
    function getGasPrice() external view returns (uint256) {
        return tx.gasprice;
    }

    /// @notice Returns the base fee of the current block
    /// @return The base fee per gas in wei
    /// @dev EIP-1559: base fee is burned, priority fee goes to validator
    function getBaseFee() external view returns (uint256) {
        return block.basefee;
    }

    /// @notice Demonstrates gas refund for clearing storage
    /// @dev Setting a storage slot to 0 refunds 4800 gas
    function clearStorage() external returns (uint256 gasUsed) {
        count = 1; // ensure it's set
        uint256 gasBefore = gasleft();
        count = 0; // clear storage - should get refund
        gasUsed = gasBefore - gasleft();
    }
}
