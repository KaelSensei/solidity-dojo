// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title SimpleContract
/// @notice Contract created by factory
contract SimpleContract {
    address public owner;
    uint256 public value;

    constructor(uint256 _value) {
        owner = msg.sender;
        value = _value;
    }

    function setValue(uint256 _newValue) external {
        require(msg.sender == owner, "Not owner");
        value = _newValue;
    }
}

/// @title ContractFactory
/// @notice Factory that creates SimpleContract instances
contract ContractFactory {
    /// @notice Array of created contracts
    SimpleContract[] public contracts;

    /// @notice Emitted when contract created
    event ContractCreated(address indexed contractAddress, uint256 indexed index, uint256 value);

    /// @notice Create a new SimpleContract
    /// @param _value Initial value for contract
    function createContract(uint256 _value) external returns (SimpleContract) {
        SimpleContract newContract = new SimpleContract(_value);
        uint256 index = contracts.length;
        contracts.push(newContract);
        emit ContractCreated(address(newContract), index, _value);
        return newContract;
    }

    /// @notice Create contract with salt (for deterministic address)
    /// @param _value Initial value
    /// @param _salt Salt for CREATE2
    function createContractWithSalt(uint256 _value, bytes32 _salt) external returns (SimpleContract) {
        SimpleContract newContract = new SimpleContract{salt: _salt}(_value);
        uint256 index = contracts.length;
        contracts.push(newContract);
        emit ContractCreated(address(newContract), index, _value);
        return newContract;
    }

    /// @notice Get number of created contracts
    function getContractCount() external view returns (uint256) {
        return contracts.length;
    }

    /// @notice Get contract at index
    function getContract(uint256 _index) external view returns (SimpleContract) {
        require(_index < contracts.length, "Index out of bounds");
        return contracts[_index];
    }

    /// @notice Predict address before creation
    function predictAddress(uint256 _value, bytes32 _salt) external view returns (address) {
        bytes32 bytecodeHash = keccak256(abi.encodePacked(type(SimpleContract).creationCode, abi.encode(_value)));
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), _salt, bytecodeHash));
        return address(uint160(uint256(hash)));
    }
}
