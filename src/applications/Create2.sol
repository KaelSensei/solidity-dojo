// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Create2
/// @notice Factory contract using CREATE2 for deterministic addresses.
/// @dev Allows deploying contracts at predictable addresses before deployment.
contract Create2 {
    address public immutable owner = msg.sender;
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
    /// @return Address where the contract will be deployed
    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash
    ) public view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /// @notice Compute the address of a contract to be deployed with a specific deployer
    /// @return Address where the contract will be deployed
    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) public pure returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                deployer,
                salt,
                bytecodeHash
            )
        );

        return address(uint160(uint256(hash)));
    }

    /// @notice Deploy a contract using CREATE2
    /// @return Address of the deployed contract
    function deploy(bytes memory bytecode, bytes32 salt) public payable returns (address) {
        uint256 value;
        assembly {
            value := callvalue()
        }
        return _deploy(bytecode, salt, value);
    }

    /// @notice Deploy a contract using CREATE2 with specific value
    /// @return Address of the deployed contract
    function deploy(bytes memory bytecode, bytes32 salt, uint256 value) public payable returns (address) {
        require(msg.value == value, "Value mismatch");
        return _deploy(bytecode, salt, value);
    }

    function _deploy(bytes memory bytecode, bytes32 salt, uint256 value) internal returns (address) {
        if (bytecode.length == 0) revert ZeroBytecode();

        bytes32 bytecodeHash = keccak256(bytecode);

        address deployedAddress = computeAddress(salt, bytecodeHash, address(this));

        // Deploy the contract
        address addr;
        assembly {
            addr := create2(
                value,
                add(bytecode, 0x20),
                mload(bytecode),
                salt
            )

            if iszero(extcodesize(addr)) {
                // Revert with DeploymentFailed
                mstore(0x00, 0x30116425)
                revert(0x00, 0x04)
            }
        }

        emit Deployed(addr, bytecodeHash, salt);

        return addr;
    }

    /// @notice Deploy a contract with constructor arguments
    /// @return Address of the deployed contract
    function deployWithConstructor(
        bytes memory bytecode,
        bytes32 salt
    ) public payable returns (address) {
        uint256 value;
        assembly {
            value := callvalue()
        }
        return _deploy(bytecode, salt, value);
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
    /// @return Deployed address
    function deploySimple(
        bytes32 salt,
        uint256 value
    ) public payable returns (address) {
        return deploy(getSimpleBytecode(), salt, value);
    }

    /// @notice Deploy multiple contracts with different salts
    /// @return Array of deployed addresses
    function deployMultiple(
        bytes memory bytecode,
        bytes32[] memory salts
    ) public payable returns (address[] memory) {
        address[] memory addresses = new address[](salts.length);
        uint256 perDeployment = msg.value / salts.length;
        require(perDeployment * salts.length == msg.value, "Uneven msg.value");

        for (uint256 i = 0; i < salts.length; i++) {
            addresses[i] = _deploy(bytecode, salts[i], perDeployment);
        }

        return addresses;
    }

    function withdrawEther(address payable to, uint256 amount) external {
        require(msg.sender == owner, "Not owner");
        require(to != address(0), "Zero address");
        (bool ok,) = to.call{value: amount}("");
        require(ok, "Withdraw failed");
    }
}


