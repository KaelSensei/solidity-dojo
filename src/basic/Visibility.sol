// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Visibility
/// @notice Demonstrates all four visibility modifiers.
contract Visibility {
    /// @notice EXTERNAL: Can only be called from outside
    function externalFunc() external pure returns (string memory) {
        return "external";
    }

    /// @notice PUBLIC: Can be called from inside or outside
    function publicFunc() public pure returns (string memory) {
        return "public";
    }

    /// @notice INTERNAL: Can only be called from this or derived contracts
    function internalFunc() internal pure returns (string memory) {
        return "internal";
    }

    /// @notice PRIVATE: Can only be called from this contract
    function privateFunc() private pure returns (string memory) {
        return "private";
    }

    /// @notice Calls internal function
    function callInternal() external pure returns (string memory) {
        return internalFunc();
    }

    /// @notice Calls private function
    function callPrivate() external pure returns (string memory) {
        return privateFunc();
    }

    /// @notice Calls public function (can call from inside)
    function callPublic() external pure returns (string memory) {
        return publicFunc();
    }

    /// @notice Demonstrates visibility with state variables
    uint256 public publicVar = 1;
    uint256 internal internalVar = 2;
    uint256 private privateVar = 3;

    /// @notice Gets internal variable
    function getInternalVar() external view returns (uint256) {
        return internalVar;
    }

    /// @notice Gets private variable
    function getPrivateVar() external view returns (uint256) {
        return privateVar;
    }
}

/// @title DerivedVisibility
/// @notice Tests visibility in derived contract
contract DerivedVisibility is Visibility {
    /// @notice Can access parent's internal
    function accessParentInternal() external view returns (uint256) {
        return internalVar; // Can access internal
    }

    /// @notice Can call parent's internal function
    function callParentInternal() external pure returns (string memory) {
        return internalFunc(); // Can call internal
    }
}
