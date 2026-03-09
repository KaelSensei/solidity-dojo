// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title BaseContract
/// @notice Base contract for inheritance demonstration
contract BaseContract {
    /// @notice Value stored in base
    uint256 public baseValue;

    /// @notice Name of the contract
    string public name;

    /// @notice Constructor
    /// @param _name Contract name
    constructor(string memory _name) {
        name = _name;
        baseValue = 100;
    }

    /// @notice Virtual function that can be overridden
    function getValue() public view virtual returns (uint256) {
        return baseValue;
    }

    /// @notice Function to set base value
    /// @param _value New value
    function setBaseValue(uint256 _value) public {
        baseValue = _value;
    }
}

/// @title DerivedContract
/// @notice Inherits from BaseContract and overrides function
contract DerivedContract is BaseContract {
    /// @notice Additional value in derived
    uint256 public derivedValue;

    /// @notice Constructor passes args to parent
    constructor() BaseContract("Derived") {
        derivedValue = 200;
    }

    /// @notice Overrides getValue from base
    function getValue() public view override returns (uint256) {
        return baseValue + derivedValue;
    }

    /// @notice Returns combined value
    function getCombinedValue() public view returns (uint256) {
        return getValue();
    }
}

/// @title AnotherBase
/// @notice Another base contract for multiple inheritance
contract AnotherBase {
    /// @notice Value in another base
    uint256 public anotherValue = 300;

    /// @notice Virtual function
    function getAnotherValue() public view virtual returns (uint256) {
        return anotherValue;
    }
}

/// @title MultipleInheritance
/// @notice Demonstrates multiple inheritance with C3 linearization
contract MultipleInheritance is BaseContract, AnotherBase {
    /// @notice Constructor passes to first parent
    constructor() BaseContract("Multiple") {}

    /// @notice Overrides both getValue and getAnotherValue
    function getValue() public view override returns (uint256) {
        return baseValue + anotherValue;
    }

    /// @notice Overrides getAnotherValue
    function getAnotherValue() public view override returns (uint256) {
        return anotherValue * 2;
    }

    /// @notice Gets total from all bases
    function getTotal() public view returns (uint256) {
        return getValue() + getAnotherValue();
    }
}
