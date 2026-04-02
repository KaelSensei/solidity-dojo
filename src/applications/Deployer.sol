// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Deployer
/// @notice Factory contract that can deploy any contract given its creation bytecode.
/// @dev Useful for deploying contracts with complex constructors.
contract Deployer {
    /// @notice Emitted when a contract is deployed
    event Deployed(
        address indexed deployedAddress,
        bytes32 indexed bytecodeHash
    );

    /// @notice Thrown when deployment fails
    error DeploymentFailed();

    /// @notice Thrown when bytecode length is zero
    error ZeroBytecode();

    /// @notice Deploy a contract with creation bytecode
    /// @return deployedAddress Address of the deployed contract
    function deploy(bytes memory bytecode)
        public
        payable
        returns (address deployedAddress)
    {
        if (bytecode.length == 0) revert ZeroBytecode();

        bytes32 bytecodeHash = keccak256(abi.encode(bytecode));
        uint256 value = msg.value;

        assembly {
            deployedAddress := create(
                value,
                add(bytecode, 0x20),
                mload(bytecode)
            )

            if iszero(extcodesize(deployedAddress)) {
                // Revert with DeploymentFailed
                mstore(0x00, 0x30116425)
                revert(0x00, 0x04)
            }
        }

        emit Deployed(deployedAddress, bytecodeHash);
    }

    /// @notice Deploy a contract and run initialization
    /// @return deployedAddress Address of the deployed contract
    function deployAndInit(
        bytes memory bytecode,
        bytes memory initCode
    ) public payable returns (address deployedAddress) {
        deployedAddress = deploy(bytecode);

        if (initCode.length > 0) {
            (bool success, ) = deployedAddress.call(initCode);
            require(success, "Initialization failed");
        }
    }

    /// @notice Compute address before deployment
    /// @return Predicted address
    function computeAddress(
        bytes memory bytecode,
        bytes32 salt
    ) public view returns (address) {
        bytes32 bytecodeHash = keccak256(abi.encode(bytecode));

        return address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(this),
                            salt,
                            bytecodeHash
                        )
                    )
                )
            )
        );
    }

    /// @notice Deploy using CREATE2
    /// @return deployedAddress Address of deployed contract
    function deploy2(
        bytes memory bytecode,
        bytes32 salt
    ) public payable returns (address deployedAddress) {
        if (bytecode.length == 0) revert ZeroBytecode();

        bytes32 bytecodeHash = keccak256(abi.encode(bytecode));
        uint256 value = msg.value;

        assembly {
            deployedAddress := create2(
                value,
                add(bytecode, 0x20),
                mload(bytecode),
                salt
            )

            if iszero(extcodesize(deployedAddress)) {
                mstore(0x00, 0x30116425)
                revert(0x00, 0x04)
            }
        }

        emit Deployed(deployedAddress, bytecodeHash);
    }
}

/// @title SimpleStorage
/// @notice A simple storage contract for testing
contract SimpleStorage {
    uint256 public value;

    function set(uint256 _value) external {
        value = _value;
    }
}


