// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Import specific contract from same directory
import {Events} from "./Events.sol";

/// @title Import
/// @notice Demonstrates import statements
contract Import {
    /// @notice Reference to imported contract type
    Events public eventsContract;

    /// @notice Set events contract address
    function setEventsContract(address _addr) external {
        eventsContract = Events(_addr);
    }

    /// @notice Use imported contract
    function useImported() external view returns (address) {
        return address(eventsContract);
    }
}
