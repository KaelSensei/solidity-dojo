// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Create2
/// @notice Factory contract using CREATE2 for deterministic addresses.
/// @dev Allows deploying contracts at predictable addresses before deployment.
contract Create2 {
    /// @notice Emitted when a contract is deployed
    event Deployed(
        address indexed deployedAddress,
        bytes32 indexed bytecodeHash,
        bytes32 salt
    );

    /// @notice Thrown when deployment fails
    error DeploymentFailed();

    /// @notice Thrown when bytecode length is zero
    error ZeroBytecode();

    /// @notice Compute the address of a contract to be deployed
    /// @param _salt Salt value used in deployment
    /// @param _bytecodeHash Hash of the contract bytecode
    /// @return Address where the contract will be deployed
    function computeAddress(
        bytes32 _salt,
        bytes32 _bytecodeHash
    ) public view returns (address) {
        return computeAddress(_salt, _bytecodeHash, address(this));
    }

    /// @notice Compute the address of a contract to be deployed with a specific deployer
    /// @param _salt Salt value used in deployment
    /// @param _bytecodeHash Hash of the contract bytecode
    /// @param _deployer Address of the deployer
    /// @return Address where the contract will be deployed
    function computeAddress(
        bytes32 _salt,
        bytes32 _bytecodeHash,
        address _deployer
    ) public pure returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                _deployer,
                _salt,
                _bytecodeHash
            )
        );

        return address(uint160(uint256(hash)));
    }

    /// @notice Deploy a contract using CREATE2
    /// @param _bytecode Contract creation bytecode
    /// @param _salt Salt value for deterministic address
    /// @return Address of the deployed contract
    function deploy(
        bytes memory _bytecode,
        bytes32 _salt
    ) public payable returns (address) {
        return deploy(_bytecode, _salt, msg.value);
    }

    /// @notice Deploy a contract using CREATE2 with specific value
    /// @param _bytecode Contract creation bytecode
    /// @param _salt Salt value for deterministic address
    /// @param _value Ether to send to the deployed contract
    /// @return Address of the deployed contract
    function deploy(
        bytes memory _bytecode,
        bytes32 _salt,
        uint256 _value
    ) public payable returns (address) {
        if (_bytecode.length == 0) revert ZeroBytecode();

        bytes32 bytecodeHash = keccak256(_bytecode);

        address deployedAddress = computeAddress(_salt, bytecodeHash, address(this));

        // Deploy the contract
        address addr;
        assembly {
            addr := create2(
                _value,
                add(_bytecode, 0x20),
                mload(_bytecode),
                _salt
            )

            if iszero(extcodesize(addr)) {
                // Revert with DeploymentFailed
                mstore(0x00, 0x30116425)
                revert(0x00, 0x04)
            }
        }

        emit Deployed(addr, bytecodeHash, _salt);

        return addr;
    }

    /// @notice Deploy a contract with constructor arguments
    /// @param _bytecode Contract creation bytecode (with constructor)
    /// @param _salt Salt value for deterministic address
    /// @return Address of the deployed contract
    function deployWithConstructor(
        bytes memory _bytecode,
        bytes32 _salt
    ) public payable returns (address) {
        return deploy(_bytecode, _salt, msg.value);
    }

    /// @notice Get the bytecode for a simple contract
    /// @return Bytecode for deployment
    function getSimpleBytecode() public pure returns (bytes memory) {
        // Simple contract: PUSH1 0x00 PUSH1 0x00 RETURN
        // This is a minimal contract that returns empty bytes
        return
            bytes.concat(
                bytes1(0x61), // PUSH1 0x00 (will be replaced)
                bytes1(0x80), // PUSH1 0x00
                bytes1(0x52), // MSTORE
                bytes1(0x60), // PUSH1 0x00
                bytes1(0x20), // PUSH1 0x20
                bytes1(0xf3) // RETURN
            );
    }

    /// @notice Get bytecode hash for a simple contract
    /// @return Keccak256 hash of the simple bytecode
    function getSimpleBytecodeHash() public pure returns (bytes32) {
        return keccak256(getSimpleBytecode());
    }

    /// @notice Deploy a simple contract with a value
    /// @param _salt Salt value
    /// @param _value Ether to send
    /// @return Deployed address
    function deploySimple(
        bytes32 _salt,
        uint256 _value
    ) public payable returns (address) {
        return deploy(getSimpleBytecode(), _salt, _value);
    }

    /// @notice Deploy multiple contracts with different salts
    /// @param _bytecode Contract bytecode
    /// @param _salts Array of salt values
    /// @return Array of deployed addresses
    function deployMultiple(
        bytes memory _bytecode,
        bytes32[] memory _salts
    ) public payable returns (address[] memory) {
        address[] memory addresses = new address[](_salts.length);

        for (uint256 i = 0; i < _salts.length; i++) {
            addresses[i] = deploy(_bytecode, _salts[i]);
        }

        return addresses;
    }
}
