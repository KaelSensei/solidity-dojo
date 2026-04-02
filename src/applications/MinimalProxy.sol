// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

/// @title MinimalProxy
/// @notice Factory contract using EIP-1167 minimal proxy pattern.
/// @dev Deploys cheap clones of implementation contracts.
contract MinimalProxy {
    /// @notice Emitted when a proxy is deployed
    event ProxyDeployed(
        address indexed proxy,
        address indexed implementation
    );

    /// @notice Address of the implementation contract
    address public implementation;

    /// @notice Constructor sets the implementation address
    constructor(address _implementation) {
        implementation = _implementation;
    }

    /// @notice Deploy a minimal proxy clone
    /// @return proxy Address of the deployed proxy
    function clone() public returns (address proxy) {
        proxy = Clones.clone(implementation);
        emit ProxyDeployed(proxy, implementation);
    }

    /// @notice Deploy a minimal proxy with initialization
    /// @return proxy Address of the deployed proxy
    function cloneWithInitialization(bytes memory initData)
        public
        returns (address proxy)
    {
        proxy = Clones.cloneDeterministic(
            implementation,
            bytes32(0)
        );
        
        if (initData.length > 0) {
            (bool success, ) = proxy.call(initData);
            require(success, "Initialization failed");
        }

        emit ProxyDeployed(proxy, implementation);
    }

    /// @notice Deploy multiple clones
    /// @return proxies Array of deployed proxy addresses
    function cloneMany(uint256 count)
        public
        returns (address[] memory proxies)
    {
        proxies = new address[](count);

        for (uint256 i = 0; i < count; i++) {
            proxies[i] = clone();
        }
    }

    /// @notice Predict the address of a clone
    /// @return Predicted address of the clone
    function predictCloneAddress() public view returns (address) {
        return Clones.predictDeterministicAddress(
            implementation,
            bytes32(0),
            address(this)
        );
    }

    /// @notice Predict the address of a clone with a specific salt
    /// @return Predicted address of the clone
    function predictCloneAddress(bytes32 salt) public view returns (address) {
        return Clones.predictDeterministicAddress(
            implementation,
            salt,
            address(this)
        );
    }

    /// @notice Deploy a deterministic clone using a salt
    /// @return proxy Address of the deployed proxy
    function cloneDeterministic(bytes32 salt)
        public
        returns (address proxy)
    {
        proxy = Clones.cloneDeterministic(implementation, salt);
        emit ProxyDeployed(proxy, implementation);
    }

    /// @notice Get implementation address
    /// @return Implementation address
    function getImplementation() public view returns (address) {
        return implementation;
    }
}

/// @title MinimalProxyFactory
/// @notice Standalone factory for deploying minimal proxies.
contract MinimalProxyFactory {
    using Clones for address;

    /// @notice Emitted when a proxy is deployed
    event ProxyDeployed(
        address indexed proxy,
        address indexed implementation,
        bytes32 indexed salt
    );

    /// @notice Deploy a minimal proxy of the given implementation
    /// @return proxy Address of the deployed proxy
    function deploy(address implementation)
        public
        returns (address proxy)
    {
        proxy = implementation.clone();
        emit ProxyDeployed(proxy, implementation, bytes32(0));
    }

    /// @notice Deploy a minimal proxy with a specific salt
    /// @return proxy Address of the deployed proxy
    function deployDeterministic(
        address implementation,
        bytes32 salt
    ) public returns (address proxy) {
        proxy = implementation.cloneDeterministic(salt);
        emit ProxyDeployed(proxy, implementation, salt);
    }

    /// @notice Predict the address of a clone
    /// @return Predicted address of the clone
    function predictAddress(
        address implementation,
        bytes32 salt
    ) public view returns (address) {
        return implementation.predictDeterministicAddress(salt);
    }

    /// @notice Check if a proxy has been deployed at address
    /// @return True if proxy is deployed (has code)
    function isDeployed(address proxyAddr) public view returns (bool) {
        return proxyAddr.code.length > 0;
    }
}


