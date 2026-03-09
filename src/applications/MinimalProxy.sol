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
    /// @param _implementation Address of the implementation contract
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
    /// @param _initData Initialization data to call on the proxy
    /// @return proxy Address of the deployed proxy
    function cloneWithInitialization(bytes memory _initData)
        public
        returns (address proxy)
    {
        proxy = Clones.cloneDeterministic(
            implementation,
            bytes32(0)
        );
        
        if (_initData.length > 0) {
            (bool success, ) = proxy.call(_initData);
            require(success, "Initialization failed");
        }

        emit ProxyDeployed(proxy, implementation);
    }

    /// @notice Deploy multiple clones
    /// @param count Number of clones to deploy
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
    /// @param _salt Salt for deterministic address
    /// @return Predicted address of the clone
    function predictCloneAddress(bytes32 _salt) public view returns (address) {
        return Clones.predictDeterministicAddress(
            implementation,
            _salt,
            address(this)
        );
    }

    /// @notice Deploy a deterministic clone using a salt
    /// @param _salt Salt for deterministic address
    /// @return proxy Address of the deployed proxy
    function cloneDeterministic(bytes32 _salt)
        public
        returns (address proxy)
    {
        proxy = Clones.cloneDeterministic(implementation, _salt);
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
    /// @param _implementation Implementation contract address
    /// @return proxy Address of the deployed proxy
    function deploy(address _implementation)
        public
        returns (address proxy)
    {
        proxy = _implementation.clone();
        emit ProxyDeployed(proxy, _implementation, bytes32(0));
    }

    /// @notice Deploy a minimal proxy with a specific salt
    /// @param _implementation Implementation contract address
    /// @param _salt Salt for deterministic address
    /// @return proxy Address of the deployed proxy
    function deployDeterministic(
        address _implementation,
        bytes32 _salt
    ) public returns (address proxy) {
        proxy = _implementation.cloneDeterministic(_salt);
        emit ProxyDeployed(proxy, _implementation, _salt);
    }

    /// @notice Predict the address of a clone
    /// @param _implementation Implementation contract address
    /// @param _salt Salt for deterministic address
    /// @return Predicted address of the clone
    function predictAddress(
        address _implementation,
        bytes32 _salt
    ) public view returns (address) {
        return _implementation.predictDeterministicAddress(_salt);
    }

    /// @notice Check if a proxy has been deployed at address
    /// @param _proxy Proxy address to check
    /// @return True if proxy is deployed (has code)
    function isDeployed(address _proxy) public view returns (bool) {
        return _proxy.code.length > 0;
    }
}
