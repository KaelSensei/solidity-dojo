// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title HelloWorld
/// @notice A simple introductory contract demonstrating basic Solidity syntax.
/// @dev This contract shows SPDX license, pragma version pinning, state variables,
///      and auto-generated getters.
contract HelloWorld {
    // The `public` visibility modifier auto-generates a getter function.
    // This saves gas compared to manually writing a getter and improves readability.
    // The getter will be: function greet() external view returns (string memory)
    string public greet = "Hello World";

    // SPDX-License-Identifier is required to suppress compiler warnings about
    // missing license. MIT is permissive and commonly used for examples.
    // pragma solidity ^0.8.26 pins to 0.8.26 or higher but below 0.9.0.
    // Pinning versions prevents unexpected behavior from compiler changes.
}
