// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title SimpleBytecodeContract
/// @notice Deploys contracts from raw bytecode using the CREATE opcode.
/// @dev Demonstrates how the EVM creates new contracts at the low level.
///      The CREATE opcode takes (value, offset, size) and deploys whatever
///      bytecode is in memory, returning the new contract address (or 0 on failure).
contract SimpleBytecodeContract {
    address public immutable owner = msg.sender;
    /// @notice Emitted when a contract is successfully deployed
    event Deployed(address indexed addr, uint256 value);

    /// @notice Thrown when deployment fails (CREATE returns address(0))
    error DeploymentFailed();

    /// @notice Deploy a contract from raw bytecode
    /// @dev Uses the CREATE opcode via inline assembly. The bytecode must be
    ///      valid EVM init code: it runs once and returns the runtime bytecode
    ///      that will be stored at the new address.
    /// @return addr The address of the deployed contract
    function deploy(bytes memory bytecode) external returns (address addr) {
        // create(value, offset, size)
        // - value: 0 ETH sent
        // - offset: bytecode data starts at bytecode + 0x20 (skip the length prefix)
        // - size: mload(bytecode) is the length stored in the first 32 bytes
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        // CREATE returns address(0) on failure
        if (addr == address(0)) revert DeploymentFailed();

        emit Deployed(addr, 0);
    }

    /// @notice Deploy a contract from raw bytecode, sending ETH to the constructor
    /// @dev The deployed contract's constructor must be payable to accept ETH.
    /// @return addr The address of the deployed contract
    function deployWithValue(bytes memory bytecode) external payable returns (address addr) {
        // create(value, offset, size) — msg.value is forwarded to the new contract
        assembly {
            addr := create(callvalue(), add(bytecode, 0x20), mload(bytecode))
        }

        if (addr == address(0)) revert DeploymentFailed();

        emit Deployed(addr, msg.value);
    }

    function withdrawEther(address payable to, uint256 amount) external {
        require(msg.sender == owner, "Not owner");
        require(to != address(0), "Zero address");
        (bool ok,) = to.call{value: amount}("");
        require(ok, "Withdraw failed");
    }
}

