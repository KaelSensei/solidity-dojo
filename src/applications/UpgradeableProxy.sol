// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title UpgradeableProxy
/// @notice Transparent upgradeable proxy using EIP-1967 storage slots.
/// @dev Stores implementation and admin addresses at deterministic slots to avoid
///      storage collisions with the logic contract.
contract UpgradeableProxy {
    /// @dev EIP-1967 implementation slot: keccak256("eip1967.proxy.implementation") - 1
    bytes32 private constant _IMPL_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /// @dev EIP-1967 admin slot: keccak256("eip1967.proxy.admin") - 1
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event Upgraded(address indexed implementation);
    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);

    error NotAdmin();
    error InvalidImplementation();

    /// @param _implementation Initial logic contract address
    constructor(address _implementation) {
        if (_implementation == address(0) || _implementation.code.length == 0) {
            revert InvalidImplementation();
        }
        _setImplementation(_implementation);
        _setAdmin(msg.sender);
        emit AdminChanged(address(0), msg.sender);
    }

    /// @notice Upgrade to a new implementation (admin only)
    /// @param _newImpl Address of the new logic contract
    function upgradeTo(address _newImpl) external {
        if (msg.sender != _getAdmin()) revert NotAdmin();
        if (_newImpl == address(0) || _newImpl.code.length == 0) revert InvalidImplementation();
        _setImplementation(_newImpl);
        emit Upgraded(_newImpl);
    }

    /// @notice Returns the current implementation address
    function implementation() external view returns (address) {
        return _getImplementation();
    }

    /// @notice Returns the current admin address
    function admin() external view returns (address) {
        return _getAdmin();
    }

    function _getImplementation() private view returns (address impl) {
        assembly { impl := sload(_IMPL_SLOT) }
    }

    function _setImplementation(address impl) private {
        assembly { sstore(_IMPL_SLOT, impl) }
    }

    function _getAdmin() private view returns (address adm) {
        assembly { adm := sload(_ADMIN_SLOT) }
    }

    function _setAdmin(address adm) private {
        assembly { sstore(_ADMIN_SLOT, adm) }
    }

    /// @dev Delegates all calls to the implementation via delegatecall
    fallback() external payable {
        address impl = _getImplementation();
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}

/// @title CounterV1
/// @notice Logic contract v1 — simple counter with increment
contract CounterV1 {
    uint256 public count;

    function increment() external {
        ++count;
    }

    function version() external pure returns (uint256) {
        return 1;
    }
}

/// @title CounterV2
/// @notice Logic contract v2 — adds decrement and reset
/// @dev Demonstrates that storage persists across upgrades
contract CounterV2 {
    uint256 public count;

    function increment() external {
        ++count;
    }

    function decrement() external {
        --count;
    }

    function reset() external {
        count = 0;
    }

    function version() external pure returns (uint256) {
        return 2;
    }
}
