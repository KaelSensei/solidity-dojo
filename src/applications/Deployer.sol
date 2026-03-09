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
    /// @param _bytecode Creation bytecode (constructor + contract bytecode)
    /// @return deployedAddress Address of the deployed contract
    function deploy(bytes memory _bytecode)
        public
        payable
        returns (address deployedAddress)
    {
        if (_bytecode.length == 0) revert ZeroBytecode();

        bytes32 bytecodeHash = keccak256(abi.encode(_bytecode));
        uint256 value = msg.value;

        assembly {
            deployedAddress := create(
                value,
                add(_bytecode, 0x20),
                mload(_bytecode)
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
    /// @param _bytecode Creation bytecode
    /// @param _initCode Initialization code to run after deployment
    /// @return deployedAddress Address of the deployed contract
    function deployAndInit(
        bytes memory _bytecode,
        bytes memory _initCode
    ) public payable returns (address deployedAddress) {
        deployedAddress = deploy(_bytecode);

        if (_initCode.length > 0) {
            (bool success, ) = deployedAddress.call(_initCode);
            require(success, "Initialization failed");
        }
    }

    /// @notice Compute address before deployment
    /// @param _bytecode Creation bytecode
    /// @param _salt Salt value (for CREATE2)
    /// @return Predicted address
    function computeAddress(
        bytes memory _bytecode,
        bytes32 _salt
    ) public view returns (address) {
        bytes32 bytecodeHash = keccak256(abi.encode(_bytecode));

        return address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(this),
                            _salt,
                            bytecodeHash
                        )
                    )
                )
            )
        );
    }

    /// @notice Deploy using CREATE2
    /// @param _bytecode Creation bytecode
    /// @param _salt Salt for deterministic address
    /// @return deployedAddress Address of deployed contract
    function deploy2(
        bytes memory _bytecode,
        bytes32 _salt
    ) public payable returns (address deployedAddress) {
        if (_bytecode.length == 0) revert ZeroBytecode();

        bytes32 bytecodeHash = keccak256(abi.encode(_bytecode));
        uint256 value = msg.value;

        assembly {
            deployedAddress := create2(
                value,
                add(_bytecode, 0x20),
                mload(_bytecode),
                _salt
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
