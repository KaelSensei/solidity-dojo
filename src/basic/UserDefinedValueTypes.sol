// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title UserDefinedValueTypes
/// @notice Demonstrates user-defined value types for type safety.
/// @dev Zero-cost abstraction over primitives. Enforces type safety at compile time.
contract UserDefinedValueTypes {
    /// @notice Price type based on uint256
    type Price is uint256;

    /// @notice Quantity type based on uint256
    type Quantity is uint256;

    /// @notice Total value type based on uint256
    type Total is uint256;

    /// @notice Wraps a uint256 into a Price
    function wrapPrice(uint256 value) external pure returns (Price) {
        return Price.wrap(value);
    }

    /// @notice Unwraps a Price to uint256
    function unwrapPrice(Price price) external pure returns (uint256) {
        return Price.unwrap(price);
    }

    /// @notice Wraps a uint256 into a Quantity
    function wrapQuantity(uint256 value) external pure returns (Quantity) {
        return Quantity.wrap(value);
    }

    /// @notice Unwraps a Quantity to uint256
    function unwrapQuantity(Quantity qty) external pure returns (uint256) {
        return Quantity.unwrap(qty);
    }

    /// @notice Calculates total (price * quantity) maintaining type safety
    /// @param price The price per unit
    /// @param quantity The number of units
    /// @return total The total value
    function calculateTotal(Price price, Quantity quantity)
        external
        pure
        returns (Total total)
    {
        uint256 rawTotal = Price.unwrap(price) * Quantity.unwrap(quantity);
        total = Total.wrap(rawTotal);
    }

    /// @notice Adds two prices together
    function addPrices(Price a, Price b) external pure returns (Price) {
        return Price.wrap(Price.unwrap(a) + Price.unwrap(b));
    }

    /// @notice Compares two prices
    function pricesEqual(Price a, Price b) external pure returns (bool) {
        return Price.unwrap(a) == Price.unwrap(b);
    }
}
